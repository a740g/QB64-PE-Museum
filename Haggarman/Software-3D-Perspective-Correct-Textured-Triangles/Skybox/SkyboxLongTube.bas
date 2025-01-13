Option _Explicit
_Title "Skybox Long Tube"
' 2023 Haggarman
' Since we now have frustum near clipping, we can draw a skybox.
'
' Camera and matrix math code translated from the works of Javidx9 OneLoneCoder.
' Texel interpolation and triangle drawing code by me.
' 3D Triangle code inspired by Youtube: Javidx9, Bisqwit
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
Dim Cube_Count As Integer
Dim Thing_Count As Integer

' MODIFY THESE if you want.
Cube_Count = 12 ' how many cubes are used to make a tube thing
Thing_Count = 100 ' number of tube things
Size_Screen_X = 1024
Size_Screen_Y = 768
Size_Render_X = Size_Screen_X \ 2 ' render size
Size_Render_Y = Size_Screen_Y \ 2

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
    texture As _Unsigned Long
    options As _Unsigned Long
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

Type vertex_attribute5
    u As Single
    v As Single
    r As Single
    g As Single
    b As Single
End Type

' Projection Matrix
Dim Shared Frustum_Near As Single
Dim Shared Frustum_Far As Single
Dim Shared Frustum_FOV_deg As Single
Dim Shared Frustum_Aspect_Ratio As Single
Dim Shared Frustum_FOV_ratio As Single

Frustum_Near = 0.5
Frustum_Far = 1000.0
Frustum_FOV_deg = 100.0
Frustum_Aspect_Ratio = _Height / _Width
Frustum_FOV_ratio = 1.0 / Tan(_D2R(Frustum_FOV_deg * 0.5))

Dim Shared matProj(3, 3) As Single
matProj(0, 0) = Frustum_Aspect_Ratio * Frustum_FOV_ratio
matProj(1, 1) = Frustum_FOV_ratio
matProj(2, 2) = Frustum_Far / (Frustum_Far - Frustum_Near)
matProj(2, 3) = 1.0
matProj(3, 2) = (-Frustum_Far * Frustum_Near) / (Frustum_Far - Frustum_Near)
matProj(3, 3) = 0.0

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
Fog_near = 30.0
Fog_far = 90.0
Fog_rate = 1.0 / (Fog_far - Fog_near)

Fog_color = _RGB32(47, 78, 105)
Fog_R = _Red(Fog_color)
Fog_G = _Green(Fog_color)
Fog_B = _Blue(Fog_color)

' Load textures from file
Dim Shared TextureCatalog_lastIndex As Integer
TextureCatalog_lastIndex = 4
Dim Shared TextureCatalog(TextureCatalog_lastIndex) As Long
TextureCatalog(0) = _LoadImage("Origin16x16.png", 32)
TextureCatalog(1) = _LoadImage("Grass_Block_top.png", 32)
TextureCatalog(2) = _LoadImage("Grass_Block_side.png", 32)
TextureCatalog(3) = _LoadImage("Dirt_Block.png", 32)
TextureCatalog(4) = _LoadImage("Red_Brick.png", 32)

' Error _LoadImage returns -1 as an invalid handle if it cannot load the image.
Dim refIndex As Integer
For refIndex = 0 To TextureCatalog_lastIndex
    If TextureCatalog(refIndex) = -1 Then
        Print "Could not load texture file for index: "; refIndex
        End
    End If
Next refIndex


' These T1 Texture characteristics are read later on during drawing.
Dim Shared T1_ImageHandle As Long
Dim Shared T1_width As Integer, T1_width_MASK As Integer
Dim Shared T1_height As Integer, T1_height_MASK As Integer
Dim Shared T1_Filter_Selection As Integer
Dim Shared T1_mblock As _MEM

Dim Shared T1_options As _Unsigned Long
Dim Shared T1_option_clamp_width As _Unsigned Long
Dim Shared T1_option_clamp_height As _Unsigned Long
Dim Shared T1_option_alpha_channel As _Unsigned Long
Dim Shared T1_option_no_backface_cull As _Unsigned Long
T1_option_clamp_width = 1 'constant
T1_option_clamp_height = 2 'constant
T1_option_alpha_channel = 8 'constant
T1_option_no_backface_cull = 16 'constant

' Later optimization requires these to be powers of 2.
' That means: 2,4,8,16,32,64,128,256...
T1_width = 16: T1_width_MASK = T1_width - 1
T1_height = 16: T1_height_MASK = T1_height - 1

T1_mblock = _MemImage(TextureCatalog(0))

' Load the cube
' Load what is called a mesh from data statements.
' (x0,y0,z0) (x1,y1,z1) (x2,y2,z2) (u0,v0) (u1,v1) (u2,v2)

Dim Triangles_In_A_Cube
Triangles_In_A_Cube = 12

Dim Shared Mesh_Last_Element As Integer
Mesh_Last_Element = (Thing_Count * Cube_Count * Triangles_In_A_Cube) - 1
Dim mesh(Mesh_Last_Element) As triangle
Dim A As Integer
A = 0

Dim thing As Integer
Dim cube As Integer
Dim tri_num As Integer

Dim thing_offset As Single
Dim cube_offset As Single

For thing = 1 To Thing_Count
    thing_offset = 5.5 * (thing - (Thing_Count + 1) / 2)

    For cube = 1 To Cube_Count
        Restore MESHCUBE

        For tri_num = 0 To Triangles_In_A_Cube - 1
            Read mesh(A).x0
            Read mesh(A).y0
            Read mesh(A).z0

            Read mesh(A).x1
            Read mesh(A).y1
            Read mesh(A).z1

            Read mesh(A).x2
            Read mesh(A).y2
            Read mesh(A).z2

            Read mesh(A).u0
            Read mesh(A).v0
            Read mesh(A).u1
            Read mesh(A).v1
            Read mesh(A).u2
            Read mesh(A).v2

            Read mesh(A).texture
            Read mesh(A).options

            ' distort the cube to make a larger tube-like thing
            cube_offset = cube * 8 * Atn(1) / Cube_Count

            mesh(A).z0 = thing_offset + mesh(A).z0 + 2 * Sin(cube_offset)
            mesh(A).z1 = thing_offset + mesh(A).z1 + 2 * Sin(cube_offset)
            mesh(A).z2 = thing_offset + mesh(A).z2 + 2 * Sin(cube_offset)

            mesh(A).y0 = mesh(A).y0 + 2 * Cos(cube_offset)
            mesh(A).y1 = mesh(A).y1 + 2 * Cos(cube_offset)
            mesh(A).y2 = mesh(A).y2 + 2 * Cos(cube_offset)

            mesh(A).x0 = mesh(A).x0 * 100
            mesh(A).x1 = mesh(A).x1 * 100
            mesh(A).x2 = mesh(A).x2 * 100

            A = A + 1
        Next tri_num

    Next cube

Next thing

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


Dim Shared Sky_Last_Element As Integer
Sky_Last_Element = 11

Dim sky(Sky_Last_Element) As triangle
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
    Read sky(A).options
Next A

Sleep 1.6

' Here are the 3D math and projection vars

' Rotation
Dim matRotZ(3, 3) As Single
Dim matRotX(3, 3) As Single

Dim point0 As vec3d
Dim point1 As vec3d
Dim point2 As vec3d

Dim pointRotZ0 As vec3d
Dim pointRotZ1 As vec3d
Dim pointRotZ2 As vec3d

Dim pointRotZX0 As vec3d
Dim pointRotZX1 As vec3d
Dim pointRotZX2 As vec3d

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
Dim Shared vattb0 As vertex_attribute5
Dim Shared vattb1 As vertex_attribute5
Dim Shared vattb2 As vertex_attribute5
Dim Shared vattb3 As vertex_attribute5

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
vCameraPsn.x = -5.0
vCameraPsn.y = 0.2
vCameraPsn.z = 0.0

Dim cameraRay As vec3d
Dim dotProductCam As Single

' View Space 2-10-2023
Dim fYaw As Single ' FPS Camera rotation in XZ plane (Y)
Dim matCameraRot(3, 3) As Single

Dim vCameraHome As vec3d ' Home angle orientation is facing down the Z line.
vCameraHome.x = 0.0: vCameraHome.y = 0.0: vCameraHome.z = 1.0

Dim vCameraUp As vec3d
vCameraUp.x = 0.0: vCameraUp.y = 1.0: vCameraUp.z = 0.0

Dim vLookDir As vec3d
Dim vTarget As vec3d
Dim matCamera(3, 3) As Single


' Directional light 1-17-2023
Dim vLightDir As vec3d
vLightDir.x = -0.5
vLightDir.y = 0.6 ' +Y is now up
vLightDir.z = 0.4
Vector3_Normalize vLightDir
Dim Shared Light_Directional As Single
Dim Shared Light_AmbientVal As Single
Light_AmbientVal = 0.3


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
Dim vertexA As vertex8
Dim vertexB As vertex8
Dim vertexC As vertex8

' Screen clipping
clip_min_y = 5
clip_max_y = Size_Render_Y - 5

clip_min_x = 10
clip_max_x = Size_Render_X - 10

' This is so that the cube object animates by rotating
Dim spinAngleDegZ As Single
Dim spinAngleDegX As Single
spinAngleDegZ = 0.0
spinAngleDegX = 0.0

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
Dim Animate_Spin As Integer
Dim Triangles_Drawn As Long
Dim triCount As Integer
Dim New_Triangles_Drawn As Long ' because of clipping
Dim vMove_Player_Forward As vec3d


$Checking:Off
main:
ExitCode = 0
Animate_Spin = 0
T1_Filter_Selection = 1
fYaw = 275

frametime_fullframe_ms = 1 / 60.0
frametime_fullframethreshold_ms = 1 / 61.0
frametimestamp_prior_ms = Timer(.001)
frametimestamp_delta_ms = frametime_fullframe_ms
frame_advance = 0

Do
    If Animate_Spin Then
        spinAngleDegZ = spinAngleDegZ '+ (0.980 * frame_advance)
        spinAngleDegX = spinAngleDegX + (0.228 * frame_advance)
        'fYaw = fYaw + 1
    End If

    ' Set up rotation matrices
    ' _D2R is just a built-in degrees to radians conversion

    ' Rotation Z
    matRotZ(0, 0) = Cos(_D2R(spinAngleDegZ))
    matRotZ(0, 1) = Sin(_D2R(spinAngleDegZ))
    matRotZ(1, 0) = -Sin(_D2R(spinAngleDegZ))
    matRotZ(1, 1) = Cos(_D2R(spinAngleDegZ))
    matRotZ(2, 2) = 1
    matRotZ(3, 3) = 1

    ' Rotation X
    matRotX(0, 0) = 1
    matRotX(1, 1) = Cos(_D2R(spinAngleDegX))
    matRotX(1, 2) = -Sin(_D2R(spinAngleDegX)) 'flip
    matRotX(2, 1) = Sin(_D2R(spinAngleDegX)) 'flip
    matRotX(2, 2) = Cos(_D2R(spinAngleDegX))
    matRotX(3, 3) = 1


    ' Create "Point At" Matrix for camera
    Matrix4_MakeRotation_Y fYaw, matCameraRot()
    Multiply_Vector3_Matrix4 vCameraHome, matCameraRot(), vLookDir
    Vector3_Add vCameraPsn, vLookDir, vTarget
    Matrix4_PointAt vCameraPsn, vTarget, vCameraUp, matCamera()

    ' Make view matrix from Camera
    Matrix4_QuickInverse matCamera(), matView()

    Triangles_Drawn = 0
    New_Triangles_Drawn = 0
    start_ms = Timer(.001)

    ' Due to Skybox being drawn wherever Z_Buffer is 0, do not need to Clear Screen
    _Dest WORK_IMAGE
    'Cls , Fog_color

    ' Clear Z-Buffer
    'For L = 0 To Screen_Z_Buffer_MaxElement
    'Screen_Z_Buffer(L) = 0.0
    'Next L
    ' This is a qbasic only optimization. it sets the array to zero. it saves 10 ms.
    ReDim Screen_Z_Buffer(Screen_Z_Buffer_MaxElement)

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

        ' Rotate in Z-Axis
        Multiply_Vector3_Matrix4 point0, matRotZ(), pointRotZ0
        Multiply_Vector3_Matrix4 point1, matRotZ(), pointRotZ1
        Multiply_Vector3_Matrix4 point2, matRotZ(), pointRotZ2

        ' Rotate in X-Axis
        Multiply_Vector3_Matrix4 pointRotZ0, matRotX(), pointRotZX0
        Multiply_Vector3_Matrix4 pointRotZ1, matRotX(), pointRotZX1
        Multiply_Vector3_Matrix4 pointRotZ2, matRotX(), pointRotZX2

        ' Offset into the screen
        pointTrans0 = pointRotZX0
        pointTrans1 = pointRotZX1
        pointTrans2 = pointRotZX2


        ' Part 2 (Triangle Surface Normal Calculation)
        CalcSurfaceNormal_3Point pointTrans0, pointTrans1, pointTrans2, tri_normal

        Vector3_Delta vCameraPsn, pointTrans0, cameraRay
        dotProductCam = Vector3_DotProduct!(tri_normal, cameraRay)

        T1_options = mesh(A).options
        If (T1_options And T1_option_no_backface_cull) Or (dotProductCam > 0.0) Then
            ' Convert World Space --> View Space
            Multiply_Vector3_Matrix4 pointTrans0, matView(), pointView0
            Multiply_Vector3_Matrix4 pointTrans1, matView(), pointView1
            Multiply_Vector3_Matrix4 pointTrans2, matView(), pointView2

            ' Load up attribute lists here because NearClip will interpolate those too.
            vattb0.u = mesh(A).u0: vattb0.v = mesh(A).v0
            vattb1.u = mesh(A).u1: vattb1.v = mesh(A).v1
            vattb2.u = mesh(A).u2: vattb2.v = mesh(A).v2

            ' Clip if any Z is too close. Assumption is that near clip is uncommon.
            ' If there is a lot of near clipping going on, please remove this precheck and just always call NearClip.
            If (pointView0.z < Frustum_Near) Or (pointView1.z < Frustum_Near) Or (pointView2.z < Frustum_Near) Then
                NearClip pointView0, pointView1, pointView2, pointView3, vattb0, vattb1, vattb2, vattb3, triCount
                If triCount = 0 Then GoTo Lbl_SkipTriAll
            Else
                triCount = 1
            End If

            ' Project triangles from 3D -----------------> 2D
            ProjectMatrixVector4 pointView0, matProj(), pointProj0
            ProjectMatrixVector4 pointView1, matProj(), pointProj1
            ProjectMatrixVector4 pointView2, matProj(), pointProj2

            ' Directional light 1-17-2023
            Light_Directional = Vector3_DotProduct!(tri_normal, vLightDir)
            If dotProductCam > 0.0 Then
                ' front face
                If Light_Directional < 0.0 Then Light_Directional = 0.0
            Else
                ' back face
                If Light_Directional > 0.0 Then Light_Directional = 0.0
                Light_Directional = Abs(Light_Directional)
            End If

            ' Fill in Texture 1 data
            T1_ImageHandle = TextureCatalog(mesh(A).texture)
            T1_mblock = _MemImage(T1_ImageHandle)
            T1_width = _Width(T1_ImageHandle): T1_width_MASK = T1_width - 1
            T1_height = _Height(T1_ImageHandle): T1_height_MASK = T1_height - 1

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
            vertexA.u = vattb0.u * pointProj0.w
            vertexA.v = vattb0.v * pointProj0.w

            vertexB.x = SX1
            vertexB.y = SY1
            vertexB.w = pointProj1.w ' depth
            vertexB.u = vattb1.u * pointProj1.w
            vertexB.v = vattb1.v * pointProj1.w

            vertexC.x = SX2
            vertexC.y = SY2
            vertexC.w = pointProj2.w ' depth
            vertexC.u = vattb2.u * pointProj2.w
            vertexC.v = vattb2.v * pointProj2.w

            TexturedVtxColorTriangle vertexA, vertexB, vertexC

            ' Wireframe triangle
            'Line (SX0, SY0)-(SX1, SY1), _RGB32(128, 128, 128)
            'Line (SX1, SY1)-(SX2, SY2), _RGB32(128, 128, 128)
            'Line (SX2, SY2)-(SX0, SY0), _RGB32(128, 128, 128)
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
                vertexA.u = vattb0.u * pointProj0.w
                vertexA.v = vattb0.v * pointProj0.w

                vertexB.x = SX2
                vertexB.y = SY2
                vertexB.w = pointProj2.w ' depth
                vertexB.u = vattb2.u * pointProj2.w
                vertexB.v = vattb2.v * pointProj2.w

                vertexC.x = SX3
                vertexC.y = SY3
                vertexC.w = pointProj3.w ' depth
                vertexC.u = vattb3.u * pointProj3.w
                vertexC.v = vattb3.v * pointProj3.w

                TexturedVtxColorTriangle vertexA, vertexB, vertexC

                ' Wireframe triangle
                'Line (SX0, SY0)-(SX2, SY2), _RGB32(128, 128, 128)
                'Line (SX2, SY2)-(SX3, SY3), _RGB32(128, 128, 128)
                'Line (SX3, SY3)-(SX0, SY0), _RGB32(128, 128, 128)
                New_Triangles_Drawn = New_Triangles_Drawn + 1

            End If
            Lbl_SkipTriAll:
        End If

    Next A


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
        CalcSurfaceNormal_3Point pointTrans0, pointTrans1, pointTrans2, tri_normal

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
        vattb0.u = sky(A).u0: vattb0.v = sky(A).v0
        vattb1.u = sky(A).u1: vattb1.v = sky(A).v1
        vattb2.u = sky(A).u2: vattb2.v = sky(A).v2

        ' Clip more often than not in this example
        NearClip pointView0, pointView1, pointView2, pointView3, vattb0, vattb1, vattb2, vattb3, triCount
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

            ' Load Vertex List for Textured triangle
            vertexA.x = SX0
            vertexA.y = SY0
            vertexA.w = pointProj0.w ' depth
            vertexA.u = vattb0.u * pointProj0.w
            vertexA.v = vattb0.v * pointProj0.w

            vertexB.x = SX1
            vertexB.y = SY1
            vertexB.w = pointProj1.w ' depth
            vertexB.u = vattb1.u * pointProj1.w
            vertexB.v = vattb1.v * pointProj1.w

            vertexC.x = SX2
            vertexC.y = SY2
            vertexC.w = pointProj2.w ' depth
            vertexC.u = vattb2.u * pointProj2.w
            vertexC.v = vattb2.v * pointProj2.w

            ' No Directional light

            ' Fill in Texture 1 data
            T1_ImageHandle = SkyBoxRef(sky(A).texture)
            T1_mblock = _MemImage(T1_ImageHandle)
            T1_options = sky(A).options
            T1_width = _Width(T1_ImageHandle): T1_width_MASK = T1_width - 1
            T1_height = _Height(T1_ImageHandle): T1_height_MASK = T1_height - 1

            TexturedNonlitTriangle vertexA, vertexB, vertexC

            ' Wireframe triangle
            'Line (SX0, SY0)-(SX1, SY1), _RGB32(128, 0, 128)
            'Line (SX1, SY1)-(SX2, SY2), _RGB32(128, 0, 128)
            'Line (SX2, SY2)-(SX0, SY0), _RGB32(128, 0, 128)
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
            vertexA.u = vattb0.u * pointProj0.w
            vertexA.v = vattb0.v * pointProj0.w

            vertexB.x = SX2
            vertexB.y = SY2
            vertexB.w = pointProj2.w ' depth
            vertexB.u = vattb2.u * pointProj2.w
            vertexB.v = vattb2.v * pointProj2.w

            vertexC.x = SX3
            vertexC.y = SY3
            vertexC.w = pointProj3.w ' depth
            vertexC.u = vattb3.u * pointProj3.w
            vertexC.v = vattb3.v * pointProj3.w

            TexturedNonlitTriangle vertexA, vertexB, vertexC

            ' Wireframe triangle
            'Line (SX0, SY0)-(SX2, SY2), _RGB32(0, 128, 128)
            'Line (SX2, SY2)-(SX3, SY3), _RGB32(0, 128, 128)
            'Line (SX3, SY3)-(SX0, SY0), _RGB32(0, 128, 128)
            New_Triangles_Drawn = New_Triangles_Drawn + 1
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
    Print "Arrow Keys Move."

    If Animate_Spin Then
        Print "Press S to Stop Spin"
    Else
        Print "Press S to Start Spin"
    End If

    Print "+FOV- Degrees: "; Frustum_FOV_deg

    Print "Triangles Drawn: "; Triangles_Drawn; "+"; New_Triangles_Drawn

    _Limit 60
    _Display

    $Checking:On
    KeyNow = UCase$(InKey$)
    If KeyNow <> "" Then

        If KeyNow = "S" Then
            Animate_Spin = Not Animate_Spin
        ElseIf KeyNow = "=" Or KeyNow = "+" Then
            Frustum_FOV_deg = Frustum_FOV_deg - 5.0
            FOVchange
        ElseIf KeyNow = "-" Then
            Frustum_FOV_deg = Frustum_FOV_deg + 5.0
            FOVchange

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
        Multiply_Vector3_Matrix4 vCameraHome, matCameraRot(), vMove_Player_Forward
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
' texture_index, texture_options
' .0 = T1_option_clamp_width
' .1 = T1_option_clamp_height

MESHCUBE:
' TOP
Data 0,1,0,0,1,1,1,1,1
Data 0,16,0,0,1600,0
Data 1,0
Data 0,1,0,1,1,1,1,1,0
Data 0,16,1600,0,1600,16
Data 1,0

' BOTTOM
Data 1,0,1,0,0,1,0,0,0
Data 0,1600,0,0,16,0
Data 3,0
Data 1,0,1,0,0,0,1,0,0
Data 0,1600,16,0,16,1600
Data 3,0

' SOUTH
Data 0,0,0,0,1,0,1,1,0
Data 0,16,0,0,1600,0
Data 2,2
Data 0,0,0,1,1,0,1,0,0
Data 0,16,1600,0,1600,16
Data 2,2

' EAST
Data 1,0,0,1,1,0,1,1,1
Data 0,16,0,0,16,0
Data 4,2
Data 1,0,0,1,1,1,1,0,1
Data 0,16,16,0,16,16
Data 4,2

' NORTH
Data 1,0,1,1,1,1,0,1,1
Data 0,16,0,0,1600,0
Data 2,2
Data 1,0,1,0,1,1,0,0,1
Data 0,16,1600,0,1600,16
Data 2,2

' WEST
Data 0,0,1,0,1,1,0,1,0
Data 0,16,0,0,16,0
Data 2,2
Data 0,0,1,0,1,0,0,0,0
Data 0,16,16,0,16,16
Data 2,2


' x0,y0,z0, x1,y1,z1, x2,y2,z2
' u0,v0, u1,v1, u2,v2
' texture_index, texture_options
' .0 = T1_option_clamp_width
' .1 = T1_option_clamp_height
SKYBOX:
' FRONT Z+
Data -10,+10,+10
Data +10,+10,+10
Data -10,-10,+10
Data 0,0,128,0,0,128
Data 4,3

Data +10,+10,+10
Data +10,-10,+10
Data -10,-10,+10
Data 128,0,128,128,0,128
Data 4,3

' RIGHT X+
Data +10,+10,+10
Data +10,+10,-10
Data +10,-10,+10
Data 0,0,128,0,0,128
Data 0,3

Data +10,+10,-10
Data +10,-10,-10
Data +10,-10,+10
Data 128,0,128,128,0,128
Data 0,3

' LEFT X-
Data -10,+10,-10
Data -10,+10,+10
Data -10,-10,-10
Data 0,0,128,0,0,128
Data 1,3

Data -10,+10,+10
Data -10,-10,+10
Data -10,-10,-10
Data 128,0,128,128,0,128
Data 1,3

' BACK Z-
Data +10,+10,-10
Data -10,+10,-10
Data +10,-10,-10
Data 0,0,128,0,0,128
Data 5,3

Data -10,+10,-10
Data -10,-10,-10
Data +10,-10,-10
Data 128,0,128,128,0,128
Data 5,3

' TOP Y+
Data -10,+10,-10
Data +10,+10,-10
Data -10,+10,+10
Data 0,0,128,0,0,128
Data 2,3

Data +10,+10,-10
Data +10,+10,+10
Data -10,+10,+10
Data 128,0,128,128,0,128
Data 2,3

' BOTTOM Y-
Data -10,-10,+10
Data 10,-10,+10
Data -10,-10,-10
Data 0,0,128,0,0,128
Data 3,3

Data +10,-10,+10
Data +10,-10,-10
Data -10,-10,-10
Data 128,0,128,128,0,128
Data 3,3


Sub FOVchange
    If Frustum_FOV_deg < 10.0 Then Frustum_FOV_deg = 10.0
    If Frustum_FOV_deg > 140.0 Then Frustum_FOV_deg = 140.0
    Frustum_FOV_ratio = 1.0 / Tan(_D2R(Frustum_FOV_deg * 0.5))
    matProj(0, 0) = Frustum_Aspect_Ratio * Frustum_FOV_ratio
    matProj(1, 1) = Frustum_FOV_ratio
    matProj(2, 2) = Frustum_Far / (Frustum_Far - Frustum_Near)
    matProj(2, 3) = 1.0
    matProj(3, 2) = (-Frustum_Far * Frustum_Near) / (Frustum_Far - Frustum_Near)
End Sub

Sub NearClip (A As vec3d, B As vec3d, C As vec3d, D As vec3d, TA As vertex_attribute5, TB As vertex_attribute5, TC As vertex_attribute5, TD As vertex_attribute5, result As Integer)
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
    o.z = i.x * m(0, 2) + i.y * m(1, 2) + i.z * m(2, 2) + m(3, 2)
    www = i.x * m(0, 3) + i.y * m(1, 3) + i.z * m(2, 3) + m(3, 3)

    ' Normalizing
    If www <> 0.0 Then
        o.w = 1 / www 'optimization
        o.x = o.x * o.w
        o.y = -o.y * o.w 'because I feel +Y is up
        o.z = o.z * o.w
    End If
End Sub


Sub TexturedVtxColorTriangle (A As vertex8, B As vertex8, C As vertex8)
    Static delta2 As vertex8
    Static delta1 As vertex8
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

    Static legx2_step As Single
    Static legw2_step As Single, legu2_step As Single, legv2_step As Single
    Static legr2_step As Single, legg2_step As Single, legb2_step As Single

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y
    legr2_step = delta2.r / delta2.y
    legg2_step = delta2.g / delta2.y
    legb2_step = delta2.b / delta2.y

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
    End If

    ' Y Accumulators
    Static leg_x1 As Single
    Static leg_w1 As Single, leg_u1 As Single, leg_v1 As Single
    Static leg_r1 As Single, leg_g1 As Single, leg_b1 As Single

    Static leg_x2 As Single
    Static leg_w2 As Single, leg_u2 As Single, leg_v2 As Single
    Static leg_r2 As Single, leg_g2 As Single, leg_b2 As Single

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

    leg_x2 = A.x + prestep_y1 * legx2_step
    leg_w2 = A.w + prestep_y1 * legw2_step
    leg_u2 = A.u + prestep_y1 * legu2_step
    leg_v2 = A.v + prestep_y1 * legv2_step
    leg_r2 = A.r + prestep_y1 * legr2_step
    leg_g2 = A.g + prestep_y1 * legg2_step
    leg_b2 = A.b + prestep_y1 * legb2_step

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

    ' X Accumulators
    Static tex_w As Single, tex_u As Single, tex_v As Single
    Static tex_r As Single, tex_g As Single, tex_b As Single

    ' Screen Memory Pointers
    Static screen_mem_info As _MEM
    Static screen_next_row_step As _Offset
    Static screen_row_base As _Offset ' Calculated every row
    Static screen_address As _Offset ' Calculated at every starting column
    screen_mem_info = _MemImage(WORK_IMAGE)
    screen_next_row_step = 4 * Size_Render_X

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

            If delta1.y = 0.0 Then Exit Sub

            ' Full steps in the y direction from B to C
            legx1_step = delta1.x / delta1.y
            legw1_step = delta1.w / delta1.y
            legu1_step = delta1.u / delta1.y
            legv1_step = delta1.v / delta1.y
            legr1_step = delta1.r / delta1.y ' vertex color
            legg1_step = delta1.g / delta1.y
            legb1_step = delta1.b / delta1.y

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

                ' ending point is (1)
                draw_max_x = _Ceil(leg_x1)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            End If

            ' Draw the Horizontal Scanline
            screen_address = screen_row_base + 4 * col
            zbuf_index = row * Size_Render_X + col
            While col < draw_max_x

                tex_z = 1 / tex_w
                If Screen_Z_Buffer(zbuf_index) = 0.0 Or tex_z < Screen_Z_Buffer(zbuf_index) Then
                    Screen_Z_Buffer(zbuf_index) = tex_z + Z_Fight_Bias

                    '--- Begin Inline Texel Read
                    ' Originally function ReadTexel3Point& (ccol As Single, rrow As Single)
                    ' Relies on some shared T1 variables over by Texture1
                    Static cc As Integer
                    Static rr As Integer
                    Static cc1 As Integer
                    Static rr1 As Integer

                    Static Frac_cc1 As Single
                    Static Frac_rr1 As Single

                    Static Area_00 As Single
                    Static Area_11 As Single
                    Static Area_2f As Single

                    Static T1_address_pointer As _Offset
                    Static uv_0_0 As _Unsigned Long
                    Static uv_1_1 As _Unsigned Long
                    Static uv_f As _Unsigned Long

                    Static r0 As Integer
                    Static g0 As Integer
                    Static b0 As Integer

                    Static cm5 As Single
                    Static rm5 As Single

                    ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                    cm5 = (tex_u * tex_z) - 0.5
                    rm5 = (tex_v * tex_z) - 0.5

                    If T1_options And T1_option_clamp_width Then
                        ' clamp
                        If cm5 < 0.0 Then cm5 = 0.0
                        If cm5 >= T1_width_MASK Then
                            ' 15.0 and up
                            cc = T1_width_MASK
                            cc1 = T1_width_MASK
                        Else
                            ' 0 1 2 .. 13 14.999
                            cc = Int(cm5)
                            cc1 = cc + 1
                        End If
                    Else
                        ' tile the texture
                        cc = Int(cm5) And T1_width_MASK
                        cc1 = (cc + 1) And T1_width_MASK
                    End If

                    If T1_options And T1_option_clamp_height Then
                        ' clamp
                        If rm5 < 0.0 Then rm5 = 0.0
                        If rm5 >= T1_height_MASK Then
                            ' 15.0 and up
                            rr = T1_height_MASK
                            rr1 = T1_height_MASK
                        Else
                            rr = Int(rm5)
                            rr1 = rr + 1
                        End If
                    Else
                        ' tile
                        rr = Int(rm5) And T1_height_MASK
                        rr1 = (rr + 1) And T1_height_MASK
                    End If

                    'uv_0_0 = Texture1(cc, rr)
                    T1_address_pointer = T1_mblock.OFFSET + (cc + rr * T1_width) * 4
                    _MemGet T1_mblock, T1_address_pointer, uv_0_0

                    'uv_1_1 = Texture1(cc1, rr1)
                    T1_address_pointer = T1_mblock.OFFSET + (cc1 + rr1 * T1_width) * 4
                    _MemGet T1_mblock, T1_address_pointer, uv_1_1

                    Frac_cc1 = cm5 - Int(cm5)
                    Frac_rr1 = rm5 - Int(rm5)

                    If Frac_cc1 > Frac_rr1 Then
                        ' top-right
                        ' Area of a triangle = 1/2 * base * height
                        ' Using twice the areas (rectangles) to eliminate a multiply by 1/2 and a later divide by 1/2
                        Area_11 = Frac_rr1
                        Area_00 = 1.0 - Frac_cc1

                        'uv_f = Texture1(cc1, rr)
                        T1_address_pointer = T1_mblock.OFFSET + (cc1 + rr * T1_width) * 4
                        _MemGet T1_mblock, T1_address_pointer, uv_f
                    Else
                        ' bottom-left
                        Area_00 = 1.0 - Frac_rr1
                        Area_11 = Frac_cc1

                        'uv_f = Texture1(cc, rr1)
                        T1_address_pointer = T1_mblock.OFFSET + (cc + rr1 * T1_width) * 4
                        _MemGet T1_mblock, T1_address_pointer, uv_f

                    End If

                    Area_2f = 1.0 - (Area_00 + Area_11) '1.0 here is twice the total triangle area.

                    r0 = tex_r + _Red32(uv_f) * Area_2f + _Red32(uv_0_0) * Area_00 + _Red32(uv_1_1) * Area_11
                    g0 = tex_g + _Green32(uv_f) * Area_2f + _Green32(uv_0_0) * Area_00 + _Green32(uv_1_1) * Area_11
                    b0 = tex_b + _Blue32(uv_f) * Area_2f + _Blue32(uv_0_0) * Area_00 + _Blue32(uv_1_1) * Area_11
                    '--- End Inline Texel Read

                    '---- Begin Inline Directional Lighting
                    Static scale As Single
                    scale = Light_Directional + Light_AmbientVal 'oversaturate the bright colors
                    r0 = r0 * scale
                    g0 = g0 * scale
                    b0 = b0 * scale
                    '---- End Inline Directional Lighting

                    '----- Begin Inline Fog
                    Static fog_scale As Single

                    If tex_z <= Fog_near Then
                        ' do nothing
                        pixel_value = _RGB32(r0, g0, b0)
                    ElseIf tex_z >= Fog_far Then
                        ' overwrite
                        pixel_value = Fog_color
                    Else
                        fog_scale = (tex_z - Fog_near) * Fog_rate
                        pixel_value = _RGB32((Fog_R - r0) * fog_scale + r0, (Fog_G - g0) * fog_scale + g0, (Fog_B - b0) * fog_scale + b0)
                    End If
                    '----- End Inline Fog

                    _MemPut screen_mem_info, screen_address, pixel_value
                    'PSet (col, row), pixel_value

                End If ' tex_z
                zbuf_index = zbuf_index + 1
                tex_w = tex_w + tex_w_step
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                tex_r = tex_r + tex_r_step
                tex_g = tex_g + tex_g_step
                tex_b = tex_b + tex_b_step
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

        leg_x2 = leg_x2 + legx2_step
        leg_w2 = leg_w2 + legw2_step
        leg_u2 = leg_u2 + legu2_step
        leg_v2 = leg_v2 + legv2_step
        leg_r2 = leg_r2 + legr2_step
        leg_g2 = leg_g2 + legg2_step
        leg_b2 = leg_b2 + legb2_step

        screen_row_base = screen_row_base + screen_next_row_step
        row = row + 1
    Wend ' row

End Sub


Sub TexturedNonlitTriangle (A As vertex8, B As vertex8, C As vertex8)
    ' this is a reduced copy for skybox drawing
    ' T1_options is ignored
    Static delta2 As vertex8
    Static delta1 As vertex8
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
    Static zbuf_index As _Unsigned Long ' Z-Buffer
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
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step

                ' ending point is (1)
                draw_max_x = _Ceil(leg_x1)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            End If

            ' Draw the Horizontal Scanline
            screen_address = screen_row_base + 4 * col
            zbuf_index = row * Size_Render_X + col
            While col < draw_max_x

                If Screen_Z_Buffer(zbuf_index) = 0.0 Then
                    ' do not update Z Buffer
                    tex_z = 1 / tex_w

                    '--- Begin Inline Texel Read
                    ' Originally function ReadTexel3Point& (ccol As Single, rrow As Single)
                    ' Relies on some shared T1 variables over by Texture1
                    Static cc As Integer
                    Static rr As Integer
                    Static cc1 As Integer
                    Static rr1 As Integer

                    Static Frac_cc1 As Single
                    Static Frac_rr1 As Single

                    Static Area_00 As Single
                    Static Area_11 As Single
                    Static Area_2f As Single

                    Static T1_address_pointer As _Offset
                    Static uv_0_0 As _Unsigned Long
                    Static uv_1_1 As _Unsigned Long
                    Static uv_f As _Unsigned Long

                    Static r0 As Integer
                    Static g0 As Integer
                    Static b0 As Integer

                    Static cm5 As Single
                    Static rm5 As Single

                    ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                    cm5 = (tex_u * tex_z) - 0.5
                    rm5 = (tex_v * tex_z) - 0.5

                    ' clamp
                    If cm5 < 0.0 Then cm5 = 0.0
                    If cm5 >= T1_width_MASK Then
                        '15.0 and up
                        cc = T1_width_MASK
                        cc1 = T1_width_MASK
                    Else
                        ' 0 1 2 .. 13 14.999
                        cc = Int(cm5)
                        cc1 = cc + 1
                    End If

                    ' clamp
                    If rm5 < 0.0 Then rm5 = 0.0
                    If rm5 >= T1_height_MASK Then
                        ' 15.0 and up
                        rr = T1_height_MASK
                        rr1 = T1_height_MASK
                    Else
                        rr = Int(rm5)
                        rr1 = rr + 1
                    End If

                    'uv_0_0 = Texture1(cc, rr)
                    T1_address_pointer = T1_mblock.OFFSET + (cc + rr * T1_width) * 4
                    _MemGet T1_mblock, T1_address_pointer, uv_0_0

                    'uv_1_1 = Texture1(cc1, rr1)
                    T1_address_pointer = T1_mblock.OFFSET + (cc1 + rr1 * T1_width) * 4
                    _MemGet T1_mblock, T1_address_pointer, uv_1_1

                    Frac_cc1 = cm5 - Int(cm5)
                    Frac_rr1 = rm5 - Int(rm5)

                    If Frac_cc1 > Frac_rr1 Then
                        ' top-right
                        ' Area of a triangle = 1/2 * base * height
                        ' Using twice the areas (rectangles) to eliminate a multiply by 1/2 and a later divide by 1/2
                        Area_11 = Frac_rr1
                        Area_00 = 1.0 - Frac_cc1

                        'uv_f = Texture1(cc1, rr)
                        T1_address_pointer = T1_mblock.OFFSET + (cc1 + rr * T1_width) * 4
                        _MemGet T1_mblock, T1_address_pointer, uv_f
                    Else
                        ' bottom-left
                        Area_00 = 1.0 - Frac_rr1
                        Area_11 = Frac_cc1

                        'uv_f = Texture1(cc, rr1)
                        T1_address_pointer = T1_mblock.OFFSET + (cc + rr1 * T1_width) * 4
                        _MemGet T1_mblock, T1_address_pointer, uv_f

                    End If

                    Area_2f = 1.0 - (Area_00 + Area_11) '1.0 here is twice the total triangle area.

                    r0 = _Red32(uv_f) * Area_2f + _Red32(uv_0_0) * Area_00 + _Red32(uv_1_1) * Area_11
                    g0 = _Green32(uv_f) * Area_2f + _Green32(uv_0_0) * Area_00 + _Green32(uv_1_1) * Area_11
                    b0 = _Blue32(uv_f) * Area_2f + _Blue32(uv_0_0) * Area_00 + _Blue32(uv_1_1) * Area_11
                    '--- End Inline Texel Read


                    '----- No lighting or Fog
                    pixel_value = _RGB32(r0, g0, b0)
                    '----- End No lighting or Fog

                    _MemPut screen_mem_info, screen_address, pixel_value
                    'PSet (col, row), pixel_value

                End If ' tex_z
                zbuf_index = zbuf_index + 1
                tex_w = tex_w + tex_w_step
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

