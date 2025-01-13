Option _Explicit
_Title "Tri-Linear Mipmap Variants 164"
' 2024 Haggarman
' Trilinear Mip Mapping variants
'
'  Press (T) to change TLMMI mode between 8-point and 5-point.
'  Toggle false colors with (F) and move around with the arrow keys.
'  Press (C) to toggle metrics: bright yellow or electric blue = cache hit
'
'  (M)ode 0 = no mipmap
'         1 = Per-Pixel LOD avoiding a square root and avoiding a log2f(). LOD_fraction curve is bent due to using LOD squared, but not very noticeable.
'
' Camera and matrix math code translated from the works of Javidx9 OneLoneCoder.
' Texel interpolation and triangle drawing code by me.
' 3D Triangle code inspired by Youtube: Javidx9, Bisqwit
'
'  4/25/2024 - TLMMI Variants: 5 point or normal 8 point.
'  3/02/2024 - LOD aspect ratio
'  2/23/2024 - Improved alpha blending
'  1/22/2024 - LOD using no square root and no log2f()
'  6/07/2023 - Trilinear Mipmap Interpolation
'  6/04/2023 - Mipmap Vertical LOD calculated
'  5/27/2023 - Level of Detail Texture Mipmap
'  5/19/2023 - Twin Textures
'  4/04/2023 - Texture alpha channel blending
'  3/04/2023 - Bugfix for wide triangles (make col a Long)
'  2/28/2023 - Skybox
'  2/27/2023 - Frustum near clipping
'  2/23/2023 - Texture wrapping options
'  2/22/2023 - Load textures from files
'  2/18/2023 - Utilize all reasonable and known methods to speed up the inner pixel X drawing loop.
'  2/12/2023 - Release to the World
'  2/10/2023 - Camera View Space, move with Arrow keys.
'  2/07/2023 - Swapped the N64 3-point diagonal direction.
'  2/03/2023 - Refactor triangle drawing into one Y loop.
'  2/01/2023 - Vertex color
'  1/24/2023 - Z fighting depth biasing
'  1/23/2023 - Directional and Diffuse lighting
'  1/16/2023 - caching previous array reads for the fixpoint filter. yellow grid to show where it grabs new.
'  1/15/2023 - fixed point math in the bilinear fixpoint filter. see how confusing it gets?
'  1/10/2023 - Z buffer and Fog
'  1/04/2023 - cleanup
' 12/31/2022 - GOT IT. N64 3-point Barycentric (proportional area) texture filtering.
' 12/26/2022 - Bilinear magnification texture filter.
' 11/26/2022 - Taken this experiment as far as it needs to go.
' Learned: The need for Prestep to align to integer pixel boundaries.
'          You can then window edge clip "for free" when using Prestep with just one more comparison.
'          Use the ceiling function to round up. Used to always rounding down with INT().
'          How to draw in 32-bit color on QB64.
'          Do not put a comma after the last number on the line in a DATA statement.
'          It is possible to linear interpolate in the 1/z dimension (w coord).
'          Some other clever genius thought of the triangle knee concept, but I think I explain it better in code.
'          It is thus easy to draw perspective correct textures in software.
'

Dim Shared DISP_IMAGE As Long
Dim Shared WORK_IMAGE As Long
Dim Shared Size_Screen_X As Integer, Size_Screen_Y As Integer
Dim Shared Size_Render_X As Integer, Size_Render_Y As Integer
Dim Shared Road_Count As Integer
Dim Shared Tree_Count As Integer
Dim Shared Wall_Count As Integer

' MODIFY THESE if you want.
Tree_Count = 400 ' number of trees
Road_Count = 400 ' number of road squares
Wall_Count = 400 ' number of sidewall squares
Size_Screen_X = 1200
Size_Screen_Y = 900
Size_Render_X = Size_Screen_X \ 3 ' render size
Size_Render_Y = Size_Screen_Y \ 3

DISP_IMAGE = _NewImage(Size_Screen_X, Size_Screen_Y, 32)
Screen DISP_IMAGE
_DisplayOrder _Software

WORK_IMAGE = _NewImage(Size_Render_X, Size_Render_Y, 32)
_DontBlend

Dim Shared Screen_Z_Buffer_MaxElement As Long
Screen_Z_Buffer_MaxElement = Size_Render_X * Size_Render_Y - 1
Dim Shared Screen_Z_Buffer(Screen_Z_Buffer_MaxElement) As Single

' Z Fight has to do with overdrawing on top of the same coplanar surface.
' If it is positive, a newer pixel at the same exact Z will always overdraw the older one.
Dim Shared Z_Fight_Bias
Z_Fight_Bias = -0.001953125 / 4.0

Type vec3d
    x As Single
    y As Single
    z As Single
End Type

Type vec4d
    x As Single
    y As Single
    z As Single
    w As Single
End Type

Type triangle
    x0 As Single
    y0 As Single
    z0 As Single
    x1 As Single
    y1 As Single
    z1 As Single
    x2 As Single
    y2 As Single
    z2 As Single

    u0 As Single
    v0 As Single
    u1 As Single
    v1 As Single
    u2 As Single
    v2 As Single

    s0 As Single
    t0 As Single
    s1 As Single
    t1 As Single
    s2 As Single
    t2 As Single

    texture1 As _Unsigned Long
    options As _Unsigned Long
    texture2 As _Unsigned Long
End Type

Type skybox_triangle
    x0 As Single
    y0 As Single
    z0 As Single
    x1 As Single
    y1 As Single
    z1 As Single
    x2 As Single
    y2 As Single
    z2 As Single

    u0 As Single
    v0 As Single
    u1 As Single
    v1 As Single
    u2 As Single
    v2 As Single
    texture As _Unsigned Long
End Type

Type vertex5
    x As Single
    y As Single
    w As Single
    u As Single
    v As Single
End Type

Type vertex8
    x As Single
    y As Single
    w As Single
    u As Single
    v As Single
    r As Single
    g As Single
    b As Single
End Type

Type vertex10
    x As Single
    y As Single
    w As Single
    u As Single
    v As Single
    r As Single
    g As Single
    b As Single
    s As Single
    t As Single
End Type

Type vertex_attribute5
    u As Single
    v As Single
    r As Single
    g As Single
    b As Single
End Type

Type vertex_attribute7
    u As Single
    v As Single
    r As Single
    g As Single
    b As Single
    s As Single
    t As Single
End Type

Type particle
    anim_state As Long
    anim_start As Long
    anim_count As Long

    vcenter As vec3d
    vbegin As vec3d
    vtarget As vec3d

    relWidth As Single '  *>
    relHeight As Single ' V
    u0 As Single ' *...  top left texel
    v0 As Single ' ....
    u1 As Single ' ....
    v1 As Single ' ...*  lower right texel

    texture1 As _Unsigned Long
    options As _Unsigned Long
End Type


' Projection Matrix
Dim Shared Frustum_Near As Single
Dim Shared Frustum_Far As Single
Dim Shared Frustum_Aspect_Ratio As Single
Dim Shared Frustum_FOV_deg As Single
Dim Shared Frustum_FOV_ratio As Single
Dim Shared matProj(3, 3) As Single

Frustum_Near = 0.5
Frustum_Far = 1000.0
Frustum_Aspect_Ratio = _Height / _Width
Frustum_FOV_deg = 80.0
FOVchange

' Viewing area clipping
Dim Shared clip_min_y As Long, clip_max_y As Long
Dim Shared clip_min_x As Long, clip_max_x As Long
clip_min_y = 0
clip_max_y = Size_Render_Y - 1
clip_min_x = 0
clip_max_x = Size_Render_X ' not (-1) because rounding rule drops one pixel on right

' Fog
Dim Shared Fog_near As Single, Fog_far As Single, Fog_rate As Single
Dim Shared Fog_color As Long
Dim Shared Fog_R As Long, Fog_G As Long, Fog_B As Long
Fog_near = 250.0
Fog_far = 310.0
Fog_rate = 1.0 / (Fog_far - Fog_near)

Fog_color = _RGB32(47, 78, 105)
Fog_R = _Red(Fog_color)
Fog_G = _Green(Fog_color)
Fog_B = _Blue(Fog_color)

' Load textures from file
Dim Shared TextureCatalog_lastIndex As Integer
TextureCatalog_lastIndex = 20
Dim Shared TextureCatalog(TextureCatalog_lastIndex) As Long
TextureCatalog(0) = _LoadImage("Origin16x16.png", 32)
TextureCatalog(1) = _LoadImage("DU_BEG_TreeFir2.png", 32)
TextureCatalog(2) = _LoadImage("DU_Light_Road.png", 32)
TextureCatalog(3) = _LoadImage("MM_Road0.png", 32)
TextureCatalog(4) = _LoadImage("MM_Road1.png", 32)
TextureCatalog(5) = _LoadImage("MM_Road2.png", 32)
TextureCatalog(6) = _LoadImage("MM_Road3.png", 32)
TextureCatalog(7) = _LoadImage("MM_Road4.png", 32)
TextureCatalog(8) = _LoadImage("MM_Road5.png", 32)
TextureCatalog(9) = _LoadImage("MMF_Road0.png", 32)
TextureCatalog(10) = _LoadImage("MMF_Road1.png", 32)
TextureCatalog(11) = _LoadImage("MMF_Road2.png", 32)
TextureCatalog(12) = _LoadImage("MMF_Road3.png", 32)
TextureCatalog(13) = _LoadImage("MMF_Road4.png", 32)
TextureCatalog(14) = _LoadImage("MMF_Road5.png", 32)
TextureCatalog(15) = _LoadImage("MM_SmallWall0.png", 32)
TextureCatalog(16) = _LoadImage("MM_SmallWall1.png", 32)
TextureCatalog(17) = _LoadImage("MM_SmallWall2.png", 32)
TextureCatalog(18) = _LoadImage("MM_SmallWall3.png", 32)
TextureCatalog(19) = _LoadImage("MM_SmallWall4.png", 32)
TextureCatalog(20) = _LoadImage("MM_SmallWall5.png", 32)


' Error _LoadImage returns -1 as an invalid handle if it cannot load the image.
Dim refIndex As Integer
For refIndex = 0 To TextureCatalog_lastIndex
    If TextureCatalog(refIndex) = -1 Then
        Print "Could not load texture file for index: "; refIndex
        End
    End If
Next refIndex


' These T1 Texture characteristics are read later on during drawing.
Dim Shared T1_CatalogIndex As Long
Dim Shared T1_ImageHandle As Long
Dim Shared T1_width As _Unsigned Integer, T1_width_MASK As _Unsigned Integer
Dim Shared T1_height As _Unsigned Integer, T1_height_MASK As _Unsigned Integer
Dim Shared T1_Filter_Selection As Integer
Dim Shared T1_mblock As _MEM
Dim Shared T1_Alpha_Threshold As Integer
Const oneOver255 = 1.0 / 255.0

' T2 calculates before T1
Dim Shared T2_ImageHandle As Long
Dim Shared T2_width As _Unsigned Integer, T2_width_MASK As _Unsigned Integer
Dim Shared T2_height As _Unsigned Integer, T2_height_MASK As _Unsigned Integer
Dim Shared T2_Filter_Selection As Integer
Dim Shared T2_mblock As _MEM
Dim Shared T2_Alpha_Threshold As Integer
Dim Shared T2_Offset_S As Single
Dim Shared T2_Offset_T As Single

' Texture sampling
Dim Shared Texture_options As _Unsigned Long
Const T1_option_clamp_width = 1
Const T1_option_clamp_height = 2
Const T1_option_alpha_channel = 8
Const T1_option_no_backface_cull = 16
Const T2_option_disable_RGBA = 32
Const T2_option_clamp_width = 64
Const T2_option_clamp_height = 128
Const T2_option_alpha_channel = 256
Const T2_option_no_backface_cull = 512
Const T2_option_color_sum = 1024

' Give sensible defaults to avoid crashes
' Optimization requires that width and height be powers of 2.
'  That means: 2,4,8,16,32,64,128,256...
T1_width = 16: T1_width_MASK = T1_width - 1
T1_height = 16: T1_height_MASK = T1_height - 1
T1_CatalogIndex = 0
T1_mblock = _MemImage(TextureCatalog(0))
T1_Alpha_Threshold = 250 ' below this alpha channel value, do not update z buffer (0..255)

T2_width = 16: T2_width_MASK = T2_width - 1
T2_height = 16: T2_height_MASK = T2_height - 1
T2_mblock = _MemImage(TextureCatalog(0))
T2_Alpha_Threshold = 250 ' below this alpha channel value, do not update z buffer (0..255)
T2_Offset_S = 0.0
T2_Offset_T = 0.0

' Color Combiner math
Dim Shared CC_mod_red As Single
Dim Shared CC_mod_green As Single
Dim Shared CC_mod_blue As Single
CC_mod_red = 1.0
CC_mod_green = 1.0
CC_mod_blue = 1.0

' Mipmap Level of Detail
Dim Shared LOD_mode As Integer
Dim Shared LOD_max As Integer
Dim Shared LOD_aspect_vertical As Single ' vertical / horizontal
Dim Shared LOD_aspect_squared As Single

LOD_mode = 1
LOD_max = 0 ' 0 is the base level texture (largest)
LOD_aspect_vertical = 0.5 ' LOD calculation acts like the textures are 1/2 as tall than as wide. Value chosen based on expected grazing angle of the texture.
LOD_aspect_squared = LOD_aspect_vertical * LOD_aspect_vertical

' Load the Mesh
Dim Triangles_In_A_Tree
Triangles_In_A_Tree = 4

Dim Triangles_In_A_Road
Triangles_In_A_Road = 3

Dim Triangles_In_A_Wall
Triangles_In_A_Wall = 2

Dim Shared Mesh_Last_Element As Integer
Mesh_Last_Element = (Wall_Count * Triangles_In_A_Wall) + (Tree_Count * Triangles_In_A_Tree) + (Road_Count * Triangles_In_A_Road) - 1
Dim Shared mesh(Mesh_Last_Element) As triangle

Dim Shared Mesh_Seed As Long
Mesh_Seed = 183 ' interesting enough
MakeMesh Mesh_Seed


'     +---+
'     | 2 |
' +---+---+---+---+
' | 1 | 4 | 0 | 5 |
' +---+---+---+---+
'     | 3 |
'     +---+

Dim Shared SkyBoxRef(5) As Long
SkyBoxRef(0) = _LoadImage("SkyBoxRight.png", 32)
SkyBoxRef(1) = _LoadImage("SkyBoxLeft.png", 32)
SkyBoxRef(2) = _LoadImage("SkyBoxTop.png", 32)
SkyBoxRef(3) = _LoadImage("SkyBoxBottom.png", 32)
SkyBoxRef(4) = _LoadImage("SkyBoxFront.png", 32)
SkyBoxRef(5) = _LoadImage("SkyBoxBack.png", 32)

' Error _LoadImage returns -1 as an invalid handle if it cannot load the image.
For refIndex = 0 To 5
    If SkyBoxRef(refIndex) = -1 Then
        Print "Could not load texture file for skybox face: "; refIndex
        End
    End If
    Print refIndex; _Width(SkyBoxRef(refIndex)); _Height(SkyBoxRef(refIndex))
Next refIndex

_PutImage (128, 0), SkyBoxRef(2)
_PutImage (0, 128), SkyBoxRef(1)
_PutImage (128 * 1, 128), SkyBoxRef(4)
_PutImage (128 * 2, 128), SkyBoxRef(0)
_PutImage (128 * 3, 128), SkyBoxRef(5)
_PutImage (128 * 1, 128 * 2), SkyBoxRef(3)

Dim A As Integer
Dim Shared Sky_Last_Element As Integer
Sky_Last_Element = 11

Dim sky(Sky_Last_Element) As skybox_triangle
Restore SKYBOX
For A = 0 To Sky_Last_Element
    Read sky(A).x0
    Read sky(A).y0
    Read sky(A).z0

    Read sky(A).x1
    Read sky(A).y1
    Read sky(A).z1

    Read sky(A).x2
    Read sky(A).y2
    Read sky(A).z2

    Read sky(A).u0
    Read sky(A).v0
    Read sky(A).u1
    Read sky(A).v1
    Read sky(A).u2
    Read sky(A).v2

    Read sky(A).texture
Next A

Dim Shared Particle_Last_Element As Integer
Particle_Last_Element = 0
Dim particles(Particle_Last_Element) As particle

Sleep 1

' Here are the 3D math and projection vars

Dim point0 As vec3d
Dim point1 As vec3d
Dim point2 As vec3d

' Translation (as in offset)
Dim pointTrans0 As vec3d
Dim pointTrans1 As vec3d
Dim pointTrans2 As vec3d

' View Space 2-10-2023
Dim matView(3, 3) As Single
Dim pointView0 As vec3d
Dim pointView1 As vec3d
Dim pointView2 As vec3d
Dim pointView3 As vec3d ' extra clipped tri

' Near frustum clipping 2-27-2023
Dim Shared vatr0 As vertex_attribute7
Dim Shared vatr1 As vertex_attribute7
Dim Shared vatr2 As vertex_attribute7
Dim Shared vatr3 As vertex_attribute7

' Projection
Dim pointProj0 As vec4d ' added w
Dim pointProj1 As vec4d
Dim pointProj2 As vec4d
Dim pointProj3 As vec4d ' extra clipped tri

' Surface Normal Calculation
' Part 2
Dim tri_normal As vec3d

' Part 2-2
Dim vCameraPsn As vec3d ' location of camera in world space
vCameraPsn.x = 0.0
vCameraPsn.y = 0.0
vCameraPsn.z = 0.0

Dim cameraRay As vec3d
Dim dotProductCam As Single

' View Space 2-10-2023
Dim fPitch As Single ' FPS Camera rotation in YZ plane (X)
Dim fYaw As Single ' FPS Camera rotation in XZ plane (Y)
Dim fRoll As Single
Dim matCameraRot(3, 3) As Single

Dim vCameraHomeFwd As vec3d ' Home angle forward orientation is facing down the Z line.
vCameraHomeFwd.x = 0.0: vCameraHomeFwd.y = 0.0: vCameraHomeFwd.z = 1.0

Dim vCameraTripod As vec3d ' Home angle orientation of which way is up.
' You could simulate tipping over the camera tripod with something other than y=1, and it will gimbal oddly.
vCameraTripod.x = 0.0: vCameraTripod.y = 1.0: vCameraTripod.z = 0.0

Dim vLookPitch As vec3d
Dim vLookDir As vec3d
Dim vCameraTarget As vec3d
Dim matCamera(3, 3) As Single


' Sun
Dim vSunDir As vec3d
vSunDir.x = -0.5
vSunDir.y = 0.4375 ' +Y is up
vSunDir.z = 1.0
Vector3_Normalize vSunDir
Dim Sun_Rv As Single
Dim Sun_Gv As Single
Dim Sun_Bv As Single
Sun_Rv = 254 * oneOver255
Sun_Gv = 255 * oneOver255
Sun_Bv = 250 * oneOver255

' Directional light 1-17-2023
Dim Light_Diffuse As Single
Dim Light_Directional As Single
Dim Light_Ambient As Single
Light_Ambient = 0.3


' Screen Scaling
Dim halfWidth As Single
Dim halfHeight As Single
halfWidth = Size_Render_X / 2
halfHeight = Size_Render_Y / 2

' Projected Screen Coordinate List
Dim SX0 As Single, SY0 As Single
Dim SX1 As Single, SY1 As Single
Dim SX2 As Single, SY2 As Single
Dim SX3 As Single, SY3 As Single

' Triangle Vertex List
Dim vertexA As vertex10
Dim vertexB As vertex10
Dim vertexC As vertex10

' Screen clipping
clip_min_y = 5
clip_max_y = Size_Render_Y - 5

clip_min_x = 10
clip_max_x = Size_Render_X - 10

' code execution time
Dim start_ms As Double
Dim finish_ms As Double

' physics framerate
Dim frametime_fullframe_ms As Double
Dim frametime_fullframethreshold_ms As Double
Dim frametimestamp_now_ms As Double
Dim frametimestamp_prior_ms As Double
Dim frametimestamp_delta_ms As Double
Dim frame_advance As Integer

' Main loop stuff
Dim KeyNow As String
Dim ExitCode As Integer
Dim Toggle_Mipmap_FalseColor As Integer
Dim Triangles_Drawn As Long
Dim triCount As Integer
Dim New_Triangles_Drawn As Long ' because of clipping
Dim vMove_Player_Forward As vec3d

Dim interpolater As Single
Dim vParticlePsn As vec3d

Dim Shared TLMMI_Variant As Integer

' metrics
Dim Shared Toggle_Cache_FalseColor As Integer
Dim Shared T1_total_fetch_attempts As _Unsigned Long
Dim Shared T1_cache_miss_count As _Unsigned Long
Dim Shared T3_total_fetch_attempts As _Unsigned Long
Dim Shared T3_cache_miss_count As _Unsigned Long

$Checking:Off
main:
ExitCode = 0
Toggle_Mipmap_FalseColor = 0
T1_Filter_Selection = 1
T2_Filter_Selection = 1
fPitch = -10.0
fYaw = 0.0
fRoll = 0.0

particles(0).anim_state = 1
particles(0).vcenter = vSunDir
particles(0).relHeight = 0.1
particles(0).relWidth = 0.1 * Frustum_Aspect_Ratio


frametime_fullframe_ms = 1 / 60.0
frametime_fullframethreshold_ms = 1 / 61.0
frametimestamp_prior_ms = Timer(.001)
frametimestamp_delta_ms = frametime_fullframe_ms
frame_advance = 0

TLMMI_Variant = 0
Toggle_Cache_FalseColor = 0
T1_total_fetch_attempts = 0
T1_cache_miss_count = 0

Do
    ' Create "Point At" Matrix for camera

    ' the neck tilts up and down first
    Matrix4_MakeRotation_X fPitch, matCameraRot()
    Multiply_Vector3_Matrix4 vCameraHomeFwd, matCameraRot(), vLookPitch

    ' then you spin around in place
    Matrix4_MakeRotation_Y fYaw, matCameraRot()
    Multiply_Vector3_Matrix4 vLookPitch, matCameraRot(), vLookDir

    ' Add to camera position to chase a dangling carrot so to speak
    Vector3_Add vCameraPsn, vLookDir, vCameraTarget

    Matrix4_PointAt vCameraPsn, vCameraTarget, vCameraTripod, matCamera()

    ' Make view matrix from Camera
    Matrix4_QuickInverse matCamera(), matView()

    Triangles_Drawn = 0
    New_Triangles_Drawn = 0
    start_ms = Timer(.001)

    ' Due to Skybox being drawn always, do not need to Clear Screen
    _Dest WORK_IMAGE
    'Cls , Fog_color

    ' Clear Z-Buffer
    ' This is a qbasic only optimization. it sets the array to zero. it saves 10 ms.
    ReDim Screen_Z_Buffer(Screen_Z_Buffer_MaxElement)

    ' Draw Skybox 2-28-2023
    For A = 0 To Sky_Last_Element
        point0.x = sky(A).x0
        point0.y = sky(A).y0
        point0.z = sky(A).z0

        point1.x = sky(A).x1
        point1.y = sky(A).y1
        point1.z = sky(A).z1

        point2.x = sky(A).x2
        point2.y = sky(A).y2
        point2.z = sky(A).z2

        ' Follow the camera coordinate position (slide)
        ' Skybox is like putting your head inside a floating box that travels with you, but never rotates.
        ' You rotate your head inside the skybox as you look around.
        Vector3_Add point0, vCameraPsn, pointTrans0
        Vector3_Add point1, vCameraPsn, pointTrans1
        Vector3_Add point2, vCameraPsn, pointTrans2

        ' Part 2 (Triangle Surface Normal Calculation)
        'CalcSurfaceNormal_3Point pointTrans0, pointTrans1, pointTrans2, tri_normal

        ' The dot product to this skybox surface is just the way you are facing.
        ' The surface completely behind you is going to get later removed with NearClip.
        'Vector3_Delta vCameraPsn, pointTrans0, cameraRay
        'dotProductCam = Vector3_DotProduct!(tri_normal, cameraRay)
        'If dotProductCam > 0.0 Then

        ' Convert World Space --> View Space
        Multiply_Vector3_Matrix4 pointTrans0, matView(), pointView0
        Multiply_Vector3_Matrix4 pointTrans1, matView(), pointView1
        Multiply_Vector3_Matrix4 pointTrans2, matView(), pointView2

        ' Load up attribute lists here because NearClip will interpolate those too.
        vatr0.u = sky(A).u0: vatr0.v = sky(A).v0
        vatr1.u = sky(A).u1: vatr1.v = sky(A).v1
        vatr2.u = sky(A).u2: vatr2.v = sky(A).v2

        ' Clip more often than not in this example
        NearClip pointView0, pointView1, pointView2, pointView3, vatr0, vatr1, vatr2, vatr3, triCount
        If triCount > 0 Then
            ' Project triangles from 3D -----------------> 2D
            ProjectMatrixVector4 pointView0, matProj(), pointProj0
            ProjectMatrixVector4 pointView1, matProj(), pointProj1
            ProjectMatrixVector4 pointView2, matProj(), pointProj2

            ' Slide to center, then Scale into viewport
            SX0 = (pointProj0.x + 1) * halfWidth
            SY0 = (pointProj0.y + 1) * halfHeight

            SX1 = (pointProj1.x + 1) * halfWidth
            SY1 = (pointProj1.y + 1) * halfHeight

            SX2 = (pointProj2.x + 1) * halfWidth
            SY2 = (pointProj2.y + 1) * halfHeight

            ' Load Vertex List for Single Textured triangle
            vertexA.x = SX0
            vertexA.y = SY0
            vertexA.w = pointProj0.w ' depth
            vertexA.u = vatr0.u * pointProj0.w
            vertexA.v = vatr0.v * pointProj0.w

            vertexB.x = SX1
            vertexB.y = SY1
            vertexB.w = pointProj1.w ' depth
            vertexB.u = vatr1.u * pointProj1.w
            vertexB.v = vatr1.v * pointProj1.w

            vertexC.x = SX2
            vertexC.y = SY2
            vertexC.w = pointProj2.w ' depth
            vertexC.u = vatr2.u * pointProj2.w
            vertexC.v = vatr2.v * pointProj2.w

            ' No Directional light

            ' Fill in Texture 1 data
            T1_ImageHandle = SkyBoxRef(sky(A).texture)
            T1_mblock = _MemImage(T1_ImageHandle)
            T1_width = _Width(T1_ImageHandle): T1_width_MASK = T1_width - 1
            T1_height = _Height(T1_ImageHandle): T1_height_MASK = T1_height - 1

            TexturedNonlitTriangle vertexA, vertexB, vertexC
            Triangles_Drawn = Triangles_Drawn + 1
        End If
        If triCount = 2 Then

            ProjectMatrixVector4 pointView3, matProj(), pointProj3
            SX3 = (pointProj3.x + 1) * halfWidth
            SY3 = (pointProj3.y + 1) * halfHeight

            ' Reload Vertex List for Textured triangle
            vertexA.x = SX0
            vertexA.y = SY0
            vertexA.w = pointProj0.w ' depth
            vertexA.u = vatr0.u * pointProj0.w
            vertexA.v = vatr0.v * pointProj0.w

            vertexB.x = SX2
            vertexB.y = SY2
            vertexB.w = pointProj2.w ' depth
            vertexB.u = vatr2.u * pointProj2.w
            vertexB.v = vatr2.v * pointProj2.w

            vertexC.x = SX3
            vertexC.y = SY3
            vertexC.w = pointProj3.w ' depth
            vertexC.u = vatr3.u * pointProj3.w
            vertexC.v = vatr3.v * pointProj3.w

            TexturedNonlitTriangle vertexA, vertexB, vertexC
            New_Triangles_Drawn = New_Triangles_Drawn + 1
        End If
    Next A

    ' Spotlight animation
    ' For the purpose of this example, cause Texture 2 to move to prove it is independent.
    Dim spotlightAnimationCount As Single
    Dim lc As Single
    Dim lr As Single

    lc = (Cos(_D2R(spotlightAnimationCount)) + 1.0) * 28.0
    lr = (Sin(_D2R(spotlightAnimationCount)) + 1.0) * 28.0

    spotlightAnimationCount = spotlightAnimationCount + 7.0 * frame_advance
    If spotlightAnimationCount >= 360.0 Then spotlightAnimationCount = spotlightAnimationCount - 360.0


    ' Draw Particles
    For A = 0 To Particle_Last_Element
        If particles(A).anim_state > 0 Then

            Select Case particles(A).anim_state
                Case 1
                    particles(A).vbegin = particles(A).vcenter
                    particles(A).vtarget.x = Rnd - 0.5
                    particles(A).vtarget.y = Rnd ' +Y is up
                    particles(A).vtarget.z = Rnd - 0.5

                    particles(A).anim_start = 200
                    particles(A).anim_count = 200
                    particles(A).anim_state = 2

                Case 2
                    particles(A).anim_count = particles(A).anim_count - 1
                    If (particles(A).anim_count <= 0) _Orelse (particles(A).anim_start <= 0) Then
                        particles(A).vcenter = particles(A).vtarget
                        particles(A).anim_state = 1
                    Else
                        interpolater = SmootherStep(particles(A).anim_count / particles(A).anim_start)
                        Vector3_Lerp particles(A).vtarget, particles(A).vbegin, interpolater, particles(A).vcenter
                    End If

                Case 3
                    particles(A).anim_state = 3
            End Select

            If A = 0 Then
                ' Sun darts around the sky
                vSunDir = particles(A).vcenter
                Vector3_Normalize vSunDir
                Vector3_Add vSunDir, vCameraPsn, vParticlePsn
            Else
                vParticlePsn = particles(A).vcenter
            End If

            ' Convert World Space --> View Space
            Multiply_Vector3_Matrix4 vParticlePsn, matView(), pointView0

            If pointView0.z >= Frustum_Near Then
                ' Project centerpoint from 3D -----------------> 2D
                ProjectMatrixVector4 pointView0, matProj(), pointProj0

                ' Slide to center, then Scale into viewport
                ' centerpoint
                'SX0 = (pointProj0.x + 1) * halfWidth
                'SY0 = (pointProj0.y + 1) * halfHeight
                'PSet (SX0, SY0), _RGB32(0, 0, 0)

                ' top left
                SX1 = (pointProj0.x + 1 - particles(A).relWidth) * halfWidth
                SY1 = (pointProj0.y + 1 - particles(A).relHeight) * halfHeight

                ' bottom right
                SX2 = (pointProj0.x + 1 + particles(A).relWidth) * halfWidth
                SY2 = (pointProj0.y + 1 + particles(A).relHeight) * halfHeight

                T1_CatalogIndex = 2
                T1_ImageHandle = TextureCatalog(T1_CatalogIndex)
                T1_mblock = _MemImage(T1_ImageHandle)
                T1_width = _Width(T1_ImageHandle): T1_width_MASK = T1_width - 1
                T1_height = _Height(T1_ImageHandle): T1_height_MASK = T1_height - 1

                ' Load Vertex List for Textured triangle
                vertexA.x = SX1
                vertexA.y = SY1
                vertexA.w = 1.0 ' depth
                vertexA.u = 0
                vertexA.v = 0

                vertexB.x = SX1
                vertexB.y = SY2
                vertexB.w = 1.0 ' depth
                vertexB.u = 0
                vertexB.v = T1_height

                vertexC.x = SX2
                vertexC.y = SY2
                vertexC.w = 1.0 ' depth
                vertexC.u = T1_width
                vertexC.v = T1_height

                TexturedNonlitAlphaTriangle vertexA, vertexB, vertexC

                ' Load Vertex List for Textured triangle
                vertexA.x = SX1
                vertexA.y = SY1
                vertexA.w = 1.0 ' depth
                vertexA.u = 0
                vertexA.v = 0

                vertexB.x = SX2
                vertexB.y = SY1
                vertexB.w = 1.0 ' depth
                vertexB.u = T1_width
                vertexB.v = 0

                vertexC.x = SX2
                vertexC.y = SY2
                vertexC.w = 1.0 ' depth
                vertexC.u = T1_width
                vertexC.v = T1_height

                TexturedNonlitAlphaTriangle vertexA, vertexB, vertexC
                Triangles_Drawn = Triangles_Drawn + 2
            End If

        End If ' anim_state > 0
    Next A


    ' Draw Triangles
    For A = 0 To Mesh_Last_Element
        point0.x = mesh(A).x0
        point0.y = mesh(A).y0
        point0.z = mesh(A).z0

        point1.x = mesh(A).x1
        point1.y = mesh(A).y1
        point1.z = mesh(A).z1

        point2.x = mesh(A).x2
        point2.y = mesh(A).y2
        point2.z = mesh(A).z2

        Texture_options = mesh(A).options

        ' no offset
        pointTrans0 = point0
        pointTrans1 = point1
        pointTrans2 = point2

        ' Part 2 (Triangle Surface Normal Calculation)
        CalcSurfaceNormal_3Point pointTrans0, pointTrans1, pointTrans2, tri_normal

        Vector3_Delta vCameraPsn, pointTrans0, cameraRay
        dotProductCam = Vector3_DotProduct!(tri_normal, cameraRay)

        If (Texture_options And T1_option_no_backface_cull) Or (dotProductCam > 0.0) Then
            ' Convert World Space --> View Space
            Multiply_Vector3_Matrix4 pointTrans0, matView(), pointView0
            Multiply_Vector3_Matrix4 pointTrans1, matView(), pointView1
            Multiply_Vector3_Matrix4 pointTrans2, matView(), pointView2

            ' Load up attribute lists here because NearClip will interpolate those too.
            vatr0.u = mesh(A).u0: vatr0.v = mesh(A).v0
            vatr1.u = mesh(A).u1: vatr1.v = mesh(A).v1
            vatr2.u = mesh(A).u2: vatr2.v = mesh(A).v2

            If mesh(A).texture2 = 2 Then
                'road piece
                LOD_max = 5

                ' animate the spotlight
                vatr0.s = mesh(A).s0 - lc: vatr0.t = mesh(A).t0 - lr
                vatr1.s = mesh(A).s1 - lc: vatr1.t = mesh(A).t1 - lr
                vatr2.s = mesh(A).s2 - lc: vatr2.t = mesh(A).t2 - lr

                ' Darken
                vatr0.r = -30.0: vatr0.g = -20.0: vatr0.b = -20.0
                vatr1.r = -30.0: vatr1.g = -20.0: vatr1.b = -20.0
                vatr2.r = -30.0: vatr2.g = -20.0: vatr2.b = -20.0

            Else
                vatr0.s = mesh(A).s0: vatr0.t = mesh(A).t0
                vatr1.s = mesh(A).s1: vatr1.t = mesh(A).t1
                vatr2.s = mesh(A).s2: vatr2.t = mesh(A).t2

                ' Reset Darken
                vatr0.r = 0.0: vatr0.g = 0.0: vatr0.b = 0.0
                vatr1.r = 0.0: vatr1.g = 0.0: vatr1.b = 0.0
                vatr2.r = 0.0: vatr2.g = 0.0: vatr2.b = 0.0

                If mesh(A).texture1 = 15 Then
                    LOD_max = 5
                    T1_Alpha_Threshold = 128
                Else
                    LOD_max = 0
                    T1_Alpha_Threshold = 250
                End If
            End If


            ' Clip if any Z is too close. Assumption is that near clip is uncommon.
            ' If there is a lot of near clipping going on, please remove this precheck and just always call NearClip.
            If (pointView0.z < Frustum_Near) Or (pointView1.z < Frustum_Near) Or (pointView2.z < Frustum_Near) Then
                NearClip pointView0, pointView1, pointView2, pointView3, vatr0, vatr1, vatr2, vatr3, triCount
                If triCount = 0 Then GoTo Lbl_SkipTriAll
            Else
                triCount = 1
            End If

            ' Project triangles from 3D -----------------> 2D
            ProjectMatrixVector4 pointView0, matProj(), pointProj0
            ProjectMatrixVector4 pointView1, matProj(), pointProj1
            ProjectMatrixVector4 pointView2, matProj(), pointProj2

            ' Directional light 1-17-2023
            Light_Directional = Vector3_DotProduct!(tri_normal, vSunDir)
            If dotProductCam > 0.0 Then
                ' front face
                If Light_Directional < 0.0 Then Light_Directional = 0.0
            Else
                ' back face
                If Light_Directional > 0.0 Then Light_Directional = 0.0
                Light_Directional = Abs(Light_Directional)
            End If
            Light_Diffuse = Light_Ambient + Light_Directional
            CC_mod_red = Light_Diffuse * Sun_Rv
            CC_mod_green = Light_Diffuse * Sun_Gv
            CC_mod_blue = Light_Diffuse * Sun_Bv

            ' Fill in Texture 1 data
            T1_CatalogIndex = mesh(A).texture1
            ' Road?
            If T1_CatalogIndex = 3 Then
                If Toggle_Mipmap_FalseColor Then T1_CatalogIndex = 9
            End If

            T1_ImageHandle = TextureCatalog(T1_CatalogIndex)
            T1_mblock = _MemImage(T1_ImageHandle)
            T1_width = _Width(T1_ImageHandle): T1_width_MASK = T1_width - 1
            T1_height = _Height(T1_ImageHandle): T1_height_MASK = T1_height - 1

            ' Fill in Texture 2 data
            T2_ImageHandle = TextureCatalog(mesh(A).texture2)
            T2_mblock = _MemImage(T2_ImageHandle)
            T2_width = _Width(T2_ImageHandle): T2_width_MASK = T2_width - 1
            T2_height = _Height(T2_ImageHandle): T2_height_MASK = T2_height - 1

            ' Slide to center, then Scale into viewport
            SX0 = (pointProj0.x + 1) * halfWidth
            SY0 = (pointProj0.y + 1) * halfHeight

            SX2 = (pointProj2.x + 1) * halfWidth
            SY2 = (pointProj2.y + 1) * halfHeight

            ' Early scissor reject
            If (pointProj0.x > 1.0) And (pointProj1.x > 1.0) And (pointProj2.x > 1.0) Then GoTo Lbl_Skip012
            If (pointProj0.x < -1.0) And (pointProj1.x < -1.0) And (pointProj2.x < -1.0) Then GoTo Lbl_Skip012
            If (pointProj0.y > 1.0) And (pointProj1.y > 1.0) And (pointProj2.y > 1.0) Then GoTo Lbl_Skip012
            If (pointProj0.y < -1.0) And (pointProj1.y < -1.0) And (pointProj2.y < -1.0) Then GoTo Lbl_Skip012

            ' This is unique to triangle 012
            SX1 = (pointProj1.x + 1) * halfWidth
            SY1 = (pointProj1.y + 1) * halfHeight

            ' Load Vertex List for Textured triangle
            vertexA.x = SX0
            vertexA.y = SY0
            vertexA.w = pointProj0.w ' depth
            vertexA.u = vatr0.u * pointProj0.w
            vertexA.v = vatr0.v * pointProj0.w
            vertexA.s = vatr0.s * pointProj0.w
            vertexA.t = vatr0.t * pointProj0.w
            vertexA.r = vatr0.r
            vertexA.g = vatr0.g
            vertexA.b = vatr0.b

            vertexB.x = SX1
            vertexB.y = SY1
            vertexB.w = pointProj1.w ' depth
            vertexB.u = vatr1.u * pointProj1.w
            vertexB.v = vatr1.v * pointProj1.w
            vertexB.s = vatr1.s * pointProj1.w
            vertexB.t = vatr1.t * pointProj1.w
            vertexB.r = vatr1.r
            vertexB.g = vatr1.g
            vertexB.b = vatr1.b

            vertexC.x = SX2
            vertexC.y = SY2
            vertexC.w = pointProj2.w ' depth
            vertexC.u = vatr2.u * pointProj2.w
            vertexC.v = vatr2.v * pointProj2.w
            vertexC.s = vatr2.s * pointProj2.w
            vertexC.t = vatr2.t * pointProj2.w
            vertexC.r = vatr2.r
            vertexC.g = vatr2.g
            vertexC.b = vatr2.b

            TwoTextureTriangle vertexA, vertexB, vertexC
            Triangles_Drawn = Triangles_Drawn + 1

            Lbl_Skip012:
            If triCount = 2 Then

                ProjectMatrixVector4 pointView3, matProj(), pointProj3

                ' Late scissor reject
                If (pointProj0.x > 1.0) And (pointProj2.x > 1.0) And (pointProj3.x > 1.0) Then GoTo Lbl_SkipTriAll
                If (pointProj0.x < -1.0) And (pointProj2.x < -1.0) And (pointProj3.x < -1.0) Then GoTo Lbl_SkipTriAll
                If (pointProj0.y > 1.0) And (pointProj2.y > 1.0) And (pointProj3.y > 1.0) Then GoTo Lbl_SkipTriAll
                If (pointProj0.y < -1.0) And (pointProj2.y < -1.0) And (pointProj3.y < -1.0) Then GoTo Lbl_SkipTriAll

                ' Slide to center, then Scale into viewport
                ' This is unique to triangle 023
                SX3 = (pointProj3.x + 1) * halfWidth
                SY3 = (pointProj3.y + 1) * halfHeight

                ' Reload Vertex List for Textured triangle
                vertexA.x = SX0
                vertexA.y = SY0
                vertexA.w = pointProj0.w ' depth
                vertexA.u = vatr0.u * pointProj0.w
                vertexA.v = vatr0.v * pointProj0.w
                vertexA.s = vatr0.s * pointProj0.w
                vertexA.t = vatr0.t * pointProj0.w
                vertexA.r = vatr0.r
                vertexA.g = vatr0.g
                vertexA.b = vatr0.b

                vertexB.x = SX2
                vertexB.y = SY2
                vertexB.w = pointProj2.w ' depth
                vertexB.u = vatr2.u * pointProj2.w
                vertexB.v = vatr2.v * pointProj2.w
                vertexB.s = vatr2.s * pointProj2.w
                vertexB.t = vatr2.t * pointProj2.w
                vertexB.r = vatr2.r
                vertexB.g = vatr2.g
                vertexB.b = vatr2.b

                vertexC.x = SX3
                vertexC.y = SY3
                vertexC.w = pointProj3.w ' depth
                vertexC.u = vatr3.u * pointProj3.w
                vertexC.v = vatr3.v * pointProj3.w
                vertexC.s = vatr3.s * pointProj3.w
                vertexC.t = vatr3.t * pointProj3.w
                vertexC.r = vatr3.r
                vertexC.g = vatr3.g
                vertexC.b = vatr3.b

                TwoTextureTriangle vertexA, vertexB, vertexC
                New_Triangles_Drawn = New_Triangles_Drawn + 1

            End If
            Lbl_SkipTriAll:
        End If

    Next A

    finish_ms = Timer(.001)

    _PutImage , WORK_IMAGE, DISP_IMAGE
    _Dest DISP_IMAGE
    Locate 1, 1
    Color _RGB32(177, 227, 255)
    Print Using "render time #.###"; finish_ms - start_ms
    Color _RGB32(249, 244, 17)
    Print "ESC to exit. ";
    Color _RGB32(233)
    Print "Arrow Keys Move. Q,Z Pitch."
    If Toggle_Mipmap_FalseColor Then
        Print "(F)alse Color Mipmap on. ";
    Else
        Print "(F)alse Color Mipmap off. ";
    End If
    Print "LOD (M)ode:"; LOD_mode
    Print "(T)LMMI Variant: ";
    If TLMMI_Variant = 0 Then
        Print "8 point"
    Else
        Print "5 point"
    End If
    Print "Spacebar rise. V drop. R reset."
    Print "(N)ew Mesh Seed:"; Mesh_Seed
    Print "+FOV- Degrees:"; Frustum_FOV_deg
    Print "Triangles Drawn:"; Triangles_Drawn; "+"; New_Triangles_Drawn

    If T1_total_fetch_attempts > 0 Then
        If Toggle_Cache_FalseColor Then
            Color _RGB32(255, 255, 0)
        End If
        Print Using "T1 (C)ache Efficiency ###.###%"; (T1_total_fetch_attempts - T1_cache_miss_count) * 100.0 / T1_total_fetch_attempts
    End If
    If T3_total_fetch_attempts > 0 Then
        If Toggle_Cache_FalseColor Then
            Color _RGB32(100, 100, 255)
        End If
        Print Using "T3 Cache Efficiency   ###.###%"; (T3_total_fetch_attempts - T3_cache_miss_count) * 100.0 / T3_total_fetch_attempts
    End If

    _Limit 60
    _Display

    ' metrics
    T1_cache_miss_count = 0
    T1_total_fetch_attempts = 0
    T3_cache_miss_count = 0
    T3_total_fetch_attempts = 0

    $Checking:On
    KeyNow = UCase$(InKey$)
    If KeyNow <> "" Then

        If KeyNow = "=" Or KeyNow = "+" Then
            Frustum_FOV_deg = Frustum_FOV_deg - 5.0
            FOVchange
        ElseIf KeyNow = "-" Then
            Frustum_FOV_deg = Frustum_FOV_deg + 5.0
            FOVchange
        ElseIf KeyNow = "N" Then
            Mesh_Seed = Mesh_Seed + 1
            MakeMesh Mesh_Seed
        ElseIf KeyNow = "Z" Then
            fPitch = fPitch + 5.0
            If fPitch > 85.0 Then fPitch = 85.0
        ElseIf KeyNow = "Q" Then
            fPitch = fPitch - 5.0
            If fPitch < -85.0 Then fPitch = -85.0
        ElseIf KeyNow = "R" Then
            vCameraPsn.x = 0.0
            vCameraPsn.y = 0.0
            vCameraPsn.z = 0.0
            fPitch = 0.0
            fYaw = 0.0
        ElseIf KeyNow = "F" Then
            Toggle_Mipmap_FalseColor = Not Toggle_Mipmap_FalseColor
        ElseIf KeyNow = "M" Then
            LOD_mode = LOD_mode + 1
            If LOD_mode > 1 Then LOD_mode = 0
        ElseIf KeyNow = "T" Then
            TLMMI_Variant = TLMMI_Variant + 1
            If TLMMI_Variant > 1 Then TLMMI_Variant = 0
        ElseIf KeyNow = "C" Then
            Toggle_Cache_FalseColor = Not Toggle_Cache_FalseColor

        ElseIf Asc(KeyNow) = 27 Then
            ExitCode = 1
        End If
    End If

    frametimestamp_now_ms = Timer(0.001)
    If frametimestamp_now_ms - frametimestamp_prior_ms < 0.0 Then
        ' timer rollover
        ' without over-analyzing just use the previous delta, even if it is somewhat wrong it is a better guess than 0.
        frametimestamp_prior_ms = frametimestamp_now_ms - frametimestamp_delta_ms
    Else
        frametimestamp_delta_ms = frametimestamp_now_ms - frametimestamp_prior_ms
    End If

    frame_advance = 0
    While frametimestamp_delta_ms > frametime_fullframethreshold_ms
        frame_advance = frame_advance + 1

        If _KeyDown(32) Then
            ' Spacebar
            vCameraPsn.y = vCameraPsn.y + 0.2
        End If

        If _KeyDown(118) Or _KeyDown(86) Then
            'V
            vCameraPsn.y = vCameraPsn.y - 0.2
        End If

        If _KeyDown(19712) Then
            ' Right arrow
            fYaw = fYaw - 1.8
        End If

        If _KeyDown(19200) Then
            ' Left arrow
            fYaw = fYaw + 1.8
        End If

        ' Move the player
        Matrix4_MakeRotation_Y fYaw, matCameraRot()
        Multiply_Vector3_Matrix4 vCameraHomeFwd, matCameraRot(), vMove_Player_Forward
        Vector3_Mul vMove_Player_Forward, 0.2, vMove_Player_Forward

        If _KeyDown(18432) Then
            ' Up arrow
            Vector3_Add vCameraPsn, vMove_Player_Forward, vCameraPsn
        End If

        If _KeyDown(20480) Then
            ' Down arrow
            Vector3_Delta vCameraPsn, vMove_Player_Forward, vCameraPsn
        End If

        frametimestamp_prior_ms = frametimestamp_prior_ms + frametime_fullframe_ms
        frametimestamp_delta_ms = frametimestamp_delta_ms - frametime_fullframe_ms
    Wend ' frametime

Loop Until ExitCode <> 0

For refIndex = TextureCatalog_lastIndex To 0 Step -1
    _FreeImage TextureCatalog(refIndex)
Next refIndex

For refIndex = 5 To 0 Step -1
    _FreeImage SkyBoxRef(refIndex)
Next refIndex

End
$Checking:Off

' u,v texture coords use fencepost counting.
'
'   0    1    2    3    4    u
' 0 +----+----+----+----+
'   |    |    |    |    |
'   |    |    |    |    |
' 1 +----+----+----+----+
'   |    |    |    |    |
'   |    |    |    |    |
' 2 +----+----+----+----+
'   |    |    |    |    |
'   |    |    |    |    |
' 3 +----+----+----+----+
'   |    |    |    |    |
'   |    |    |    |    |
' 4 +----+----+----+----+
'
'
' v


' x0,y0,z0, x1,y1,z1, x2,y2,z2
' u0,v0, u1,v1, u2,v2
' texture_index

SKYBOX:
' FRONT Z+
Data -10,+10,+10
Data +10,+10,+10
Data -10,-10,+10
Data 0,0,128,0,0,128
Data 4

Data +10,+10,+10
Data +10,-10,+10
Data -10,-10,+10
Data 128,0,128,128,0,128
Data 4

' RIGHT X+
Data +10,+10,+10
Data +10,+10,-10
Data +10,-10,+10
Data 0,0,128,0,0,128
Data 0

Data +10,+10,-10
Data +10,-10,-10
Data +10,-10,+10
Data 128,0,128,128,0,128
Data 0

' LEFT X-
Data -10,+10,-10
Data -10,+10,+10
Data -10,-10,-10
Data 0,0,128,0,0,128
Data 1

Data -10,+10,+10
Data -10,-10,+10
Data -10,-10,-10
Data 128,0,128,128,0,128
Data 1

' BACK Z-
Data +10,+10,-10
Data -10,+10,-10
Data +10,-10,-10
Data 0,0,128,0,0,128
Data 5

Data -10,+10,-10
Data -10,-10,-10
Data +10,-10,-10
Data 128,0,128,128,0,128
Data 5

' TOP Y+
Data -10,+10,-10
Data +10,+10,-10
Data -10,+10,+10
Data 0,0,128,0,0,128
Data 2

Data +10,+10,-10
Data +10,+10,+10
Data -10,+10,+10
Data 128,0,128,128,0,128
Data 2

' BOTTOM Y-
Data -10,-10,+10
Data 10,-10,+10
Data -10,-10,-10
Data 0,0,128,0,0,128
Data 3

Data +10,-10,+10
Data +10,-10,-10
Data -10,-10,-10
Data 128,0,128,128,0,128
Data 3


Sub MakeMesh (seed As Long)
    ' Load what is called a mesh from a random terrain generator.
    ' (x0,y0,z0) (x1,y1,z1) (x2,y2,z2) (u0,v0) (u1,v1) (u2,v2)
    Dim A As Integer
    A = 0

    Dim thing As Integer
    Dim thing_offset As Single
    Dim noise As Single
    Dim lastNoise As Single

    thing_offset = 0.0
    noise = 0.0
    lastNoise = 0.0


    Dim road_angle As Single
    Dim road_curve As Single
    Dim road_repeat As Long
    road_angle = 0.0
    road_curve = 0.0
    road_repeat = 2

    Dim road_px0 As Single, road_pz0 As Single
    Dim road_px1 As Single, road_pz1 As Single

    Dim road_p As vec3d
    Dim road_r As vec3d
    Dim road_left0 As vec3d, road_right0 As vec3d
    Dim road_left1 As vec3d, road_right1 As vec3d
    Dim road_left_midpoint As vec3d, road_right_midpoint As vec3d

    Dim road_pa0 As Single, road_pa1 As Single
    Dim road_m44(3, 3) As Single

    road_left0.x = -10.0
    road_left0.y = -2.0
    road_left0.z = 0.0

    road_right0.x = 10.0
    road_right0.y = -2.0
    road_right0.z = 0.0

    ' 0 is previous piece
    road_pa0 = road_angle: road_px0 = 0.0: road_pz0 = 0.0

    ' road loop vars
    Dim streetlight_type As Long
    Dim streetlight_repeat As Long
    streetlight_type = 1
    streetlight_repeat = 2

    Dim remaining_trees As Integer
    remaining_trees = Tree_Count

    Dim remaining_walls As Integer
    remaining_walls = Wall_Count

    Dim wall_type As Long
    Dim wall_repeat As Long
    wall_type = 4
    wall_repeat = 2

    Randomize Using seed

    For thing = 1 To Road_Count

        Matrix4_MakeRotation_Y road_angle, road_m44()

        ' centerline
        road_p.x = 0.0
        road_p.y = 0.0
        road_p.z = 10.0
        Multiply_Vector3_Matrix4 road_p, road_m44(), road_r
        road_px1 = road_px0 + road_r.x
        road_pz1 = road_pz0 + road_r.z

        thing_offset = Rnd - 0.54

        ' 2D rotation of left curb
        road_p.x = -10.0
        road_p.y = 0.0
        road_p.z = 10.0
        Multiply_Vector3_Matrix4 road_p, road_m44(), road_r
        road_left1.x = road_px0 + road_r.x
        road_left1.y = road_left0.y + thing_offset
        road_left1.z = road_pz0 + road_r.z
        Vector3_Lerp road_left0, road_left1, 0.5, road_left_midpoint

        ' 2D rotation of right curb
        road_p.x = 10.0
        road_p.y = 0.0
        road_p.z = 10.0
        Multiply_Vector3_Matrix4 road_p, road_m44(), road_r
        road_right1.x = road_px0 + road_r.x
        road_right1.y = road_right0.y + thing_offset
        road_right1.z = road_pz0 + road_r.z
        Vector3_Lerp road_right0, road_right1, 0.5, road_right_midpoint

        ' Insert side wall
        Select Case wall_type
            Case 0:
                '
            Case 1:
                SpawnLeftWall A, remaining_walls, road_left0, road_left1

            Case 2:
                SpawnRightWall A, remaining_walls, road_right0, road_right1

            Case 3:
                SpawnLeftWall A, remaining_walls, road_left0, road_left1
                SpawnRightWall A, remaining_walls, road_right0, road_right1

            Case 4:
                SpawnPineTree A, remaining_trees, road_right_midpoint

            Case 5:
                SpawnPineTree A, remaining_trees, road_left_midpoint

        End Select

        If road_curve > 0 Then
            SpawnRoadCurveLeft A, streetlight_type, road_left0, road_left_midpoint, road_left1, road_right0, road_right_midpoint, road_right1
        ElseIf road_curve < 0 Then
            SpawnRoadCurveRight A, streetlight_type, road_left0, road_left_midpoint, road_left1, road_right0, road_right_midpoint, road_right1
        Else
            SpawnRoad A, streetlight_type, road_left0, road_left_midpoint, road_left1, road_right0, road_right_midpoint, road_right1
        End If

        ' Save previous values
        road_px0 = road_px1
        road_pz0 = road_pz1
        road_pa0 = road_pa1

        Swap road_left0, road_left1
        Swap road_right0, road_right1

        road_repeat = road_repeat - 1
        If road_repeat <= 0 Then
            'INT(RND * (max% - min% + 1)) + min%
            road_curve = 1.75 * Int(Rnd * (5.0 + 5.0 + 1)) - 5.0
            road_repeat = Int(Rnd * 6.0) + 1
            If road_curve = 0 Then
                'prefer straight stretches
                road_repeat = 4.0 ^ road_repeat
            End If

        End If

        streetlight_repeat = streetlight_repeat - 1
        If streetlight_repeat <= 0 Then
            If Rnd > 0.3 Then
                streetlight_type = 1
            Else
                streetlight_type = 0
            End If
            streetlight_repeat = Int(Rnd * 10.0) + 1
        End If

        wall_repeat = wall_repeat - 1
        If wall_repeat <= 0 Then
            wall_repeat = Int(Rnd * 5.0) + 1
            wall_type = Int(Rnd * 6.0)
        End If

        ' force a wall on a curve
        If road_curve >= 3 Then
            wall_type = 2
            wall_repeat = 1
        ElseIf road_curve <= -3 Then
            wall_type = 1
            wall_repeat = 1
        End If

        road_angle = road_angle + road_curve
    Next thing
End Sub

Sub SpawnRoad (A As Integer, streetlight As Long, left00 As vec3d, left05 As vec3d, left10 As vec3d, right00 As vec3d, right05 As vec3d, right10 As vec3d)
    Dim T1c As Long
    Dim T1w As Long
    Dim T1h As Long
    Dim T1o As Long
    T1c = 3 ' road mipmap level 0
    T1w = _Width(TextureCatalog(T1c))
    T1h = _Height(TextureCatalog(T1c))
    T1o = T1_option_clamp_width Or T1_option_alpha_channel Or T2_option_clamp_width Or T2_option_clamp_height Or T2_option_alpha_channel Or T2_option_color_sum

    Dim T2c As Long
    Dim T2w As Long
    Dim T2h As Long
    T2c = 2 ' street light
    T2w = _Width(TextureCatalog(T2c)) * 4
    T2h = _Height(TextureCatalog(T2c)) * 2

    ' Triangle 1 of 2
    mesh(A).x0 = left10.x
    mesh(A).y0 = left10.y
    mesh(A).z0 = left10.z

    mesh(A).x1 = right10.x
    mesh(A).y1 = right10.y
    mesh(A).z1 = right10.z

    mesh(A).x2 = left00.x
    mesh(A).y2 = left00.y
    mesh(A).z2 = left00.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T2c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = 0
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = 0
    mesh(A).t0 = 0
    mesh(A).s1 = T2w
    mesh(A).t1 = 0
    mesh(A).s2 = 0
    mesh(A).t2 = T2h
    If streetlight = 0 Then
        mesh(A).options = mesh(A).options Or T2_option_disable_RGBA
    End If
    A = A + 1

    ' Triangle 2 of 2
    mesh(A).x0 = right10.x
    mesh(A).y0 = right10.y
    mesh(A).z0 = right10.z

    mesh(A).x1 = right00.x
    mesh(A).y1 = right00.y
    mesh(A).z1 = right00.z

    mesh(A).x2 = left00.x
    mesh(A).y2 = left00.y
    mesh(A).z2 = left00.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T2c
    mesh(A).options = T1o

    mesh(A).u0 = T1w
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = T1h
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = T2w
    mesh(A).t0 = 0
    mesh(A).s1 = T2w
    mesh(A).t1 = T2h
    mesh(A).s2 = 0
    mesh(A).t2 = T2h
    If streetlight = 0 Then
        mesh(A).options = mesh(A).options Or T2_option_disable_RGBA
    End If
    A = A + 1

    Dim dummy As Single ' remove compiler warnings
    dummy = left05.x
    dummy = right05.x
End Sub

Sub SpawnRoadCurveLeft (A As Integer, streetlight As Long, left00 As vec3d, left05 As vec3d, left10 As vec3d, right00 As vec3d, right05 As vec3d, right10 As vec3d)
    Dim T1c As Long
    Dim T1w As Long
    Dim T1h As Long
    Dim T1o As Long
    T1c = 3 ' road mipmap level 0
    T1w = _Width(TextureCatalog(T1c))
    T1h = _Height(TextureCatalog(T1c))
    T1o = T1_option_clamp_width Or T1_option_alpha_channel Or T2_option_clamp_width Or T2_option_clamp_height Or T2_option_alpha_channel Or T2_option_color_sum

    Dim T2c As Long
    Dim T2w As Long
    Dim T2h As Long
    T2c = 2 ' street light
    T2w = _Width(TextureCatalog(T2c)) * 4
    T2h = _Height(TextureCatalog(T2c)) * 2

    ' Triangle 1 of 3
    mesh(A).x0 = left00.x
    mesh(A).y0 = left00.y
    mesh(A).z0 = left00.z

    mesh(A).x1 = right05.x
    mesh(A).y1 = right05.y
    mesh(A).z1 = right05.z

    mesh(A).x2 = right00.x
    mesh(A).y2 = right00.y
    mesh(A).z2 = right00.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T2c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = T1h
    mesh(A).u1 = T1w
    mesh(A).v1 = T1h * 0.5
    mesh(A).u2 = T1w
    mesh(A).v2 = T1h

    mesh(A).s0 = 0
    mesh(A).t0 = T2h
    mesh(A).s1 = T2w
    mesh(A).t1 = T2h * 0.5
    mesh(A).s2 = T2w
    mesh(A).t2 = T2h
    If streetlight = 0 Then
        mesh(A).options = mesh(A).options Or T2_option_disable_RGBA
    End If
    A = A + 1

    ' Triangle 2 of 3
    mesh(A).x0 = left10.x
    mesh(A).y0 = left10.y
    mesh(A).z0 = left10.z

    mesh(A).x1 = right05.x
    mesh(A).y1 = right05.y
    mesh(A).z1 = right05.z

    mesh(A).x2 = left00.x
    mesh(A).y2 = left00.y
    mesh(A).z2 = left00.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T2c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = T1h * 0.5
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = 0
    mesh(A).t0 = 0
    mesh(A).s1 = T2w
    mesh(A).t1 = T2h * 0.5
    mesh(A).s2 = 0
    mesh(A).t2 = T2h
    If streetlight = 0 Then
        mesh(A).options = mesh(A).options Or T2_option_disable_RGBA
    End If
    A = A + 1

    ' Triangle 3 of 3
    mesh(A).x0 = left10.x
    mesh(A).y0 = left10.y
    mesh(A).z0 = left10.z

    mesh(A).x1 = right10.x
    mesh(A).y1 = right10.y
    mesh(A).z1 = right10.z

    mesh(A).x2 = right05.x
    mesh(A).y2 = right05.y
    mesh(A).z2 = right05.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T2c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = 0
    mesh(A).u2 = T1w
    mesh(A).v2 = T1h * 0.5

    mesh(A).s0 = 0
    mesh(A).t0 = 0
    mesh(A).s1 = T2w
    mesh(A).t1 = 0
    mesh(A).s2 = T2w
    mesh(A).t2 = T2h * 0.5
    If streetlight = 0 Then
        mesh(A).options = mesh(A).options Or T2_option_disable_RGBA
    End If
    A = A + 1

    Dim dummy As Single ' remove compiler warnings
    dummy = left05.x
End Sub


Sub SpawnRoadCurveRight (A As Integer, streetlight As Long, left00 As vec3d, left05 As vec3d, left10 As vec3d, right00 As vec3d, right05 As vec3d, right10 As vec3d)
    Dim T1c As Long
    Dim T1w As Long
    Dim T1h As Long
    Dim T1o As Long
    T1c = 3 ' road mipmap level 0
    T1w = _Width(TextureCatalog(T1c))
    T1h = _Height(TextureCatalog(T1c))
    T1o = T1_option_clamp_width Or T1_option_alpha_channel Or T2_option_clamp_width Or T2_option_clamp_height Or T2_option_alpha_channel Or T2_option_color_sum

    Dim T2c As Long
    Dim T2w As Long
    Dim T2h As Long
    T2c = 2 ' street light
    T2w = _Width(TextureCatalog(T2c)) * 4
    T2h = _Height(TextureCatalog(T2c)) * 2

    ' Triangle 1 of 3
    mesh(A).x0 = left05.x
    mesh(A).y0 = left05.y
    mesh(A).z0 = left05.z

    mesh(A).x1 = right00.x
    mesh(A).y1 = right00.y
    mesh(A).z1 = right00.z

    mesh(A).x2 = left00.x
    mesh(A).y2 = left00.y
    mesh(A).z2 = left00.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T2c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = T1h * 0.5
    mesh(A).u1 = T1w
    mesh(A).v1 = T1h
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = 0
    mesh(A).t0 = T2h * 0.5
    mesh(A).s1 = T2w
    mesh(A).t1 = T2h
    mesh(A).s2 = 0
    mesh(A).t2 = T2h
    If streetlight = 0 Then
        mesh(A).options = mesh(A).options Or T2_option_disable_RGBA
    End If
    A = A + 1

    ' Triangle 2 of 3
    mesh(A).x0 = left05.x
    mesh(A).y0 = left05.y
    mesh(A).z0 = left05.z

    mesh(A).x1 = right10.x
    mesh(A).y1 = right10.y
    mesh(A).z1 = right10.z

    mesh(A).x2 = right00.x
    mesh(A).y2 = right00.y
    mesh(A).z2 = right00.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T2c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = T1h * 0.5
    mesh(A).u1 = T1w
    mesh(A).v1 = 0
    mesh(A).u2 = T1w
    mesh(A).v2 = T1h

    mesh(A).s0 = 0
    mesh(A).t0 = T2h * 0.5
    mesh(A).s1 = T2w
    mesh(A).t1 = 0
    mesh(A).s2 = T2w
    mesh(A).t2 = T2h
    If streetlight = 0 Then
        mesh(A).options = mesh(A).options Or T2_option_disable_RGBA
    End If
    A = A + 1

    ' Triangle 3 of 3
    mesh(A).x0 = left10.x
    mesh(A).y0 = left10.y
    mesh(A).z0 = left10.z

    mesh(A).x1 = right10.x
    mesh(A).y1 = right10.y
    mesh(A).z1 = right10.z

    mesh(A).x2 = left05.x
    mesh(A).y2 = left05.y
    mesh(A).z2 = left05.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T2c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = 0
    mesh(A).u2 = 0
    mesh(A).v2 = T1h * 0.5

    mesh(A).s0 = 0
    mesh(A).t0 = 0
    mesh(A).s1 = T2w
    mesh(A).t1 = 0
    mesh(A).s2 = 0
    mesh(A).t2 = T2h * 0.5
    If streetlight = 0 Then
        mesh(A).options = mesh(A).options Or T2_option_disable_RGBA
    End If
    A = A + 1

    Dim dummy As Single ' remove compiler warnings
    dummy = right05.x
End Sub


Sub SpawnLeftWall (A As Integer, remain As Integer, left0 As vec3d, left1 As vec3d)
    Dim p0 As vec3d
    Dim p1 As vec3d

    If remain <= 0 Then Exit Sub
    remain = remain - 1

    p0.x = left0.x
    p0.y = left0.y
    p0.z = left0.z

    p1.x = left1.x
    p1.y = left1.y
    p1.z = left1.z

    ' texture
    Dim T1c As Long
    Dim T1w As Long
    Dim T1h As Long
    Dim T1o As Long
    T1c = 15 ' metal pipe fence thing
    T1w = _Width(TextureCatalog(T1c))
    T1h = _Height(TextureCatalog(T1c))
    T1o = T1_option_clamp_height Or T1_option_alpha_channel Or T1_option_no_backface_cull Or T2_option_disable_RGBA

    Dim fenceheight As Single
    fenceheight = 5.0

    ' post near
    mesh(A).x0 = p0.x
    mesh(A).y0 = p0.y + fenceheight
    mesh(A).z0 = p0.z

    mesh(A).x1 = p1.x
    mesh(A).y1 = p1.y + fenceheight
    mesh(A).z1 = p1.z

    mesh(A).x2 = p0.x
    mesh(A).y2 = p0.y
    mesh(A).z2 = p0.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T1c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = 0
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = mesh(A).u0
    mesh(A).t0 = mesh(A).v0
    mesh(A).s1 = mesh(A).u1
    mesh(A).t1 = mesh(A).v1
    mesh(A).s2 = mesh(A).u2
    mesh(A).t2 = mesh(A).v2

    A = A + 1


    ' post far
    mesh(A).x0 = p1.x
    mesh(A).y0 = p1.y + fenceheight
    mesh(A).z0 = p1.z

    mesh(A).x1 = p1.x
    mesh(A).y1 = p1.y
    mesh(A).z1 = p1.z

    mesh(A).x2 = p0.x
    mesh(A).y2 = p0.y
    mesh(A).z2 = p0.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T1c
    mesh(A).options = T1o

    mesh(A).u0 = T1w
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = T1h
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = mesh(A).u0
    mesh(A).t0 = mesh(A).v0
    mesh(A).s1 = mesh(A).u1
    mesh(A).t1 = mesh(A).v1
    mesh(A).s2 = mesh(A).u2
    mesh(A).t2 = mesh(A).v2

    A = A + 1

End Sub

Sub SpawnRightWall (A As Integer, remain As Integer, right0 As vec3d, right1 As vec3d)
    Dim p0 As vec3d
    Dim p1 As vec3d

    If remain <= 0 Then Exit Sub
    remain = remain - 1

    p0.x = right0.x
    p0.y = right0.y
    p0.z = right0.z

    p1.x = right1.x
    p1.y = right1.y
    p1.z = right1.z

    ' texture
    Dim T1c As Long
    Dim T1w As Long
    Dim T1h As Long
    Dim T1o As Long
    T1c = 15 ' metal pipe fence thing
    T1w = _Width(TextureCatalog(T1c))
    T1h = _Height(TextureCatalog(T1c))
    T1o = T1_option_clamp_height Or T1_option_alpha_channel Or T1_option_no_backface_cull Or T2_option_disable_RGBA

    Dim fenceheight As Single
    fenceheight = 5.0

    ' post near
    mesh(A).x0 = p1.x
    mesh(A).y0 = p1.y + fenceheight
    mesh(A).z0 = p1.z

    mesh(A).x1 = p0.x
    mesh(A).y1 = p0.y + fenceheight
    mesh(A).z1 = p0.z

    mesh(A).x2 = p0.x
    mesh(A).y2 = p0.y
    mesh(A).z2 = p0.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T1c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = 0
    mesh(A).u2 = T1w
    mesh(A).v2 = T1h

    mesh(A).s0 = mesh(A).u0
    mesh(A).t0 = mesh(A).v0
    mesh(A).s1 = mesh(A).u1
    mesh(A).t1 = mesh(A).v1
    mesh(A).s2 = mesh(A).u2
    mesh(A).t2 = mesh(A).v2

    A = A + 1


    ' post far
    mesh(A).x0 = p1.x
    mesh(A).y0 = p1.y + fenceheight
    mesh(A).z0 = p1.z

    mesh(A).x1 = p0.x
    mesh(A).y1 = p0.y
    mesh(A).z1 = p0.z

    mesh(A).x2 = p1.x
    mesh(A).y2 = p1.y
    mesh(A).z2 = p1.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T1c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = T1h
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = mesh(A).u0
    mesh(A).t0 = mesh(A).v0
    mesh(A).s1 = mesh(A).u1
    mesh(A).t1 = mesh(A).v1
    mesh(A).s2 = mesh(A).u2
    mesh(A).t2 = mesh(A).v2

    A = A + 1

End Sub

Sub SpawnPineTree (A As Integer, remain As Integer, center As vec3d)
    Static psn As vec3d

    If remain <= 0 Then Exit Sub
    remain = remain - 1

    psn.x = center.x
    psn.y = center.y
    psn.z = center.z


    ' texture
    Dim T1c As Long
    Dim T1w As Long
    Dim T1h As Long
    Dim T1o As Long
    T1c = 1 ' pine tree
    T1w = _Width(TextureCatalog(T1c))
    T1h = _Height(TextureCatalog(T1c))
    T1o = T1_option_clamp_width Or T1_option_clamp_height Or T1_option_alpha_channel Or T1_option_no_backface_cull Or T2_option_disable_RGBA

    ' X plane
    mesh(A).x0 = -2.0 + psn.x
    mesh(A).y0 = 8.0 + psn.y
    mesh(A).z0 = psn.z

    mesh(A).x1 = 2.0 + psn.x
    mesh(A).y1 = 8.0 + psn.y
    mesh(A).z1 = psn.z

    mesh(A).x2 = -2.0 + psn.x
    mesh(A).y2 = 0.0 + psn.y
    mesh(A).z2 = psn.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T1c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = 0
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = 0
    mesh(A).t0 = 0
    mesh(A).s1 = T1w
    mesh(A).t1 = 0
    mesh(A).s2 = 0
    mesh(A).t2 = T1h

    A = A + 1


    mesh(A).x0 = 2.0 + psn.x
    mesh(A).y0 = 8.0 + psn.y
    mesh(A).z0 = psn.z

    mesh(A).x1 = 2.0 + psn.x
    mesh(A).y1 = 0.0 + psn.y
    mesh(A).z1 = psn.z

    mesh(A).x2 = -2.0 + psn.x
    mesh(A).y2 = 0.0 + psn.y
    mesh(A).z2 = psn.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T1c
    mesh(A).options = T1o

    mesh(A).u0 = T1w
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = T1h
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = T1w
    mesh(A).t0 = 0
    mesh(A).s1 = T1w
    mesh(A).t1 = T1h
    mesh(A).s2 = 0
    mesh(A).t2 = T1h

    A = A + 1


    ' Z plane
    mesh(A).x0 = psn.x
    mesh(A).y0 = 8.0 + psn.y
    mesh(A).z0 = -2.0 + psn.z

    mesh(A).x1 = psn.x
    mesh(A).y1 = 8.0 + psn.y
    mesh(A).z1 = 2.0 + psn.z

    mesh(A).x2 = psn.x
    mesh(A).y2 = 0.0 + psn.y
    mesh(A).z2 = -2.0 + psn.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T1c
    mesh(A).options = T1o

    mesh(A).u0 = 0
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = 0
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = 0
    mesh(A).t0 = 0
    mesh(A).s1 = T1w
    mesh(A).t1 = 0
    mesh(A).s2 = 0
    mesh(A).t2 = T1h

    A = A + 1


    mesh(A).x0 = psn.x
    mesh(A).y0 = 8.0 + psn.y
    mesh(A).z0 = 2.0 + psn.z

    mesh(A).x1 = psn.x
    mesh(A).y1 = 0.0 + psn.y
    mesh(A).z1 = 2.0 + psn.z

    mesh(A).x2 = psn.x
    mesh(A).y2 = 0.0 + psn.y
    mesh(A).z2 = -2.0 + psn.z

    mesh(A).texture1 = T1c
    mesh(A).texture2 = T1c
    mesh(A).options = T1o

    mesh(A).u0 = T1w
    mesh(A).v0 = 0
    mesh(A).u1 = T1w
    mesh(A).v1 = T1h
    mesh(A).u2 = 0
    mesh(A).v2 = T1h

    mesh(A).s0 = T1w
    mesh(A).t0 = 0
    mesh(A).s1 = T1w
    mesh(A).t1 = T1h
    mesh(A).s2 = 0
    mesh(A).t2 = T1h

    A = A + 1
End Sub


Sub FOVchange
    ' requires Frustum_FOV_deg, Frustum_Aspect_Ratio, Frustum_Far, Frustum_Near
    If Frustum_FOV_deg < 10.0 Then Frustum_FOV_deg = 10.0
    If Frustum_FOV_deg > 120.0 Then Frustum_FOV_deg = 120.0
    Frustum_FOV_ratio = 1.0 / Tan(_D2R(Frustum_FOV_deg * 0.5))
    matProj(0, 0) = Frustum_Aspect_Ratio * Frustum_FOV_ratio
    matProj(1, 1) = Frustum_FOV_ratio
    matProj(2, 2) = Frustum_Far / (Frustum_Far - Frustum_Near)
    matProj(2, 3) = 1.0
    matProj(3, 2) = (-Frustum_Far * Frustum_Near) / (Frustum_Far - Frustum_Near)
End Sub


Sub NearClip (A As vec3d, B As vec3d, C As vec3d, D As vec3d, TA As vertex_attribute7, TB As vertex_attribute7, TC As vertex_attribute7, TD As vertex_attribute7, result As Integer)
    ' This function clips a triangle to Frustum_Near
    ' Winding order is preserved.
    ' result:
    ' 0 = do not draw
    ' 1 = only draw ABCA
    ' 2 = draw both ABCA and ACDA

    Static d_A_near_z As Single
    Static d_B_near_z As Single
    Static d_C_near_z As Single
    Static clip_score As _Unsigned Integer
    Static ratio1 As Single
    Static ratio2 As Single

    d_A_near_z = A.z - Frustum_Near
    d_B_near_z = B.z - Frustum_Near
    d_C_near_z = C.z - Frustum_Near

    clip_score = 0
    If d_A_near_z < 0.0 Then clip_score = clip_score Or 1
    If d_B_near_z < 0.0 Then clip_score = clip_score Or 2
    If d_C_near_z < 0.0 Then clip_score = clip_score Or 4

    'Print clip_score;

    Select Case clip_score
        Case &B000
            'Print "no clip"
            result = 1


        Case &B001
            'Print "A is out"
            result = 2

            ' C to new D (using C to A)
            ratio1 = d_C_near_z / (C.z - A.z)
            D.x = (A.x - C.x) * ratio1 + C.x
            D.y = (A.y - C.y) * ratio1 + C.y
            D.z = Frustum_Near
            TD.u = (TA.u - TC.u) * ratio1 + TC.u
            TD.v = (TA.v - TC.v) * ratio1 + TC.v
            TD.r = (TA.r - TC.r) * ratio1 + TC.r
            TD.g = (TA.g - TC.g) * ratio1 + TC.g
            TD.b = (TA.b - TC.b) * ratio1 + TC.b
            TD.s = (TA.s - TC.s) * ratio1 + TC.s
            TD.t = (TA.t - TC.t) * ratio1 + TC.t

            ' new A to B, going backward from B
            ratio2 = d_B_near_z / (B.z - A.z)
            A.x = (A.x - B.x) * ratio2 + B.x
            A.y = (A.y - B.y) * ratio2 + B.y
            A.z = Frustum_Near
            TA.u = (TA.u - TB.u) * ratio2 + TB.u
            TA.v = (TA.v - TB.v) * ratio2 + TB.v
            TA.r = (TA.r - TB.r) * ratio2 + TB.r
            TA.g = (TA.g - TB.g) * ratio2 + TB.g
            TA.b = (TA.b - TB.b) * ratio2 + TB.b
            TA.s = (TA.s - TB.s) * ratio2 + TB.s
            TA.t = (TA.t - TB.t) * ratio2 + TB.t


        Case &B010
            'Print "B is out"
            result = 2

            ' the oddball case
            D = C
            TD = TC

            ' old B to new C, going backward from C to B
            ratio1 = d_C_near_z / (C.z - B.z)
            C.x = (B.x - C.x) * ratio1 + C.x
            C.y = (B.y - C.y) * ratio1 + C.y
            C.z = Frustum_Near
            TC.u = (TB.u - TC.u) * ratio1 + TC.u
            TC.v = (TB.v - TC.v) * ratio1 + TC.v
            TC.r = (TB.r - TC.r) * ratio1 + TC.r
            TC.g = (TB.g - TC.g) * ratio1 + TC.g
            TC.b = (TB.b - TC.b) * ratio1 + TC.b
            TC.s = (TB.s - TC.s) * ratio1 + TC.s
            TC.t = (TB.t - TC.t) * ratio1 + TC.t

            ' A to new B, going forward from A
            ratio2 = d_A_near_z / (A.z - B.z)
            B.x = (B.x - A.x) * ratio2 + A.x
            B.y = (B.y - A.y) * ratio2 + A.y
            B.z = Frustum_Near
            TB.u = (TB.u - TA.u) * ratio2 + TA.u
            TB.v = (TB.v - TA.v) * ratio2 + TA.v
            TB.r = (TB.r - TA.r) * ratio2 + TA.r
            TB.g = (TB.g - TA.g) * ratio2 + TA.g
            TB.b = (TB.b - TA.b) * ratio2 + TA.b
            TB.s = (TB.s - TA.s) * ratio2 + TA.s
            TB.t = (TB.t - TA.t) * ratio2 + TA.t


        Case &B011
            'Print "C is in"
            result = 1

            ' new B to C
            ratio1 = d_C_near_z / (C.z - B.z)
            B.x = (B.x - C.x) * ratio1 + C.x
            B.y = (B.y - C.y) * ratio1 + C.y
            B.z = Frustum_Near
            TB.u = (TB.u - TC.u) * ratio1 + TC.u
            TB.v = (TB.v - TC.v) * ratio1 + TC.v
            TB.r = (TB.r - TC.r) * ratio1 + TC.r
            TB.g = (TB.g - TC.g) * ratio1 + TC.g
            TB.b = (TB.b - TC.b) * ratio1 + TC.b
            TB.s = (TB.s - TC.s) * ratio1 + TC.s
            TB.t = (TB.t - TC.t) * ratio1 + TC.t

            ' C to new A
            ratio2 = d_C_near_z / (C.z - A.z)
            A.x = (A.x - C.x) * ratio2 + C.x
            A.y = (A.y - C.y) * ratio2 + C.y
            A.z = Frustum_Near
            TA.u = (TA.u - TC.u) * ratio2 + TC.u
            TA.v = (TA.v - TC.v) * ratio2 + TC.v
            TA.r = (TA.r - TC.r) * ratio2 + TC.r
            TA.g = (TA.g - TC.g) * ratio2 + TC.g
            TA.b = (TA.b - TC.b) * ratio2 + TC.b
            TA.s = (TA.s - TC.s) * ratio2 + TC.s
            TA.t = (TA.t - TC.t) * ratio2 + TC.t


        Case &B100
            'Print "C is out"
            result = 2

            ' new D to A
            ratio1 = d_A_near_z / (A.z - C.z)
            D.x = (C.x - A.x) * ratio1 + A.x
            D.y = (C.y - A.y) * ratio1 + A.y
            D.z = Frustum_Near
            TD.u = (TC.u - TA.u) * ratio1 + TA.u
            TD.v = (TC.v - TA.v) * ratio1 + TA.v
            TD.r = (TC.r - TA.r) * ratio1 + TA.r
            TD.g = (TC.g - TA.g) * ratio1 + TA.g
            TD.b = (TC.b - TA.b) * ratio1 + TA.b
            TD.s = (TC.s - TA.s) * ratio1 + TA.s
            TD.t = (TC.t - TA.t) * ratio1 + TA.t

            ' B to new C
            ratio2 = d_B_near_z / (B.z - C.z)
            C.x = (C.x - B.x) * ratio2 + B.x
            C.y = (C.y - B.y) * ratio2 + B.y
            C.z = Frustum_Near
            TC.u = (TC.u - TB.u) * ratio2 + TB.u
            TC.v = (TC.v - TB.v) * ratio2 + TB.v
            TC.r = (TC.r - TB.r) * ratio2 + TB.r
            TC.g = (TC.g - TB.g) * ratio2 + TB.g
            TC.b = (TC.b - TB.b) * ratio2 + TB.b
            TC.s = (TC.s - TB.s) * ratio2 + TB.s
            TC.t = (TC.t - TB.t) * ratio2 + TB.t


        Case &B101
            'Print "B is in"
            result = 1

            ' new A to B
            ratio1 = d_B_near_z / (B.z - A.z)
            A.x = (A.x - B.x) * ratio1 + B.x
            A.y = (A.y - B.y) * ratio1 + B.y
            A.z = Frustum_Near
            TA.u = (TA.u - TB.u) * ratio1 + TB.u
            TA.v = (TA.v - TB.v) * ratio1 + TB.v
            TA.r = (TA.r - TB.r) * ratio1 + TB.r
            TA.g = (TA.g - TB.g) * ratio1 + TB.g
            TA.b = (TA.b - TB.b) * ratio1 + TB.b
            TA.s = (TA.s - TB.s) * ratio1 + TB.s
            TA.t = (TA.t - TB.t) * ratio1 + TB.t

            ' B to new C
            ratio2 = d_B_near_z / (B.z - C.z)
            C.x = (C.x - B.x) * ratio2 + B.x
            C.y = (C.y - B.y) * ratio2 + B.y
            C.z = Frustum_Near
            TC.u = (TC.u - TB.u) * ratio2 + TB.u
            TC.v = (TC.v - TB.v) * ratio2 + TB.v
            TC.r = (TC.r - TB.r) * ratio2 + TB.r
            TC.g = (TC.g - TB.g) * ratio2 + TB.g
            TC.b = (TC.b - TB.b) * ratio2 + TB.b
            TC.s = (TC.s - TB.s) * ratio2 + TB.s
            TC.t = (TC.t - TB.t) * ratio2 + TB.t


        Case &B110
            'Print "A is in"
            result = 1

            ' A to new B
            ratio1 = d_A_near_z / (A.z - B.z)
            B.x = (B.x - A.x) * ratio1 + A.x
            B.y = (B.y - A.y) * ratio1 + A.y
            B.z = Frustum_Near
            TB.u = (TB.u - TA.u) * ratio1 + TA.u
            TB.v = (TB.v - TA.v) * ratio1 + TA.v
            TB.r = (TB.r - TA.r) * ratio1 + TA.r
            TB.g = (TB.g - TA.g) * ratio1 + TA.g
            TB.b = (TB.b - TA.b) * ratio1 + TA.b
            TB.s = (TB.s - TA.s) * ratio1 + TA.s
            TB.t = (TB.t - TA.t) * ratio1 + TA.t

            ' new C to A
            ratio2 = d_A_near_z / (A.z - C.z)
            C.x = (C.x - A.x) * ratio2 + A.x
            C.y = (C.y - A.y) * ratio2 + A.y
            C.z = Frustum_Near
            TC.u = (TC.u - TA.u) * ratio2 + TA.u
            TC.v = (TC.v - TA.v) * ratio2 + TA.v
            TC.r = (TC.r - TA.r) * ratio2 + TA.r
            TC.g = (TC.g - TA.g) * ratio2 + TA.g
            TC.b = (TC.b - TA.b) * ratio2 + TA.b
            TC.s = (TC.s - TA.s) * ratio2 + TA.s
            TC.t = (TC.t - TA.t) * ratio2 + TA.t


        Case &B111
            'Print "discard"
            result = 0

    End Select

End Sub


' Multiply a 3D vector into a 4x4 matrix and output another 3D vector
' Important!: matrix o must be a different variable from matrix i. if i and o are the same variable it will malfunction.
' To understand the optimization here. Mathematically you can only multiply matrices of the same dimension. 4 here.
' But I'm only interested in x, y, and z; so don't bother calculating "w" because it is always 1.
' Avoiding 7 unnecessary extra multiplications
Sub Multiply_Vector3_Matrix4 (i As vec3d, m( 3 , 3) As Single, o As vec3d)
    o.x = i.x * m(0, 0) + i.y * m(1, 0) + i.z * m(2, 0) + m(3, 0)
    o.y = i.x * m(0, 1) + i.y * m(1, 1) + i.z * m(2, 1) + m(3, 1)
    o.z = i.x * m(0, 2) + i.y * m(1, 2) + i.z * m(2, 2) + m(3, 2)
End Sub

' If you ever need it, then go ahead and uncomment and pass in vec4d, but I doubt you ever would need it.
'SUB MultiplyMatrixVector4 (i AS vec4d, o AS vec4d, m( 3 , 3) AS SINGLE)
'    o.x = i.x * m(0, 0) + i.y * m(1, 0) + i.z * m(2, 0) + m(3, 0) * i.w
'    o.y = i.x * m(0, 1) + i.y * m(1, 1) + i.z * m(2, 1) + m(3, 1) * i.w
'    o.z = i.x * m(0, 2) + i.y * m(1, 2) + i.z * m(2, 2) + m(3, 2) * i.w
'    o.w = i.x * m(0, 3) + i.y * m(1, 3) + i.z * m(2, 3) + m(3, 3) * i.w
'END SUB

Sub Vector3_Add (left As vec3d, right As vec3d, o As vec3d)
    o.x = left.x + right.x
    o.y = left.y + right.y
    o.z = left.z + right.z
End Sub

Sub Vector3_Delta (left As vec3d, right As vec3d, o As vec3d)
    o.x = left.x - right.x
    o.y = left.y - right.y
    o.z = left.z - right.z
End Sub

Sub Vector3_Normalize (io As vec3d)
    Dim length As Single
    length = Sqr(io.x * io.x + io.y * io.y + io.z * io.z)
    If length = 0.0 Then
        io.x = 0.0
        io.y = 0.0
        io.z = 0.0
    Else
        io.x = io.x / length
        io.y = io.y / length
        io.z = io.z / length
    End If
End Sub

Sub Vector3_Lerp (p0 As vec3d, p1 As vec3d, ratio As Single, o As vec3d)
    o.x = (p1.x - p0.x) * ratio + p0.x
    o.y = (p1.y - p0.y) * ratio + p0.y
    o.z = (p1.z - p0.z) * ratio + p0.z
End Sub

Sub Vector3_Mul (left As vec3d, scale As Single, o As vec3d)
    o.x = left.x * scale
    o.y = left.y * scale
    o.z = left.z * scale
End Sub

Sub Vector3_CrossProduct (p0 As vec3d, p1 As vec3d, o As vec3d)
    o.x = p0.y * p1.z - p0.z * p1.y
    o.y = p0.z * p1.x - p0.x * p1.z
    o.z = p0.x * p1.y - p0.y * p1.x
End Sub

Sub CalcSurfaceNormal_3Point (p0 As vec3d, p1 As vec3d, p2 As vec3d, o As vec3d)
    Static line1_x As Single, line1_y As Single, line1_z As Single
    Static line2_x As Single, line2_y As Single, line2_z As Single
    Static lengthNormal As Single

    line1_x = p1.x - p0.x
    line1_y = p1.y - p0.y
    line1_z = p1.z - p0.z

    line2_x = p2.x - p0.x
    line2_y = p2.y - p0.y
    line2_z = p2.z - p0.z

    ' Cross Product
    o.x = line1_y * line2_z - line1_z * line2_y
    o.y = line1_z * line2_x - line1_x * line2_z
    o.z = line1_x * line2_y - line1_y * line2_x

    lengthNormal = Sqr(o.x * o.x + o.y * o.y + o.z * o.z)
    If lengthNormal = 0.0 Then Exit Sub

    o.x = o.x / lengthNormal
    o.y = o.y / lengthNormal
    o.z = o.z / lengthNormal

End Sub

Function Vector3_DotProduct! (p0 As vec3d, p1 As vec3d)
    Vector3_DotProduct! = p0.x * p1.x + p0.y * p1.y + p0.z * p1.z
End Function

Function SmootherStep (t As Single)
    SmootherStep = ((6.0 * t - 15.0) * t + 10.0) * t * t * t
End Function

Sub Matrix4_MakeIdentity (m( 3 , 3) As Single)
    m(0, 0) = 1.0: m(0, 1) = 0.0: m(0, 2) = 0.0: m(0, 3) = 0.0
    m(1, 1) = 0.0: m(1, 1) = 1.0: m(1, 2) = 0.0: m(1, 3) = 0.0
    m(2, 2) = 0.0: m(2, 1) = 0.0: m(2, 2) = 1.0: m(2, 3) = 0.0
    m(3, 3) = 0.0: m(3, 1) = 0.0: m(3, 2) = 0.0: m(3, 3) = 1.0
End Sub

Sub Matrix4_MakeRotation_Z (deg As Single, m( 3 , 3) As Single)
    ' Rotation Z
    m(0, 0) = Cos(_D2R(deg))
    m(0, 1) = Sin(_D2R(deg))
    m(0, 2) = 0.0
    m(0, 3) = 0.0
    m(1, 0) = -Sin(_D2R(deg))
    m(1, 1) = Cos(_D2R(deg))
    m(1, 2) = 0.0
    m(1, 3) = 0.0
    m(2, 2) = 0.0: m(2, 1) = 0.0: m(2, 2) = 1.0: m(2, 3) = 0.0
    m(3, 3) = 0.0: m(3, 1) = 0.0: m(3, 2) = 0.0: m(3, 3) = 1.0
End Sub

Sub Matrix4_MakeRotation_Y (deg As Single, m( 3 , 3) As Single)
    m(0, 0) = Cos(_D2R(deg))
    m(0, 1) = 0.0
    m(0, 2) = Sin(_D2R(deg))
    m(0, 3) = 0.0
    m(1, 1) = 0.0: m(1, 1) = 1.0: m(1, 2) = 0.0: m(1, 3) = 0.0
    m(2, 0) = -Sin(_D2R(deg))
    m(2, 1) = 0.0
    m(2, 2) = Cos(_D2R(deg))
    m(2, 3) = 0.0
    m(3, 3) = 0.0: m(3, 1) = 0.0: m(3, 2) = 0.0: m(3, 3) = 1.0
End Sub

Sub Matrix4_MakeRotation_X (deg As Single, m( 3 , 3) As Single)
    m(0, 0) = 1.0: m(0, 1) = 0.0: m(0, 2) = 0.0: m(0, 3) = 0.0
    m(1, 0) = 0.0
    m(1, 1) = Cos(_D2R(deg))
    m(1, 2) = -Sin(_D2R(deg)) 'flip
    m(1, 3) = 0.0
    m(2, 0) = 0.0
    m(2, 1) = Sin(_D2R(deg)) 'flip
    m(2, 2) = Cos(_D2R(deg))
    m(2, 3) = 0.0
    m(3, 3) = 0.0: m(3, 1) = 0.0: m(3, 2) = 0.0: m(3, 3) = 1.0
End Sub

Sub Matrix4_PointAt (psn As vec3d, target As vec3d, up As vec3d, m( 3 , 3) As Single)
    ' It will create a matrix that keeps target centered onscreen
    '  from the vantage point of psn. It will pivot on a gimbal.

    ' Calculate new forward direction
    Dim newForward As vec3d
    Vector3_Delta target, psn, newForward
    Vector3_Normalize newForward

    ' Calculate new Up direction
    Dim a As vec3d
    Dim newUp As vec3d
    Vector3_Mul newForward, Vector3_DotProduct(up, newForward), a
    Vector3_Delta up, a, newUp
    Vector3_Normalize newUp

    ' new Right direction is just cross product
    Dim newRight As vec3d
    Vector3_CrossProduct newUp, newForward, newRight

    ' Construct Dimensioning and Translation Matrix
    m(0, 0) = newRight.x: m(0, 1) = newRight.y: m(0, 2) = newRight.z: m(0, 3) = 0.0
    m(1, 0) = newUp.x: m(1, 1) = newUp.y: m(1, 2) = newUp.z: m(1, 3) = 0.0
    m(2, 0) = newForward.x: m(2, 1) = newForward.y: m(2, 2) = newForward.z: m(2, 3) = 0.0
    m(3, 0) = psn.x: m(3, 1) = psn.y: m(3, 2) = psn.z: m(3, 3) = 1.0

End Sub

Sub Matrix4_QuickInverse (m( 3 , 3) As Single, q( 3 , 3) As Single)
    q(0, 0) = m(0, 0): q(0, 1) = m(1, 0): q(0, 2) = m(2, 0): q(0, 3) = 0.0
    q(1, 0) = m(0, 1): q(1, 1) = m(1, 1): q(1, 2) = m(2, 1): q(1, 3) = 0.0
    q(2, 0) = m(0, 2): q(2, 1) = m(1, 2): q(2, 2) = m(2, 2): q(2, 3) = 0.0
    q(3, 0) = -(m(3, 0) * q(0, 0) + m(3, 1) * q(1, 0) + m(3, 2) * q(2, 0))
    q(3, 1) = -(m(3, 0) * q(0, 1) + m(3, 1) * q(1, 1) + m(3, 2) * q(2, 1))
    q(3, 2) = -(m(3, 0) * q(0, 2) + m(3, 1) * q(1, 2) + m(3, 2) * q(2, 2))
    q(3, 3) = 1.0
End Sub

' Projection is another optimized matrix multiplcation.
' w is assumed 1 on the input side, but this time it is necessary to output.
' X and Y needs to be normalized.
' Z is unused.
Sub ProjectMatrixVector4 (i As vec3d, m( 3 , 3) As Single, o As vec4d)
    Dim www As Single
    o.x = i.x * m(0, 0) + i.y * m(1, 0) + i.z * m(2, 0) + m(3, 0)
    o.y = i.x * m(0, 1) + i.y * m(1, 1) + i.z * m(2, 1) + m(3, 1)
    'o.z = i.x * m(0, 2) + i.y * m(1, 2) + i.z * m(2, 2) + m(3, 2)
    www = i.x * m(0, 3) + i.y * m(1, 3) + i.z * m(2, 3) + m(3, 3)

    ' Normalizing
    If www <> 0.0 Then
        o.w = 1 / www 'optimization
        o.x = o.x * o.w
        o.y = -o.y * o.w 'because I feel +Y is up
        'o.z = o.z * o.w
    End If
End Sub


Sub TwoTextureTriangle (A As vertex10, B As vertex10, C As vertex10)
    Static delta2 As vertex10
    Static delta1 As vertex10
    Static draw_min_y As Long, draw_max_y As Long

    ' Sort so that vertex A is on top and C is on bottom.
    ' This seems inverted from math class, but remember that Y increases in value downward on PC monitors
    If B.y < A.y Then
        Swap A, B
    End If
    If C.y < A.y Then
        Swap A, C
    End If
    If C.y < B.y Then
        Swap B, C
    End If

    ' integer window clipping
    draw_min_y = _Ceil(A.y)
    If draw_min_y < clip_min_y Then draw_min_y = clip_min_y
    draw_max_y = _Ceil(C.y) - 1
    If draw_max_y > clip_max_y Then draw_max_y = clip_max_y
    If (draw_max_y - draw_min_y) < 0 Then Exit Sub

    ' Determine the deltas (lengths)
    ' delta 2 is from A to C (the full triangle height)
    delta2.x = C.x - A.x
    delta2.y = C.y - A.y
    delta2.w = C.w - A.w
    delta2.u = C.u - A.u
    delta2.v = C.v - A.v
    delta2.r = C.r - A.r
    delta2.g = C.g - A.g
    delta2.b = C.b - A.b
    delta2.s = C.s - A.s
    delta2.t = C.t - A.t

    ' Avoiding div by 0
    ' Entire Y height less than 1/256 would not have meaningful pixel color change
    If delta2.y < (1 / 256) Then Exit Sub

    ' Determine vertical Y steps for DDA style math
    ' DDA is Digital Differential Analyzer
    ' It is an accumulator that counts from a known start point to an end point, in equal increments defined by the number of steps in-between.
    ' Probably faster nowadays to do the one division at the start, instead of Bresenham, anyway.
    Static legx1_step As Single
    Static legw1_step As Single, legu1_step As Single, legv1_step As Single
    Static legr1_step As Single, legg1_step As Single, legb1_step As Single
    Static legs1_step As Single, legt1_step As Single

    Static legx2_step As Single
    Static legw2_step As Single, legu2_step As Single, legv2_step As Single
    Static legr2_step As Single, legg2_step As Single, legb2_step As Single
    Static legs2_step As Single, legt2_step As Single

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y
    legr2_step = delta2.r / delta2.y
    legg2_step = delta2.g / delta2.y
    legb2_step = delta2.b / delta2.y
    legs2_step = delta2.s / delta2.y
    legt2_step = delta2.t / delta2.y

    ' Leg 1, Draw top to middle
    ' For most triangles, draw downward from the apex A to a knee B.
    ' That knee could be on either the left or right side, but that is handled much later.
    Static draw_middle_y As Long
    draw_middle_y = _Ceil(B.y)
    If draw_middle_y < clip_min_y Then draw_middle_y = clip_min_y
    ' Do not clip B to max_y. Let the y count expire before reaching the knee if it is past bottom of screen.

    ' Leg 1 is from A to B (right now)
    delta1.x = B.x - A.x
    delta1.y = B.y - A.y
    delta1.w = B.w - A.w
    delta1.u = B.u - A.u
    delta1.v = B.v - A.v
    delta1.r = B.r - A.r
    delta1.g = B.g - A.g
    delta1.b = B.b - A.b
    delta1.s = B.s - A.s
    delta1.t = B.t - A.t

    ' If the triangle has no knee, this section gets skipped to avoid divide by 0.
    ' That is okay, because the recalculate Leg 1 from B to C triggers before actually drawing.
    If delta1.y > (1 / 256) Then
        ' Find Leg 1 steps in the y direction from A to B
        legx1_step = delta1.x / delta1.y
        legw1_step = delta1.w / delta1.y
        legu1_step = delta1.u / delta1.y
        legv1_step = delta1.v / delta1.y
        legr1_step = delta1.r / delta1.y
        legg1_step = delta1.g / delta1.y
        legb1_step = delta1.b / delta1.y
        legs1_step = delta1.s / delta1.y
        legt1_step = delta1.t / delta1.y
    End If

    ' Y Accumulators
    Static leg_x1 As Single
    Static leg_w1 As Single, leg_u1 As Single, leg_v1 As Single
    Static leg_r1 As Single, leg_g1 As Single, leg_b1 As Single
    Static leg_s1 As Single, leg_t1 As Single

    Static leg_x2 As Single
    Static leg_w2 As Single, leg_u2 As Single, leg_v2 As Single
    Static leg_r2 As Single, leg_g2 As Single, leg_b2 As Single
    Static leg_s2 As Single, leg_t2 As Single

    ' 11-4-2022 Prestep Y
    Static prestep_y1 As Single
    ' Basically we are sampling pixels on integer exact rows.
    ' But we only are able to know the next row by way of forward interpolation. So always round up.
    ' To get to that next row, we have to prestep by the fractional forward distance from A. _Ceil(A.y) - A.y
    prestep_y1 = draw_min_y - A.y

    leg_x1 = A.x + prestep_y1 * legx1_step
    leg_w1 = A.w + prestep_y1 * legw1_step
    leg_u1 = A.u + prestep_y1 * legu1_step
    leg_v1 = A.v + prestep_y1 * legv1_step
    leg_r1 = A.r + prestep_y1 * legr1_step
    leg_g1 = A.g + prestep_y1 * legg1_step
    leg_b1 = A.b + prestep_y1 * legb1_step
    leg_s1 = A.s + prestep_y1 * legs1_step
    leg_t1 = A.t + prestep_y1 * legt1_step

    leg_x2 = A.x + prestep_y1 * legx2_step
    leg_w2 = A.w + prestep_y1 * legw2_step
    leg_u2 = A.u + prestep_y1 * legu2_step
    leg_v2 = A.v + prestep_y1 * legv2_step
    leg_r2 = A.r + prestep_y1 * legr2_step
    leg_g2 = A.g + prestep_y1 * legg2_step
    leg_b2 = A.b + prestep_y1 * legb2_step
    leg_s2 = A.s + prestep_y1 * legs2_step
    leg_t2 = A.t + prestep_y1 * legt2_step

    ' Inner loop vars
    Static row As Long
    Static col As Long
    Static draw_max_x As Long
    Static zbuf_index As _Unsigned Long ' Z-Buffer
    Static tex_z As Single ' 1/w helper (multiply by inverse is faster than dividing each time)
    Static pixel_value As _Unsigned Long ' The ARGB value to write to screen

    ' Stepping along the X direction
    Static delta_x As Single
    Static prestep_x As Single
    Static tex_w_step As Single, tex_u_step As Single, tex_v_step As Single
    Static tex_r_step As Single, tex_g_step As Single, tex_b_step As Single
    Static tex_s_step As Single, tex_t_step As Single

    ' X Accumulators
    Static tex_w As Single, tex_u As Single, tex_v As Single
    Static tex_r As Single, tex_g As Single, tex_b As Single
    Static tex_s As Single, tex_t As Single

    ' Screen Memory Pointers
    Static screen_mem_info As _MEM
    Static screen_next_row_step As _Offset
    Static screen_row_base As _Offset ' Calculated every row
    Static screen_address As _Offset ' Calculated at every starting column
    screen_mem_info = _MemImage(WORK_IMAGE)
    screen_next_row_step = 4 * Size_Render_X

    ' Caching of 4 texels in bilinear mode
    Static T1_last_cache As _Unsigned Long
    Static T2_last_cache As _Unsigned Long
    Static T3_last_cache As _Unsigned Long
    T1_last_cache = &HFFFFFFFF ' invalidate
    T1_last_cache = &HFFFFFFFF ' invalidate
    T3_last_cache = &HFFFFFFFF ' invalidate

    ' Row Loop from top to bottom
    row = draw_min_y
    screen_row_base = screen_mem_info.OFFSET + row * screen_next_row_step
    While row <= draw_max_y

        If row = draw_middle_y Then
            ' Reached Leg 1 knee at B, recalculate Leg 1.
            ' This overwrites Leg 1 to be from B to C. Leg 2 just keeps continuing from A to C.
            delta1.x = C.x - B.x
            delta1.y = C.y - B.y
            delta1.w = C.w - B.w
            delta1.u = C.u - B.u
            delta1.v = C.v - B.v
            delta1.r = C.r - B.r
            delta1.g = C.g - B.g
            delta1.b = C.b - B.b
            delta1.s = C.s - B.s
            delta1.t = C.t - B.t

            If delta1.y = 0.0 Then Exit Sub

            ' Full steps in the y direction from B to C
            legx1_step = delta1.x / delta1.y
            legw1_step = delta1.w / delta1.y
            legu1_step = delta1.u / delta1.y
            legv1_step = delta1.v / delta1.y
            legr1_step = delta1.r / delta1.y ' vertex color
            legg1_step = delta1.g / delta1.y
            legb1_step = delta1.b / delta1.y
            legs1_step = delta1.s / delta1.y
            legt1_step = delta1.t / delta1.y

            ' 11-4-2022 Prestep Y
            ' Most cases has B lower downscreen than A.
            ' B > A usually. Only one case where B = A.
            prestep_y1 = draw_middle_y - B.y

            ' Re-Initialize DDA start values
            leg_x1 = B.x + prestep_y1 * legx1_step
            leg_w1 = B.w + prestep_y1 * legw1_step
            leg_u1 = B.u + prestep_y1 * legu1_step
            leg_v1 = B.v + prestep_y1 * legv1_step
            leg_r1 = B.r + prestep_y1 * legr1_step
            leg_g1 = B.g + prestep_y1 * legg1_step
            leg_b1 = B.b + prestep_y1 * legb1_step
            leg_s1 = B.s + prestep_y1 * legs1_step
            leg_t1 = B.t + prestep_y1 * legt1_step
        End If

        ' Horizontal Scanline
        delta_x = Abs(leg_x2 - leg_x1)
        ' Avoid div/0, this gets tiring.
        If delta_x >= (1 / 2048) Then
            ' Calculate step, start, and end values.
            ' Drawing left to right, as in incrementing from a lower to higher memory address, is usually fastest.
            If leg_x1 < leg_x2 Then
                ' leg 1 is on the left
                tex_w_step = (leg_w2 - leg_w1) / delta_x
                tex_u_step = (leg_u2 - leg_u1) / delta_x
                tex_v_step = (leg_v2 - leg_v1) / delta_x
                tex_r_step = (leg_r2 - leg_r1) / delta_x
                tex_g_step = (leg_g2 - leg_g1) / delta_x
                tex_b_step = (leg_b2 - leg_b1) / delta_x
                tex_s_step = (leg_s2 - leg_s1) / delta_x
                tex_t_step = (leg_t2 - leg_t1) / delta_x

                ' Set the horizontal starting point to (1)
                col = _Ceil(leg_x1)
                If col < clip_min_x Then col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x1
                tex_w = leg_w1 + prestep_x * tex_w_step
                tex_u = leg_u1 + prestep_x * tex_u_step
                tex_v = leg_v1 + prestep_x * tex_v_step
                tex_r = leg_r1 + prestep_x * tex_r_step
                tex_g = leg_g1 + prestep_x * tex_g_step
                tex_b = leg_b1 + prestep_x * tex_b_step
                tex_s = leg_s1 + prestep_x * tex_s_step
                tex_t = leg_t1 + prestep_x * tex_t_step

                ' ending point is (2)
                draw_max_x = _Ceil(leg_x2)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            Else
                ' Things are flipped. leg 1 is on the right.
                tex_w_step = (leg_w1 - leg_w2) / delta_x
                tex_u_step = (leg_u1 - leg_u2) / delta_x
                tex_v_step = (leg_v1 - leg_v2) / delta_x
                tex_r_step = (leg_r1 - leg_r2) / delta_x
                tex_g_step = (leg_g1 - leg_g2) / delta_x
                tex_b_step = (leg_b1 - leg_b2) / delta_x
                tex_s_step = (leg_s1 - leg_s2) / delta_x
                tex_t_step = (leg_t1 - leg_t2) / delta_x

                ' Set the horizontal starting point to (2)
                col = _Ceil(leg_x2)
                If col < clip_min_x Then col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x2
                tex_w = leg_w2 + prestep_x * tex_w_step
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step
                tex_r = leg_r2 + prestep_x * tex_r_step
                tex_g = leg_g2 + prestep_x * tex_g_step
                tex_b = leg_b2 + prestep_x * tex_b_step
                tex_s = leg_s2 + prestep_x * tex_s_step
                tex_t = leg_t2 + prestep_x * tex_t_step

                ' ending point is (1)
                draw_max_x = _Ceil(leg_x1)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            End If

            ' Level of Detail vars
            Static LOD_u00 As Single
            Static LOD_u01 As Single
            Static LODX_delta_u As Single

            Static LOD_v00 As Single
            Static LOD_v01 As Single
            Static LODX_delta_v As Single

            Static LOD_horizontal_squared As Single
            Static LOD_squared As Single

            Static LOD_coord_scale1 As Single
            Static LOD_coord_scale3 As Single

            Static LOD_fraction As Single

            Static LOD_tile1 As Integer
            Static LOD_tile3 As Integer

            ' T3 is higher up in pyramid version of T1
            Static T3_width As _Unsigned Integer, T3_width_MASK As _Unsigned Integer
            Static T3_height As _Unsigned Integer, T3_height_MASK As _Unsigned Integer
            Static T3_ImageHandle As Long
            Static T3_mblock As _MEM

            ' Used for Vertical LOD calculation.
            Static next_leg_x1 As Single
            Static next_leg_w1 As Single
            Static next_leg_u1 As Single
            Static next_leg_v1 As Single

            Static next_leg_x2 As Single
            Static next_leg_w2 As Single
            Static next_leg_u2 As Single
            Static next_leg_v2 As Single

            Static next_delta_x As Single
            Static LOD_next_leg_x0 As Single
            Static LOD_slope_u As Single
            Static LOD_next_uoz As Single

            Static LOD_slope_v As Single
            Static LOD_next_voz As Single

            Static LOD_slope_w As Single
            Static LOD_next_w As Single
            Static LOD_next_z As Single

            Static LOD_u10 As Single
            Static LODY_delta_u As Single
            Static LOD_v10 As Single
            Static LODY_delta_v As Single
            Static LOD_vertical_squared As Single

            Static LOD_vertical_failure As Integer


            If (LOD_max > 0) And (LOD_mode > 0) Then
                '
                ' Scanline Vertical LOD initialization.
                '
                ' Span for next row down
                next_leg_x1 = leg_x1 + legx1_step
                next_leg_x2 = leg_x2 + legx2_step
                next_delta_x = Abs(next_leg_x2 - next_leg_x1)

                If next_delta_x >= (1 / 2048) Then
                    LOD_vertical_failure = 0

                    next_leg_w1 = leg_w1 + legw1_step
                    next_leg_u1 = leg_u1 + legu1_step
                    next_leg_v1 = leg_v1 + legv1_step

                    next_leg_w2 = leg_w2 + legw2_step
                    next_leg_u2 = leg_u2 + legu2_step
                    next_leg_v2 = leg_v2 + legv2_step

                    If next_leg_x1 < next_leg_x2 Then

                        ' leg 1 is on the left
                        LOD_next_leg_x0 = col - next_leg_x1

                        LOD_slope_w = (next_leg_w2 - next_leg_w1) / next_delta_x
                        LOD_next_w = LOD_next_leg_x0 * LOD_slope_w + next_leg_w1

                        LOD_next_z = 1 / LOD_next_w ' start the division early. You still must iterate w, not z.

                        LOD_slope_u = (next_leg_u2 - next_leg_u1) / next_delta_x
                        LOD_next_uoz = LOD_next_leg_x0 * LOD_slope_u + next_leg_u1

                        LOD_slope_v = (next_leg_v2 - next_leg_v1) / next_delta_x
                        LOD_next_voz = LOD_next_leg_x0 * LOD_slope_v + next_leg_v1

                    Else
                        ' leg 2 is on the left
                        LOD_next_leg_x0 = col - next_leg_x2

                        LOD_slope_w = (next_leg_w1 - next_leg_w2) / next_delta_x
                        LOD_next_w = LOD_next_leg_x0 * LOD_slope_w + next_leg_w2

                        LOD_next_z = 1 / LOD_next_w ' start the division early. You still must iterate w, not z.

                        LOD_slope_u = (next_leg_u1 - next_leg_u2) / next_delta_x
                        LOD_next_uoz = LOD_next_leg_x0 * LOD_slope_u + next_leg_u2

                        LOD_slope_v = (next_leg_v1 - next_leg_v2) / next_delta_x
                        LOD_next_voz = LOD_next_leg_x0 * LOD_slope_v + next_leg_v2

                    End If

                Else
                    ' Singularity.
                    ' Horizontal LOD will be sufficient.
                    LOD_vertical_failure = 1
                End If ' next_delta_x

            End If ' LOD_mode > 0

            ' Draw the Horizontal Scanline
            tex_z = 1 / tex_w
            screen_address = screen_row_base + 4 * col
            zbuf_index = row * Size_Render_X + col
            While col < draw_max_x

                ' Check Z-Buffer early to see if we even need texture lookup and color combine
                ' Note: Only solid (non-transparent) pixels update the Z-buffer
                If Screen_Z_Buffer(zbuf_index) = 0.0 Or tex_z < Screen_Z_Buffer(zbuf_index) Then

                    ' metrics
                    Static T1_cache_miss_event As Integer
                    Static T3_cache_miss_event As Integer
                    T1_cache_miss_event = 0
                    T3_cache_miss_event = 0

                    ' Level of Detail calculation
                    If LOD_max > 0 Then

                        Select Case LOD_mode
                            ' For each path be sure to set LOD_tile1, LOD_tile3, and LOD_coord_scale1 at minimum.
                            ' When actually doing LOD, be sure to also set LOD_coord_scale3, LOD_fraction, and reset the T1_ and T3_ parameters.
                            Case 0:
                                ' Pass
                                LOD_tile1 = 0
                                LOD_tile3 = 0
                                LOD_coord_scale1 = 1.0
                                LOD_coord_scale3 = 1.0

                            Case 1:
                                ' No square root, no base 2 logarithm, LOD_fraction is approximated from LOD_squared.

                                ' Horizontal LOD
                                ' How much do the texel (U, V) coordinates change when going one pixel to the right?
                                LOD_u00 = (tex_u * tex_z)
                                LOD_u01 = ((tex_u + tex_u_step) / (tex_w + tex_w_step))

                                LOD_v00 = (tex_v * tex_z)
                                LOD_v01 = ((tex_v + tex_v_step) / (tex_w + tex_w_step))

                                LODX_delta_u = LOD_u01 - LOD_u00
                                LODX_delta_v = LOD_v01 - LOD_v00

                                ' Pythagoras distance formula but without the square root. This also makes it always positive.
                                LOD_horizontal_squared = LODX_delta_v * LODX_delta_v + LODX_delta_u * LODX_delta_u


                                ' Vertical LOD
                                LOD_u10 = LOD_next_uoz * LOD_next_z
                                LOD_v10 = LOD_next_voz * LOD_next_z

                                ' Pythagoras distance formula without the square root.
                                LODY_delta_u = LOD_u10 - LOD_u00
                                LODY_delta_v = LOD_v10 - LOD_v00
                                LOD_vertical_squared = LODY_delta_v * LODY_delta_v + LODY_delta_u * LODY_delta_u

                                ' Pick the largest of the two LODs
                                LOD_squared = LOD_vertical_squared * LOD_aspect_squared
                                If (LOD_squared < LOD_horizontal_squared) Or (LOD_vertical_failure = 1) Then LOD_squared = LOD_horizontal_squared


                                ' Threshold lookup tables.
                                ' The bend of the LOD fraction curve is not perfect but visually close enough.
                                ' Yes it ranges from 0 to 0.9999
                                If LOD_squared < 1.0 Then
                                    '1*1
                                    LOD_fraction = 0.0
                                    LOD_coord_scale1 = 1.0
                                    LOD_coord_scale3 = 1.0
                                    LOD_tile1 = 0
                                    LOD_tile3 = 0
                                ElseIf LOD_squared < 4.0 Then
                                    ' 2*2
                                    LOD_fraction = (LOD_squared - 1.0) / (4.0 - 1.0)
                                    LOD_coord_scale1 = 1.0
                                    LOD_coord_scale3 = 0.5
                                    LOD_tile1 = 0
                                    LOD_tile3 = 1
                                ElseIf LOD_squared < 16.0 Then
                                    ' 4*4
                                    LOD_fraction = (LOD_squared - 4.0) / (16.0 - 4.0)
                                    LOD_coord_scale1 = 0.5
                                    LOD_coord_scale3 = 0.25
                                    LOD_tile1 = 1
                                    LOD_tile3 = 2
                                ElseIf LOD_squared < 64.0 Then
                                    ' 8*8
                                    LOD_fraction = (LOD_squared - 16.0) / (64.0 - 16.0)
                                    LOD_coord_scale1 = 0.25
                                    LOD_coord_scale3 = 0.125
                                    LOD_tile1 = 2
                                    LOD_tile3 = 3
                                ElseIf LOD_squared < 256.0 Then
                                    ' 16*16
                                    LOD_fraction = (LOD_squared - 64.0) / (256.0 - 64.0)
                                    LOD_coord_scale1 = 0.125
                                    LOD_coord_scale3 = 0.0625
                                    LOD_tile1 = 3
                                    LOD_tile3 = 4
                                ElseIf LOD_squared < 1024.0 Then
                                    ' 32*32
                                    LOD_fraction = (LOD_squared - 256.0) / (1024.0 - 256.0)
                                    LOD_coord_scale1 = 0.0625
                                    LOD_coord_scale3 = 0.03125
                                    LOD_tile1 = 4
                                    LOD_tile3 = 5
                                Else
                                    ' 64*64
                                    LOD_fraction = 1.0
                                    LOD_coord_scale1 = 0.03125
                                    LOD_coord_scale3 = 0.03125
                                    LOD_tile1 = 5
                                    LOD_tile3 = 5
                                End If

                                If LOD_tile3 <> LOD_tile1 Then
                                    T3_ImageHandle = TextureCatalog(T1_CatalogIndex + LOD_tile3)
                                    T3_mblock = _MemImage(T3_ImageHandle)
                                    T3_width = _Width(T3_ImageHandle): T3_width_MASK = T3_width - 1
                                    T3_height = _Height(T3_ImageHandle): T3_height_MASK = T3_height - 1
                                End If

                                ' Because LOD changes up or down, these T1 numbers need to be set again.
                                ' This includes the case of going from LOD 1 back down to LOD 0.
                                ' So just set every time.
                                T1_ImageHandle = TextureCatalog(T1_CatalogIndex + LOD_tile1)
                                T1_mblock = _MemImage(T1_ImageHandle)
                                T1_width = _Width(T1_ImageHandle): T1_width_MASK = T1_width - 1
                                T1_height = _Height(T1_ImageHandle): T1_height_MASK = T1_height - 1

                        End Select

                    Else
                        LOD_coord_scale1 = 1.0
                        LOD_tile1 = 0
                        LOD_tile3 = 0
                    End If ' LOD_max

                    ' Read Texel
                    ' Relies on shared T1_ and T2_ variables
                    Static cm5 As Single
                    Static rm5 As Single
                    Static cc As _Unsigned Integer
                    Static ccp As _Unsigned Integer
                    Static rr As _Unsigned Integer
                    Static rrp As _Unsigned Integer

                    ' 4 point bilinear temp vars
                    Static Frac_cc1_FIX7 As Integer
                    Static Frac_rr1_FIX7 As Integer
                    ' 0 1
                    ' . .
                    Static bi_r0 As Integer
                    Static bi_g0 As Integer
                    Static bi_b0 As Integer
                    Static bi_a0 As Integer
                    ' . .
                    ' 2 3
                    Static bi_r1 As Integer
                    Static bi_g1 As Integer
                    Static bi_b1 As Integer
                    Static bi_a1 As Integer


                    ' color blending
                    Static r2 As Integer
                    Static g2 As Integer
                    Static b2 As Integer
                    Static a2 As Integer

                    Static r1 As Integer
                    Static g1 As Integer
                    Static b1 As Integer
                    Static a1 As Integer

                    Static r3 As Integer
                    Static g3 As Integer
                    Static b3 As Integer
                    Static a3 As Integer

                    Static r0 As Integer
                    Static g0 As Integer
                    Static b0 As Integer

                    ' This is about the limit of understanding for inlining.
                    ' I wish QB64 subroutines removed the stack setup and teardown when only static vars are used.
                    '
                    ' T2 -> (T1 or T3) -> Screen
                    '
                    ' Texture 2
                    '
                    If Texture_options And T2_option_disable_RGBA Then
                        r2 = 0: g2 = 0: b2 = 0: a2 = 0
                    Else
                        ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                        cm5 = (tex_s * tex_z) - 0.5
                        rm5 = (tex_t * tex_z) - 0.5

                        If Texture_options And T2_option_clamp_width Then
                            ' clamp
                            If cm5 < 0.0 Then cm5 = 0.0
                            If cm5 >= T2_width_MASK Then
                                ' 15.0 and up
                                cc = T2_width_MASK
                                ccp = T2_width_MASK
                            Else
                                ' 0 1 2 .. 13 14.999
                                cc = Int(cm5)
                                ccp = cc + 1
                            End If
                        Else
                            ' tile the texture
                            cc = Int(cm5) And T2_width_MASK
                            ccp = (cc + 1) And T2_width_MASK
                        End If

                        If Texture_options And T2_option_clamp_height Then
                            ' clamp
                            If rm5 < 0.0 Then rm5 = 0.0
                            If rm5 >= T2_height_MASK Then
                                ' 15.0 and up
                                rr = T2_height_MASK
                                rrp = T2_height_MASK
                            Else
                                rr = Int(rm5)
                                rrp = rr + 1
                            End If
                        Else
                            ' tile
                            rr = Int(rm5) And T2_height_MASK
                            rrp = (rr + 1) And T2_height_MASK
                        End If

                        Frac_cc1_FIX7 = (cm5 - Int(cm5)) * 128
                        Frac_rr1_FIX7 = (rm5 - Int(rm5)) * 128

                        ' caching of 4 texels
                        Static T2_this_cache As _Unsigned Long
                        Static T2_uv_0_0 As Long
                        Static T2_uv_1_0 As Long
                        Static T2_uv_0_1 As Long
                        Static T2_uv_1_1 As Long

                        T2_this_cache = _ShL(rr, 12) Or cc
                        If T2_this_cache <> T2_last_cache Then
                            _MemGet T2_mblock, T2_mblock.OFFSET + (cc + rr * T2_width) * 4, T2_uv_0_0
                            _MemGet T2_mblock, T2_mblock.OFFSET + (ccp + rr * T2_width) * 4, T2_uv_1_0
                            _MemGet T2_mblock, T2_mblock.OFFSET + (cc + rrp * T2_width) * 4, T2_uv_0_1
                            _MemGet T2_mblock, T2_mblock.OFFSET + (ccp + rrp * T2_width) * 4, T2_uv_1_1

                            T2_last_cache = T2_this_cache
                        End If

                        ' determine T2 RGB colors
                        bi_r0 = _Red32(T2_uv_0_0)
                        bi_r0 = _ShR((_Red32(T2_uv_1_0) - bi_r0) * Frac_cc1_FIX7, 7) + bi_r0

                        bi_g0 = _Green32(T2_uv_0_0)
                        bi_g0 = _ShR((_Green32(T2_uv_1_0) - bi_g0) * Frac_cc1_FIX7, 7) + bi_g0

                        bi_b0 = _Blue32(T2_uv_0_0)
                        bi_b0 = _ShR((_Blue32(T2_uv_1_0) - bi_b0) * Frac_cc1_FIX7, 7) + bi_b0

                        bi_r1 = _Red32(T2_uv_0_1)
                        bi_r1 = _ShR((_Red32(T2_uv_1_1) - bi_r1) * Frac_cc1_FIX7, 7) + bi_r1
                        r2 = _ShR((bi_r1 - bi_r0) * Frac_rr1_FIX7, 7) + bi_r0

                        bi_g1 = _Green32(T2_uv_0_1)
                        bi_g1 = _ShR((_Green32(T2_uv_1_1) - bi_g1) * Frac_cc1_FIX7, 7) + bi_g1
                        g2 = _ShR((bi_g1 - bi_g0) * Frac_rr1_FIX7, 7) + bi_g0

                        bi_b1 = _Blue32(T2_uv_0_1)
                        bi_b1 = _ShR((_Blue32(T2_uv_1_1) - bi_b1) * Frac_cc1_FIX7, 7) + bi_b1
                        b2 = _ShR((bi_b1 - bi_b0) * Frac_rr1_FIX7, 7) + bi_b0

                        ' determine T2 Alpha channel
                        If Texture_options And T2_option_alpha_channel Then
                            bi_a0 = _Alpha32(T2_uv_0_0)
                            bi_a0 = _ShR((_Alpha32(T2_uv_1_0) - bi_a0) * Frac_cc1_FIX7, 7) + bi_a0

                            bi_a1 = _Alpha32(T2_uv_0_1)
                            bi_a1 = _ShR((_Alpha32(T2_uv_1_1) - bi_a1) * Frac_cc1_FIX7, 7) + bi_a1
                            a2 = _ShR((bi_a1 - bi_a0) * Frac_rr1_FIX7, 7) + bi_a0
                        Else
                            a2 = 255 ' solid
                        End If
                    End If

                    '
                    ' Texture 1
                    '
                    ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                    cm5 = (tex_u * tex_z * LOD_coord_scale1) - 0.5
                    rm5 = (tex_v * tex_z * LOD_coord_scale1) - 0.5

                    If Texture_options And T1_option_clamp_width Then
                        ' clamp
                        If cm5 < 0.0 Then cm5 = 0.0
                        If cm5 >= T1_width_MASK Then
                            ' 15.0 and up
                            cc = T1_width_MASK
                            ccp = T1_width_MASK
                        Else
                            ' 0 1 2 .. 13 14.999
                            cc = Int(cm5)
                            ccp = cc + 1
                        End If
                    Else
                        ' tile the texture
                        cc = Int(cm5) And T1_width_MASK
                        ccp = (cc + 1) And T1_width_MASK
                    End If

                    If Texture_options And T1_option_clamp_height Then
                        ' clamp
                        If rm5 < 0.0 Then rm5 = 0.0
                        If rm5 >= T1_height_MASK Then
                            ' 15.0 and up
                            rr = T1_height_MASK
                            rrp = T1_height_MASK
                        Else
                            rr = Int(rm5)
                            rrp = rr + 1
                        End If
                    Else
                        ' tile
                        rr = Int(rm5) And T1_height_MASK
                        rrp = (rr + 1) And T1_height_MASK
                    End If

                    Frac_cc1_FIX7 = (cm5 - Int(cm5)) * 128
                    Frac_rr1_FIX7 = (rm5 - Int(rm5)) * 128

                    ' caching of 4 texels
                    Static T1_this_cache As _Unsigned Long
                    Static T1_uv_0_0 As Long
                    Static T1_uv_1_0 As Long
                    Static T1_uv_0_1 As Long
                    Static T1_uv_1_1 As Long

                    T1_total_fetch_attempts = T1_total_fetch_attempts + 1
                    T1_cache_miss_event = 1

                    T1_this_cache = _ShL(LOD_tile1, 24) Or _ShL(rr, 12) Or cc
                    If T1_this_cache <> T1_last_cache Then
                        _MemGet T1_mblock, T1_mblock.OFFSET + (cc + rr * T1_width) * 4, T1_uv_0_0
                        _MemGet T1_mblock, T1_mblock.OFFSET + (ccp + rr * T1_width) * 4, T1_uv_1_0
                        _MemGet T1_mblock, T1_mblock.OFFSET + (cc + rrp * T1_width) * 4, T1_uv_0_1
                        _MemGet T1_mblock, T1_mblock.OFFSET + (ccp + rrp * T1_width) * 4, T1_uv_1_1

                        T1_last_cache = T1_this_cache
                        T1_cache_miss_count = T1_cache_miss_count + 1
                        T1_cache_miss_event = 2
                    End If

                    ' determine T1 RGB colors
                    bi_r0 = _Red32(T1_uv_0_0)
                    bi_r0 = _ShR((_Red32(T1_uv_1_0) - bi_r0) * Frac_cc1_FIX7, 7) + bi_r0

                    bi_g0 = _Green32(T1_uv_0_0)
                    bi_g0 = _ShR((_Green32(T1_uv_1_0) - bi_g0) * Frac_cc1_FIX7, 7) + bi_g0

                    bi_b0 = _Blue32(T1_uv_0_0)
                    bi_b0 = _ShR((_Blue32(T1_uv_1_0) - bi_b0) * Frac_cc1_FIX7, 7) + bi_b0

                    bi_r1 = _Red32(T1_uv_0_1)
                    bi_r1 = _ShR((_Red32(T1_uv_1_1) - bi_r1) * Frac_cc1_FIX7, 7) + bi_r1
                    r1 = _ShR((bi_r1 - bi_r0) * Frac_rr1_FIX7, 7) + bi_r0

                    bi_g1 = _Green32(T1_uv_0_1)
                    bi_g1 = _ShR((_Green32(T1_uv_1_1) - bi_g1) * Frac_cc1_FIX7, 7) + bi_g1
                    g1 = _ShR((bi_g1 - bi_g0) * Frac_rr1_FIX7, 7) + bi_g0

                    bi_b1 = _Blue32(T1_uv_0_1)
                    bi_b1 = _ShR((_Blue32(T1_uv_1_1) - bi_b1) * Frac_cc1_FIX7, 7) + bi_b1
                    b1 = _ShR((bi_b1 - bi_b0) * Frac_rr1_FIX7, 7) + bi_b0

                    ' determine T1 Alpha channel
                    If Texture_options And T1_option_alpha_channel Then
                        bi_a0 = _Alpha32(T1_uv_0_0)
                        bi_a0 = _ShR((_Alpha32(T1_uv_1_0) - bi_a0) * Frac_cc1_FIX7, 7) + bi_a0

                        bi_a1 = _Alpha32(T1_uv_0_1)
                        bi_a1 = _ShR((_Alpha32(T1_uv_1_1) - bi_a1) * Frac_cc1_FIX7, 7) + bi_a1
                        a1 = _ShR((bi_a1 - bi_a0) * Frac_rr1_FIX7, 7) + bi_a0
                    Else
                        a1 = 255 ' solid
                    End If


                    '
                    ' Texture 3
                    '
                    If LOD_tile3 <> LOD_tile1 Then
                        If TLMMI_Variant = 0 Then
                            cm5 = (tex_u * tex_z * LOD_coord_scale3) - 0.5
                            rm5 = (tex_v * tex_z * LOD_coord_scale3) - 0.5
                        Else
                            cm5 = (tex_u * tex_z * LOD_coord_scale3)
                            rm5 = (tex_v * tex_z * LOD_coord_scale3)
                        End If

                        If Texture_options And T1_option_clamp_width Then
                            ' clamp
                            If cm5 < 0.0 Then cm5 = 0.0
                            If cm5 >= T3_width_MASK Then
                                ' 15.0 and up
                                cc = T3_width_MASK
                                ccp = T3_width_MASK
                            Else
                                ' 0 1 2 .. 13 14.999
                                cc = Int(cm5)
                                ccp = cc + 1
                            End If
                        Else
                            ' tile the texture
                            cc = Int(cm5) And T3_width_MASK
                            ccp = (cc + 1) And T3_width_MASK
                        End If

                        If Texture_options And T1_option_clamp_height Then
                            ' clamp
                            If rm5 < 0.0 Then rm5 = 0.0
                            If rm5 >= T3_height_MASK Then
                                ' 15.0 and up
                                rr = T3_height_MASK
                                rrp = T3_height_MASK
                            Else
                                rr = Int(rm5)
                                rrp = rr + 1
                            End If
                        Else
                            ' tile
                            rr = Int(rm5) And T3_height_MASK
                            rrp = (rr + 1) And T3_height_MASK
                        End If

                        If TLMMI_Variant = 0 Then
                            Frac_cc1_FIX7 = (cm5 - Int(cm5)) * 128
                            Frac_rr1_FIX7 = (rm5 - Int(rm5)) * 128

                            ' caching of 4 texels
                            Static T3_this_cache As _Unsigned Long
                            Static T3_uv_0_0 As Long
                            Static T3_uv_1_0 As Long
                            Static T3_uv_0_1 As Long
                            Static T3_uv_1_1 As Long

                            T3_total_fetch_attempts = T3_total_fetch_attempts + 1
                            T3_cache_miss_event = 1

                            T3_this_cache = _ShL(LOD_tile3, 24) Or _ShL(rr, 12) Or cc
                            If T3_this_cache <> T3_last_cache Then
                                _MemGet T3_mblock, T3_mblock.OFFSET + (cc + rr * T3_width) * 4, T3_uv_0_0
                                _MemGet T3_mblock, T3_mblock.OFFSET + (ccp + rr * T3_width) * 4, T3_uv_1_0
                                _MemGet T3_mblock, T3_mblock.OFFSET + (cc + rrp * T3_width) * 4, T3_uv_0_1
                                _MemGet T3_mblock, T3_mblock.OFFSET + (ccp + rrp * T3_width) * 4, T3_uv_1_1

                                T3_last_cache = T3_this_cache
                                T3_cache_miss_count = T3_cache_miss_count + 1
                                T3_cache_miss_event = 2
                            End If

                            ' determine T3 RGB colors
                            bi_r0 = _Red32(T3_uv_0_0)
                            bi_r0 = _ShR((_Red32(T3_uv_1_0) - bi_r0) * Frac_cc1_FIX7, 7) + bi_r0

                            bi_g0 = _Green32(T3_uv_0_0)
                            bi_g0 = _ShR((_Green32(T3_uv_1_0) - bi_g0) * Frac_cc1_FIX7, 7) + bi_g0

                            bi_b0 = _Blue32(T3_uv_0_0)
                            bi_b0 = _ShR((_Blue32(T3_uv_1_0) - bi_b0) * Frac_cc1_FIX7, 7) + bi_b0

                            ' note that the LOD_fraction blends the existing (r1 g1 b1) colors from T1 with T3
                            bi_r1 = _Red32(T3_uv_0_1)
                            bi_r1 = _ShR((_Red32(T3_uv_1_1) - bi_r1) * Frac_cc1_FIX7, 7) + bi_r1
                            r3 = _ShR((bi_r1 - bi_r0) * Frac_rr1_FIX7, 7) + bi_r0

                            bi_g1 = _Green32(T3_uv_0_1)
                            bi_g1 = _ShR((_Green32(T3_uv_1_1) - bi_g1) * Frac_cc1_FIX7, 7) + bi_g1
                            g3 = _ShR((bi_g1 - bi_g0) * Frac_rr1_FIX7, 7) + bi_g0

                            bi_b1 = _Blue32(T3_uv_0_1)
                            bi_b1 = _ShR((_Blue32(T3_uv_1_1) - bi_b1) * Frac_cc1_FIX7, 7) + bi_b1
                            b3 = _ShR((bi_b1 - bi_b0) * Frac_rr1_FIX7, 7) + bi_b0

                            r1 = (r3 - r1) * LOD_fraction + r1
                            g1 = (g3 - g1) * LOD_fraction + g1
                            b1 = (b3 - b1) * LOD_fraction + b1

                            If Texture_options And T1_option_alpha_channel Then
                                ' determine T3 Alpha channel (same as T1 option)
                                bi_a0 = _Alpha32(T3_uv_0_0)
                                bi_a0 = _ShR((_Alpha32(T3_uv_1_0) - bi_a0) * Frac_cc1_FIX7, 7) + bi_a0

                                bi_a1 = _Alpha32(T3_uv_0_1)
                                bi_a1 = _ShR((_Alpha32(T3_uv_1_1) - bi_a1) * Frac_cc1_FIX7, 7) + bi_a1

                                a3 = _ShR((bi_a1 - bi_a0) * Frac_rr1_FIX7, 7) + bi_a0
                                a1 = (a3 - a1) * LOD_fraction + a1
                            End If

                        Else
                            ' point sampling of T3
                            _MemGet T3_mblock, T3_mblock.OFFSET + (cc + rr * T3_width) * 4, T3_uv_0_0
                            r1 = (_Red32(T3_uv_0_0) - r1) * LOD_fraction + r1
                            g1 = (_Green32(T3_uv_0_0) - g1) * LOD_fraction + g1
                            b1 = (_Blue32(T3_uv_0_0) - b1) * LOD_fraction + b1

                            ' Alpha channel T3
                            If Texture_options And T1_option_alpha_channel Then
                                a1 = (_Alpha32(T3_uv_0_0) - a1) * LOD_fraction + a1
                            End If

                        End If ' TLMMI_Variant

                    End If ' Texture 3


                    ' Color Combiner RGB Channels
                    ' Template CC Equation is: (Source2 - Source1) * Scale + Offset
                    ' Typical accelerator hardware lets you select each of these 4 vars from a small mux list.
                    ' for example Source1 could be 0, 1, fixed color, vertex color, or texture color, etc.
                    ' I chose not to do that muxing here but just be aware that is how it was accomplished.

                    If a1 > 0 Then

                        If tex_z >= Fog_far Then
                            ' use table fog (pixel fog) color
                            pixel_value = Fog_color
                        Else
                            '
                            ' Stage 1 - Texture
                            '

                            ' Alpha channel of T2 determines contribution of T2 color versus T1 color.
                            Static T2_weight As Single
                            T2_weight = a2 * oneOver255

                            If Texture_options And T2_option_color_sum Then
                                ' color addition. Please see explanation above about Color Combiner Equation.
                                ' notice here how "Source1" is 0 instead of the texture 1 RGB color for interpolate.
                                r0 = (r2 - 0) * T2_weight + r1
                                g0 = (g2 - 0) * T2_weight + g1
                                b0 = (b2 - 0) * T2_weight + b1
                            Else
                                ' decal
                                ' color blend T2 with T1 based on T2 alpha channel. Please see explanation above for Color Combiner Equation.
                                r0 = (r2 - r1) * T2_weight + r1
                                g0 = (g2 - g1) * T2_weight + g1
                                b0 = (b2 - b1) * T2_weight + b1
                            End If

                            '
                            ' Stage 2 - Color Combiner Lighting
                            '
                            r0 = (tex_r + r0) * CC_mod_red
                            g0 = (tex_g + g0) * CC_mod_green
                            b0 = (tex_b + b0) * CC_mod_blue

                            If tex_z <= Fog_near Then
                                ' apply no fog
                                pixel_value = _RGB32(r0, g0, b0)
                            Else
                                ' fog linear gradient
                                Static fog_scale As Single
                                fog_scale = (tex_z - Fog_near) * Fog_rate
                                pixel_value = _RGB32((Fog_R - r0) * fog_scale + r0, (Fog_G - g0) * fog_scale + g0, (Fog_B - b0) * fog_scale + b0)
                            End If
                        End If ' fog_far

                        If a1 < 255 Then
                            ' Alpha blend
                            Static pixel_existing As _Unsigned Long
                            Static pixel_alpha As Single
                            pixel_alpha = a1 * oneOver255
                            pixel_existing = _MemGet(screen_mem_info, screen_address, _Unsigned Long)

                            pixel_value = _RGB32((  _red32(pixel_value) -  _Red32(pixel_existing))  * pixel_alpha +   _red32(pixel_existing), _
                                                 (_green32(pixel_value) - _Green32(pixel_existing)) * pixel_alpha + _green32(pixel_existing), _
                                                 ( _Blue32(pixel_value) - _Blue32(pixel_existing))  * pixel_alpha +  _blue32(pixel_existing))

                            ' x = (p1 - p0) * ratio + p0 is equivalent to
                            ' x = (1.0 - ratio) * p0 + ratio * p1
                        End If

                        ' Update the Z-Buffer, with a small bias
                        ' The simplest way to describe threshold is how potentially noticable do you want a ghosting/glowing halo around the solid parts.
                        ' Best value is entirely dependent upon the alpha (transparency) channel ranges in the source texture and the colors involved.
                        If a1 >= T1_Alpha_Threshold Then Screen_Z_Buffer(zbuf_index) = tex_z + Z_Fight_Bias

                        If Toggle_Cache_FalseColor Then
                            If T1_cache_miss_event = 1 Then
                                ' metrics bright yellow cache hit
                                pixel_value = _RGB32(255, 255, 0)
                            ElseIf T3_cache_miss_event = 1 Then
                                ' metrics bright blue cache hit
                                pixel_value = _RGB32(100, 100, 255)
                            End If
                        End If

                        'PSet (col, row), pixel_value
                        _MemPut screen_mem_info, screen_address, pixel_value
                    End If ' a1

                End If ' tex_z

                If LOD_max > 0 Then
                    LOD_next_w = LOD_next_w + LOD_slope_w
                    LOD_next_z = 1 / LOD_next_w ' start the division early. You still must iterate w, not z.
                    LOD_next_uoz = LOD_next_uoz + LOD_slope_u
                    LOD_next_voz = LOD_next_voz + LOD_slope_v
                End If

                zbuf_index = zbuf_index + 1
                tex_w = tex_w + tex_w_step
                tex_z = 1 / tex_w

                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                tex_r = tex_r + tex_r_step
                tex_g = tex_g + tex_g_step
                tex_b = tex_b + tex_b_step
                tex_s = tex_s + tex_s_step
                tex_t = tex_t + tex_t_step
                screen_address = screen_address + 4

                col = col + 1
            Wend ' col

        End If ' end div/0 avoidance

        ' DDA next step
        leg_x1 = leg_x1 + legx1_step
        leg_w1 = leg_w1 + legw1_step
        leg_u1 = leg_u1 + legu1_step
        leg_v1 = leg_v1 + legv1_step
        leg_r1 = leg_r1 + legr1_step
        leg_g1 = leg_g1 + legg1_step
        leg_b1 = leg_b1 + legb1_step
        leg_s1 = leg_s1 + legs1_step
        leg_t1 = leg_t1 + legt1_step

        leg_x2 = leg_x2 + legx2_step
        leg_w2 = leg_w2 + legw2_step
        leg_u2 = leg_u2 + legu2_step
        leg_v2 = leg_v2 + legv2_step
        leg_r2 = leg_r2 + legr2_step
        leg_g2 = leg_g2 + legg2_step
        leg_b2 = leg_b2 + legb2_step
        leg_s2 = leg_s2 + legs2_step
        leg_t2 = leg_t2 + legt2_step

        screen_row_base = screen_row_base + screen_next_row_step
        row = row + 1
    Wend ' row

End Sub


Sub TexturedNonlitTriangle (A As vertex10, B As vertex10, C As vertex10)
    ' this is a reduced copy for skybox drawing
    ' Texture_options is ignored
    Static delta2 As vertex5
    Static delta1 As vertex5
    Static draw_min_y As Long, draw_max_y As Long

    ' Sort so that vertex A is on top and C is on bottom.
    ' This seems inverted from math class, but remember that Y increases in value downward on PC monitors
    If B.y < A.y Then
        Swap A, B
    End If
    If C.y < A.y Then
        Swap A, C
    End If
    If C.y < B.y Then
        Swap B, C
    End If

    ' integer window clipping
    draw_min_y = _Ceil(A.y)
    If draw_min_y < clip_min_y Then draw_min_y = clip_min_y
    draw_max_y = _Ceil(C.y) - 1
    If draw_max_y > clip_max_y Then draw_max_y = clip_max_y
    If (draw_max_y - draw_min_y) < 0 Then Exit Sub

    ' Determine the deltas (lengths)
    ' delta 2 is from A to C (the full triangle height)
    delta2.x = C.x - A.x
    delta2.y = C.y - A.y
    delta2.w = C.w - A.w
    delta2.u = C.u - A.u
    delta2.v = C.v - A.v

    ' Avoiding div by 0
    ' Entire Y height less than 1/256 would not have meaningful pixel color change
    If delta2.y < (1 / 256) Then Exit Sub

    ' Determine vertical Y steps for DDA style math
    ' DDA is Digital Differential Analyzer
    ' It is an accumulator that counts from a known start point to an end point, in equal increments defined by the number of steps in-between.
    ' Probably faster nowadays to do the one division at the start, instead of Bresenham, anyway.
    Static legx1_step As Single
    Static legw1_step As Single, legu1_step As Single, legv1_step As Single

    Static legx2_step As Single
    Static legw2_step As Single, legu2_step As Single, legv2_step As Single

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y

    ' Leg 1, Draw top to middle
    ' For most triangles, draw downward from the apex A to a knee B.
    ' That knee could be on either the left or right side, but that is handled much later.
    Static draw_middle_y As Long
    draw_middle_y = _Ceil(B.y)
    If draw_middle_y < clip_min_y Then draw_middle_y = clip_min_y
    ' Do not clip B to max_y. Let the y count expire before reaching the knee if it is past bottom of screen.

    ' Leg 1 is from A to B (right now)
    delta1.x = B.x - A.x
    delta1.y = B.y - A.y
    delta1.w = B.w - A.w
    delta1.u = B.u - A.u
    delta1.v = B.v - A.v

    ' If the triangle has no knee, this section gets skipped to avoid divide by 0.
    ' That is okay, because the recalculate Leg 1 from B to C triggers before actually drawing.
    If delta1.y > (1 / 256) Then
        ' Find Leg 1 steps in the y direction from A to B
        legx1_step = delta1.x / delta1.y
        legw1_step = delta1.w / delta1.y
        legu1_step = delta1.u / delta1.y
        legv1_step = delta1.v / delta1.y
    End If

    ' Y Accumulators
    Static leg_x1 As Single
    Static leg_w1 As Single, leg_u1 As Single, leg_v1 As Single

    Static leg_x2 As Single
    Static leg_w2 As Single, leg_u2 As Single, leg_v2 As Single

    ' 11-4-2022 Prestep Y
    Static prestep_y1 As Single
    ' Basically we are sampling pixels on integer exact rows.
    ' But we only are able to know the next row by way of forward interpolation. So always round up.
    ' To get to that next row, we have to prestep by the fractional forward distance from A. _Ceil(A.y) - A.y
    prestep_y1 = draw_min_y - A.y

    leg_x1 = A.x + prestep_y1 * legx1_step
    leg_w1 = A.w + prestep_y1 * legw1_step
    leg_u1 = A.u + prestep_y1 * legu1_step
    leg_v1 = A.v + prestep_y1 * legv1_step

    leg_x2 = A.x + prestep_y1 * legx2_step
    leg_w2 = A.w + prestep_y1 * legw2_step
    leg_u2 = A.u + prestep_y1 * legu2_step
    leg_v2 = A.v + prestep_y1 * legv2_step

    ' Inner loop vars
    Static row As Long
    Static col As Long
    Static draw_max_x As Long
    Static tex_z As Single ' 1/w helper (multiply by inverse is faster than dividing each time)
    Static pixel_value As _Unsigned Long ' The ARGB value to write to screen

    ' Stepping along the X direction
    Static delta_x As Single
    Static prestep_x As Single
    Static tex_w_step As Single, tex_u_step As Single, tex_v_step As Single

    ' X Accumulators
    Static tex_w As Single, tex_u As Single, tex_v As Single

    ' Screen Memory Pointers
    Static screen_mem_info As _MEM
    Static screen_next_row_step As _Offset
    Static screen_row_base As _Offset ' Calculated every row
    Static screen_address As _Offset ' Calculated at every starting column
    screen_mem_info = _MemImage(WORK_IMAGE)
    screen_next_row_step = 4 * Size_Render_X

    ' caching of 4 texels in bilinear mode
    Static T1_last_cache As _Unsigned Long
    T1_last_cache = &HFFFFFFFF ' invalidate

    ' Row Loop from top to bottom
    row = draw_min_y
    screen_row_base = screen_mem_info.OFFSET + row * screen_next_row_step
    While row <= draw_max_y

        If row = draw_middle_y Then
            ' Reached Leg 1 knee at B, recalculate Leg 1.
            ' This overwrites Leg 1 to be from B to C. Leg 2 just keeps continuing from A to C.
            delta1.x = C.x - B.x
            delta1.y = C.y - B.y
            delta1.w = C.w - B.w
            delta1.u = C.u - B.u
            delta1.v = C.v - B.v

            If delta1.y = 0.0 Then Exit Sub

            ' Full steps in the y direction from B to C
            legx1_step = delta1.x / delta1.y
            legw1_step = delta1.w / delta1.y
            legu1_step = delta1.u / delta1.y
            legv1_step = delta1.v / delta1.y

            ' 11-4-2022 Prestep Y
            ' Most cases has B lower downscreen than A.
            ' B > A usually. Only one case where B = A.
            prestep_y1 = draw_middle_y - B.y

            ' Re-Initialize DDA start values
            leg_x1 = B.x + prestep_y1 * legx1_step
            leg_w1 = B.w + prestep_y1 * legw1_step
            leg_u1 = B.u + prestep_y1 * legu1_step
            leg_v1 = B.v + prestep_y1 * legv1_step

        End If

        ' Horizontal Scanline
        delta_x = Abs(leg_x2 - leg_x1)
        ' Avoid div/0, this gets tiring.
        If delta_x >= (1 / 2048) Then
            ' Calculate step, start, and end values.
            ' Drawing left to right, as in incrementing from a lower to higher memory address, is usually fastest.
            If leg_x1 < leg_x2 Then
                ' leg 1 is on the left
                tex_w_step = (leg_w2 - leg_w1) / delta_x
                tex_u_step = (leg_u2 - leg_u1) / delta_x
                tex_v_step = (leg_v2 - leg_v1) / delta_x

                ' Set the horizontal starting point to (1)
                col = _Ceil(leg_x1)
                If col < clip_min_x Then col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x1
                tex_w = leg_w1 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u1 + prestep_x * tex_u_step
                tex_v = leg_v1 + prestep_x * tex_v_step

                ' ending point is (2)
                draw_max_x = _Ceil(leg_x2)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            Else
                ' Things are flipped. leg 1 is on the right.
                tex_w_step = (leg_w1 - leg_w2) / delta_x
                tex_u_step = (leg_u1 - leg_u2) / delta_x
                tex_v_step = (leg_v1 - leg_v2) / delta_x

                ' Set the horizontal starting point to (2)
                col = _Ceil(leg_x2)
                If col < clip_min_x Then col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x2
                tex_w = leg_w2 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step

                ' ending point is (1)
                draw_max_x = _Ceil(leg_x1)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            End If

            ' Draw the Horizontal Scanline
            ' Optimization: before entering this loop, must have done tex_z = 1 / tex_w
            ' Relies on some shared T1 variables over by Texture1
            screen_address = screen_row_base + 4 * col
            While col < draw_max_x

                Static cc As _Unsigned Integer
                Static ccp As _Unsigned Integer
                Static rr As _Unsigned Integer
                Static rrp As _Unsigned Integer

                Static cm5 As Single
                Static rm5 As Single

                ' Recover U and V
                ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                cm5 = (tex_u * tex_z) - 0.5
                rm5 = (tex_v * tex_z) - 0.5

                ' clamp
                If cm5 < 0.0 Then cm5 = 0.0
                If cm5 >= T1_width_MASK Then
                    ' 15.0 and up
                    cc = T1_width_MASK
                    ccp = T1_width_MASK
                Else
                    ' 0 1 2 .. 13 14.999
                    cc = Int(cm5)
                    ccp = cc + 1
                End If

                ' clamp
                If rm5 < 0.0 Then rm5 = 0.0
                If rm5 >= T1_height_MASK Then
                    ' 15.0 and up
                    rr = T1_height_MASK
                    rrp = T1_height_MASK
                Else
                    rr = Int(rm5)
                    rrp = rr + 1
                End If

                ' 4 point bilinear temp vars
                Static Frac_cc1_FIX7 As Integer
                Static Frac_rr1_FIX7 As Integer
                ' 0 1
                ' . .
                Static bi_r0 As Integer
                Static bi_g0 As Integer
                Static bi_b0 As Integer
                ' . .
                ' 2 3
                Static bi_r1 As Integer
                Static bi_g1 As Integer
                Static bi_b1 As Integer

                Frac_cc1_FIX7 = (cm5 - Int(cm5)) * 128
                Frac_rr1_FIX7 = (rm5 - Int(rm5)) * 128

                ' Caching of 4 texels
                Static T1_this_cache As _Unsigned Long
                Static T1_uv_0_0 As Long
                Static T1_uv_1_0 As Long
                Static T1_uv_0_1 As Long
                Static T1_uv_1_1 As Long

                T1_this_cache = _ShL(rr, 12) Or cc
                If T1_this_cache <> T1_last_cache Then

                    _MemGet T1_mblock, T1_mblock.OFFSET + (cc + rr * T1_width) * 4, T1_uv_0_0
                    _MemGet T1_mblock, T1_mblock.OFFSET + (ccp + rr * T1_width) * 4, T1_uv_1_0
                    _MemGet T1_mblock, T1_mblock.OFFSET + (cc + rrp * T1_width) * 4, T1_uv_0_1
                    _MemGet T1_mblock, T1_mblock.OFFSET + (ccp + rrp * T1_width) * 4, T1_uv_1_1

                    T1_last_cache = T1_this_cache
                End If

                ' determine T1 RGB colors
                bi_r0 = _Red32(T1_uv_0_0)
                bi_r0 = _ShR((_Red32(T1_uv_1_0) - bi_r0) * Frac_cc1_FIX7, 7) + bi_r0

                bi_g0 = _Green32(T1_uv_0_0)
                bi_g0 = _ShR((_Green32(T1_uv_1_0) - bi_g0) * Frac_cc1_FIX7, 7) + bi_g0

                bi_b0 = _Blue32(T1_uv_0_0)
                bi_b0 = _ShR((_Blue32(T1_uv_1_0) - bi_b0) * Frac_cc1_FIX7, 7) + bi_b0

                bi_r1 = _Red32(T1_uv_0_1)
                bi_r1 = _ShR((_Red32(T1_uv_1_1) - bi_r1) * Frac_cc1_FIX7, 7) + bi_r1

                bi_g1 = _Green32(T1_uv_0_1)
                bi_g1 = _ShR((_Green32(T1_uv_1_1) - bi_g1) * Frac_cc1_FIX7, 7) + bi_g1

                bi_b1 = _Blue32(T1_uv_0_1)
                bi_b1 = _ShR((_Blue32(T1_uv_1_1) - bi_b1) * Frac_cc1_FIX7, 7) + bi_b1

                pixel_value = _RGB32(_ShR((bi_r1 - bi_r0) * Frac_rr1_FIX7, 7) + bi_r0, _ShR((bi_g1 - bi_g0) * Frac_rr1_FIX7, 7) + bi_g0, _ShR((bi_b1 - bi_b0) * Frac_rr1_FIX7, 7) + bi_b0)
                _MemPut screen_mem_info, screen_address, pixel_value
                'PSet (col, row), pixel_value

                tex_w = tex_w + tex_w_step
                tex_z = 1 / tex_w ' execution time for this can be absorbed when result not required immediately
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                screen_address = screen_address + 4
                col = col + 1
            Wend ' col

        End If ' end div/0 avoidance

        ' DDA next step
        leg_x1 = leg_x1 + legx1_step
        leg_w1 = leg_w1 + legw1_step
        leg_u1 = leg_u1 + legu1_step
        leg_v1 = leg_v1 + legv1_step

        leg_x2 = leg_x2 + legx2_step
        leg_w2 = leg_w2 + legw2_step
        leg_u2 = leg_u2 + legu2_step
        leg_v2 = leg_v2 + legv2_step

        screen_row_base = screen_row_base + screen_next_row_step
        row = row + 1
    Wend ' row

End Sub

Sub TexturedNonlitAlphaTriangle (A As vertex10, B As vertex10, C As vertex10)
    ' this is a reduced copy for particle effect drawing
    ' Texture_options is ignored
    Static delta2 As vertex5
    Static delta1 As vertex5
    Static draw_min_y As Long, draw_max_y As Long

    ' Sort so that vertex A is on top and C is on bottom.
    ' This seems inverted from math class, but remember that Y increases in value downward on PC monitors
    If B.y < A.y Then
        Swap A, B
    End If
    If C.y < A.y Then
        Swap A, C
    End If
    If C.y < B.y Then
        Swap B, C
    End If

    ' integer window clipping
    draw_min_y = _Ceil(A.y)
    If draw_min_y < clip_min_y Then draw_min_y = clip_min_y
    draw_max_y = _Ceil(C.y) - 1
    If draw_max_y > clip_max_y Then draw_max_y = clip_max_y
    If (draw_max_y - draw_min_y) < 0 Then Exit Sub

    ' Determine the deltas (lengths)
    ' delta 2 is from A to C (the full triangle height)
    delta2.x = C.x - A.x
    delta2.y = C.y - A.y
    delta2.w = C.w - A.w
    delta2.u = C.u - A.u
    delta2.v = C.v - A.v

    ' Avoiding div by 0
    ' Entire Y height less than 1/256 would not have meaningful pixel color change
    If delta2.y < (1 / 256) Then Exit Sub

    ' Determine vertical Y steps for DDA style math
    ' DDA is Digital Differential Analyzer
    ' It is an accumulator that counts from a known start point to an end point, in equal increments defined by the number of steps in-between.
    ' Probably faster nowadays to do the one division at the start, instead of Bresenham, anyway.
    Static legx1_step As Single
    Static legw1_step As Single, legu1_step As Single, legv1_step As Single

    Static legx2_step As Single
    Static legw2_step As Single, legu2_step As Single, legv2_step As Single

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y

    ' Leg 1, Draw top to middle
    ' For most triangles, draw downward from the apex A to a knee B.
    ' That knee could be on either the left or right side, but that is handled much later.
    Static draw_middle_y As Long
    draw_middle_y = _Ceil(B.y)
    If draw_middle_y < clip_min_y Then draw_middle_y = clip_min_y
    ' Do not clip B to max_y. Let the y count expire before reaching the knee if it is past bottom of screen.

    ' Leg 1 is from A to B (right now)
    delta1.x = B.x - A.x
    delta1.y = B.y - A.y
    delta1.w = B.w - A.w
    delta1.u = B.u - A.u
    delta1.v = B.v - A.v

    ' If the triangle has no knee, this section gets skipped to avoid divide by 0.
    ' That is okay, because the recalculate Leg 1 from B to C triggers before actually drawing.
    If delta1.y > (1 / 256) Then
        ' Find Leg 1 steps in the y direction from A to B
        legx1_step = delta1.x / delta1.y
        legw1_step = delta1.w / delta1.y
        legu1_step = delta1.u / delta1.y
        legv1_step = delta1.v / delta1.y
    End If

    ' Y Accumulators
    Static leg_x1 As Single
    Static leg_w1 As Single, leg_u1 As Single, leg_v1 As Single

    Static leg_x2 As Single
    Static leg_w2 As Single, leg_u2 As Single, leg_v2 As Single

    ' 11-4-2022 Prestep Y
    Static prestep_y1 As Single
    ' Basically we are sampling pixels on integer exact rows.
    ' But we only are able to know the next row by way of forward interpolation. So always round up.
    ' To get to that next row, we have to prestep by the fractional forward distance from A. _Ceil(A.y) - A.y
    prestep_y1 = draw_min_y - A.y

    leg_x1 = A.x + prestep_y1 * legx1_step
    leg_w1 = A.w + prestep_y1 * legw1_step
    leg_u1 = A.u + prestep_y1 * legu1_step
    leg_v1 = A.v + prestep_y1 * legv1_step

    leg_x2 = A.x + prestep_y1 * legx2_step
    leg_w2 = A.w + prestep_y1 * legw2_step
    leg_u2 = A.u + prestep_y1 * legu2_step
    leg_v2 = A.v + prestep_y1 * legv2_step

    ' Inner loop vars
    Static row As Long
    Static col As Long
    Static draw_max_x As Long
    Static tex_z As Single ' 1/w helper (multiply by inverse is faster than dividing each time)
    Static pixel_value As _Unsigned Long ' The ARGB value to write to screen

    ' Stepping along the X direction
    Static delta_x As Single
    Static prestep_x As Single
    Static tex_w_step As Single, tex_u_step As Single, tex_v_step As Single

    ' X Accumulators
    Static tex_w As Single, tex_u As Single, tex_v As Single

    ' Screen Memory Pointers
    Static screen_mem_info As _MEM
    Static screen_next_row_step As _Offset
    Static screen_row_base As _Offset ' Calculated every row
    Static screen_address As _Offset ' Calculated at every starting column
    screen_mem_info = _MemImage(WORK_IMAGE)
    screen_next_row_step = 4 * Size_Render_X

    ' caching of 4 texels in bilinear mode
    Static T1_last_cache As _Unsigned Long
    T1_last_cache = &HFFFFFFFF ' invalidate

    ' Row Loop from top to bottom
    row = draw_min_y
    screen_row_base = screen_mem_info.OFFSET + row * screen_next_row_step
    While row <= draw_max_y

        If row = draw_middle_y Then
            ' Reached Leg 1 knee at B, recalculate Leg 1.
            ' This overwrites Leg 1 to be from B to C. Leg 2 just keeps continuing from A to C.
            delta1.x = C.x - B.x
            delta1.y = C.y - B.y
            delta1.w = C.w - B.w
            delta1.u = C.u - B.u
            delta1.v = C.v - B.v

            If delta1.y = 0.0 Then Exit Sub

            ' Full steps in the y direction from B to C
            legx1_step = delta1.x / delta1.y
            legw1_step = delta1.w / delta1.y
            legu1_step = delta1.u / delta1.y
            legv1_step = delta1.v / delta1.y

            ' 11-4-2022 Prestep Y
            ' Most cases has B lower downscreen than A.
            ' B > A usually. Only one case where B = A.
            prestep_y1 = draw_middle_y - B.y

            ' Re-Initialize DDA start values
            leg_x1 = B.x + prestep_y1 * legx1_step
            leg_w1 = B.w + prestep_y1 * legw1_step
            leg_u1 = B.u + prestep_y1 * legu1_step
            leg_v1 = B.v + prestep_y1 * legv1_step

        End If

        ' Horizontal Scanline
        delta_x = Abs(leg_x2 - leg_x1)
        ' Avoid div/0, this gets tiring.
        If delta_x >= (1 / 2048) Then
            ' Calculate step, start, and end values.
            ' Drawing left to right, as in incrementing from a lower to higher memory address, is usually fastest.
            If leg_x1 < leg_x2 Then
                ' leg 1 is on the left
                tex_w_step = (leg_w2 - leg_w1) / delta_x
                tex_u_step = (leg_u2 - leg_u1) / delta_x
                tex_v_step = (leg_v2 - leg_v1) / delta_x

                ' Set the horizontal starting point to (1)
                col = _Ceil(leg_x1)
                If col < clip_min_x Then col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x1
                tex_w = leg_w1 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u1 + prestep_x * tex_u_step
                tex_v = leg_v1 + prestep_x * tex_v_step

                ' ending point is (2)
                draw_max_x = _Ceil(leg_x2)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            Else
                ' Things are flipped. leg 1 is on the right.
                tex_w_step = (leg_w1 - leg_w2) / delta_x
                tex_u_step = (leg_u1 - leg_u2) / delta_x
                tex_v_step = (leg_v1 - leg_v2) / delta_x

                ' Set the horizontal starting point to (2)
                col = _Ceil(leg_x2)
                If col < clip_min_x Then col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x2
                tex_w = leg_w2 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step

                ' ending point is (1)
                draw_max_x = _Ceil(leg_x1)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            End If

            ' Draw the Horizontal Scanline
            ' Optimization: before entering this loop, must have done tex_z = 1 / tex_w
            ' Relies on some shared T1 variables over by Texture1
            screen_address = screen_row_base + 4 * col
            While col < draw_max_x

                Static cc As _Unsigned Integer
                Static ccp As _Unsigned Integer
                Static rr As _Unsigned Integer
                Static rrp As _Unsigned Integer

                Static cm5 As Single
                Static rm5 As Single

                ' Recover U and V
                ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                cm5 = (tex_u * tex_z) - 0.5
                rm5 = (tex_v * tex_z) - 0.5

                ' clamp
                If cm5 < 0.0 Then cm5 = 0.0
                If cm5 >= T1_width_MASK Then
                    ' 15.0 and up
                    cc = T1_width_MASK
                    ccp = T1_width_MASK
                Else
                    ' 0 1 2 .. 13 14.999
                    cc = Int(cm5)
                    ccp = cc + 1
                End If

                ' clamp
                If rm5 < 0.0 Then rm5 = 0.0
                If rm5 >= T1_height_MASK Then
                    ' 15.0 and up
                    rr = T1_height_MASK
                    rrp = T1_height_MASK
                Else
                    rr = Int(rm5)
                    rrp = rr + 1
                End If

                ' 4 point bilinear temp vars
                Static Frac_cc1_FIX7 As Integer
                Static Frac_rr1_FIX7 As Integer
                ' 0 1
                ' . .
                Static bi_r0 As Integer
                Static bi_g0 As Integer
                Static bi_b0 As Integer
                Static bi_a0 As Integer
                ' . .
                ' 2 3
                Static bi_r1 As Integer
                Static bi_g1 As Integer
                Static bi_b1 As Integer
                Static bi_a1 As Integer

                ' color blending
                Static a0 As Integer

                Frac_cc1_FIX7 = (cm5 - Int(cm5)) * 128
                Frac_rr1_FIX7 = (rm5 - Int(rm5)) * 128

                ' Caching of 4 texels
                Static T1_this_cache As _Unsigned Long
                Static T1_uv_0_0 As Long
                Static T1_uv_1_0 As Long
                Static T1_uv_0_1 As Long
                Static T1_uv_1_1 As Long

                T1_this_cache = _ShL(rr, 12) Or cc
                If T1_this_cache <> T1_last_cache Then

                    _MemGet T1_mblock, T1_mblock.OFFSET + (cc + rr * T1_width) * 4, T1_uv_0_0
                    _MemGet T1_mblock, T1_mblock.OFFSET + (ccp + rr * T1_width) * 4, T1_uv_1_0
                    _MemGet T1_mblock, T1_mblock.OFFSET + (cc + rrp * T1_width) * 4, T1_uv_0_1
                    _MemGet T1_mblock, T1_mblock.OFFSET + (ccp + rrp * T1_width) * 4, T1_uv_1_1

                    T1_last_cache = T1_this_cache
                End If

                ' determine Alpha channel
                bi_a0 = _Alpha32(T1_uv_0_0)
                bi_a0 = _ShR((_Alpha32(T1_uv_1_0) - bi_a0) * Frac_cc1_FIX7, 7) + bi_a0

                bi_a1 = _Alpha32(T1_uv_0_1)
                bi_a1 = _ShR((_Alpha32(T1_uv_1_1) - bi_a1) * Frac_cc1_FIX7, 7) + bi_a1

                a0 = _ShR((bi_a1 - bi_a0) * Frac_rr1_FIX7, 7) + bi_a0
                If a0 > 0 Then

                    ' determine T1 RGB colors
                    bi_r0 = _Red32(T1_uv_0_0)
                    bi_r0 = _ShR((_Red32(T1_uv_1_0) - bi_r0) * Frac_cc1_FIX7, 7) + bi_r0

                    bi_g0 = _Green32(T1_uv_0_0)
                    bi_g0 = _ShR((_Green32(T1_uv_1_0) - bi_g0) * Frac_cc1_FIX7, 7) + bi_g0

                    bi_b0 = _Blue32(T1_uv_0_0)
                    bi_b0 = _ShR((_Blue32(T1_uv_1_0) - bi_b0) * Frac_cc1_FIX7, 7) + bi_b0

                    bi_r1 = _Red32(T1_uv_0_1)
                    bi_r1 = _ShR((_Red32(T1_uv_1_1) - bi_r1) * Frac_cc1_FIX7, 7) + bi_r1

                    bi_g1 = _Green32(T1_uv_0_1)
                    bi_g1 = _ShR((_Green32(T1_uv_1_1) - bi_g1) * Frac_cc1_FIX7, 7) + bi_g1

                    bi_b1 = _Blue32(T1_uv_0_1)
                    bi_b1 = _ShR((_Blue32(T1_uv_1_1) - bi_b1) * Frac_cc1_FIX7, 7) + bi_b1

                    pixel_value = _RGB32(_ShR((bi_r1 - bi_r0) * Frac_rr1_FIX7, 7) + bi_r0, _ShR((bi_g1 - bi_g0) * Frac_rr1_FIX7, 7) + bi_g0, _ShR((bi_b1 - bi_b0) * Frac_rr1_FIX7, 7) + bi_b0)


                    If a0 < 255 Then
                        ' Alpha blend
                        Static pixel_existing As _Unsigned Long
                        Static pixel_alpha As Single
                        pixel_alpha = a0 * oneOver255
                        pixel_existing = _MemGet(screen_mem_info, screen_address, _Unsigned Long)

                        pixel_value = _RGB32((  _red32(pixel_value) -  _Red32(pixel_existing))  * pixel_alpha +   _red32(pixel_existing), _
                                             (_green32(pixel_value) - _Green32(pixel_existing)) * pixel_alpha + _green32(pixel_existing), _
                                             ( _Blue32(pixel_value) - _Blue32(pixel_existing))  * pixel_alpha +  _blue32(pixel_existing))
                    End If

                    _MemPut screen_mem_info, screen_address, pixel_value
                    'PSet (col, row), pixel_value
                End If ' a0

                tex_w = tex_w + tex_w_step
                tex_z = 1 / tex_w ' execution time for this can be absorbed when result not required immediately
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                screen_address = screen_address + 4
                col = col + 1
            Wend ' col

        End If ' end div/0 avoidance

        ' DDA next step
        leg_x1 = leg_x1 + legx1_step
        leg_w1 = leg_w1 + legw1_step
        leg_u1 = leg_u1 + legu1_step
        leg_v1 = leg_v1 + legv1_step

        leg_x2 = leg_x2 + legx2_step
        leg_w2 = leg_w2 + legw2_step
        leg_u2 = leg_u2 + legu2_step
        leg_v2 = leg_v2 + legv2_step

        screen_row_base = screen_row_base + screen_next_row_step
        row = row + 1
    Wend ' row

End Sub
