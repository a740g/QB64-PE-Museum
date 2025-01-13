Option _Explicit
_Title "Dither Color Cube"
' 2023 Haggarman
' Draw a few perspective correct textured cubes in 3D.
' Camera and matrix math code translated from the works of Javidx9 OneLoneCoder.
' Texel interpolation and triangle drawing code by me.
' 3D Triangle code inspired by Youtube: Javidx9, Bisqwit
'  3/04/2023 - Bugfix for wide triangles (make col a Long)
'  2/23/2023 - Texture wrapping options
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

' MODIFY THESE if you want.
Cube_Count = 3
Size_Screen_X = 800
Size_Screen_Y = 600
Size_Render_X = Size_Screen_X \ 2 ' render size
Size_Render_Y = Size_Screen_Y \ 2

DISP_IMAGE = _NewImage(Size_Screen_X, Size_Screen_Y, 32)
Screen DISP_IMAGE

WORK_IMAGE = _NewImage(Size_Render_X, Size_Render_Y, 32)
_DontBlend

Dim Shared Screen_Z_Buffer_MaxElement As Long
Screen_Z_Buffer_MaxElement = Size_Render_X * Size_Render_Y - 1
Dim Shared Screen_Z_Buffer(Screen_Z_Buffer_MaxElement) As Single

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


' Projection Matrix
Dim Frustum_Near As Single
Dim Frustum_Far As Single
Dim Frustum_FOV_deg As Single
Dim Frustum_Aspect_Ratio As Single
Dim Frustum_FOV_ratio As Single

Frustum_Near = 0.1
Frustum_Far = 1000.0
Frustum_FOV_deg = 60.0
Frustum_Aspect_Ratio = _Height / _Width
Frustum_FOV_ratio = 1.0 / Tan(_D2R(Frustum_FOV_deg * 0.5))

Dim matProj(3, 3) As Single
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
Fog_near = 9.0
Fog_far = 19.0
Fog_rate = 1.0 / (Fog_far - Fog_near)

Fog_color = _RGB32(9, 9, 9)
Fog_R = _Red(Fog_color)
Fog_G = _Green(Fog_color)
Fog_B = _Blue(Fog_color)

' Z Fight has to do with overdrawing on top of the same coplanar surface.
' If it is positive, a newer pixel at the same exact Z will always overdraw the older one.
Dim Shared Z_Fight_Bias
Z_Fight_Bias = -0.001953125 / 32.0


' Load Texture1 Array from Data
Restore Texture1Data

' These are read from a sub later on, named ReadTexel
Dim Shared T1_width As Integer, T1_height As Integer
Dim Shared T1_width_MASK As Integer, T1_height_MASK As Integer
Dim Shared T1_Filter_Selection As Integer
Dim Shared T1_last_cache As _Unsigned Long
Dim Shared T1_options As _Unsigned Long
Const T1_option_clamp_width = 1 'constant
Const T1_option_clamp_height = 2 'constant
Const T1_option_no_Z_write = 4 'constant

' Later optimization in ReadTexel requires these to be powers of 2.
' That means: 2,4,8,16,32,64,128,256...
T1_width = 16: T1_width_MASK = T1_width - 1
T1_height = 16: T1_height_MASK = T1_height - 1

Dim Shared Texture1(T1_width_MASK, T1_height_MASK) As _Unsigned Long

Dim dvalue As _Unsigned Long

Dim row As Integer, col As Integer
For row = 0 To T1_height_MASK
    For col = 0 To T1_width_MASK
        Read dvalue
        Texture1(col, row) = dvalue
        'PSet (col, row), dvalue
    Next col
Next row


' Bayer Ordered Dither Matrix
Dim Shared Dither4(3, 3) As Integer
Dither4(0, 0) = 1: Dither4(1, 0) = 5: Dither4(2, 0) = 2: Dither4(3, 0) = 6
Dither4(0, 1) = 7: Dither4(1, 1) = 3: Dither4(2, 1) = 8: Dither4(3, 1) = 4
Dither4(0, 2) = 2: Dither4(1, 2) = 6: Dither4(2, 2) = 1: Dither4(3, 2) = 5
Dither4(0, 3) = 8: Dither4(1, 3) = 4: Dither4(2, 3) = 7: Dither4(3, 3) = 3


' Load the cube
' Load what is called a mesh from data statements.
' (x0,y0,z0) (x1,y1,z1) (x2,y2,z2) (u0,v0) (u1,v1) (u2,v2)
Dim Triangles_In_A_Cube As Integer
Triangles_In_A_Cube = 12

Dim Shared Mesh_Last_Element As Integer
Mesh_Last_Element = Cube_Count * Triangles_In_A_Cube - 1
Dim mesh(Mesh_Last_Element) As triangle

Dim cube As Integer
Dim tri_num As Integer
Dim offset As Single
Dim A As Integer

A = 0
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

        offset = cube * 8 * Atn(1) / Cube_Count

        mesh(A).z0 = mesh(A).z0 + 2 * Sin(offset)
        mesh(A).z1 = mesh(A).z1 + 2 * Sin(offset)
        mesh(A).z2 = mesh(A).z2 + 2 * Sin(offset)

        mesh(A).x0 = mesh(A).x0 + 2 * Cos(offset)
        mesh(A).x1 = mesh(A).x1 + 2 * Cos(offset)
        mesh(A).x2 = mesh(A).x2 + 2 * Cos(offset)

        A = A + 1
    Next tri_num

Next cube

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

' Projection
Dim pointProj0 As vec4d ' added w
Dim pointProj1 As vec4d
Dim pointProj2 As vec4d

' Surface Normal Calculation
' Part 2
Dim tri_normal As vec3d

' Part 2-2
Dim vCameraPsn As vec3d ' location of camera in world space
vCameraPsn.x = 0.0
vCameraPsn.y = 0.0
vCameraPsn.z = -6.0

Dim cameraRay As vec3d
Dim dotProductCam As Single

' View Space 2-10-2023
Dim fYaw As Single ' FPS Camera rotation in XZ plane
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
vLightDir.x = -2.0
vLightDir.y = 10.0 ' +Y is now up
vLightDir.z = -5.0
Vector3_Normalize vLightDir
Dim Shared Light_Directional As Single
Dim Shared Light_AmbientVal As Single
Light_AmbientVal = 0.6


' Screen Scaling
Dim halfWidth As Single
Dim halfHeight As Single
halfWidth = Size_Render_X / 2
halfHeight = Size_Render_Y / 2

' Triangle Vertex List
Dim SX0 As Single, SY0 As Single
Dim SX1 As Single, SY1 As Single
Dim SX2 As Single, SY2 As Single

Dim vertexA As vertex8
Dim vertexB As vertex8
Dim vertexC As vertex8

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

' Clear Z-Buffer
Dim L As _Unsigned Long
For L = 0 To Screen_Z_Buffer_MaxElement
    Screen_Z_Buffer(L) = 3.402823E+38 ' https://qb64phoenix.com/qb64wiki/index.php/Variable_Types
Next L

main:
$Checking:Off
ExitCode = 0
Animate_Spin = -1
T1_Filter_Selection = 2

frametime_fullframe_ms = 1 / 60.0
frametime_fullframethreshold_ms = 1 / 61.0
frametimestamp_prior_ms = Timer(.001)
frametimestamp_delta_ms = frametime_fullframe_ms
frame_advance = 0

Do
    If Animate_Spin Then
        spinAngleDegZ = spinAngleDegZ + frame_advance * 0.460
        spinAngleDegX = spinAngleDegX + frame_advance * 0.713
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
    matRotX(1, 2) = -Sin(_D2R(spinAngleDegX)) ' flip
    matRotX(2, 1) = Sin(_D2R(spinAngleDegX)) ' flip
    matRotX(2, 2) = Cos(_D2R(spinAngleDegX))
    matRotX(3, 3) = 1


    ' Create "Point At" Matrix for camera
    Matrix4_MakeRotation_Y fYaw, matCameraRot()
    Multiply_Vector3_Matrix4 vCameraHome, matCameraRot(), vLookDir
    Vector3_Add vCameraPsn, vLookDir, vTarget
    Matrix4_PointAt vCameraPsn, vTarget, vCameraUp, matCamera()

    ' Make view matrix from Camera
    Matrix4_QuickInverse matCamera(), matView()

    start_ms = Timer(.001)

    ' Clear Screen
    _Dest WORK_IMAGE
    Cls , Fog_color

    ' Clear Z-Buffer
    'For L = 0 To Screen_Z_Buffer_MaxElement
    'Screen_Z_Buffer(L) = 3.402823E+38 'https://qb64phoenix.com/qb64wiki/index.php/Variable_Types
    'Next L
    ' Erase Screen_Z_Buffer
    ' This is a qbasic only optimization. it sets the value to zero. it saves 10 ms.
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

        If dotProductCam > 0.0 Then
            ' Convert World Space --> View Space
            Multiply_Vector3_Matrix4 pointTrans0, matView(), pointView0
            Multiply_Vector3_Matrix4 pointTrans1, matView(), pointView1
            Multiply_Vector3_Matrix4 pointTrans2, matView(), pointView2

            ' Skip if any Z is too close
            If (pointView0.z < Frustum_Near) Or (pointView1.z < Frustum_Near) Or (pointView2.z < Frustum_Near) Then
                GoTo Lbl_SkipA
            End If

            ' Project triangles from 3D -----------------> 2D
            ProjectMatrixVector4 pointView0, matProj(), pointProj0
            ProjectMatrixVector4 pointView1, matProj(), pointProj1
            ProjectMatrixVector4 pointView2, matProj(), pointProj2

            ' Early scissor reject
            If pointProj0.x > 1.0 And pointProj1.x > 1.0 And pointProj2.x > 1.0 Then GoTo Lbl_SkipA
            If pointProj0.x < -1.0 And pointProj1.x < -1.0 And pointProj2.x < -1.0 Then GoTo Lbl_SkipA
            If pointProj0.y > 1.0 And pointProj1.y > 1.0 And pointProj2.y > 1.0 Then GoTo Lbl_SkipA
            If pointProj0.y < -1.0 And pointProj1.y < -1.0 And pointProj2.y < -1.0 Then GoTo Lbl_SkipA

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
            vertexA.u = mesh(A).u0 * pointProj0.w
            vertexA.v = mesh(A).v0 * pointProj0.w

            vertexB.x = SX1
            vertexB.y = SY1
            vertexB.w = pointProj1.w ' depth
            vertexB.u = mesh(A).u1 * pointProj1.w
            vertexB.v = mesh(A).v1 * pointProj1.w

            vertexC.x = SX2
            vertexC.y = SY2
            vertexC.w = pointProj2.w ' depth
            vertexC.u = mesh(A).u2 * pointProj2.w
            vertexC.v = mesh(A).v2 * pointProj2.w

            ' Directional light 1-17-2023
            Light_Directional = Vector3_DotProduct!(tri_normal, vLightDir)
            If Light_Directional < 0.0 Then Light_Directional = 0.0

            ' 2-23-2023
            T1_options = mesh(A).options

            ' Color each vertex brightly.
            ' Using modulation function for bright primary colors.
            vertexA.r = 240
            vertexA.g = 0
            vertexA.b = 0

            If A And 1 Then
                vertexB.r = 64
                vertexB.g = 240
                vertexB.b = 0

                vertexC.r = 0
                vertexC.g = 0
                vertexC.b = 240
            Else
                vertexB.r = 0
                vertexB.g = 0
                vertexB.b = 240

                vertexC.r = 64
                vertexC.g = 240
                vertexC.b = 0
            End If

            TexturedVtxColorTriangle vertexA, vertexB, vertexC

            ' Wireframe triangle
            'Line (SX0, SY0)-(SX1, SY1), _RGB32(128, 128, 128)
            'Line (SX1, SY1)-(SX2, SY2), _RGB32(128, 128, 128)
            'Line (SX2, SY2)-(SX0, SY0), _RGB32(128, 128, 128)
        End If

        Lbl_SkipA:
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
    Print "Press F for Filter: ";
    Select Case T1_Filter_Selection
        Case 0
            Print "Nearest"
        Case 1
            Print "3-Point N64"
        Case 2
            Print "Bilinear Fix"
        Case 3
            Print "Bilinear Float"

    End Select
    If Animate_Spin Then
        Print "Press S to Stop Spin"
    Else
        Print "Press S to Start Spin"
    End If

    _Limit 60
    _Display

    $Checking:On
    KeyNow = UCase$(InKey$)
    If KeyNow <> "" Then

        If KeyNow = "F" Then
            T1_Filter_Selection = T1_Filter_Selection + 1
            If T1_Filter_Selection > 3 Then T1_Filter_Selection = 0
        ElseIf KeyNow = "S" Then
            Animate_Spin = Not Animate_Spin

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
            fYaw = fYaw - 1.9
        End If

        If _KeyDown(19200) Then
            ' Left arrow
            fYaw = fYaw + 1.9
        End If

        Dim vMove_Player_Forward As vec3d
        Vector3_Mul vLookDir, 0.2, vMove_Player_Forward

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

End
$Checking:Off

Texture1Data:
'Red_Brick', 16x16px
Data &HFFd93f0f,&HFFdd340a,&HFFd93f0f,&HFFcfcbd2,&HFFd93f0f,&HFFdd3d1b,&HFFd93509,&HFFe04609,&HFFd93f0f,&HFFe14a1b,&HFFcf380a,&HFFd1d1d1,&HFFd93f0f,&HFFde4712,&HFFd93f0f,&HFFd93f0f
Data &HFFb33409,&HFFb33409,&HFFbe3912,&HFFdce1d7,&HFFe1501b,&HFFb33409,&HFFae2a0a,&HFFac2213,&HFFb33409,&HFFaa320f,&HFFbf3806,&HFFd6ceda,&HFFd93f0f,&HFFb73508,&HFFb33409,&HFFb43705
Data &HFFb33409,&HFFba3e19,&HFFac2903,&HFFd1d1d1,&HFFd93f0f,&HFFa93b13,&HFFb33409,&HFFa83207,&HFFb33409,&HFFb33409,&HFFb33409,&HFFd1d1d1,&HFFd12d02,&HFFc04110,&HFFb33409,&HFFbc4107
Data &HFFb89f91,&HFFb89a8a,&HFFae8e8f,&HFFd1d1d1,&HFFb29291,&HFFb3938b,&HFFb3938b,&HFFaf8f81,&HFFb3938b,&HFFbb9d8d,&HFFc3898d,&HFFd7dee4,&HFFb3938b,&HFFb3938b,&HFFaa8d8c,&HFFc8a597
Data &HFFd0320a,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFd73907,&HFFd93f0f,&HFFd1d1d1,&HFFde4619,&HFFd94915,&HFFe23d14,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFd0d0ca
Data &HFFd93f0f,&HFFb33409,&HFFc1481e,&HFFb33409,&HFFa92902,&HFFb33409,&HFFb73006,&HFFd1d1d1,&HFFd93f0f,&HFFb33409,&HFFaf2e05,&HFFb33409,&HFFac2b00,&HFFb33409,&HFFb33409,&HFFcbd9d5
Data &HFFd93f0f,&HFFa62600,&HFFb83c15,&HFFb02b00,&HFFb33409,&HFFaf2103,&HFFb33409,&HFFcfe0dd,&HFFdb4b15,&HFFaa2e02,&HFFb63b0f,&HFFad3209,&HFFb33409,&HFFb33409,&HFFb33409,&HFFd4cfd1
Data &HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFaa938b,&HFFb0918e,&HFFc1998f,&HFFb3938b,&HFFd1d1d1,&HFFb3938b,&HFFb3938b,&HFFb3878b,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFb69384,&HFFd1d1d1
Data &HFFdf3f14,&HFFd93f0f,&HFFd93f0f,&HFFd1d1d1,&HFFda3d08,&HFFd93f0f,&HFFda4515,&HFFee5519,&HFFde3f19,&HFFd93f0f,&HFFd93f0f,&HFFd1d1d1,&HFFd93f0f,&HFFd93f0f,&HFFe95407,&HFFc62f00
Data &HFFb33409,&HFFb33409,&HFFb33409,&HFFc8cfd1,&HFFde3419,&HFFb33409,&HFFb1350d,&HFFb33409,&HFFb93c0d,&HFFb64305,&HFFb92f0a,&HFFcfcacd,&HFFd93f0f,&HFFbb3a17,&HFFb33409,&HFFb33409
Data &HFFb14310,&HFFb33409,&HFFbc3b0f,&HFFd8dede,&HFFd93f0f,&HFFb33409,&HFFb0150c,&HFFb33409,&HFFb52500,&HFFb23a18,&HFFb33409,&HFFcad1d3,&HFFd93f0f,&HFFb33409,&HFFb53d0f,&HFFb33409
Data &HFFb3938b,&HFFb3938b,&HFFa58588,&HFFd1d1d1,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFad9092,&HFFd1d5d8,&HFFba8e88,&HFFb99e96,&HFFa89283,&HFFaa9784
Data &HFFca4a0f,&HFFd84118,&HFFe14a18,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFcf3d06,&HFFc7cbcf,&HFFd93b02,&HFFdd561a,&HFFd93f0f,&HFFd93f0f,&HFFd83c15,&HFFd93f0f,&HFFdd3f12,&HFFdee0e0
Data &HFFd93f0f,&HFFb33409,&HFFa93515,&HFFae3709,&HFFb33409,&HFFb33409,&HFFaa2709,&HFFc4cdcc,&HFFd93f0f,&HFFbd2d09,&HFFb33409,&HFFb33409,&HFFb33409,&HFFb43507,&HFFb73510,&HFFd1d1d1
Data &HFFd93f0f,&HFFa61800,&HFFb93a1a,&HFFb33409,&HFFb33409,&HFFb33409,&HFFb33409,&HFFd1d3d4,&HFFd93f0f,&HFFb33409,&HFFb33409,&HFFb33409,&HFFb63521,&HFFb33409,&HFFaf3c0c,&HFFd1d1d1
Data &HFFb3938b,&HFFb59181,&HFFa5857c,&HFFb59895,&HFFb3938b,&HFFb09a96,&HFFb3938b,&HFFd1d1d1,&HFFbaa085,&HFFb3938b,&HFFad8c8a,&HFFb3938b,&HFFbc9a8e,&HFFb3938b,&HFFb3938b,&HFFbec7c9

'Origin16x16', 16x16px
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffdbc4,&HFFff7f27,&HFFffdbc4,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffac75,&HFFff7f27,&HFFffac75,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFff7f27,&HFFff7f27,&HFFff7f27,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFff7f27,&HFFffdbc4,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFFffffff,&HFF00a2e8,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFff7f27,&HFFffdbc4,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFF9de1ff,&HFF00a2e8,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFF9de1ff,&HFF00a2e8,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFFffffff,&HFF00a2e8,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFF64d0ff,&HFF9de1ff,&HFFffffff
Data &HFFffffff,&HFFa349a4,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8
Data &HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFF64d0ff,&HFF9de1ff,&HFFffffff


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
' SOUTH
Data 0,0,0,0,1,0,1,1,0
Data 0,32,0,16,16,16
Data 0,0
Data 0,0,0,1,1,0,1,0,0
Data 0,32,16,16,16,32
Data 0,0

' EAST
Data 1,0,0,1,1,0,1,1,1
Data 0,32,0,16,16,16
Data 0,0
Data 1,0,0,1,1,1,1,0,1
Data 0,32,16,16,16,32
Data 0,0

' NORTH
Data 1,0,1,1,1,1,0,1,1
Data 0,32,0,16,16,16
Data 0,0
Data 1,0,1,0,1,1,0,0,1
Data 0,32,16,16,16,32
Data 0,0

' WEST
Data 0,0,1,0,1,1,0,1,0
Data 0,32,0,16,16,16
Data 0,0
Data 0,0,1,0,1,0,0,0,0
Data 0,32,16,16,16,32
Data 0,0

' TOP
Data 0,1,0,0,1,1,1,1,1
Data 0,16,0,0,16,0
Data 0,3
Data 0,1,0,1,1,1,1,1,0
Data 0,16,16,0,16,16
Data 0,3

' BOTTOM
Data 1,0,1,0,0,1,0,0,0
Data 0,48,0,32,16,32
Data 0,3
Data 1,0,1,0,0,0,1,0,0
Data 0,48,16,32,16,48
Data 0,3


' Multiply a 3D vector into a 4x4 matrix and output another 3D vector
'
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


Function ReadTexel& (ccol As Single, rrow As Single) Static
    Select Case T1_Filter_Selection
        Case 0
            ReadTexel& = ReadTexelNearest&(ccol, rrow)
        Case 1
            ReadTexel& = ReadTexel3Point&(ccol, rrow)
        Case 2
            ReadTexel& = ReadTexelBiLinearFix&(ccol, rrow)
        Case 3
            ReadTexel& = ReadTexelBiLinear&(ccol, rrow)
    End Select
End Function


Function ReadTexelNearest& (ccol As Single, rrow As Single) Static
    ' Relies on some shared variables over by Texture1
    Static cc As Integer
    Static rr As Integer

    ' Decided just to tile the texture if out of bounds
    cc = Int(ccol) And T1_width_MASK
    rr = Int(rrow) And T1_height_MASK

    ReadTexelNearest& = Texture1(cc, rr)
End Function


Function ReadTexel3Point& (ccol As Single, rrow As Single) Static
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

    Static uv_0_0 As Long
    Static uv_1_1 As Long
    Static uv_f As Long

    Static r0 As Long
    Static g0 As Long
    Static b0 As Long

    Static cm5 As Single
    Static rm5 As Single

    ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
    cm5 = ccol - 0.5
    rm5 = rrow - 0.5

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

    uv_0_0 = Texture1(cc, rr)
    uv_1_1 = Texture1(cc1, rr1)

    Frac_cc1 = cm5 - Int(cm5)
    Frac_rr1 = rm5 - Int(rm5)

    If Frac_cc1 > Frac_rr1 Then
        ' top-right
        ' Area of a triangle = 1/2 * base * height
        ' Using twice the areas (rectangles) to eliminate a multiply by 1/2 and a later divide by 1/2
        Area_11 = Frac_rr1
        Area_00 = 1.0 - Frac_cc1
        uv_f = Texture1(cc1, rr)
    Else
        ' bottom-left
        Area_00 = 1.0 - Frac_rr1
        Area_11 = Frac_cc1
        uv_f = Texture1(cc, rr1)
    End If

    Area_2f = 1.0 - (Area_00 + Area_11) '1.0 here is twice the total triangle area.

    r0 = _Red32(uv_f) * Area_2f + _Red32(uv_0_0) * Area_00 + _Red32(uv_1_1) * Area_11
    g0 = _Green32(uv_f) * Area_2f + _Green32(uv_0_0) * Area_00 + _Green32(uv_1_1) * Area_11
    b0 = _Blue32(uv_f) * Area_2f + _Blue32(uv_0_0) * Area_00 + _Blue32(uv_1_1) * Area_11

    'ReadTexel3Point& = _RGB32(r0, g0, b0)
    ReadTexel3Point& = _ShL(r0, 16) Or _ShL(g0, 8) Or b0
End Function


Function ReadTexelBiLinear& (ccol As Single, rrow As Single)
    ' Relies on some shared variables over by Texture1
    Static cc As Integer
    Static rr As Integer
    Static cc1 As Integer
    Static rr1 As Integer

    Static Frac_cc As Single
    Static Frac_rr As Single
    Static Frac_cc1 As Single
    Static Frac_rr1 As Single

    Static uv_0_0 As Long
    Static uv_0_1 As Long
    Static uv_1_0 As Long
    Static uv_1_1 As Long

    Static r0 As Long
    Static g0 As Long
    Static b0 As Long
    Static r1 As Long
    Static g1 As Long
    Static b1 As Long

    Static cm5 As Single
    Static rm5 As Single

    cm5 = ccol - 0.5
    rm5 = rrow - 0.5

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

    uv_0_0 = Texture1(cc, rr)
    uv_1_0 = Texture1(cc1, rr)
    uv_0_1 = Texture1(cc, rr1)
    uv_1_1 = Texture1(cc1, rr1)

    Frac_cc1 = cm5 - Int(cm5)
    Frac_rr1 = rm5 - Int(rm5)
    Frac_cc = 1.0 - Frac_cc1
    Frac_rr = 1.0 - Frac_rr1

    r0 = _Red32(uv_0_0) * Frac_cc + _Red32(uv_1_0) * Frac_cc1
    g0 = _Green32(uv_0_0) * Frac_cc + _Green32(uv_1_0) * Frac_cc1
    b0 = _Blue32(uv_0_0) * Frac_cc + _Blue32(uv_1_0) * Frac_cc1

    r1 = _Red32(uv_0_1) * Frac_cc + _Red32(uv_1_1) * Frac_cc1
    g1 = _Green32(uv_0_1) * Frac_cc + _Green32(uv_1_1) * Frac_cc1
    b1 = _Blue32(uv_0_1) * Frac_cc + _Blue32(uv_1_1) * Frac_cc1

    ReadTexelBiLinear& = _RGB32(r0 * Frac_rr + r1 * Frac_rr1, g0 * Frac_rr + g1 * Frac_rr1, b0 * Frac_rr + b1 * Frac_rr1)
End Function


Function ReadTexelBiLinearFix& (ccol As Single, rrow As Single) Static
    ' caching of 4 texels
    Static this_cache As _Unsigned Long
    Static uv_0_0 As Long
    Static uv_0_1 As Long
    Static uv_1_0 As Long
    Static uv_1_1 As Long

    ' Relies on some shared variables over by Texture1
    Static cc As _Unsigned Integer
    Static rr As _Unsigned Integer
    Static cc1 As _Unsigned Integer
    Static rr1 As _Unsigned Integer

    'Static Frac_cc1 As Single
    'Static Frac_rr1 As Single

    Static Frac_cc1_FIX7 As Integer
    Static Frac_rr1_FIX7 As Integer

    Static r0 As Integer
    Static g0 As Integer
    Static b0 As Integer
    Static r1 As Integer
    Static g1 As Integer
    Static b1 As Integer

    Static cm5 As Single
    Static rm5 As Single

    cm5 = ccol - 0.5
    rm5 = rrow - 0.5

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

    'Frac_cc1 = cm5 - Int(cm5)
    Frac_cc1_FIX7 = (cm5 - Int(cm5)) * 128
    'Frac_rr1 = rm5 - Int(rm5)
    Frac_rr1_FIX7 = (rm5 - Int(rm5)) * 128

    ' cache
    this_cache = _ShL(rr, 16) Or cc
    If this_cache <> T1_last_cache Then
        uv_0_0 = Texture1(cc, rr)
        uv_1_0 = Texture1(cc1, rr)
        uv_0_1 = Texture1(cc, rr1)
        uv_1_1 = Texture1(cc1, rr1)
        T1_last_cache = this_cache
        ' uncomment below to show cache miss in yellow
        'ReadTexelBiLinearFix& = _RGB32(255, 255, 127)
        'Exit Function
    End If

    r0 = _Red32(uv_0_0)
    r0 = _ShR((_Red32(uv_1_0) - r0) * Frac_cc1_FIX7, 7) + r0

    g0 = _Green32(uv_0_0)
    g0 = _ShR((_Green32(uv_1_0) - g0) * Frac_cc1_FIX7, 7) + g0

    b0 = _Blue32(uv_0_0)
    b0 = _ShR((_Blue32(uv_1_0) - b0) * Frac_cc1_FIX7, 7) + b0

    r1 = _Red32(uv_0_1)
    r1 = _ShR((_Red32(uv_1_1) - r1) * Frac_cc1_FIX7, 7) + r1

    g1 = _Green32(uv_0_1)
    g1 = _ShR((_Green32(uv_1_1) - g1) * Frac_cc1_FIX7, 7) + g1

    b1 = _Blue32(uv_0_1)
    b1 = _ShR((_Blue32(uv_1_1) - b1) * Frac_cc1_FIX7, 7) + b1

    ReadTexelBiLinearFix& = _ShL(_ShR((r1 - r0) * Frac_rr1_FIX7, 7) + r0, 16) Or _ShL(_ShR((g1 - g0) * Frac_rr1_FIX7, 7) + g0, 8) Or _ShR((b1 - b0) * Frac_rr1_FIX7, 7) + b0
End Function


Function RGB_Fog& (zz As Single, RGB_color As _Unsigned Long) Static
    Static r0 As Long
    Static g0 As Long
    Static b0 As Long
    Static fog_scale As Single

    If zz <= Fog_near Then
        RGB_Fog& = RGB_color
    ElseIf zz >= Fog_far Then
        RGB_Fog& = Fog_color
    Else
        fog_scale = (zz - Fog_near) * Fog_rate
        r0 = _Red32(RGB_color)
        g0 = _Green32(RGB_color)
        b0 = _Blue32(RGB_color)

        RGB_Fog& = _RGB32((Fog_R - r0) * fog_scale + r0, (Fog_G - g0) * fog_scale + g0, (Fog_B - b0) * fog_scale + b0)
    End If
End Function


Function RGB_Lit& (RGB_color As _Unsigned Long) Static
    Static scale As Single
    scale = Light_Directional + Light_AmbientVal ' oversaturate the bright colors

    RGB_Lit& = _RGB32(scale * _Red32(RGB_color), scale * _Green32(RGB_color), scale * _Blue32(RGB_color)) 'values over 255 are just clamped to 255
End Function


Function RGB_Sum& (RGB_1 As _Unsigned Long, RGB_2 As _Unsigned Long) Static
    ' Lighten function
    Static r1 As Long
    Static g1 As Long
    Static b1 As Long
    Static r2 As Long
    Static g2 As Long
    Static b2 As Long

    r1 = _Red32(RGB_1)
    g1 = _Green32(RGB_1)
    b1 = _Blue32(RGB_1)
    r2 = _Red32(RGB_2)
    g2 = _Green32(RGB_2)
    b2 = _Blue32(RGB_2)

    RGB_Sum& = _RGB32(r1 + r2, g1 + g2, b1 + b2) ' values over 255 are just clamped to 255
End Function


Function RGB_Modulate& (RGB_1 As _Unsigned Long, RGB_Mod As _Unsigned Long) Static
    ' Darken function
    Static r1 As Integer
    Static g1 As Integer
    Static b1 As Integer
    Static r2 As Integer
    Static g2 As Integer
    Static b2 As Integer

    r1 = _Red32(RGB_1)
    g1 = _Green32(RGB_1)
    b1 = _Blue32(RGB_1)
    r2 = _Red32(RGB_Mod) + 1 'make it so that 255 is 1.0
    g2 = _Green32(RGB_Mod) + 1 'but do it in a way that is not a division
    b2 = _Blue32(RGB_Mod) + 1

    RGB_Modulate& = _RGB32(_ShR(r1 * r2, 8), _ShR(g1 * g2, 8), _ShR(b1 * b2, 8))
End Function


Sub RGB_Dither555 (col As Long, row As Long, RGB_1 As _Unsigned Long) Static
    Static r1 As Long
    Static g1 As Long
    Static b1 As Long
    Static r2 As Long
    Static g2 As Long
    Static b2 As Long
    Static threshold As Long

    ' Extract bit fields
    r1 = _Red32(RGB_1)
    g1 = _Green32(RGB_1)
    b1 = _Blue32(RGB_1)
    r2 = r1 And 7
    g2 = g1 And 7
    b2 = b1 And 7

    ' Duplicate the 3 MSB into the 3 LSB
    ' This is because if you just zero the 3 LSB, you'll never hit full 255 brightness.
    ' We need to act like the DAC only has 5 bits instead of 8.
    r1 = (r1 And &HFFF8) Or _ShR(r1, 5)
    g1 = (g1 And &HFFF8) Or _ShR(g1, 5)
    b1 = (b1 And &HFFF8) Or _ShR(b1, 5)

    ' Compare the fractional LSB amount to the 4x4 Bayer matrix.
    ' Select the next brighter color component if threshold is reached.
    threshold = Dither4(col And 3, row And 3)
    If r2 >= threshold Then r1 = r1 + 9
    If g2 >= threshold Then g1 = g1 + 9
    If b2 >= threshold Then b1 = b1 + 9

    PSet (col, row), _RGB32(r1, g1, b1) ' Relying on >255 clamped to 255
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

    ' Stepping along the X direction
    Static delta_x As Single
    Static prestep_x As Single
    Static tex_w_step As Single, tex_u_step As Single, tex_v_step As Single
    Static tex_r_step As Single, tex_g_step As Single, tex_b_step As Single

    ' X Accumulators
    Static tex_w As Single, tex_u As Single, tex_v As Single
    Static tex_r As Single, tex_g As Single, tex_b As Single

    ' Invalidate texel cache
    T1_last_cache = &HFFFFFFFF

    row = draw_min_y
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
            zbuf_index = row * Size_Render_X + col
            While col < draw_max_x
                tex_z = 1 / tex_w
                If Screen_Z_Buffer(zbuf_index) = 0.0 Or tex_z < Screen_Z_Buffer(zbuf_index) Then
                    Screen_Z_Buffer(zbuf_index) = tex_z + Z_Fight_Bias

                    RGB_Dither555 col, row, RGB_Fog&(tex_z, RGB_Lit&(RGB_Modulate&(ReadTexel&(tex_u * tex_z, tex_v * tex_z), _RGB32(tex_r, tex_g, tex_b))))

                End If ' tex_z
                zbuf_index = zbuf_index + 1
                tex_w = tex_w + tex_w_step
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                tex_r = tex_r + tex_r_step
                tex_g = tex_g + tex_g_step
                tex_b = tex_b + tex_b_step
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

        row = row + 1
    Wend ' row

End Sub

