OPTION _EXPLICIT
_TITLE "Alias Object File 62"
' 2024 Haggarman
'  V62 Simplify 3D point perspective projection function. map_d forces on backface.
'  V61 Turntable and other selectable spin rotations.
'  V59 optional -clamp texture coordinates but be aware Windows 10 3D Viewer does not like it.
'  V58 Environment Map and Backface toggle.
'  V56 Near frustum plane clipping. Mainly for room interior models.
'  V53 camera movement speed adjustment using + or - keys.
'  V52 fix mesh being mirrored due to -Z and CCW winding order differences.
'  V49 fix bad last vt on a 4 vertex face, example: f 1/1 2/2 3/3 4/4
'  V44 Load Kd texture maps
'  V43 Pre-rotate the vertexes to gain about 10 ms on large objects.
'  V41 obj illumination model
'  V34 Any size skybox texture dimensions
'  V31 Mirror Reflective Surface
'  V30 Skybox
'  V26 Experiments with using half-angle instead of bounce reflection for specular.
'  V23 Specular gouraud.
'  V19 Re-introduce texture mapping, although you only get red brick for now.
'  V17 is where the directional lighting using vertex normals is functioning.
'
'  Press G to toggle face lighting method, if vertex normals are available.
'  Press E to toggle skybox environment map.
'  Press B to toggle backface rendering.
'  Press S to toggle spin (move the model). J to select motion type. O resets angles.
'
' Camera and matrix math code translated from the works of Javidx9 OneLoneCoder.
' Texel interpolation and triangle drawing code by me.
'
DECLARE LIBRARY ""
    ' grab a C99 function from math.h
    FUNCTION powf! (BYVAL ba!, BYVAL ex!)
END DECLARE

DIM SHARED DISP_IMAGE AS LONG
DIM SHARED WORK_IMAGE AS LONG
DIM SHARED Size_Screen_X AS INTEGER, Size_Screen_Y AS INTEGER
DIM SHARED Size_Render_X AS INTEGER, Size_Render_Y AS INTEGER
DIM Actor_Count AS INTEGER
Actor_Count = 1 ' keep at 1 for now
DIM SHARED Camera_Start_Z
DIM Obj_File_Path AS STRING


' MODIFY THESE if you want.
Obj_File_Path = "" ' "bunny.obj" "cube.obj" "teacup.obj" "spoonfix.obj" empty string shows system open file dialog box.
Size_Screen_X = 1024
Size_Screen_Y = 768
Size_Render_X = Size_Screen_X \ 2 ' render size
Size_Render_Y = Size_Screen_Y \ 2
Camera_Start_Z = -6.0

DISP_IMAGE = _NEWIMAGE(Size_Screen_X, Size_Screen_Y, 32)
SCREEN DISP_IMAGE

WORK_IMAGE = _NEWIMAGE(Size_Render_X, Size_Render_Y, 32)
_DONTBLEND

DIM SHARED Screen_Z_Buffer_MaxElement AS LONG
Screen_Z_Buffer_MaxElement = Size_Render_X * Size_Render_Y - 1
DIM SHARED Screen_Z_Buffer(Screen_Z_Buffer_MaxElement) AS SINGLE

TYPE vec3d
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE vec4d
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
    w AS SINGLE
END TYPE

TYPE mesh_triangle
    i0 AS LONG ' vertex index
    i1 AS LONG
    i2 AS LONG

    vni0 AS LONG ' vector normal index
    vni1 AS LONG
    vni2 AS LONG

    u0 AS SINGLE ' texture coords
    v0 AS SINGLE
    u1 AS SINGLE
    v1 AS SINGLE
    u2 AS SINGLE
    v2 AS SINGLE

    options AS _UNSIGNED LONG
    material AS LONG
END TYPE

TYPE skybox_triangle
    x0 AS SINGLE
    y0 AS SINGLE
    z0 AS SINGLE
    x1 AS SINGLE
    y1 AS SINGLE
    z1 AS SINGLE
    x2 AS SINGLE
    y2 AS SINGLE
    z2 AS SINGLE

    u0 AS SINGLE
    v0 AS SINGLE
    u1 AS SINGLE
    v1 AS SINGLE
    u2 AS SINGLE
    v2 AS SINGLE
    texture AS _UNSIGNED LONG
END TYPE

TYPE vertex5
    x AS SINGLE
    y AS SINGLE
    w AS SINGLE
    u AS SINGLE
    v AS SINGLE
END TYPE

TYPE vertex9
    x AS SINGLE
    y AS SINGLE
    w AS SINGLE
    u AS SINGLE
    v AS SINGLE
    r AS SINGLE
    g AS SINGLE
    b AS SINGLE
    a AS SINGLE ' alpha ranges from 0.0 to 1.0 for less conversion calculations
END TYPE

TYPE vertex_attribute5
    u AS SINGLE
    v AS SINGLE
    r AS SINGLE
    g AS SINGLE
    b AS SINGLE
END TYPE

TYPE vertex_attribute7
    u AS SINGLE
    v AS SINGLE
    r AS SINGLE
    g AS SINGLE
    b AS SINGLE
    s AS SINGLE
    t AS SINGLE
END TYPE

TYPE objectlist_type
    viewz AS SINGLE
    psn AS vec3d
    first AS LONG
    last AS LONG
END TYPE

TYPE newmtl_type
    illum AS LONG '  illumination model
    options AS _UNSIGNED LONG
    map_Kd AS LONG ' image handle to diffuse texture map when -2 or lower
    Kd_r AS SINGLE ' diffuse color (main color)
    Kd_g AS SINGLE
    Kd_b AS SINGLE
    Ks_r AS SINGLE ' specular color
    Ks_g AS SINGLE
    Ks_b AS SINGLE
    Ns AS SINGLE ' specular power exponent (0 to 1000)
    diaphaneity AS SINGLE ' translucency where 1.0 means fully opaque. Strangely, Alias Wavefront documentation calls this dissolve.
    textName AS STRING
END TYPE

TYPE texture_catalog_type
    textName AS STRING
    imageHandle AS LONG
END TYPE

CONST illum_model_constant_color = 0 ' Kd only
CONST illum_model_lambertian = 1 ' ambient constant term plus a diffuse shading term for the angle of each light source
CONST illum_model_blinn_phong = 2 ' ambient constant term, plus a diffuse and specular shading term for each light source
CONST illum_model_reflection_map_raytrace = 3 ' like model 2, plus Ks * (reflection map + raytracing)
CONST illum_model_glass_map_raytrace = 4 ' When dissolve < 0.1, specular highlights from lights or reflections become imperceptible.
CONST illum_model_fresnel = 5
CONST illum_model_refraction = 6 ' uses optical density (Ni) and resulting light is filtered by Tf (transmission filter)
CONST illum_model_fresnel_refraction = 7
CONST illum_model_reflection_map = 8 ' like model 2, plus Ks * reflection map. (but without raytracing)
CONST illum_model_glass_map = 9 ' like model 4, but without raytrace
CONST illum_model_shadow_only = 10 ' movie film shadowmatte

' Projection Matrix
DIM SHARED Frustum_Near AS SINGLE
DIM Frustum_Far AS SINGLE
DIM Frustum_FOV_deg AS SINGLE
DIM Frustum_Aspect_Ratio AS SINGLE
DIM Frustum_FOV_ratio AS SINGLE

Frustum_Near = 0.1
Frustum_Far = 1000.0
Frustum_FOV_deg = 60.0
Frustum_Aspect_Ratio = _HEIGHT / _WIDTH
Frustum_FOV_ratio = 1.0 / TAN(_D2R(Frustum_FOV_deg * 0.5)) ' 90 degrees gives 1.0

DIM matProj(3, 3) AS SINGLE
matProj(0, 0) = Frustum_Aspect_Ratio * Frustum_FOV_ratio ' output X = input X * factors. The screen is wider than it is tall.
matProj(1, 1) = -Frustum_FOV_ratio ' output Y = input Y * factors. Negate so that +Y is up
matProj(2, 2) = Frustum_Far / (Frustum_Far - Frustum_Near) ' remap output Z between near and far planes, scale factor applied to input Z.
matProj(3, 2) = (-Frustum_Far * Frustum_Near) / (Frustum_Far - Frustum_Near) ' remap output Z between near and far planes, constant offset.
matProj(2, 3) = 1.0 ' divide outputs X and Y by input Z.
' All other matrix elements assumed 0.0

' Viewing area clipping
DIM SHARED clip_min_y AS LONG, clip_max_y AS LONG
DIM SHARED clip_min_x AS LONG, clip_max_x AS LONG
clip_min_y = 1
clip_max_y = Size_Render_Y - 2
clip_min_x = 1
clip_max_x = Size_Render_X - 1

' Fog
DIM SHARED Fog_near AS SINGLE, Fog_far AS SINGLE, Fog_rate AS SINGLE
DIM SHARED Fog_color AS LONG
DIM SHARED Fog_R AS LONG, Fog_G AS LONG, Fog_B AS LONG
Fog_near = 9.0
Fog_far = 19.0
Fog_rate = 1.0 / (Fog_far - Fog_near)

Fog_color = _RGB32(111, 177, 233)
'Fog_color = _RGB32(2, 2, 2)
Fog_R = _RED(Fog_color)
Fog_G = _GREEN(Fog_color)
Fog_B = _BLUE(Fog_color)

' Z Fight has to do with overdrawing on top of the same coplanar surface.
' If it is positive, a newer pixel at the same exact Z will always overdraw the older one.
DIM SHARED Z_Fight_Bias
Z_Fight_Bias = -0.000061


' These T1 Texture characteristics are read later on during drawing.
DIM SHARED T1_ImageHandle AS LONG
DIM SHARED T1_width AS INTEGER, T1_height AS INTEGER
DIM SHARED T1_width_MASK AS INTEGER, T1_height_MASK AS INTEGER
DIM SHARED T1_mblock AS _MEM
DIM SHARED T1_Alpha_Threshold AS INTEGER

' Texture sampling
DIM SHARED Texture_options AS _UNSIGNED LONG
CONST T1_option_clamp_width = 1
CONST T1_option_clamp_height = 2
CONST T1_option_no_Z_write = 4
CONST T1_option_no_backface_cull = 16
CONST T1_option_metallic = 32768
CONST T1_option_no_T1 = 65536
CONST oneOver255 = 1.0 / 255.0

' Give sensible defaults to avoid crashes or invisible textures.
' Later optimization in ReadTexel requires these to be powers of 2.
' That means: 2,4,8,16,32,64,128,256...
T1_width = 16: T1_width_MASK = T1_width - 1
T1_height = 16: T1_height_MASK = T1_height - 1
T1_Alpha_Threshold = 250 ' below this alpha channel value, do not update z buffer (0..255)

' Texture1 math
DIM SHARED T1_mod_R AS SINGLE ' simulate a generic color register
DIM SHARED T1_mod_G AS SINGLE
DIM SHARED T1_mod_B AS SINGLE
DIM SHARED T1_mod_A AS SINGLE
T1_mod_R = 1.0
T1_mod_G = 1.0
T1_mod_B = 1.0
T1_mod_A = 1.0

DIM SHARED TextureCatalog(90) AS texture_catalog_type
DIM SHARED TextureCatalog_nextIndex
TextureCatalog_nextIndex = 0


' Load Skybox
'     +---+
'     | 2 |
' +---+---+---+---+
' | 1 | 4 | 0 | 5 |
' +---+---+---+---+
'     | 3 |
'     +---+

DIM SHARED SkyBoxRef(5) AS LONG
SkyBoxRef(0) = _LOADIMAGE("px.png", 32)
SkyBoxRef(1) = _LOADIMAGE("nx.png", 32)
SkyBoxRef(2) = _LOADIMAGE("py.png", 32)
SkyBoxRef(3) = _LOADIMAGE("ny.png", 32)
SkyBoxRef(4) = _LOADIMAGE("pz.png", 32)
SkyBoxRef(5) = _LOADIMAGE("nz.png", 32)

' Error _LoadImage returns -1 as an invalid handle if it cannot load the image.
DIM refIndex AS INTEGER
FOR refIndex = 0 TO 5
    IF SkyBoxRef(refIndex) = -1 THEN
        PRINT "Could not load texture file for skybox face: "; refIndex
        END
    END IF
NEXT refIndex

DIM SHARED Sky_Last_Element AS INTEGER
Sky_Last_Element = 11
DIM sky(Sky_Last_Element) AS skybox_triangle
RESTORE SKYBOX
FOR refIndex = 0 TO Sky_Last_Element
    READ sky(refIndex).x0: READ sky(refIndex).y0: READ sky(refIndex).z0
    READ sky(refIndex).x1: READ sky(refIndex).y1: READ sky(refIndex).z1
    READ sky(refIndex).x2: READ sky(refIndex).y2: READ sky(refIndex).z2

    READ sky(refIndex).u0: READ sky(refIndex).v0
    READ sky(refIndex).u1: READ sky(refIndex).v1
    READ sky(refIndex).u2: READ sky(refIndex).v2

    READ sky(refIndex).texture
    ' Fill in Texture 1 data
    T1_ImageHandle = SkyBoxRef(sky(refIndex).texture)
    T1_mblock = _MEMIMAGE(T1_ImageHandle)
    T1_width = _WIDTH(T1_ImageHandle): T1_width_MASK = T1_width - 1
    T1_height = _HEIGHT(T1_ImageHandle): T1_height_MASK = T1_height - 1

    ' any size
    sky(refIndex).u0 = sky(refIndex).u0 * T1_width: sky(refIndex).v0 = sky(refIndex).v0 * T1_height
    sky(refIndex).u1 = sky(refIndex).u1 * T1_width: sky(refIndex).v1 = sky(refIndex).v1 * T1_height
    sky(refIndex).u2 = sky(refIndex).u2 * T1_width: sky(refIndex).v2 = sky(refIndex).v2 * T1_height
NEXT refIndex

' Load Mesh
WHILE Obj_File_Path = ""
    Obj_File_Path = _OPENFILEDIALOG$("Load Alias Object File", , "*.OBJ|*.obj")
    IF Obj_File_Path = "" THEN END
WEND

DIM SHARED Objects_Last_Element AS INTEGER
Objects_Last_Element = Actor_Count
DIM Objects(Objects_Last_Element) AS objectlist_type
' index 0 will be invisible

DIM SHARED Mesh_Last_Element AS LONG ' number of triangles, 1 is the minimum
DIM SHARED Vertex_Count AS LONG ' 3 is the minimum
DIM SHARED TextureCoord_Count AS LONG ' can be 0, textures are optional
DIM SHARED Vtx_Normals_Count AS LONG ' can be 0, vertex normals are optional
DIM SHARED Material_File_Count AS LONG
DIM SHARED Obj_Directory AS STRING
DIM SHARED Obj_FileNameOnly AS STRING
DIM SHARED Material_File_Name AS STRING
DIM SHARED Material_File_Path AS STRING
DIM SHARED Materials_Count AS LONG
DIM SHARED Hidden_Materials_Count AS LONG

' Isolate the object's directory from its full file path.
' This is because an object file refers to other files that need to be loaded.
DIM fpps AS INTEGER
fpps = 0
DIM i AS INTEGER
FOR i = LEN(Obj_File_Path) TO 1 STEP -1
    IF ASC(Obj_File_Path, i) = 92 OR ASC(Obj_File_Path, i) = 47 THEN
        ' found a / slash \
        fpps = i
        EXIT FOR
    END IF
NEXT i

IF fpps > 0 THEN
    Obj_Directory = LEFT$(Obj_File_Path, fpps)
    Obj_FileNameOnly = MID$(Obj_File_Path, fpps + 1)
ELSE
    ' within current working directory
    Obj_Directory = ""
    Obj_FileNameOnly = Obj_File_Path
END IF
PRINT "Loading "; Obj_FileNameOnly

PrescanMesh Obj_File_Path, Mesh_Last_Element, Vertex_Count, TextureCoord_Count, Vtx_Normals_Count, Material_File_Count, Material_File_Name
IF Mesh_Last_Element = 0 THEN
    COLOR _RGB(249, 161, 50)
    PRINT "Error Loading Object File "; Obj_File_Path
    END
END IF

Material_File_Path = Obj_Directory + Material_File_Name
IF Material_File_Count >= 1 THEN
    PrescanMaterialFile Material_File_Path, Materials_Count
    IF Materials_Count = 0 THEN
        COLOR _RGB(249, 161, 50)
        PRINT "Error Loading Material File "; Material_File_Name
        PRINT "Material Full Path "; Material_File_Path
        END
    END IF
END IF

' always create at least one material. 0 just creates a single element index 0.
DIM SHARED Materials(Materials_Count) AS newmtl_type
' sensible defaults to at least show something.
Materials(0).illum = 2
Materials(0).options = T1_option_no_T1
Materials(0).map_Kd = 0 ' invalid handle intentionally
Materials(0).diaphaneity = 1.0
Materials(0).Kd_r = 0.5: Materials(0).Kd_g = 0.5: Materials(0).Kd_b = 0.5
Materials(0).Ks_r = 0.25: Materials(0).Ks_g = 0.25: Materials(0).Ks_b = 0.25
Materials(0).Ns = 18

DIM L AS LONG
IF Material_File_Count >= 1 THEN
    LoadMaterialFile Material_File_Path, Materials(), Materials_Count, Hidden_Materials_Count

    IF Hidden_Materials_Count > 0 THEN
        DIM ratio AS LONG
        IF Hidden_Materials_Count > Materials_Count \ 2 THEN ratio = 1 ELSE ratio = 0
        DIM askhidden$
        askhidden$ = STR$(Hidden_Materials_Count) + " of " + STR$(Materials_Count) + " materials are hidden. Make them visible?"
        IF _MESSAGEBOX("Material File", askhidden$, "yesno", "question", ratio) = 1 THEN
            FOR L = 1 TO Materials_Count
                IF Materials(L).diaphaneity = 0.0 THEN Materials(L).diaphaneity = 1.0
            NEXT L
        END IF
    END IF
ELSE
    PRINT "No Material File specified"
END IF

' create and start reading in the triangle mesh
DIM SHARED mesh(Mesh_Last_Element) AS mesh_triangle

' 10-5-2024
DIM VertexList(Vertex_Count) AS vec3d
DIM VtxNorms(Vtx_Normals_Count) AS vec3d


DIM actor AS INTEGER
DIM tri AS LONG
tri = 0
FOR actor = 1 TO Actor_Count
    Objects(actor).first = tri + 1
    LoadMesh Obj_File_Path, mesh(), tri, VertexList(), TextureCoord_Count, VtxNorms(), Materials()
    Objects(actor).last = tri
NEXT actor

' find the furthest out point to be able to pull back camera start position for large objects
DIM index_v AS LONG
DIM distance AS DOUBLE
DIM GreatestDistance AS DOUBLE
GreatestDistance = 0.0
FOR tri = 1 TO Mesh_Last_Element
    index_v = mesh(tri).i0
    distance = VertexList(index_v).x * VertexList(index_v).x + VertexList(index_v).y * VertexList(index_v).y + VertexList(index_v).z * VertexList(index_v).z
    IF distance > GreatestDistance THEN GreatestDistance = distance

    index_v = mesh(tri).i1
    distance = VertexList(index_v).x * VertexList(index_v).x + VertexList(index_v).y * VertexList(index_v).y + VertexList(index_v).z * VertexList(index_v).z
    IF distance > GreatestDistance THEN GreatestDistance = distance

    index_v = mesh(tri).i2
    distance = VertexList(index_v).x * VertexList(index_v).x + VertexList(index_v).y * VertexList(index_v).y + VertexList(index_v).z * VertexList(index_v).z
    IF distance > GreatestDistance THEN GreatestDistance = distance
NEXT tri
GreatestDistance = SQR(GreatestDistance)
distance = -2.0 * GreatestDistance
IF distance < Camera_Start_Z THEN Camera_Start_Z = distance


' Here are the 3D math and projection vars
DIM object_vertexes(Vertex_Count) AS vec3d

' Rotation
DIM matRotObjX(3, 3) AS SINGLE
DIM matRotObjY(3, 3) AS SINGLE
DIM matRotObjZ(3, 3) AS SINGLE
DIM pointRotObj1 AS vec3d
DIM pointRotObj2 AS vec3d

DIM point0 AS vec3d
DIM point1 AS vec3d
DIM point2 AS vec3d

' Translation (as in offset)
DIM pointWorld0 AS vec3d
DIM pointWorld1 AS vec3d
DIM pointWorld2 AS vec3d

' View Space 2-10-2023
DIM matView(3, 3) AS SINGLE
DIM pointView0 AS vec3d
DIM pointView1 AS vec3d
DIM pointView2 AS vec3d
DIM pointView3 AS vec3d ' extra clipped tri

' Near frustum clipping 2-27-2023
DIM SHARED vatr0 AS vertex_attribute7
DIM SHARED vatr1 AS vertex_attribute7
DIM SHARED vatr2 AS vertex_attribute7
DIM SHARED vatr3 AS vertex_attribute7

' Projection
DIM pointProj0 AS vec4d ' added w
DIM pointProj1 AS vec4d
DIM pointProj2 AS vec4d
DIM pointProj3 AS vec4d ' extra clipped tri

' Surface Normal Calculation
' Part 2
DIM tri_normal AS vec3d
' 6-1-2024
DIM vertex_normal_A AS vec3d
DIM vertex_normal_B AS vec3d
DIM vertex_normal_C AS vec3d
DIM object_vtx_normals(Vtx_Normals_Count) AS vec3d

' Part 2-2
DIM vCameraPsn AS vec3d ' location of camera in world space
vCameraPsn.x = 0.0
vCameraPsn.y = 0.0
vCameraPsn.z = Camera_Start_Z

DIM vCameraPsnNext AS vec3d
DIM cameraRay0 AS vec3d
DIM dotProductCam AS SINGLE

' Adjustable camera movement speed
CONST CameraSpeedLevel_max = 12
DIM SHARED CameraSpeedLookup(CameraSpeedLevel_max) AS SINGLE
DIM SHARED CameraSpeedLevel AS INTEGER
CameraSpeedLevel = 5
FOR i = 0 TO CameraSpeedLevel_max
    IF i AND 1 THEN
        ' odd fives
        CameraSpeedLookup(i) = 0.5 * powf(10.0, i \ 2 - 2)
    ELSE
        ' even tens
        CameraSpeedLookup(i) = powf(10.0, i \ 2 - 3)
    END IF
NEXT i

' View Space 2-10-2023
DIM fPitch AS SINGLE ' FPS Camera rotation in YZ plane (X)
DIM fYaw AS SINGLE ' FPS Camera rotation in XZ plane (Y)
DIM fRoll AS SINGLE
DIM SHARED matCameraRot(3, 3) AS SINGLE

DIM SHARED vCameraHomeFwd AS vec3d ' Home angle orientation is facing down the Z line.
vCameraHomeFwd.x = 0.0: vCameraHomeFwd.y = 0.0: vCameraHomeFwd.z = 1.0

DIM vCameraTripod AS vec3d ' Home angle orientation of which way is up.
' You could simulate tipping over the camera tripod with something other than y=1, and it will gimbal oddly.
vCameraTripod.x = 0.0: vCameraTripod.y = 1.0: vCameraTripod.z = 0.0

DIM vLookPitch AS vec3d
DIM vLookDir AS vec3d
DIM vCameraTarget AS vec3d
DIM matCamera(3, 3) AS SINGLE


' Directional light 1-17-2023
DIM vLightDir AS vec3d
' When developing, set the light source where the camera starts so you don't go insane when trying to get the specular vectors correct.
vLightDir.x = 0.7411916
vLightDir.y = 0.5735765 '+Y is up
vLightDir.z = -0.3487767 ' Camera_Start_Z
Vector3_Normalize vLightDir
DIM SHARED Light_Directional AS SINGLE
DIM SHARED Light_AmbientVal AS SINGLE
Light_AmbientVal = 0.24 ' High Ambient just washes out the image but whatever it's part of the light model

' Directional lighting using vertex normals
DIM light_directional_A AS SINGLE
DIM light_directional_B AS SINGLE
DIM light_directional_C AS SINGLE
DIM face_light_r AS SINGLE
DIM face_light_g AS SINGLE
DIM face_light_b AS SINGLE

' Specular lighting
DIM cameraRay1 AS vec3d
DIM cameraRay2 AS vec3d
DIM vLightSpec AS vec3d
DIM reflectLightDir0 AS vec3d
DIM reflectLightDir1 AS vec3d
DIM reflectLightDir2 AS vec3d
DIM light_specular_A AS SINGLE
DIM light_specular_B AS SINGLE
DIM light_specular_C AS SINGLE

' Screen Scaling
DIM halfWidth AS SINGLE
DIM halfHeight AS SINGLE
halfWidth = Size_Render_X / 2
halfHeight = Size_Render_Y / 2

' Projected Screen Coordinate List
DIM SX0 AS SINGLE, SY0 AS SINGLE
DIM SX1 AS SINGLE, SY1 AS SINGLE
DIM SX2 AS SINGLE, SY2 AS SINGLE
DIM SX3 AS SINGLE, SY3 AS SINGLE

DIM vertexA AS vertex9
DIM vertexB AS vertex9
DIM vertexC AS vertex9
DIM SHARED envMapReflectionRayA AS vec3d
DIM SHARED envMapReflectionRayB AS vec3d
DIM SHARED envMapReflectionRayC AS vec3d

' This is so that the cube object animates by rotating
DIM spinAngleDegX AS SINGLE
DIM spinAngleDegY AS SINGLE
DIM spinAngleDegZ AS SINGLE
spinAngleDegX = 0.0
spinAngleDegY = 0.0
spinAngleDegZ = 0.0

' code execution time
DIM start_ms AS DOUBLE
DIM trimesh_ms AS DOUBLE
DIM render_ms AS DOUBLE
DIM render_period_ms AS DOUBLE

' physics framerate
DIM frametime_fullframe_ms AS DOUBLE
DIM frametime_fullframethreshold_ms AS DOUBLE
DIM frametimestamp_now_ms AS DOUBLE
DIM frametimestamp_prior_ms AS DOUBLE
DIM frametimestamp_delta_ms AS DOUBLE
DIM frame_advance AS INTEGER
DIM frame_tracking_size AS INTEGER
frame_tracking_size = 30
DIM frame_ts(frame_tracking_size) AS DOUBLE
DIM frame_early_polls(frame_tracking_size) AS LONG

' Main loop stuff
DIM renderPass AS INTEGER
DIM transparencyFactor AS SINGLE
DIM KeyNow AS STRING
DIM ExitCode AS INTEGER
DIM triCount AS INTEGER
DIM Animate_Spin AS INTEGER
DIM Draw_Environment_Map AS INTEGER
DIM Draw_Backface AS INTEGER
DIM Gouraud_Shading_Selection AS INTEGER
DIM Jog_Motion_Selection AS INTEGER
DIM thisMaterial AS newmtl_type
DIM triloop_input_poll AS LONG
DIM SHARED Pixels_Drawn_This_Frame AS LONG

main:
$CHECKING:OFF
ExitCode = 0
Animate_Spin = 0
Draw_Environment_Map = -1
Draw_Backface = 0
Gouraud_Shading_Selection = 1
Jog_Motion_Selection = 1
actor = 1

fPitch = 0.0
fYaw = 0.0
fRoll = 0.0

frametime_fullframe_ms = 1 / 60.0
frametime_fullframethreshold_ms = 1 / 61.0
frametimestamp_prior_ms = TIMER(.001)
frametimestamp_delta_ms = frametime_fullframe_ms
frame_advance = 0

DO
    IF Animate_Spin THEN
        SELECT CASE Jog_Motion_Selection
            CASE 0
                'Print "Zero Orientation"
                spinAngleDegX = 0
                spinAngleDegY = 0
                spinAngleDegZ = 0
                Animate_Spin = 0
            CASE 1
                'Print "Turntable Y-Axis"
                spinAngleDegY = spinAngleDegY + frame_advance * 0.2
            CASE 2
                'Print "Roll X-Axis"
                spinAngleDegX = spinAngleDegX - frame_advance * 0.25
            CASE 3
                'Print "Tumble X and Z"
                spinAngleDegZ = spinAngleDegZ + frame_advance * 0.355
                spinAngleDegX = spinAngleDegX - frame_advance * 0.23
        END SELECT
    END IF
    frame_advance = 0

    ' Set up rotation matrices
    ' _D2R is just a built-in degrees to radians conversion
    Matrix4_MakeRotation_X spinAngleDegX, matRotObjX()
    Matrix4_MakeRotation_Y spinAngleDegY, matRotObjY()
    Matrix4_MakeRotation_Z spinAngleDegZ, matRotObjZ()

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

    start_ms = TIMER(.001)

    _DEST WORK_IMAGE
    _SOURCE WORK_IMAGE

    ' Clear Z-Buffer
    ' This is a qbasic only optimization. it sets the array to zero. it saves 10 ms.
    REDIM Screen_Z_Buffer(Screen_Z_Buffer_MaxElement)

    IF Draw_Environment_Map = 0 THEN
        CLS , Fog_color
    ELSE
        ' Draw Skybox 2-28-2023
        FOR tri = 0 TO Sky_Last_Element
            point0.x = sky(tri).x0
            point0.y = sky(tri).y0
            point0.z = sky(tri).z0

            point1.x = sky(tri).x1
            point1.y = sky(tri).y1
            point1.z = sky(tri).z1

            point2.x = sky(tri).x2
            point2.y = sky(tri).y2
            point2.z = sky(tri).z2

            ' Follow the camera coordinate position (slide)
            ' Skybox is like putting your head inside a floating box that travels with you, but never rotates.
            ' You rotate your head inside the skybox as you look around.
            Vector3_Add point0, vCameraPsn, pointWorld0
            Vector3_Add point1, vCameraPsn, pointWorld1
            Vector3_Add point2, vCameraPsn, pointWorld2

            ' Part 2 (Triangle Surface Normal Calculation)
            CalcSurfaceNormal_3Point pointWorld0, pointWorld1, pointWorld2, tri_normal

            ' The dot product to this skybox surface is just the way you are facing.
            ' The surface completely behind you is going to get later removed with NearClip.
            'Vector3_Delta vCameraPsn, pointWorld0, cameraRay
            'dotProductCam = Vector3_DotProduct!(tri_normal, cameraRay)
            'If dotProductCam > 0.0 Then

            ' Convert World Space --> View Space
            Multiply_Vector3_Matrix4 pointWorld0, matView(), pointView0
            Multiply_Vector3_Matrix4 pointWorld1, matView(), pointView1
            Multiply_Vector3_Matrix4 pointWorld2, matView(), pointView2

            ' Load up attribute lists here because NearClip will interpolate those too.
            vatr0.u = sky(tri).u0: vatr0.v = sky(tri).v0
            vatr1.u = sky(tri).u1: vatr1.v = sky(tri).v1
            vatr2.u = sky(tri).u2: vatr2.v = sky(tri).v2

            ' Clip more often than not in this example
            NearClip pointView0, pointView1, pointView2, pointView3, vatr0, vatr1, vatr2, vatr3, triCount
            IF triCount > 0 THEN
                ' Fill in Texture 1 data
                T1_ImageHandle = SkyBoxRef(sky(tri).texture)
                T1_mblock = _MEMIMAGE(T1_ImageHandle)
                T1_width = _WIDTH(T1_ImageHandle): T1_width_MASK = T1_width - 1
                T1_height = _HEIGHT(T1_ImageHandle): T1_height_MASK = T1_height - 1

                ' Project triangles from 3D -----------------> 2D
                ProjectPerspectiveVector4 pointView0, matProj(), pointProj0
                ProjectPerspectiveVector4 pointView1, matProj(), pointProj1
                ProjectPerspectiveVector4 pointView2, matProj(), pointProj2

                ' Slide to center, then Scale into viewport
                SX0 = (pointProj0.x + 1) * halfWidth
                SY0 = (pointProj0.y + 1) * halfHeight

                SX2 = (pointProj2.x + 1) * halfWidth
                SY2 = (pointProj2.y + 1) * halfHeight

                ' Early scissor reject
                IF pointProj0.x > 1.0 AND pointProj1.x > 1.0 AND pointProj2.x > 1.0 THEN GOTO Lbl_SkipEnv012
                IF pointProj0.x < -1.0 AND pointProj1.x < -1.0 AND pointProj2.x < -1.0 THEN GOTO Lbl_SkipEnv012
                IF pointProj0.y > 1.0 AND pointProj1.y > 1.0 AND pointProj2.y > 1.0 THEN GOTO Lbl_SkipEnv012
                IF pointProj0.y < -1.0 AND pointProj1.y < -1.0 AND pointProj2.y < -1.0 THEN GOTO Lbl_SkipEnv012

                SX1 = (pointProj1.x + 1) * halfWidth
                SY1 = (pointProj1.y + 1) * halfHeight

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

                TexturedNonlitTriangle vertexA, vertexB, vertexC
            END IF

            Lbl_SkipEnv012:
            IF triCount = 2 THEN

                ProjectPerspectiveVector4 pointView3, matProj(), pointProj3

                ' Late scissor reject
                IF (pointProj0.x > 1.0) AND (pointProj2.x > 1.0) AND (pointProj3.x > 1.0) THEN GOTO Lbl_SkipEnv023
                IF (pointProj0.x < -1.0) AND (pointProj2.x < -1.0) AND (pointProj3.x < -1.0) THEN GOTO Lbl_SkipEnv023
                IF (pointProj0.y > 1.0) AND (pointProj2.y > 1.0) AND (pointProj3.y > 1.0) THEN GOTO Lbl_SkipEnv023
                IF (pointProj0.y < -1.0) AND (pointProj2.y < -1.0) AND (pointProj3.y < -1.0) THEN GOTO Lbl_SkipEnv023

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
            END IF
            Lbl_SkipEnv023:
        NEXT tri
    END IF ' skybox

    ' pre-rotate the vertexes
    ' object_vertexes() = T.F. vertexList()
    FOR tri = 1 TO Vertex_Count
        ' Rotate in Z-Axis
        Multiply_Vector3_Matrix4 VertexList(tri), matRotObjZ(), pointRotObj1
        ' Rotate in X-Axis
        Multiply_Vector3_Matrix4 pointRotObj1, matRotObjX(), pointRotObj2
        ' Rotate in Y-Axis
        Multiply_Vector3_Matrix4 pointRotObj2, matRotObjY(), object_vertexes(tri)
    NEXT tri

    IF Vtx_Normals_Count > 0 THEN
        ' Vertex normals can be rotated around their origin and still retain their effectiveness.
        ' object_vtx_normals() = T.F. VtxNorms()
        FOR tri = 1 TO Vtx_Normals_Count
            ' Rotate in Z-Axis
            Multiply_Vector3_Matrix4 VtxNorms(tri), matRotObjZ(), pointRotObj1
            ' Rotate in X-Axis
            Multiply_Vector3_Matrix4 pointRotObj1, matRotObjX(), pointRotObj2
            ' Rotate in Y-Axis
            Multiply_Vector3_Matrix4 pointRotObj2, matRotObjY(), object_vtx_normals(tri)
        NEXT tri
    END IF

    triloop_input_poll = 25000 ' because of all of the other stuff above, trigger the first check early.
    vCameraPsnNext = vCameraPsn ' capture where the camera is before starting triangle draw loop
    trimesh_ms = TIMER(0.001)
    Pixels_Drawn_This_Frame = 0
    REDIM frame_early_polls(frame_tracking_size) AS LONG

    ' Draw Triangles
    FOR renderPass = 0 TO 1
        FOR tri = Objects(actor).first TO Objects(actor).last
            transparencyFactor = Materials(mesh(tri).material).diaphaneity ' all illumination models use d
            IF ((renderPass = 0) AND (transparencyFactor < 1.0)) OR ((renderPass = 1) AND (transparencyFactor = 1.0)) THEN GOTO Lbl_SkipTriAll

            ' material
            thisMaterial = Materials(mesh(tri).material)
            ' Combine the material options with this specific triangle's options.
            ' Reason is that a given tri face could possibly omit texture coordinates or backface could be forced on.
            Texture_options = thisMaterial.options OR mesh(tri).options

            ' the object vertexes have been rotated already, so we just need to reference them
            pointWorld0 = object_vertexes(mesh(tri).i0)
            pointWorld1 = object_vertexes(mesh(tri).i1)
            pointWorld2 = object_vertexes(mesh(tri).i2)

            ' Part 2 (Triangle Surface Normal Calculation)
            CalcSurfaceNormal_3Point pointWorld0, pointWorld1, pointWorld2, tri_normal
            Vector3_Delta vCameraPsn, pointWorld0, cameraRay0 ' be careful, this is not normalized.
            dotProductCam = Vector3_DotProduct!(tri_normal, cameraRay0) ' only interested here in the sign

            IF Draw_Backface _ORELSE (dotProductCam < 0.0) _ORELSE (Texture_options AND T1_option_no_backface_cull) THEN
                ' Front facing is negative dot product because obj vertex is specified with counter-clockwise (CCW) winding.
                ' Convert World Space --> View Space
                Multiply_Vector3_Matrix4 pointWorld0, matView(), pointView0
                Multiply_Vector3_Matrix4 pointWorld1, matView(), pointView1
                Multiply_Vector3_Matrix4 pointWorld2, matView(), pointView2

                ' Skip if all Z is too close
                IF (pointView0.z < Frustum_Near) _ANDALSO (pointView1.z < Frustum_Near) _ANDALSO (pointView2.z < Frustum_Near) THEN GOTO Lbl_SkipTriAll

                ' Texture 1
                T1_mod_A = transparencyFactor

                IF (Texture_options AND T1_option_no_T1) = 0 THEN
                    ' still need to check if texture loaded
                    IF thisMaterial.map_Kd >= -1 THEN
                        ' bad texture handle, just use diffuse color
                        Texture_options = Texture_options OR T1_option_no_T1
                    ELSE
                        ' Fill in Texture 1 data
                        T1_ImageHandle = thisMaterial.map_Kd
                        T1_mblock = _MEMIMAGE(T1_ImageHandle)
                        T1_width = _WIDTH(T1_ImageHandle): T1_width_MASK = T1_width - 1
                        T1_height = _HEIGHT(T1_ImageHandle): T1_height_MASK = T1_height - 1

                        ' obj vt (0, 0) is bottom left of a texture, but our texture origin is top left.
                        vatr0.u = mesh(tri).u0 * T1_width
                        vatr0.v = T1_height - mesh(tri).v0 * T1_height
                        vatr1.u = mesh(tri).u1 * T1_width
                        vatr1.v = T1_height - mesh(tri).v1 * T1_height
                        vatr2.u = mesh(tri).u2 * T1_width
                        vatr2.v = T1_height - mesh(tri).v2 * T1_height
                    END IF
                END IF

                ' Lighting
                SELECT CASE thisMaterial.illum
                    CASE illum_model_constant_color
                        ' Kd only

                        IF Texture_options AND T1_option_no_T1 THEN
                            ' define as 8 bit values
                            face_light_r = 255.0 * thisMaterial.Kd_r
                            face_light_g = 255.0 * thisMaterial.Kd_g
                            face_light_b = 255.0 * thisMaterial.Kd_b

                            vatr0.r = face_light_r
                            vatr0.g = face_light_g
                            vatr0.b = face_light_b

                            vatr1.r = face_light_r
                            vatr1.g = face_light_g
                            vatr1.b = face_light_b

                            vatr2.r = face_light_r
                            vatr2.g = face_light_g
                            vatr2.b = face_light_b
                        ELSE
                            ' draw diffuse texture as-is
                            vatr0.r = 1.0
                            vatr0.g = 1.0
                            vatr0.b = 1.0

                            vatr1.r = 1.0
                            vatr1.g = 1.0
                            vatr1.b = 1.0

                            vatr2.r = 1.0
                            vatr2.g = 1.0
                            vatr2.b = 1.0
                        END IF


                    CASE illum_model_lambertian
                        ' ambient constant term plus a diffuse shading term for the angle of each light source

                        SELECT CASE Gouraud_Shading_Selection
                            CASE 0:
                                ' Flat face shading with runtime normal calculation
                                Light_Directional = -Vector3_DotProduct!(tri_normal, vLightDir) ' CCW winding
                                IF Light_Directional < 0.0 THEN Light_Directional = 0.0

                                IF Texture_options AND T1_option_no_T1 THEN
                                    ' define as 8 bit values
                                    face_light_r = 255.0 * thisMaterial.Kd_r * (Light_Directional + Light_AmbientVal)
                                    face_light_g = 255.0 * thisMaterial.Kd_g * (Light_Directional + Light_AmbientVal)
                                    face_light_b = 255.0 * thisMaterial.Kd_b * (Light_Directional + Light_AmbientVal)
                                ELSE
                                    ' range from 0 to 1
                                    face_light_r = thisMaterial.Kd_r * (Light_Directional + Light_AmbientVal)
                                    face_light_g = thisMaterial.Kd_g * (Light_Directional + Light_AmbientVal)
                                    face_light_b = thisMaterial.Kd_b * (Light_Directional + Light_AmbientVal)
                                END IF

                                vatr0.r = face_light_r
                                vatr0.g = face_light_g
                                vatr0.b = face_light_b

                                vatr1.r = face_light_r
                                vatr1.g = face_light_g
                                vatr1.b = face_light_b

                                vatr2.r = face_light_r
                                vatr2.g = face_light_g
                                vatr2.b = face_light_b

                            CASE 1:
                                ' Smooth shading with precalculated normals

                                ' 6-15-2024 pre-rotated normals
                                vertex_normal_A = object_vtx_normals(mesh(tri).vni0)
                                vertex_normal_B = object_vtx_normals(mesh(tri).vni1)
                                vertex_normal_C = object_vtx_normals(mesh(tri).vni2)

                                ' Directional light
                                light_directional_A = Vector3_DotProduct(vertex_normal_A, vLightDir)
                                light_directional_B = Vector3_DotProduct(vertex_normal_B, vLightDir)
                                light_directional_C = Vector3_DotProduct(vertex_normal_C, vLightDir)

                                IF light_directional_A < 0.0 THEN light_directional_A = 0.0
                                IF light_directional_B < 0.0 THEN light_directional_B = 0.0
                                IF light_directional_C < 0.0 THEN light_directional_C = 0.0

                                IF Texture_options AND T1_option_no_T1 THEN
                                    ' define as 8 bit values
                                    vatr0.r = 255.0 * thisMaterial.Kd_r * (light_directional_A + Light_AmbientVal)
                                    vatr0.g = 255.0 * thisMaterial.Kd_g * (light_directional_A + Light_AmbientVal)
                                    vatr0.b = 255.0 * thisMaterial.Kd_b * (light_directional_A + Light_AmbientVal)

                                    vatr1.r = 255.0 * thisMaterial.Kd_r * (light_directional_B + Light_AmbientVal)
                                    vatr1.g = 255.0 * thisMaterial.Kd_g * (light_directional_B + Light_AmbientVal)
                                    vatr1.b = 255.0 * thisMaterial.Kd_b * (light_directional_B + Light_AmbientVal)

                                    vatr2.r = 255.0 * thisMaterial.Kd_r * (light_directional_C + Light_AmbientVal)
                                    vatr2.g = 255.0 * thisMaterial.Kd_g * (light_directional_C + Light_AmbientVal)
                                    vatr2.b = 255.0 * thisMaterial.Kd_b * (light_directional_C + Light_AmbientVal)
                                ELSE
                                    ' range from 0 to 1
                                    vatr0.r = thisMaterial.Kd_r * (light_directional_A + Light_AmbientVal)
                                    vatr0.g = thisMaterial.Kd_g * (light_directional_A + Light_AmbientVal)
                                    vatr0.b = thisMaterial.Kd_b * (light_directional_A + Light_AmbientVal)

                                    vatr1.r = thisMaterial.Kd_r * (light_directional_B + Light_AmbientVal)
                                    vatr1.g = thisMaterial.Kd_g * (light_directional_B + Light_AmbientVal)
                                    vatr1.b = thisMaterial.Kd_b * (light_directional_B + Light_AmbientVal)

                                    vatr2.r = thisMaterial.Kd_r * (light_directional_C + Light_AmbientVal)
                                    vatr2.g = thisMaterial.Kd_g * (light_directional_C + Light_AmbientVal)
                                    vatr2.b = thisMaterial.Kd_b * (light_directional_C + Light_AmbientVal)
                                END IF
                        END SELECT


                    CASE illum_model_blinn_phong
                        ' ambient constant term, plus a diffuse and specular shading term for each light source
                        SELECT CASE Gouraud_Shading_Selection
                            CASE 0:
                                ' Flat face shading with runtime normal calculation

                                ' Directional light 1-17-2023
                                Light_Directional = -Vector3_DotProduct!(tri_normal, vLightDir) ' CCW winding
                                IF Light_Directional < 0.0 THEN Light_Directional = 0.0

                                ' Specular light
                                ' Instead of a normalized light position pointing out from origin, needs to be pointing inward towards the reflective surface.
                                vLightSpec.x = -vLightDir.x: vLightSpec.y = -vLightDir.y: vLightSpec.z = -vLightDir.z
                                Vector3_Reflect vLightSpec, tri_normal, reflectLightDir0
                                'Vector3_Normalize reflectLightDir0

                                ' cameraRay0 was already calculated for backface removal.
                                Vector3_Normalize cameraRay0
                                light_specular_A = Vector3_DotProduct!(reflectLightDir0, cameraRay0)
                                IF light_specular_A > 0.0 THEN
                                    ' this power thing only works because it should range from 0..1 again.
                                    ' so what it actually does is a higher power pushes the number towards 0 and makes the rolloff steeper.
                                    light_specular_A = powf(light_specular_A, thisMaterial.Ns)
                                ELSE
                                    light_specular_A = 0.0
                                END IF

                                IF Texture_options AND T1_option_no_T1 THEN
                                    ' define as 8 bit values
                                    face_light_r = 255.0 * (thisMaterial.Kd_r * (Light_Directional + Light_AmbientVal) + thisMaterial.Ks_r * light_specular_A)
                                    face_light_g = 255.0 * (thisMaterial.Kd_g * (Light_Directional + Light_AmbientVal) + thisMaterial.Ks_g * light_specular_A)
                                    face_light_b = 255.0 * (thisMaterial.Kd_b * (Light_Directional + Light_AmbientVal) + thisMaterial.Ks_b * light_specular_A)
                                ELSE
                                    face_light_r = thisMaterial.Kd_r * (Light_Directional + Light_AmbientVal) + thisMaterial.Ks_r * light_specular_A
                                    face_light_g = thisMaterial.Kd_g * (Light_Directional + Light_AmbientVal) + thisMaterial.Ks_g * light_specular_A
                                    face_light_b = thisMaterial.Kd_b * (Light_Directional + Light_AmbientVal) + thisMaterial.Ks_b * light_specular_A
                                END IF

                                vatr0.r = face_light_r
                                vatr0.g = face_light_g
                                vatr0.b = face_light_b

                                vatr1.r = face_light_r
                                vatr1.g = face_light_g
                                vatr1.b = face_light_b

                                vatr2.r = face_light_r
                                vatr2.g = face_light_g
                                vatr2.b = face_light_b

                            CASE 1:
                                ' Smooth shading with precalculated normals

                                ' 6-15-2024 pre-rotated normals
                                vertex_normal_A = object_vtx_normals(mesh(tri).vni0)
                                vertex_normal_B = object_vtx_normals(mesh(tri).vni1)
                                vertex_normal_C = object_vtx_normals(mesh(tri).vni2)

                                ' Directional light
                                light_directional_A = Vector3_DotProduct(vertex_normal_A, vLightDir)
                                light_directional_B = Vector3_DotProduct(vertex_normal_B, vLightDir)
                                light_directional_C = Vector3_DotProduct(vertex_normal_C, vLightDir)

                                IF light_directional_A < 0.0 THEN light_directional_A = 0.0
                                IF light_directional_B < 0.0 THEN light_directional_B = 0.0
                                IF light_directional_C < 0.0 THEN light_directional_C = 0.0

                                ' Specular at Vertex
                                ' Instead of a normalized light position pointing out from origin, needs to be pointing inward towards the reflective surface.
                                vLightSpec.x = -vLightDir.x: vLightSpec.y = -vLightDir.y: vLightSpec.z = -vLightDir.z

                                Vector3_Reflect vLightSpec, vertex_normal_A, reflectLightDir0
                                Vector3_Reflect vLightSpec, vertex_normal_B, reflectLightDir1
                                Vector3_Reflect vLightSpec, vertex_normal_C, reflectLightDir2

                                ' A
                                ' cameraRay0 was already calculated for backface removal.
                                Vector3_Normalize cameraRay0
                                light_specular_A = Vector3_DotProduct!(reflectLightDir0, cameraRay0)
                                IF light_specular_A > 0.0 THEN
                                    ' this power thing only works because it should range from 0..1 again.
                                    ' so what it actually does is a higher power pushes the number towards 0 and makes the rolloff steeper.
                                    light_specular_A = powf(light_specular_A, thisMaterial.Ns)
                                ELSE
                                    light_specular_A = 0.0
                                END IF

                                ' B
                                Vector3_Delta vCameraPsn, pointWorld1, cameraRay1
                                Vector3_Normalize cameraRay1
                                light_specular_B = Vector3_DotProduct!(reflectLightDir1, cameraRay1)
                                IF light_specular_B > 0.0 THEN
                                    light_specular_B = powf(light_specular_B, thisMaterial.Ns)
                                ELSE
                                    light_specular_B = 0.0
                                END IF

                                ' C
                                Vector3_Delta vCameraPsn, pointWorld2, cameraRay2
                                Vector3_Normalize cameraRay2
                                light_specular_C = Vector3_DotProduct!(reflectLightDir2, cameraRay2)
                                IF light_specular_C > 0.0 THEN
                                    light_specular_C = powf(light_specular_C, thisMaterial.Ns)
                                ELSE
                                    light_specular_C = 0.0
                                END IF

                                IF Texture_options AND T1_option_no_T1 THEN
                                    ' define as 8 bit values
                                    vatr0.r = 255.0 * (thisMaterial.Kd_r * (light_directional_A + Light_AmbientVal) + thisMaterial.Ks_r * light_specular_A)
                                    vatr0.g = 255.0 * (thisMaterial.Kd_g * (light_directional_A + Light_AmbientVal) + thisMaterial.Ks_g * light_specular_A)
                                    vatr0.b = 255.0 * (thisMaterial.Kd_b * (light_directional_A + Light_AmbientVal) + thisMaterial.Ks_b * light_specular_A)

                                    vatr1.r = 255.0 * (thisMaterial.Kd_r * (light_directional_B + Light_AmbientVal) + thisMaterial.Ks_r * light_specular_B)
                                    vatr1.g = 255.0 * (thisMaterial.Kd_g * (light_directional_B + Light_AmbientVal) + thisMaterial.Ks_g * light_specular_B)
                                    vatr1.b = 255.0 * (thisMaterial.Kd_b * (light_directional_B + Light_AmbientVal) + thisMaterial.Ks_b * light_specular_B)

                                    vatr2.r = 255.0 * (thisMaterial.Kd_r * (light_directional_C + Light_AmbientVal) + thisMaterial.Ks_r * light_specular_C)
                                    vatr2.g = 255.0 * (thisMaterial.Kd_g * (light_directional_C + Light_AmbientVal) + thisMaterial.Ks_g * light_specular_C)
                                    vatr2.b = 255.0 * (thisMaterial.Kd_b * (light_directional_C + Light_AmbientVal) + thisMaterial.Ks_b * light_specular_C)
                                ELSE
                                    ' range from 0 to 1
                                    vatr0.r = thisMaterial.Kd_r * (light_directional_A + Light_AmbientVal) + thisMaterial.Ks_r * light_specular_A
                                    vatr0.g = thisMaterial.Kd_g * (light_directional_A + Light_AmbientVal) + thisMaterial.Ks_g * light_specular_A
                                    vatr0.b = thisMaterial.Kd_b * (light_directional_A + Light_AmbientVal) + thisMaterial.Ks_b * light_specular_A

                                    vatr1.r = thisMaterial.Kd_r * (light_directional_B + Light_AmbientVal) + thisMaterial.Ks_r * light_specular_B
                                    vatr1.g = thisMaterial.Kd_g * (light_directional_B + Light_AmbientVal) + thisMaterial.Ks_g * light_specular_B
                                    vatr1.b = thisMaterial.Kd_b * (light_directional_B + Light_AmbientVal) + thisMaterial.Ks_b * light_specular_B

                                    vatr2.r = thisMaterial.Kd_r * (light_directional_C + Light_AmbientVal) + thisMaterial.Ks_r * light_specular_C
                                    vatr2.g = thisMaterial.Kd_g * (light_directional_C + Light_AmbientVal) + thisMaterial.Ks_g * light_specular_C
                                    vatr2.b = thisMaterial.Kd_b * (light_directional_C + Light_AmbientVal) + thisMaterial.Ks_b * light_specular_C
                                END IF
                        END SELECT


                    CASE illum_model_reflection_map, illum_model_glass_map
                        ' Mirror
                        ' the reflection map is modulated by the specular factor
                        T1_mod_R = thisMaterial.Ks_r
                        T1_mod_G = thisMaterial.Ks_g
                        T1_mod_B = thisMaterial.Ks_b

                        SELECT CASE Gouraud_Shading_Selection
                            CASE 0:
                                ' Flat face shading
                                vertex_normal_A = tri_normal
                                vertex_normal_B = tri_normal
                                vertex_normal_C = tri_normal
                            CASE 1:
                                ' 6-15-2024 pre-rotated normals
                                vertex_normal_A = object_vtx_normals(mesh(tri).vni0)
                                vertex_normal_B = object_vtx_normals(mesh(tri).vni1)
                                vertex_normal_C = object_vtx_normals(mesh(tri).vni2)
                        END SELECT

                        Vector3_Delta pointWorld0, vCameraPsn, cameraRay0
                        Vector3_Reflect cameraRay0, vertex_normal_A, envMapReflectionRayA

                        Vector3_Delta pointWorld1, vCameraPsn, cameraRay1
                        Vector3_Reflect cameraRay1, vertex_normal_B, envMapReflectionRayB

                        Vector3_Delta pointWorld2, vCameraPsn, cameraRay2
                        Vector3_Reflect cameraRay2, vertex_normal_C, envMapReflectionRayC

                        vatr0.r = envMapReflectionRayA.x ' RGB holds (X,Y,Z) instead
                        vatr0.g = envMapReflectionRayA.y
                        vatr0.b = envMapReflectionRayA.z

                        vatr1.r = envMapReflectionRayB.x
                        vatr1.g = envMapReflectionRayB.y
                        vatr1.b = envMapReflectionRayB.z

                        vatr2.r = envMapReflectionRayC.x
                        vatr2.g = envMapReflectionRayC.y
                        vatr2.b = envMapReflectionRayC.z

                        Texture_options = Texture_options OR T1_option_metallic
                    CASE ELSE:
                END SELECT

                ' Clip if any Z is too close. Assumption is that near clip is uncommon.
                ' If there is a lot of near clipping going on, please remove this precheck and just always call NearClip.
                IF (pointView0.z < Frustum_Near) _ORELSE (pointView1.z < Frustum_Near) _ORELSE (pointView2.z < Frustum_Near) THEN
                    NearClip pointView0, pointView1, pointView2, pointView3, vatr0, vatr1, vatr2, vatr3, triCount
                    IF triCount = 0 THEN GOTO Lbl_SkipTriAll
                ELSE
                    triCount = 1
                END IF

                ' Project triangles from 3D -----------------> 2D
                ProjectPerspectiveVector4 pointView0, matProj(), pointProj0
                ProjectPerspectiveVector4 pointView1, matProj(), pointProj1
                ProjectPerspectiveVector4 pointView2, matProj(), pointProj2

                ' Slide to center, then Scale into viewport
                SX0 = (pointProj0.x + 1) * halfWidth
                SY0 = (pointProj0.y + 1) * halfHeight
                SX2 = (pointProj2.x + 1) * halfWidth
                SY2 = (pointProj2.y + 1) * halfHeight

                ' Early scissor reject
                IF pointProj0.x > 1.0 AND pointProj1.x > 1.0 AND pointProj2.x > 1.0 THEN GOTO Lbl_Skip012
                IF pointProj0.x < -1.0 AND pointProj1.x < -1.0 AND pointProj2.x < -1.0 THEN GOTO Lbl_Skip012
                IF pointProj0.y > 1.0 AND pointProj1.y > 1.0 AND pointProj2.y > 1.0 THEN GOTO Lbl_Skip012
                IF pointProj0.y < -1.0 AND pointProj1.y < -1.0 AND pointProj2.y < -1.0 THEN GOTO Lbl_Skip012

                ' This is unique to triangle 012
                SX1 = (pointProj1.x + 1) * halfWidth
                SY1 = (pointProj1.y + 1) * halfHeight

                ' Load Vertex Lists
                vertexA.x = SX0
                vertexA.y = SY0
                vertexA.w = pointProj0.w ' depth

                vertexB.x = SX1
                vertexB.y = SY1
                vertexB.w = pointProj1.w ' depth

                vertexC.x = SX2
                vertexC.y = SY2
                vertexC.w = pointProj2.w ' depth

                IF Texture_options AND T1_option_metallic THEN
                    vertexA.r = vatr0.r * pointProj0.w
                    vertexA.g = vatr0.g * pointProj0.w
                    vertexA.b = vatr0.b * pointProj0.w

                    vertexB.r = vatr1.r * pointProj1.w
                    vertexB.g = vatr1.g * pointProj1.w
                    vertexB.b = vatr1.b * pointProj1.w

                    vertexC.r = vatr2.r * pointProj2.w
                    vertexC.g = vatr2.g * pointProj2.w
                    vertexC.b = vatr2.b * pointProj2.w
                    ReflectionMapTriangle vertexA, vertexB, vertexC
                ELSE
                    vertexA.r = vatr0.r
                    vertexA.g = vatr0.g
                    vertexA.b = vatr0.b
                    vertexB.r = vatr1.r
                    vertexB.g = vatr1.g
                    vertexB.b = vatr1.b
                    vertexC.r = vatr2.r
                    vertexC.g = vatr2.g
                    vertexC.b = vatr2.b
                    IF Texture_options AND T1_option_no_T1 THEN
                        VertexColorAlphaTriangle vertexA, vertexB, vertexC
                    ELSE
                        vertexA.u = vatr0.u * pointProj0.w
                        vertexA.v = vatr0.v * pointProj0.w
                        vertexB.u = vatr1.u * pointProj1.w
                        vertexB.v = vatr1.v * pointProj1.w
                        vertexC.u = vatr2.u * pointProj2.w
                        vertexC.v = vatr2.v * pointProj2.w
                        TextureWithAlphaTriangle vertexA, vertexB, vertexC
                    END IF
                END IF ' metallic


                Lbl_Skip012:
                IF triCount = 2 THEN
                    ProjectPerspectiveVector4 pointView3, matProj(), pointProj3

                    ' Late scissor reject
                    IF (pointProj0.x > 1.0) AND (pointProj2.x > 1.0) AND (pointProj3.x > 1.0) THEN GOTO Lbl_SkipTriAll
                    IF (pointProj0.x < -1.0) AND (pointProj2.x < -1.0) AND (pointProj3.x < -1.0) THEN GOTO Lbl_SkipTriAll
                    IF (pointProj0.y > 1.0) AND (pointProj2.y > 1.0) AND (pointProj3.y > 1.0) THEN GOTO Lbl_SkipTriAll
                    IF (pointProj0.y < -1.0) AND (pointProj2.y < -1.0) AND (pointProj3.y < -1.0) THEN GOTO Lbl_SkipTriAll

                    ' This is unique to triangle 023
                    SX3 = (pointProj3.x + 1) * halfWidth
                    SY3 = (pointProj3.y + 1) * halfHeight

                    ' Reload Vertex Lists
                    vertexA.x = SX0
                    vertexA.y = SY0
                    vertexA.w = pointProj0.w ' depth

                    vertexB.x = SX2
                    vertexB.y = SY2
                    vertexB.w = pointProj2.w ' depth

                    vertexC.x = SX3
                    vertexC.y = SY3
                    vertexC.w = pointProj3.w ' depth

                    IF Texture_options AND T1_option_metallic THEN
                        vertexA.r = vatr0.r * pointProj0.w
                        vertexA.g = vatr0.g * pointProj0.w
                        vertexA.b = vatr0.b * pointProj0.w

                        vertexB.r = vatr2.r * pointProj2.w
                        vertexB.g = vatr2.g * pointProj2.w
                        vertexB.b = vatr2.b * pointProj2.w

                        vertexC.r = vatr3.r * pointProj3.w
                        vertexC.g = vatr3.g * pointProj3.w
                        vertexC.b = vatr3.b * pointProj3.w
                        ReflectionMapTriangle vertexA, vertexB, vertexC
                    ELSE
                        vertexA.r = vatr0.r
                        vertexA.g = vatr0.g
                        vertexA.b = vatr0.b
                        vertexB.r = vatr2.r
                        vertexB.g = vatr2.g
                        vertexB.b = vatr2.b
                        vertexC.r = vatr3.r
                        vertexC.g = vatr3.g
                        vertexC.b = vatr3.b
                        IF Texture_options AND T1_option_no_T1 THEN
                            VertexColorAlphaTriangle vertexA, vertexB, vertexC
                        ELSE
                            vertexA.u = vatr0.u * pointProj0.w
                            vertexA.v = vatr0.v * pointProj0.w
                            vertexB.u = vatr2.u * pointProj2.w
                            vertexB.v = vatr2.v * pointProj2.w
                            vertexC.u = vatr3.u * pointProj3.w
                            vertexC.v = vatr3.v * pointProj3.w
                            TextureWithAlphaTriangle vertexA, vertexB, vertexC
                        END IF
                    END IF ' metallic
                END IF ' tricount=2

            END IF ' visible according to dotProductCam

            ' Improve camera control feeling by polling the keyboard every so often during this main triangle draw loop.
            triloop_input_poll = triloop_input_poll + 1
            IF triloop_input_poll < 30000 GOTO Lbl_SkipTriAll
            triloop_input_poll = triloop_input_poll - 6000 ' in case too early
            frame_early_polls(frame_advance) = frame_early_polls(frame_advance) + 1

            frametimestamp_now_ms = TIMER(0.001) ' this function is slow
            IF frametimestamp_now_ms - frametimestamp_prior_ms < 0.0 THEN
                ' timer rollover
                ' without over-analyzing just use the previous delta, even if it is somewhat wrong it is a better guess than 0.
                frametimestamp_prior_ms = frametimestamp_now_ms - frametimestamp_delta_ms
            ELSE
                frametimestamp_delta_ms = frametimestamp_now_ms - frametimestamp_prior_ms
            END IF
            WHILE frametimestamp_delta_ms > frametime_fullframethreshold_ms
                frame_advance = frame_advance + 1
                IF frame_advance > frame_tracking_size THEN frame_advance = frame_tracking_size
                frame_ts(frame_advance) = frametimestamp_delta_ms

                frametimestamp_prior_ms = frametimestamp_prior_ms + frametime_fullframe_ms
                frametimestamp_delta_ms = frametimestamp_delta_ms - frametime_fullframe_ms

                CameraPoll vCameraPsnNext, fYaw, fPitch
                triloop_input_poll = 0 ' did the poll so go back
            WEND ' frametime

            Lbl_SkipTriAll:
        NEXT tri
    NEXT renderPass
    render_ms = TIMER(.001)

    _PUTIMAGE , WORK_IMAGE, DISP_IMAGE
    _DEST DISP_IMAGE
    LOCATE 1, 1
    COLOR _RGB32(177, 227, 255)
    PRINT USING "render time #.###"; render_ms - start_ms
    COLOR _RGB32(249, 244, 17)
    PRINT "ESC to exit. ";
    COLOR _RGB32(233)
    PRINT "Arrow Keys Move. -Speed+:"; CameraSpeedLookup(CameraSpeedLevel)

    IF Jog_Motion_Selection <> 0 THEN
        IF Animate_Spin THEN
            PRINT "(S)top Spin  ";
        ELSE
            PRINT "(S)tart Spin ";
        END IF
    END IF

    PRINT "(J)og Type: ";
    SELECT CASE Jog_Motion_Selection
        CASE 0
            PRINT "Zero Orientation"
        CASE 1
            PRINT "Turntable Y-Axis"
        CASE 2
            PRINT "Roll X-Axis"
        CASE 3
            PRINT "Tumble X and Z"
        CASE ELSE
            PRINT Jog_Motion_Selection
    END SELECT

    IF Draw_Environment_Map THEN
        PRINT "(E)nvironment Map on ";
    ELSE
        PRINT "(E)nvironment Map off";
    END IF

    IF Draw_Backface THEN
        PRINT " (B)ackface on"
    ELSE
        PRINT " (B)ackface off"
    END IF

    PRINT "Press G for Lighting: ";
    SELECT CASE Gouraud_Shading_Selection
        CASE 0
            PRINT "Flat using face normals"
        CASE 1
            PRINT "Gouraud using vertex normals"
        CASE 2
            PRINT "Mirror"
    END SELECT

    render_period_ms = render_ms - trimesh_ms
    'If render_period_ms < 0.001 Then render_period_ms = 0.001
    'Print Using "draw time #.###"; render_period_ms
    'Print "Pixels Drawn"; Pixels_Drawn_This_Frame
    'Print "Pixels/Second"; Int(Pixels_Drawn_This_Frame / render_period_ms)

    'For tri = 0 To frame_advance
    '    Print Using "#.### "; frame_ts(tri);
    'Next tri
    'Print " "
    'For tri = 0 To frame_advance
    '    Print Using "##### "; frame_early_polls(tri);
    'Next tri


    _LIMIT 60
    _DISPLAY

    $CHECKING:ON
    vCameraPsn = vCameraPsnNext

    ' keyboard polling for camera movement
    frametimestamp_now_ms = TIMER(0.001)
    IF frametimestamp_now_ms - frametimestamp_prior_ms < 0.0 THEN
        ' timer rollover
        ' without over-analyzing just use the previous delta, even if it is somewhat wrong it is a better guess than 0.
        frametimestamp_prior_ms = frametimestamp_now_ms - frametimestamp_delta_ms
    ELSE
        frametimestamp_delta_ms = frametimestamp_now_ms - frametimestamp_prior_ms
    END IF
    WHILE frametimestamp_delta_ms > frametime_fullframethreshold_ms
        frametimestamp_delta_ms = frametimestamp_delta_ms - frametime_fullframe_ms
        frametimestamp_prior_ms = frametimestamp_prior_ms + frametime_fullframe_ms

        frame_advance = frame_advance + 1
        CameraPoll vCameraPsn, fYaw, fPitch
    WEND ' frametime

    KeyNow = UCASE$(INKEY$)
    i = 1 ' avoid deadlock
    WHILE (KeyNow <> "") AND (i < 100)

        IF KeyNow = "S" THEN
            Animate_Spin = NOT Animate_Spin
        ELSEIF KeyNow = "E" THEN
            Draw_Environment_Map = NOT Draw_Environment_Map
        ELSEIF KeyNow = "=" OR KeyNow = "+" THEN
            CameraSpeedLevel = CameraSpeedLevel + 1
            IF CameraSpeedLevel > CameraSpeedLevel_max THEN CameraSpeedLevel = CameraSpeedLevel_max
        ELSEIF KeyNow = "-" OR KeyNow = "_" THEN
            CameraSpeedLevel = CameraSpeedLevel - 1
            IF CameraSpeedLevel < 0 THEN CameraSpeedLevel = 0
        ELSEIF KeyNow = "R" THEN
            vCameraPsn.x = 0.0
            vCameraPsn.y = 0.0
            vCameraPsn.z = Camera_Start_Z
            fPitch = 0.0
            fYaw = 0.0
        ELSEIF KeyNow = "G" THEN
            Gouraud_Shading_Selection = Gouraud_Shading_Selection + 1
            IF Gouraud_Shading_Selection > 1 THEN Gouraud_Shading_Selection = 0
        ELSEIF KeyNow = "B" THEN
            Draw_Backface = NOT Draw_Backface
        ELSEIF KeyNow = "J" THEN
            Jog_Motion_Selection = Jog_Motion_Selection + 1
            IF Jog_Motion_Selection > 3 THEN Jog_Motion_Selection = 1
        ELSEIF KeyNow = "O" THEN
            Jog_Motion_Selection = 0
            Animate_Spin = -1
        ELSEIF ASC(KeyNow) = 27 THEN
            ExitCode = 1
        END IF
        KeyNow = UCASE$(INKEY$)
        i = i + 1
    WEND

    ' overrides
    IF Vtx_Normals_Count = 0 THEN Gouraud_Shading_Selection = 0

LOOP UNTIL ExitCode <> 0

FOR refIndex = 5 TO 0 STEP -1
    _FREEIMAGE SkyBoxRef(refIndex)
NEXT refIndex

END
$CHECKING:OFF

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
DATA -10,+10,+10
DATA +10,+10,+10
DATA -10,-10,+10
DATA 0,0,1,0,0,1
DATA 4

DATA +10,+10,+10
DATA +10,-10,+10
DATA -10,-10,+10
DATA 1,0,1,1,0,1
DATA 4

' RIGHT X+
DATA +10,+10,+10
DATA +10,+10,-10
DATA +10,-10,+10
DATA 0,0,1,0,0,1
DATA 0

DATA +10,+10,-10
DATA +10,-10,-10
DATA +10,-10,+10
DATA 1,0,1,1,0,1
DATA 0

' LEFT X-
DATA -10,+10,-10
DATA -10,+10,+10
DATA -10,-10,-10
DATA 0,0,1,0,0,1
DATA 1

DATA -10,+10,+10
DATA -10,-10,+10
DATA -10,-10,-10
DATA 1,0,1,1,0,1
DATA 1

' BACK Z-
DATA +10,+10,-10
DATA -10,+10,-10
DATA +10,-10,-10
DATA 0,0,1,0,0,1
DATA 5

DATA -10,+10,-10
DATA -10,-10,-10
DATA +10,-10,-10
DATA 1,0,1,1,0,1
DATA 5

' TOP Y+
DATA -10,+10,-10
DATA +10,+10,-10
DATA -10,+10,+10
DATA 0,0,1,0,0,1
DATA 2

DATA +10,+10,-10
DATA +10,+10,+10
DATA -10,+10,+10
DATA 1,0,1,1,0,1
DATA 2

' BOTTOM Y-
DATA -10,-10,+10
DATA 10,-10,+10
DATA -10,-10,-10
DATA 0,0,1,0,0,1
DATA 3

DATA +10,-10,+10
DATA +10,-10,-10
DATA -10,-10,-10
DATA 1,0,1,1,0,1
DATA 3

$CHECKING:ON
SUB CameraPoll (camloc AS vec3d, yaw AS SINGLE, pitch AS SINGLE)
    STATIC cammove AS vec3d

    IF _KEYDOWN(32) THEN
        ' Spacebar
        camloc.y = camloc.y + CameraSpeedLookup(CameraSpeedLevel) / 2
    END IF

    IF _KEYDOWN(118) OR _KEYDOWN(86) THEN
        'V
        camloc.y = camloc.y - CameraSpeedLookup(CameraSpeedLevel) / 2
    END IF

    IF _KEYDOWN(19712) THEN
        ' Right arrow
        yaw = yaw - 1.2
    END IF

    IF _KEYDOWN(19200) THEN
        ' Left arrow
        yaw = yaw + 1.2
    END IF

    ' forward camera movement vector
    Matrix4_MakeRotation_Y yaw, matCameraRot()
    Multiply_Vector3_Matrix4 vCameraHomeFwd, matCameraRot(), cammove
    Vector3_Mul cammove, CameraSpeedLookup(CameraSpeedLevel), cammove

    IF _KEYDOWN(18432) THEN
        ' Up arrow
        Vector3_Add camloc, cammove, camloc
    END IF

    IF _KEYDOWN(20480) THEN
        ' Down arrow
        Vector3_Delta camloc, cammove, camloc
    END IF

    IF _KEYDOWN(122) OR _KEYDOWN(90) THEN
        ' Z
        pitch = pitch + 1.0
        IF pitch > 85.0 THEN pitch = 85.0
    END IF

    IF _KEYDOWN(113) OR _KEYDOWN(81) THEN
        ' Q
        pitch = pitch - 1.0
        IF pitch < -85.0 THEN pitch = -85.0
    END IF
END SUB

SUB InsertCatalogTexture (thefile AS STRING, h AS LONG)
    ' returns -1 in h if texture cannot be loaded
    DIM i AS INTEGER
    IF TextureCatalog_nextIndex > UBOUND(TextureCatalog) THEN
        PRINT "need to increase texture catalog size"
        END
    END IF

    FOR i = 0 TO TextureCatalog_nextIndex
        IF TextureCatalog(i).textName = thefile THEN
            'match
            'Print i; " match "; thefile; TextureCatalog(i).imageHandle
            h = TextureCatalog(i).imageHandle
            '_Delay 2
            EXIT SUB
        END IF
    NEXT i

    h = _LOADIMAGE(Obj_Directory + thefile, 32)
    IF h = -1 THEN
        PRINT "texture not loaded: "; thefile
        EXIT SUB
    END IF

    TextureCatalog(TextureCatalog_nextIndex).imageHandle = h
    TextureCatalog(TextureCatalog_nextIndex).textName = thefile
    TextureCatalog_nextIndex = TextureCatalog_nextIndex + 1
END SUB

SUB PrescanMesh (thefile AS STRING, requiredTriangles AS LONG, totalVertex AS LONG, totalTextureCoords AS LONG, totalNormals AS LONG, totalMaterialLibrary AS LONG, materialFile AS STRING)
    ' Primary purpose is to determine the required amount of triangles.
    ' This is not straightforward as any size n-gons are allowed, although typically faces with 3 or 4 vertexes is encountered.
    DIM totalFaces AS LONG
    DIM lineCount AS LONG
    DIM lineLength AS INTEGER
    DIM lineCursor AS INTEGER
    DIM parameterIndex AS INTEGER
    DIM substringStart AS INTEGER
    DIM substringLength AS INTEGER

    DIM rawString AS STRING

    requiredTriangles = 0
    totalVertex = 0
    totalTextureCoords = 0
    totalNormals = 0
    totalMaterialLibrary = 0
    materialFile = "default.mtl"

    totalFaces = 0
    lineCount = 0
    lineLength = 0

    IF _FILEEXISTS(thefile) = 0 THEN
        PRINT "The file was not found"
        EXIT SUB
    END IF
    OPEN thefile FOR BINARY AS #2
    IF LOF(2) = 0 THEN
        PRINT "The file is empty"
        CLOSE #2
        EXIT SUB
    END IF

    DO UNTIL EOF(2)
        LINE INPUT #2, rawString
        lineCount = lineCount + 1

        IF LEFT$(rawString, 2) = "v " THEN
            totalVertex = totalVertex + 1

        ELSEIF LEFT$(rawString, 3) = "vt " THEN
            totalTextureCoords = totalTextureCoords + 1

        ELSEIF LEFT$(rawString, 3) = "vn " THEN
            totalNormals = totalNormals + 1


        ELSEIF LEFT$(rawString, 2) = "f " THEN
            totalFaces = totalFaces + 1

            lineCursor = 3
            parameterIndex = 0

            lineLength = LEN(rawString)
            WHILE lineCursor < lineLength
                substringStart = lineCursor
                substringLength = 0

                ' eat spaces
                WHILE ASC(rawString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_FACE_PRESCAN
                WEND

                ' count number digits
                WHILE ASC(rawString, lineCursor) > 32
                    substringLength = substringLength + 1
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                WEND

                IF substringLength > 0 THEN
                    parameterIndex = parameterIndex + 1
                END IF
            WEND

            BAIL_FACE_PRESCAN:
            IF parameterIndex = 3 THEN
                requiredTriangles = requiredTriangles + 1
            ELSE
                requiredTriangles = requiredTriangles + 2
            END IF

        ELSEIF LEFT$(rawString, 7) = "mtllib " THEN
            totalMaterialLibrary = totalMaterialLibrary + 1
            ' return the most recently encountered material file. there is usually only one.
            materialFile = _TRIM$(MID$(rawString, 8))
        END IF
    LOOP

    CLOSE #2

    PRINT lineCount, "lineCount"
    PRINT requiredTriangles, "Required Triangles"
    PRINT totalVertex, "Vertexes"
    PRINT totalTextureCoords, "Texture Coordinates"
    PRINT totalNormals, "Vertex Normals"
    PRINT totalFaces, "Faces"
    PRINT totalMaterialLibrary, "Material Libraries"
    IF totalMaterialLibrary > 0 THEN PRINT materialFile
    'Dim temp$
    'Input "waiting..."; temp$
END SUB

SUB LoadMesh (thefile AS STRING, tris() AS mesh_triangle, indexTri AS LONG, v() AS vec3d, leVertexTexelList AS LONG, vn() AS vec3d, mats() AS newmtl_type)
    DIM ParameterStorage(10, 2) AS DOUBLE

    DIM totalVertex AS LONG
    DIM totalFaces AS LONG
    DIM lineCount AS LONG
    DIM lineLength AS INTEGER
    DIM lineCursor AS INTEGER
    DIM parameterIndex AS INTEGER
    DIM paramStringStart AS INTEGER
    DIM paramStringLength AS INTEGER
    DIM useMaterialNumber AS LONG
    DIM totalVertexNormals AS LONG
    DIM totalVertexTexels AS LONG
    'Dim VertexList(leVertexList) As vec3d ' this is now global
    DIM TexelCoord(leVertexTexelList) AS vec3d ' this gets tossed after loading mesh()

    totalVertex = 0 ' refers to v() array
    totalVertexNormals = 0 ' refers to vn() array

    lineCount = 0
    lineLength = 0

    DIM rawString AS STRING
    DIM parameter AS STRING

    IF _FILEEXISTS(thefile) = 0 THEN
        PRINT "The object file was not found"
        EXIT SUB
    END IF
    OPEN thefile FOR BINARY AS #2
    IF LOF(2) = 0 THEN
        PRINT "The object file is empty"
        CLOSE #2
        EXIT SUB
    END IF
    DO UNTIL EOF(2)
        LINE INPUT #2, rawString
        lineCount = lineCount + 1

        lineLength = LEN(rawString)

        IF LEFT$(rawString, 2) = "v " THEN
            totalVertex = totalVertex + 1
            'Print "Vertex #"; totalVertex;

            lineCursor = 3
            parameterIndex = 0

            WHILE lineCursor < lineLength
                paramStringLength = 0

                ' eat spaces
                WHILE ASC(rawString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_VERTEX
                WEND

                ' count chars up to next space char, stopping if end of string reached
                paramStringStart = lineCursor
                WHILE ASC(rawString, lineCursor) > 32
                    'Print Mid$(rawString, lineCursor, 1);
                    paramStringLength = paramStringLength + 1
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                WEND

                IF paramStringLength > 0 THEN
                    parameterIndex = parameterIndex + 1
                    parameter$ = MID$(rawString, paramStringStart, paramStringLength)
                    ParameterStorage(parameterIndex, 0) = VAL(parameter$)
                    'Print parameterIndex, paramStringStart, paramStringLength, "["; parameter$; "]"
                END IF
            WEND

            BAIL_VERTEX:
            'Print parameterIndex; " EOL"

            IF parameterIndex >= 3 THEN
                v(totalVertex).x = ParameterStorage(1, 0)
                v(totalVertex).y = ParameterStorage(2, 0)
                v(totalVertex).z = -ParameterStorage(3, 0) ' in obj files, Z+ points toward viewer
                'Print "v "; ParameterStorage(1); ParameterStorage(2); ParameterStorage(3)
            END IF

        ELSEIF LEFT$(rawString, 3) = "vn " THEN
            totalVertexNormals = totalVertexNormals + 1

            lineCursor = 4
            parameterIndex = 0

            WHILE lineCursor < lineLength
                paramStringLength = 0

                ' eat spaces
                WHILE ASC(rawString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_VERTEXNORMS
                WEND

                ' count chars up to next space char, stopping if end of string reached
                paramStringStart = lineCursor
                WHILE ASC(rawString, lineCursor) > 32
                    'Print Mid$(rawString, lineCursor, 1);
                    paramStringLength = paramStringLength + 1
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                WEND

                IF paramStringLength > 0 THEN
                    parameterIndex = parameterIndex + 1
                    parameter$ = MID$(rawString, paramStringStart, paramStringLength)
                    ParameterStorage(parameterIndex, 0) = VAL(parameter$)
                    'Print parameterIndex, paramStringStart, paramStringLength, "["; parameter$; "]"
                END IF
            WEND

            BAIL_VERTEXNORMS:
            'Print parameterIndex; " EOL"

            IF parameterIndex >= 3 THEN
                vn(totalVertexNormals).x = ParameterStorage(1, 0)
                vn(totalVertexNormals).y = ParameterStorage(2, 0)
                vn(totalVertexNormals).z = -ParameterStorage(3, 0) ' in obj files, Z+ points toward viewer
                Vector3_Normalize vn(totalVertexNormals)
                'Print "vn "; ParameterStorage(1); ParameterStorage(2); ParameterStorage(3)
            END IF


        ELSEIF LEFT$(rawString, 3) = "vt " THEN
            totalVertexTexels = totalVertexTexels + 1

            lineCursor = 4
            parameterIndex = 0

            WHILE lineCursor < lineLength
                paramStringLength = 0

                ' eat spaces
                WHILE ASC(rawString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_VERTEXTEXELS
                WEND

                ' count chars up to next space char, stopping if end of string reached
                paramStringStart = lineCursor
                WHILE ASC(rawString, lineCursor) > 32
                    'Print Mid$(rawString, lineCursor, 1);
                    paramStringLength = paramStringLength + 1
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                WEND

                IF paramStringLength > 0 THEN
                    parameterIndex = parameterIndex + 1
                    parameter$ = MID$(rawString, paramStringStart, paramStringLength)
                    ParameterStorage(parameterIndex, 0) = VAL(parameter$)
                    'Print parameterIndex, paramStringStart, paramStringLength, "["; parameter$; "]"
                END IF
            WEND

            BAIL_VERTEXTEXELS:
            'Print parameterIndex; " EOL"

            IF parameterIndex >= 2 THEN
                TexelCoord(totalVertexTexels).x = ParameterStorage(1, 0) ' it is amazing how bad at following the standard people are.
                TexelCoord(totalVertexTexels).y = ParameterStorage(2, 0) ' it is only supposed to range from 0.0 to 1.0
                'Print "vt "; ParameterStorage(1, 0); ParameterStorage(2, 0);
            END IF

        END IF
    LOOP

    lineCount = 0
    lineLength = 0
    totalFaces = 0

    DIM mostRecentVertex AS LONG
    DIM mostRecentVertexNormal AS LONG
    DIM mostRecentVertexTexel AS LONG
    mostRecentVertex = 0
    mostRecentVertexNormal = 0
    mostRecentVertexTexel = 0

    DIM i0 AS LONG
    DIM i1 AS LONG
    DIM i2 AS LONG
    DIM i3 AS LONG
    DIM tex0 AS LONG
    DIM tex1 AS LONG
    DIM tex2 AS LONG
    DIM tex3 AS LONG

    useMaterialNumber = 0

    DIM ssc AS INTEGER
    ssc = 0

    DIM paramSubindex AS INTEGER
    paramSubindex = 0

    SEEK #2, 1
    DO UNTIL EOF(2)
        LINE INPUT #2, rawString
        lineCount = lineCount + 1
        lineLength = LEN(rawString)

        IF LEFT$(rawString, 2) = "v " THEN
            ' vertex command
            ' Increase vertex counter due to the relative vertex feature
            ' If a vertex in a face command is -1, it refers to the most recent vertex.
            ' So then -2 means the second most recent vertex, etc.
            mostRecentVertex = mostRecentVertex + 1

        ELSEIF LEFT$(rawString, 3) = "vn " THEN
            ' vertex normal command (directional shading)
            mostRecentVertexNormal = mostRecentVertexNormal + 1

        ELSEIF LEFT$(rawString, 3) = "vt " THEN
            ' vertex texture coordinate(s)
            mostRecentVertexTexel = mostRecentVertexTexel + 1

        ELSEIF LEFT$(rawString, 2) = "f " THEN
            ' face command
            ' f v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3 ...
            ' f vt//vn1 v2//vn2 v3//vn3 ...
            totalFaces = totalFaces + 1
            'Print "Face #"; totalFaces;

            lineCursor = 3
            parameterIndex = 0
            paramSubindex = 0

            WHILE lineCursor <= lineLength
                paramStringLength = 0

                ' eat spaces
                ' space is used as a separator between parameters
                WHILE ASC(rawString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_FACES
                    paramSubindex = 0
                WEND

                ' count chars up to next space or slash char, stopping if end of string reached
                paramStringStart = lineCursor
                ssc = ASC(rawString, lineCursor)
                WHILE (ssc > 32)
                    lineCursor = lineCursor + 1
                    IF ssc = 47 THEN EXIT WHILE
                    paramStringLength = paramStringLength + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                    ssc = ASC(rawString, lineCursor)
                WEND

                IF paramStringLength > 0 THEN
                    IF paramSubindex = 0 THEN parameterIndex = parameterIndex + 1
                    parameter$ = MID$(rawString, paramStringStart, paramStringLength)
                    ParameterStorage(parameterIndex, paramSubindex) = VAL(parameter$)
                    'Print "("; parameterIndex; ","; paramSubindex; ")", paramStringStart, paramStringLength, "["; parameter$; "]"
                END IF

                IF ssc = 47 THEN
                    ' / character means next sub parameter
                    paramSubindex = paramSubindex + 1
                    ParameterStorage(parameterIndex, paramSubindex) = 0
                END IF

            WEND

            BAIL_FACES:
            'Print parameterIndex; " EOL"
            IF parameterIndex >= 3 THEN
                i0 = FindVertexNumAbsOrRel(ParameterStorage(1, 0), mostRecentVertex)
                i1 = FindVertexNumAbsOrRel(ParameterStorage(2, 0), mostRecentVertex)
                i2 = FindVertexNumAbsOrRel(ParameterStorage(3, 0), mostRecentVertex)

                indexTri = indexTri + 1
                tris(indexTri).i0 = i0
                tris(indexTri).i1 = i1
                tris(indexTri).i2 = i2
                tris(indexTri).options = 0
                tris(indexTri).material = useMaterialNumber

                IF paramSubindex >= 1 THEN
                    IF ParameterStorage(1, 1) = 0 THEN
                        ' no texture 1
                        tris(indexTri).options = tris(indexTri).options OR T1_option_no_T1
                    ELSE
                        tex0 = FindVertexNumAbsOrRel(ParameterStorage(1, 1), mostRecentVertexTexel)
                        tex1 = FindVertexNumAbsOrRel(ParameterStorage(2, 1), mostRecentVertexTexel)
                        tex2 = FindVertexNumAbsOrRel(ParameterStorage(3, 1), mostRecentVertexTexel)

                        tris(indexTri).u0 = TexelCoord(tex0).x
                        tris(indexTri).v0 = TexelCoord(tex0).y

                        tris(indexTri).u1 = TexelCoord(tex1).x
                        tris(indexTri).v1 = TexelCoord(tex1).y

                        tris(indexTri).u2 = TexelCoord(tex2).x
                        tris(indexTri).v2 = TexelCoord(tex2).y
                    END IF
                END IF

                IF paramSubindex >= 2 THEN
                    tris(indexTri).vni0 = FindVertexNumAbsOrRel(ParameterStorage(1, 2), mostRecentVertexNormal)
                    tris(indexTri).vni1 = FindVertexNumAbsOrRel(ParameterStorage(2, 2), mostRecentVertexNormal)
                    tris(indexTri).vni2 = FindVertexNumAbsOrRel(ParameterStorage(3, 2), mostRecentVertexNormal)
                ELSE
                    tris(indexTri).vni0 = 0
                    tris(indexTri).vni1 = 0
                    tris(indexTri).vni2 = 0
                END IF
            END IF

            IF parameterIndex = 4 THEN
                i3 = FindVertexNumAbsOrRel(ParameterStorage(4, 0), mostRecentVertex)

                indexTri = indexTri + 1
                tris(indexTri).i0 = i0
                tris(indexTri).i1 = i2
                tris(indexTri).i2 = i3
                tris(indexTri).options = tris(indexTri - 1).options
                tris(indexTri).material = useMaterialNumber

                IF paramSubindex >= 1 THEN
                    IF (tris(indexTri).options AND T1_option_no_T1) = 0 THEN
                        tris(indexTri).u0 = TexelCoord(tex0).x
                        tris(indexTri).v0 = TexelCoord(tex0).y

                        tris(indexTri).u1 = TexelCoord(tex2).x
                        tris(indexTri).v1 = TexelCoord(tex2).y

                        tex3 = FindVertexNumAbsOrRel(ParameterStorage(4, 1), mostRecentVertexTexel)
                        tris(indexTri).u2 = TexelCoord(tex3).x
                        tris(indexTri).v2 = TexelCoord(tex3).y
                    END IF
                END IF

                IF paramSubindex >= 2 THEN
                    tris(indexTri).vni0 = FindVertexNumAbsOrRel(ParameterStorage(1, 2), mostRecentVertexNormal)
                    tris(indexTri).vni1 = FindVertexNumAbsOrRel(ParameterStorage(3, 2), mostRecentVertexNormal)
                    tris(indexTri).vni2 = FindVertexNumAbsOrRel(ParameterStorage(4, 2), mostRecentVertexNormal)
                ELSE
                    tris(indexTri).vni0 = 0
                    tris(indexTri).vni1 = 0
                    tris(indexTri).vni2 = 0
                END IF
            END IF

            IF (parameterIndex <> 3) AND (parameterIndex <> 4) THEN
                PRINT "Line "; lineCount; " what kind of face is this? ***************************************"
                SLEEP 3
            END IF

        ELSEIF LEFT$(rawString, 7) = "usemtl " THEN
            ' use material command

            lineCursor = 8
            parameterIndex = 0

            WHILE lineCursor < lineLength
                paramStringLength = 0

                ' eat spaces
                WHILE ASC(rawString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_SETMTL
                WEND

                ' count chars up to next space char, stopping if end of string reached
                paramStringStart = lineCursor
                WHILE ASC(rawString, lineCursor) > 32
                    paramStringLength = paramStringLength + 1
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                WEND

                IF paramStringLength > 0 THEN
                    parameterIndex = parameterIndex + 1
                    parameter$ = MID$(rawString, paramStringStart, paramStringLength)
                    useMaterialNumber = Find_Material_id_from_name(mats(), parameter$)
                    PRINT "use material ["; parameter$; "]", useMaterialNumber
                END IF
            WEND

            BAIL_SETMTL:
        END IF
    LOOP
    CLOSE #2
    'Dim temp$
    'Input "waiting..."; temp$
    'Sleep 3
END SUB

FUNCTION FindVertexNumAbsOrRel (param AS DOUBLE, recentvert AS LONG)
    IF param < 0 THEN
        ' relative
        ' -1 means the most recent vertex encountered
        FindVertexNumAbsOrRel = param + recentvert + 1
    ELSE
        FindVertexNumAbsOrRel = param
    END IF
END FUNCTION

SUB PrescanMaterialFile (thefile AS STRING, totalMaterials AS LONG)
    DIM lineCount AS LONG
    DIM rawString AS STRING
    DIM trimString AS STRING

    totalMaterials = 0
    lineCount = 0

    IF _FILEEXISTS(thefile) = 0 THEN
        PRINT "The file was not found"
        EXIT SUB
    END IF
    OPEN thefile FOR BINARY AS #2
    IF LOF(2) = 0 THEN
        PRINT "The file is empty"
        CLOSE #2
        EXIT SUB
    END IF

    DO UNTIL EOF(2)
        LINE INPUT #2, rawString
        lineCount = lineCount + 1
        trimString = _TRIM$(rawString)

        IF LEFT$(trimString, 7) = "newmtl " THEN
            totalMaterials = totalMaterials + 1
        END IF
    LOOP
    CLOSE #2

    PRINT totalMaterials, "Total Materials"
    'Dim temp$
    'Input "waiting..."; temp$

END SUB

SUB LoadMaterialFile (theFile AS STRING, mats() AS newmtl_type, totalMaterials AS LONG, hiddenMaterials AS LONG)
    DIM ParameterStorageNumeric(40) AS DOUBLE
    DIM ParameterStorageText(40) AS STRING

    DIM lineCount AS LONG
    DIM lineLength AS INTEGER
    DIM lineCursor AS INTEGER
    DIM parameterIndex AS INTEGER
    DIM subindex AS INTEGER
    DIM substringStart AS INTEGER
    DIM substringLength AS INTEGER

    DIM rawString AS STRING
    DIM trimString AS STRING
    DIM parameter AS STRING
    DIM textureFilename AS STRING

    totalMaterials = 0
    hiddenMaterials = 0
    lineCount = 0

    IF _FILEEXISTS(theFile) = 0 THEN
        PRINT "The mtl file was not found"
        EXIT SUB
    END IF
    OPEN theFile FOR BINARY AS #2
    IF LOF(2) = 0 THEN
        PRINT "The mtl file is empty"
        CLOSE #2
        EXIT SUB
    END IF

    DO UNTIL EOF(2)
        lineCount = lineCount + 1
        LINE INPUT #2, rawString
        lineLength = LEN(rawString)
        IF lineLength < 1 THEN _CONTINUE

        ' eat spaces
        ' unfortunately there is a tendency to have tabs or spaces in front of parameters to indent them
        lineCursor = 1
        WHILE ASC(rawString, lineCursor) <= 32
            lineCursor = lineCursor + 1
            IF lineCursor > lineLength THEN GOTO BAIL_INDENT_MATERIAL
        WEND
        trimString = MID$(rawString, lineCursor)

        lineCursor = 1 'now looking at trimString
        lineLength = LEN(trimString)
        IF LEFT$(trimString, 7) = "newmtl " THEN
            totalMaterials = totalMaterials + 1
            mats(totalMaterials).textName = _TRIM$(MID$(trimString, 8))
            ' set any defaults that are non-zero
            mats(totalMaterials).diaphaneity = 1.0
            mats(totalMaterials).illum = 2
            mats(totalMaterials).Ns = 10.0
            mats(totalMaterials).options = 0

        ELSEIF LEFT$(trimString, 6) = "map_d " THEN
            ' assume that this texture has see through parts, like a fence or ironwork.
            mats(totalMaterials).options = mats(totalMaterials).options OR T1_option_no_backface_cull

        ELSEIF LEFT$(trimString, 7) = "map_Kd " THEN
            ' this is the most common texture map from an image file
            lineCursor = 8
            parameterIndex = 0

            WHILE lineCursor < lineLength
                substringLength = 0

                ' eat spaces
                WHILE ASC(trimString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_MAP_KD
                WEND

                ' count chars up to next space char, stopping if end of string reached
                substringStart = lineCursor
                WHILE ASC(trimString, lineCursor) > 32
                    'Print Mid$(trimString, lineCursor, 1);
                    substringLength = substringLength + 1
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                WEND

                IF substringLength > 0 THEN
                    parameterIndex = parameterIndex + 1
                    parameter$ = MID$(trimString, substringStart, substringLength)
                    ParameterStorageText(parameterIndex) = _TRIM$(parameter$)
                    'Print parameterIndex, substringStart, substringLength, "["; parameter$; "]"
                END IF
            WEND

            BAIL_MAP_KD:
            IF parameterIndex > 0 THEN
                ' -options string comparison
                subindex = 1
                WHILE subindex < (parameterIndex - 1)
                    IF ParameterStorageText(subindex) = "-clamp" THEN
                        IF ParameterStorageText(subindex + 1) = "on" THEN
                            mats(totalMaterials).options = mats(totalMaterials).options OR T1_option_clamp_height OR T1_option_clamp_width
                            subindex = subindex + 1
                        ELSEIF ParameterStorageText(subindex + 1) = "u" THEN
                            mats(totalMaterials).options = mats(totalMaterials).options OR T1_option_clamp_width
                            subindex = subindex + 1
                        ELSEIF ParameterStorageText(subindex + 1) = "v" THEN
                            mats(totalMaterials).options = mats(totalMaterials).options OR T1_option_clamp_height
                            subindex = subindex + 1
                        END IF
                        subindex = subindex + 1
                    END IF
                WEND

                ' the filename is always last in the list
                textureFilename = ParameterStorageText(parameterIndex)
                InsertCatalogTexture textureFilename, mats(totalMaterials).map_Kd
                ' check for modelers giving bad Kd values when using a texture
                IF (mats(totalMaterials).Kd_r < oneOver255) AND (mats(totalMaterials).Kd_g < oneOver255) AND (mats(totalMaterials).Kd_b < oneOver255) THEN
                    PRINT "Warning: Kd RGB values are zero. Texture would be all black. Changing to 1.0"
                    mats(totalMaterials).Kd_r = 1.0
                    mats(totalMaterials).Kd_g = 1.0
                    mats(totalMaterials).Kd_b = 1.0
                END IF
            END IF

        ELSEIF LEFT$(trimString, 3) = "Kd " THEN
            ' Diffuse color is the most dominant color
            lineCursor = 4
            parameterIndex = 0

            WHILE lineCursor < lineLength
                substringLength = 0

                ' eat spaces
                WHILE ASC(trimString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_KD
                WEND

                ' count chars up to next space char, stopping if end of string reached
                substringStart = lineCursor
                WHILE ASC(trimString, lineCursor) > 32
                    'Print Mid$(trimString, lineCursor, 1);
                    substringLength = substringLength + 1
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                WEND

                IF substringLength > 0 THEN
                    parameterIndex = parameterIndex + 1
                    parameter$ = MID$(trimString, substringStart, substringLength)
                    ParameterStorageNumeric(parameterIndex) = VAL(parameter$)
                    'Print parameterIndex, substringStart, substringLength, "["; parameter$; "]"
                END IF
            WEND

            BAIL_KD:
            IF parameterIndex = 3 THEN
                mats(totalMaterials).Kd_r = ParameterStorageNumeric(1)
                mats(totalMaterials).Kd_g = ParameterStorageNumeric(2)
                mats(totalMaterials).Kd_b = ParameterStorageNumeric(3)
            END IF
            PRINT totalMaterials, "["; MID$(trimString, 4); "]"

        ELSEIF LEFT$(trimString, 3) = "Ks " THEN
            ' Specular color
            lineCursor = 4
            parameterIndex = 0

            WHILE lineCursor < lineLength
                substringLength = 0

                ' eat spaces
                WHILE ASC(trimString, lineCursor) <= 32
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN GOTO BAIL_KS
                WEND

                ' count chars up to next space char, stopping if end of string reached
                substringStart = lineCursor
                WHILE ASC(trimString, lineCursor) > 32
                    'Print Mid$(trimString, lineCursor, 1);
                    substringLength = substringLength + 1
                    lineCursor = lineCursor + 1
                    IF lineCursor > lineLength THEN EXIT WHILE
                WEND

                IF substringLength > 0 THEN
                    parameterIndex = parameterIndex + 1
                    parameter$ = MID$(trimString, substringStart, substringLength)
                    ParameterStorageNumeric(parameterIndex) = VAL(parameter$)
                    'Print parameterIndex, substringStart, substringLength, "["; parameter$; "]"
                END IF
            WEND

            BAIL_KS:
            IF parameterIndex = 3 THEN
                mats(totalMaterials).Ks_r = ParameterStorageNumeric(1)
                mats(totalMaterials).Ks_g = ParameterStorageNumeric(2)
                mats(totalMaterials).Ks_b = ParameterStorageNumeric(3)
            END IF
            'Print totalMaterials, "["; Mid$(trimString, 4); "]"

        ELSEIF LEFT$(trimString, 2) = "d " THEN
            ' diaphaneity
            mats(totalMaterials).diaphaneity = VAL(MID$(trimString, 3))
            IF mats(totalMaterials).diaphaneity = 0.0 THEN
                hiddenMaterials = hiddenMaterials + 1
            END IF

        ELSEIF LEFT$(trimString, 3) = "Ns " THEN
            ' specular power exponent
            mats(totalMaterials).Ns = VAL(MID$(trimString, 4))

        ELSEIF LEFT$(trimString, 6) = "illum " THEN
            ' illumination model
            mats(totalMaterials).illum = INT(VAL(MID$(trimString, 7)))

            ' correct overly ambitious raytracing illumination models to what we can render
            IF mats(totalMaterials).illum = illum_model_reflection_map_raytrace THEN mats(totalMaterials).illum = illum_model_blinn_phong
            IF mats(totalMaterials).illum = illum_model_glass_map_raytrace THEN mats(totalMaterials).illum = illum_model_blinn_phong
            IF mats(totalMaterials).illum = illum_model_fresnel THEN mats(totalMaterials).illum = illum_model_blinn_phong
            IF mats(totalMaterials).illum = illum_model_refraction THEN mats(totalMaterials).illum = illum_model_blinn_phong
            IF mats(totalMaterials).illum = illum_model_fresnel_refraction THEN mats(totalMaterials).illum = illum_model_blinn_phong
            IF mats(totalMaterials).illum = illum_model_glass_map THEN mats(totalMaterials).illum = illum_model_reflection_map

        END IF
        BAIL_INDENT_MATERIAL:
    LOOP
    CLOSE #2

    PRINT totalMaterials, "Total Materials"
    PRINT "#", "Name", "Kd_r", "Kd_g", "Kd_b", "d", "Ns", "illum"
    DIM i AS LONG
    FOR i = 1 TO totalMaterials
        PRINT i, mats(i).textName, mats(i).Kd_r, mats(i).Kd_g, mats(i).Kd_b, mats(i).diaphaneity, mats(i).Ns, mats(i).illum
    NEXT i

    'Dim temp$
    'Input "waiting..."; temp$
END SUB

FUNCTION Find_Material_id_from_name (mats() AS newmtl_type, in_name AS STRING)
    DIM i AS LONG
    Find_Material_id_from_name = 0

    'Print "find ["; in_name; "]"

    FOR i = LBOUND(mats) TO UBOUND(mats)
        'Print "{"; mats(i).textName; "} ";
        IF in_name = mats(i).textName THEN
            Find_Material_id_from_name = i
            'Print i; "match", in_name, mats(i).textName
            EXIT FOR
        END IF
    NEXT i
END FUNCTION

$CHECKING:OFF
SUB NearClip (A AS vec3d, B AS vec3d, C AS vec3d, D AS vec3d, TA AS vertex_attribute7, TB AS vertex_attribute7, TC AS vertex_attribute7, TD AS vertex_attribute7, result AS INTEGER)
    ' This function clips a triangle to Frustum_Near
    ' Winding order is preserved.
    ' result:
    ' 0 = do not draw
    ' 1 = only draw ABCA
    ' 2 = draw both ABCA and ACDA

    STATIC d_A_near_z AS SINGLE
    STATIC d_B_near_z AS SINGLE
    STATIC d_C_near_z AS SINGLE
    STATIC clip_score AS _UNSIGNED INTEGER
    STATIC ratio1 AS SINGLE
    STATIC ratio2 AS SINGLE

    d_A_near_z = A.z - Frustum_Near
    d_B_near_z = B.z - Frustum_Near
    d_C_near_z = C.z - Frustum_Near

    clip_score = 0
    IF d_A_near_z < 0.0 THEN clip_score = clip_score OR 1
    IF d_B_near_z < 0.0 THEN clip_score = clip_score OR 2
    IF d_C_near_z < 0.0 THEN clip_score = clip_score OR 4

    'Print clip_score;

    SELECT CASE clip_score
        CASE &B000
            'Print "no clip"
            result = 1


        CASE &B001
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


        CASE &B010
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


        CASE &B011
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


        CASE &B100
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


        CASE &B101
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


        CASE &B110
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


        CASE &B111
            'Print "discard"
            result = 0

    END SELECT

END SUB


' Multiply a 3D vector into a 4x4 matrix and output another 3D vector
' Important!: matrix o must be a different variable from matrix i. if i and o are the same variable it will malfunction.
' To understand the optimization here. Mathematically you can only multiply matrices of the same dimension. 4 here.
' But I'm only interested in x, y, and z; so don't bother calculating "w" because it is always 1.
' Avoiding 7 unnecessary extra multiplications
SUB Multiply_Vector3_Matrix4 (i AS vec3d, m( 3 , 3) AS SINGLE, o AS vec3d)
    o.x = i.x * m(0, 0) + i.y * m(1, 0) + i.z * m(2, 0) + m(3, 0)
    o.y = i.x * m(0, 1) + i.y * m(1, 1) + i.z * m(2, 1) + m(3, 1)
    o.z = i.x * m(0, 2) + i.y * m(1, 2) + i.z * m(2, 2) + m(3, 2)
END SUB

' If you ever need it, then go ahead and uncomment and pass in vec4d, but I doubt you ever would need it.
'SUB MultiplyMatrixVector4 (i AS vec4d, o AS vec4d, m( 3 , 3) AS SINGLE)
'    o.x = i.x * m(0, 0) + i.y * m(1, 0) + i.z * m(2, 0) + m(3, 0) * i.w
'    o.y = i.x * m(0, 1) + i.y * m(1, 1) + i.z * m(2, 1) + m(3, 1) * i.w
'    o.z = i.x * m(0, 2) + i.y * m(1, 2) + i.z * m(2, 2) + m(3, 2) * i.w
'    o.w = i.x * m(0, 3) + i.y * m(1, 3) + i.z * m(2, 3) + m(3, 3) * i.w
'END SUB

SUB Vector3_Add (left AS vec3d, right AS vec3d, o AS vec3d) STATIC
    o.x = left.x + right.x
    o.y = left.y + right.y
    o.z = left.z + right.z
END SUB

SUB Vector3_Delta (left AS vec3d, right AS vec3d, o AS vec3d) STATIC
    o.x = left.x - right.x
    o.y = left.y - right.y
    o.z = left.z - right.z
END SUB

SUB Vector3_Normalize (io AS vec3d) STATIC
    DIM length AS SINGLE
    length = SQR(io.x * io.x + io.y * io.y + io.z * io.z)
    IF length = 0.0 THEN
        io.x = 0.0
        io.y = 0.0
        io.z = 0.0
    ELSE
        io.x = io.x / length
        io.y = io.y / length
        io.z = io.z / length
    END IF
END SUB

SUB Vector3_Mul (left AS vec3d, scale AS SINGLE, o AS vec3d) STATIC
    o.x = left.x * scale
    o.y = left.y * scale
    o.z = left.z * scale
END SUB

SUB Vector3_CrossProduct (p0 AS vec3d, p1 AS vec3d, o AS vec3d) STATIC
    o.x = p0.y * p1.z - p0.z * p1.y
    o.y = p0.z * p1.x - p0.x * p1.z
    o.z = p0.x * p1.y - p0.y * p1.x
END SUB

SUB CalcSurfaceNormal_3Point (p0 AS vec3d, p1 AS vec3d, p2 AS vec3d, o AS vec3d) STATIC
    STATIC line1_x AS SINGLE, line1_y AS SINGLE, line1_z AS SINGLE
    STATIC line2_x AS SINGLE, line2_y AS SINGLE, line2_z AS SINGLE
    STATIC lengthNormal AS SINGLE

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

    lengthNormal = SQR(o.x * o.x + o.y * o.y + o.z * o.z)
    IF lengthNormal = 0.0 THEN EXIT SUB

    o.x = o.x / lengthNormal
    o.y = o.y / lengthNormal
    o.z = o.z / lengthNormal
END SUB

FUNCTION Vector3_DotProduct! (p0 AS vec3d, p1 AS vec3d) STATIC
    Vector3_DotProduct! = p0.x * p1.x + p0.y * p1.y + p0.z * p1.z
END FUNCTION

SUB Vector3_Reflect (i AS vec3d, normal AS vec3d, o AS vec3d) STATIC
    'mag = -2.0 * Vector3_DotProduct!(i, normal)
    'Vector3_Mul normal, mag, bounce
    'Vector3_Add bounce, i, o
    STATIC mag AS SINGLE
    mag = -2.0 * (i.x * normal.x + i.y * normal.y + i.z * normal.z)
    o.x = i.x + normal.x * mag
    o.y = i.y + normal.y * mag
    o.z = i.z + normal.z * mag
END SUB

SUB ConvertXYZ_to_CubeIUV (x AS SINGLE, y AS SINGLE, z AS SINGLE, index AS INTEGER, u AS SINGLE, v AS SINGLE)
    '     +---+
    '     | 2 |
    ' +---+---+---+---+
    ' | 1 | 4 | 0 | 5 |
    ' +---+---+---+---+
    '     | 3 |
    '     +---+
    STATIC absX AS SINGLE, absY AS SINGLE, absZ AS SINGLE
    absX = ABS(x)
    absY = ABS(y)
    absZ = ABS(z)

    IF absX >= absY AND absX >= absZ THEN
        IF x > 0 THEN
            ' POSITIVE X
            ' u (0 to 1) goes from +z to -z
            ' v (0 to 1) goes from -y to +y
            index = 0
            ' Convert range from -1 to 1 to 0 to 1
            u = 0.5 * (-z / absX + 1.0)
            v = 0.5 * (-y / absX + 1.0)
            EXIT SUB
        ELSE
            ' NEGATIVE X
            ' u (0 to 1) goes from -z to +z
            ' v (0 to 1) goes from -y to +y
            index = 1
            IF absX = 0 THEN
                ' Bail out
                u = 0.5
                v = 0.5
                EXIT SUB
            END IF
            ' Convert range from -1 to 1 to 0 to 1
            u = 0.5 * (z / absX + 1.0)
            v = 0.5 * (-y / absX + 1.0)
            EXIT SUB
        END IF
    END IF

    IF absY >= absX AND absY >= absZ THEN
        IF y > 0 THEN
            ' POSITIVE Y
            ' u (0 to 1) goes from -x to +x
            ' v (0 to 1) goes from +z to -z
            index = 2
            ' Convert range from -1 to 1 to 0 to 1
            u = 0.5 * (x / absY + 1.0)
            v = 0.5 * (z / absY + 1.0)
            EXIT SUB
        ELSE
            ' NEGATIVE Y
            ' u (0 to 1) goes from -x to +x
            ' v (0 to 1) goes from -z to +z
            index = 3
            ' Convert range from -1 to 1 to 0 to 1
            u = 0.5 * (x / absY + 1.0)
            v = 0.5 * (-z / absY + 1.0)
            EXIT SUB
        END IF
    END IF

    IF z > 0 THEN
        ' POSITIVE Z
        ' u (0 to 1) goes from -x to +x
        ' v (0 to 1) goes from -y to +y
        index = 4
        ' Convert range from -1 to 1 to 0 to 1
        u = 0.5 * (x / absZ + 1.0)
        v = 0.5 * (-y / absZ + 1.0)
        EXIT SUB
    ELSE
        ' NEGATIVE Z
        ' u (0 to 1) goes from +x to -x
        ' v (0 to 1) goes from -y to +y
        index = 5
        ' Convert range from -1 to 1 to 0 to 1
        u = 0.5 * (-x / absZ + 1.0)
        v = 0.5 * (-y / absZ + 1.0)
    END IF
END SUB

SUB Matrix4_MakeIdentity (m( 3 , 3) AS SINGLE)
    m(0, 0) = 1.0: m(0, 1) = 0.0: m(0, 2) = 0.0: m(0, 3) = 0.0
    m(1, 1) = 0.0: m(1, 1) = 1.0: m(1, 2) = 0.0: m(1, 3) = 0.0
    m(2, 2) = 0.0: m(2, 1) = 0.0: m(2, 2) = 1.0: m(2, 3) = 0.0
    m(3, 0) = 0.0: m(3, 1) = 0.0: m(3, 2) = 0.0: m(3, 3) = 1.0
END SUB

SUB Matrix4_MakeRotation_Z (deg AS SINGLE, m( 3 , 3) AS SINGLE)
    ' Rotation Z
    m(0, 0) = COS(_D2R(deg))
    m(0, 1) = SIN(_D2R(deg))
    m(0, 2) = 0.0
    m(0, 3) = 0.0
    m(1, 0) = -SIN(_D2R(deg))
    m(1, 1) = COS(_D2R(deg))
    m(1, 2) = 0.0
    m(1, 3) = 0.0
    m(2, 0) = 0.0: m(2, 1) = 0.0: m(2, 2) = 1.0: m(2, 3) = 0.0
    m(3, 0) = 0.0: m(3, 1) = 0.0: m(3, 2) = 0.0: m(3, 3) = 1.0
END SUB

SUB Matrix4_MakeRotation_Y (deg AS SINGLE, m( 3 , 3) AS SINGLE)
    m(0, 0) = COS(_D2R(deg))
    m(0, 1) = 0.0
    m(0, 2) = SIN(_D2R(deg))
    m(0, 3) = 0.0
    m(1, 0) = 0.0: m(1, 1) = 1.0: m(1, 2) = 0.0: m(1, 3) = 0.0
    m(2, 0) = -SIN(_D2R(deg))
    m(2, 1) = 0.0
    m(2, 2) = COS(_D2R(deg))
    m(2, 3) = 0.0
    m(3, 0) = 0.0: m(3, 1) = 0.0: m(3, 2) = 0.0: m(3, 3) = 1.0
END SUB

SUB Matrix4_MakeRotation_X (deg AS SINGLE, m( 3 , 3) AS SINGLE)
    m(0, 0) = 1.0: m(0, 1) = 0.0: m(0, 2) = 0.0: m(0, 3) = 0.0
    m(1, 0) = 0.0
    m(1, 1) = COS(_D2R(deg))
    m(1, 2) = -SIN(_D2R(deg)) 'flip
    m(1, 3) = 0.0
    m(2, 0) = 0.0
    m(2, 1) = SIN(_D2R(deg)) 'flip
    m(2, 2) = COS(_D2R(deg))
    m(2, 3) = 0.0
    m(3, 0) = 0.0: m(3, 1) = 0.0: m(3, 2) = 0.0: m(3, 3) = 1.0
END SUB

SUB Matrix4_PointAt (psn AS vec3d, target AS vec3d, up AS vec3d, m( 3 , 3) AS SINGLE)
    ' Calculate new forward direction
    DIM newForward AS vec3d
    Vector3_Delta target, psn, newForward
    Vector3_Normalize newForward

    ' Calculate new Up direction
    DIM a AS vec3d
    DIM newUp AS vec3d
    Vector3_Mul newForward, Vector3_DotProduct(up, newForward), a
    Vector3_Delta up, a, newUp
    Vector3_Normalize newUp

    ' new Right direction is just cross product
    DIM newRight AS vec3d
    Vector3_CrossProduct newUp, newForward, newRight

    ' Construct Dimensioning and Translation Matrix
    m(0, 0) = newRight.x: m(0, 1) = newRight.y: m(0, 2) = newRight.z: m(0, 3) = 0.0
    m(1, 0) = newUp.x: m(1, 1) = newUp.y: m(1, 2) = newUp.z: m(1, 3) = 0.0
    m(2, 0) = newForward.x: m(2, 1) = newForward.y: m(2, 2) = newForward.z: m(2, 3) = 0.0
    m(3, 0) = psn.x: m(3, 1) = psn.y: m(3, 2) = psn.z: m(3, 3) = 1.0

END SUB

SUB Matrix4_QuickInverse (m( 3 , 3) AS SINGLE, q( 3 , 3) AS SINGLE)
    q(0, 0) = m(0, 0): q(0, 1) = m(1, 0): q(0, 2) = m(2, 0): q(0, 3) = 0.0
    q(1, 0) = m(0, 1): q(1, 1) = m(1, 1): q(1, 2) = m(2, 1): q(1, 3) = 0.0
    q(2, 0) = m(0, 2): q(2, 1) = m(1, 2): q(2, 2) = m(2, 2): q(2, 3) = 0.0
    q(3, 0) = -(m(3, 0) * q(0, 0) + m(3, 1) * q(1, 0) + m(3, 2) * q(2, 0))
    q(3, 1) = -(m(3, 0) * q(0, 1) + m(3, 1) * q(1, 1) + m(3, 2) * q(2, 1))
    q(3, 2) = -(m(3, 0) * q(0, 2) + m(3, 1) * q(1, 2) + m(3, 2) * q(2, 2))
    q(3, 3) = 1.0
END SUB

' This is the generic 3D point projection formula with a 4 by 4 matrix.
'  input w is assumed always 1, so you can send a vec3d.
' Practical reasons for this existing are to:
'  Simulate lens field of view angles.
'  Normalize depth to maximum numeric range between the near and far plane.
'  Have the ability to swap coordinates. For example swap input Y and Z.
'  Give a 4th channel with which to perform perspective division (or not).
'  Perform non-perspective projections like isometric.
'  Warp projections to depict momentary disorientation from a large blast.
SUB ProjectMatrixVector4 (i AS vec3d, m( 3 , 3) AS SINGLE, o AS vec4d)
    DIM www AS SINGLE
    o.x = i.x * m(0, 0) + i.y * m(1, 0) + i.z * m(2, 0) + m(3, 0)
    o.y = i.x * m(0, 1) + i.y * m(1, 1) + i.z * m(2, 1) + m(3, 1)
    o.z = i.x * m(0, 2) + i.y * m(1, 2) + i.z * m(2, 2) + m(3, 2)
    www = i.x * m(0, 3) + i.y * m(1, 3) + i.z * m(2, 3) + m(3, 3)

    ' Normalizing
    IF www <> 0.0 THEN
        o.w = 1 / www ' optimization
        o.x = o.x * o.w
        o.y = o.y * o.w
    END IF
END SUB

' Simplified Perspective Projection Only
' The concept of perspective projection being division by z gets lost in the matrix.
' Here is the equation from above, rewritten without the always zero and unused Z matrix element values.
' o.z is unused.
SUB ProjectPerspectiveVector4 (i AS vec3d, m( 3 , 3) AS SINGLE, o AS vec4d)
    IF i.z <> 0.0 THEN
        o.w = 1.0 / i.z ' we need 1/z for later, plus we can multiply it with x and y instead of divide.
        o.x = i.x * m(0, 0) * o.w ' same as i.x * m(0,0) / i.z
        o.y = i.y * m(1, 1) * o.w
    ELSE
        o.w = 0.0
    END IF
END SUB


SUB VertexColorAlphaTriangle (A AS vertex9, B AS vertex9, C AS vertex9)
    STATIC delta2 AS vertex9
    STATIC delta1 AS vertex9
    STATIC draw_min_y AS LONG, draw_max_y AS LONG

    ' Sort so that vertex A is on top and C is on bottom.
    ' This seems inverted from math class, but remember that Y increases in value downward on PC monitors
    IF B.y < A.y THEN
        SWAP A, B
    END IF
    IF C.y < A.y THEN
        SWAP A, C
    END IF
    IF C.y < B.y THEN
        SWAP B, C
    END IF

    ' integer window clipping
    draw_min_y = _CEIL(A.y)
    IF draw_min_y < clip_min_y THEN draw_min_y = clip_min_y
    draw_max_y = _CEIL(C.y) - 1
    IF draw_max_y > clip_max_y THEN draw_max_y = clip_max_y
    IF (draw_max_y - draw_min_y) < 0 THEN EXIT SUB

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
    delta2.a = C.a - A.a

    ' Avoiding div by 0
    ' Entire Y height less than 1/256 would not have meaningful pixel color change
    IF delta2.y < (1 / 256) THEN EXIT SUB

    ' Determine vertical Y steps for DDA style math
    ' DDA is Digital Differential Analyzer
    ' It is an accumulator that counts from a known start point to an end point, in equal increments defined by the number of steps in-between.
    ' Probably faster nowadays to do the one division at the start, instead of Bresenham, anyway.
    STATIC legx1_step AS SINGLE
    STATIC legw1_step AS SINGLE, legu1_step AS SINGLE, legv1_step AS SINGLE
    STATIC legr1_step AS SINGLE, legg1_step AS SINGLE, legb1_step AS SINGLE
    STATIC lega1_step AS SINGLE

    STATIC legx2_step AS SINGLE
    STATIC legw2_step AS SINGLE, legu2_step AS SINGLE, legv2_step AS SINGLE
    STATIC legr2_step AS SINGLE, legg2_step AS SINGLE, legb2_step AS SINGLE
    STATIC lega2_step AS SINGLE

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y
    legr2_step = delta2.r / delta2.y
    legg2_step = delta2.g / delta2.y
    legb2_step = delta2.b / delta2.y
    lega2_step = delta2.a / delta2.y

    ' Leg 1, Draw top to middle
    ' For most triangles, draw downward from the apex A to a knee B.
    ' That knee could be on either the left or right side, but that is handled much later.
    STATIC draw_middle_y AS LONG
    draw_middle_y = _CEIL(B.y)
    IF draw_middle_y < clip_min_y THEN draw_middle_y = clip_min_y
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
    delta1.a = B.a - A.a

    ' If the triangle has no knee, this section gets skipped to avoid divide by 0.
    ' That is okay, because the recalculate Leg 1 from B to C triggers before actually drawing.
    IF delta1.y > (1 / 256) THEN
        ' Find Leg 1 steps in the y direction from A to B
        legx1_step = delta1.x / delta1.y
        legw1_step = delta1.w / delta1.y
        legu1_step = delta1.u / delta1.y
        legv1_step = delta1.v / delta1.y
        legr1_step = delta1.r / delta1.y
        legg1_step = delta1.g / delta1.y
        legb1_step = delta1.b / delta1.y
        lega1_step = delta1.a / delta1.y
    END IF

    ' Y Accumulators
    STATIC leg_x1 AS SINGLE
    STATIC leg_w1 AS SINGLE, leg_u1 AS SINGLE, leg_v1 AS SINGLE
    STATIC leg_r1 AS SINGLE, leg_g1 AS SINGLE, leg_b1 AS SINGLE
    STATIC leg_a1 AS SINGLE

    STATIC leg_x2 AS SINGLE
    STATIC leg_w2 AS SINGLE, leg_u2 AS SINGLE, leg_v2 AS SINGLE
    STATIC leg_r2 AS SINGLE, leg_g2 AS SINGLE, leg_b2 AS SINGLE
    STATIC leg_a2 AS SINGLE

    ' 11-4-2022 Prestep Y
    STATIC prestep_y1 AS SINGLE
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
    leg_a1 = A.a + prestep_y1 * lega1_step

    leg_x2 = A.x + prestep_y1 * legx2_step
    leg_w2 = A.w + prestep_y1 * legw2_step
    leg_u2 = A.u + prestep_y1 * legu2_step
    leg_v2 = A.v + prestep_y1 * legv2_step
    leg_r2 = A.r + prestep_y1 * legr2_step
    leg_g2 = A.g + prestep_y1 * legg2_step
    leg_b2 = A.b + prestep_y1 * legb2_step
    leg_a2 = A.a + prestep_y1 * lega2_step

    ' Inner loop vars
    STATIC row AS LONG
    STATIC col AS LONG
    STATIC draw_max_x AS LONG
    STATIC zbuf_index AS _UNSIGNED LONG ' Z-Buffer
    STATIC tex_z AS SINGLE ' 1/w helper (multiply by inverse is faster than dividing each time)
    STATIC pixel_alpha AS SINGLE

    ' Stepping along the X direction
    STATIC delta_x AS SINGLE
    STATIC prestep_x AS SINGLE
    STATIC tex_w_step AS SINGLE, tex_u_step AS SINGLE, tex_v_step AS SINGLE
    STATIC tex_r_step AS SINGLE, tex_g_step AS SINGLE, tex_b_step AS SINGLE
    STATIC tex_a_step AS SINGLE

    ' X Accumulators
    STATIC tex_w AS SINGLE, tex_u AS SINGLE, tex_v AS SINGLE
    STATIC tex_r AS SINGLE, tex_g AS SINGLE, tex_b AS SINGLE
    STATIC tex_a AS SINGLE

    ' Work Screen Memory Pointers
    STATIC work_mem_info AS _MEM
    STATIC work_next_row_step AS _OFFSET
    STATIC work_row_base AS _OFFSET ' Calculated every row
    STATIC work_address AS _OFFSET ' Calculated at every starting column
    work_mem_info = _MEMIMAGE(WORK_IMAGE)
    work_next_row_step = 4 * Size_Render_X

    ' caching of 4 texels in bilinear mode
    STATIC T1_last_cache AS _UNSIGNED LONG
    T1_last_cache = &HFFFFFFFF ' Invalidate texel cache

    ' Row Loop from top to bottom
    row = draw_min_y
    work_row_base = work_mem_info.OFFSET + row * work_next_row_step
    WHILE row <= draw_max_y

        IF row = draw_middle_y THEN
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
            delta1.a = C.a - B.a

            IF delta1.y = 0.0 THEN EXIT SUB

            ' Full steps in the y direction from B to C
            legx1_step = delta1.x / delta1.y
            legw1_step = delta1.w / delta1.y
            legu1_step = delta1.u / delta1.y
            legv1_step = delta1.v / delta1.y
            legr1_step = delta1.r / delta1.y ' vertex color
            legg1_step = delta1.g / delta1.y
            legb1_step = delta1.b / delta1.y
            lega1_step = delta1.a / delta1.y

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
            leg_a1 = B.a + prestep_y1 * lega1_step
        END IF

        ' Horizontal Scanline
        delta_x = ABS(leg_x2 - leg_x1)
        ' Avoid div/0, this gets tiring.
        IF delta_x >= (1 / 2048) THEN
            ' Calculate step, start, and end values.
            ' Drawing left to right, as in incrementing from a lower to higher memory address, is usually fastest.
            IF leg_x1 < leg_x2 THEN
                ' leg 1 is on the left
                tex_w_step = (leg_w2 - leg_w1) / delta_x
                tex_u_step = (leg_u2 - leg_u1) / delta_x
                tex_v_step = (leg_v2 - leg_v1) / delta_x
                tex_r_step = (leg_r2 - leg_r1) / delta_x
                tex_g_step = (leg_g2 - leg_g1) / delta_x
                tex_b_step = (leg_b2 - leg_b1) / delta_x
                tex_a_step = (leg_a2 - leg_a1) / delta_x

                ' Set the horizontal starting point to (1)
                col = _CEIL(leg_x1)
                IF col < clip_min_x THEN col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x1
                tex_w = leg_w1 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u1 + prestep_x * tex_u_step
                tex_v = leg_v1 + prestep_x * tex_v_step
                tex_r = leg_r1 + prestep_x * tex_r_step
                tex_g = leg_g1 + prestep_x * tex_g_step
                tex_b = leg_b1 + prestep_x * tex_b_step
                tex_a = leg_a1 + prestep_x * tex_a_step

                ' ending point is (2)
                draw_max_x = _CEIL(leg_x2)
                IF draw_max_x > clip_max_x THEN draw_max_x = clip_max_x

            ELSE
                ' Things are flipped. leg 1 is on the right.
                tex_w_step = (leg_w1 - leg_w2) / delta_x
                tex_u_step = (leg_u1 - leg_u2) / delta_x
                tex_v_step = (leg_v1 - leg_v2) / delta_x
                tex_r_step = (leg_r1 - leg_r2) / delta_x
                tex_g_step = (leg_g1 - leg_g2) / delta_x
                tex_b_step = (leg_b1 - leg_b2) / delta_x
                tex_a_step = (leg_a1 - leg_a2) / delta_x

                ' Set the horizontal starting point to (2)
                col = _CEIL(leg_x2)
                IF col < clip_min_x THEN col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x2
                tex_w = leg_w2 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step
                tex_r = leg_r2 + prestep_x * tex_r_step
                tex_g = leg_g2 + prestep_x * tex_g_step
                tex_b = leg_b2 + prestep_x * tex_b_step
                tex_a = leg_a2 + prestep_x * tex_a_step

                ' ending point is (1)
                draw_max_x = _CEIL(leg_x1)
                IF draw_max_x > clip_max_x THEN draw_max_x = clip_max_x

            END IF

            ' metrics
            IF col < draw_max_x THEN Pixels_Drawn_This_Frame = Pixels_Drawn_This_Frame + (draw_max_x - col)

            ' Draw the Horizontal Scanline
            ' Optimization: before entering this loop, must have done tex_z = 1 / tex_w
            work_address = work_row_base + 4 * col
            zbuf_index = row * Size_Render_X + col
            WHILE col < draw_max_x

                IF Screen_Z_Buffer(zbuf_index) = 0.0 OR tex_z < Screen_Z_Buffer(zbuf_index) THEN
                    IF (Texture_options AND T1_option_no_Z_write) = 0 THEN
                        Screen_Z_Buffer(zbuf_index) = tex_z + Z_Fight_Bias
                    END IF

                    STATIC pixel_combine AS _UNSIGNED LONG
                    pixel_combine = _RGB32(tex_r, tex_g, tex_b)

                    STATIC pixel_existing AS _UNSIGNED LONG
                    pixel_alpha = T1_mod_A
                    IF pixel_alpha < 0.998 THEN
                        pixel_existing = _MEMGET(work_mem_info, work_address, _UNSIGNED LONG)
                        pixel_combine = _RGB32((  _red32(pixel_combine) - _Red32(pixel_existing))   * pixel_alpha + _red32(pixel_existing), _
                                               (_green32(pixel_combine) - _Green32(pixel_existing)) * pixel_alpha + _green32(pixel_existing), _
                                               ( _Blue32(pixel_combine) - _Blue32(pixel_existing))  * pixel_alpha + _blue32(pixel_existing))

                        ' x = (p1 - p0) * ratio + p0 is equivalent to
                        ' x = (1.0 - ratio) * p0 + ratio * p1
                    END IF
                    _MEMPUT work_mem_info, work_address, pixel_combine

                END IF ' tex_z
                zbuf_index = zbuf_index + 1
                tex_w = tex_w + tex_w_step
                tex_z = 1 / tex_w ' floating point divide can be done in parallel when result not required immediately.
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                tex_r = tex_r + tex_r_step
                tex_g = tex_g + tex_g_step
                tex_b = tex_b + tex_b_step
                tex_a = tex_a + tex_a_step
                work_address = work_address + 4
                col = col + 1
            WEND ' col

        END IF ' end div/0 avoidance

        ' DDA next step
        leg_x1 = leg_x1 + legx1_step
        leg_w1 = leg_w1 + legw1_step
        leg_u1 = leg_u1 + legu1_step
        leg_v1 = leg_v1 + legv1_step
        leg_r1 = leg_r1 + legr1_step
        leg_g1 = leg_g1 + legg1_step
        leg_b1 = leg_b1 + legb1_step
        leg_a1 = leg_a1 + lega1_step

        leg_x2 = leg_x2 + legx2_step
        leg_w2 = leg_w2 + legw2_step
        leg_u2 = leg_u2 + legu2_step
        leg_v2 = leg_v2 + legv2_step
        leg_r2 = leg_r2 + legr2_step
        leg_g2 = leg_g2 + legg2_step
        leg_b2 = leg_b2 + legb2_step
        leg_a2 = leg_a2 + lega2_step

        work_row_base = work_row_base + work_next_row_step
        row = row + 1
    WEND ' row

END SUB

SUB TextureWithAlphaTriangle (A AS vertex9, B AS vertex9, C AS vertex9)
    ' is able to handle non power of 2 texture sizes
    STATIC delta2 AS vertex9
    STATIC delta1 AS vertex9
    STATIC draw_min_y AS LONG, draw_max_y AS LONG

    ' Sort so that vertex A is on top and C is on bottom.
    ' This seems inverted from math class, but remember that Y increases in value downward on PC monitors
    IF B.y < A.y THEN
        SWAP A, B
    END IF
    IF C.y < A.y THEN
        SWAP A, C
    END IF
    IF C.y < B.y THEN
        SWAP B, C
    END IF

    ' integer window clipping
    draw_min_y = _CEIL(A.y)
    IF draw_min_y < clip_min_y THEN draw_min_y = clip_min_y
    draw_max_y = _CEIL(C.y) - 1
    IF draw_max_y > clip_max_y THEN draw_max_y = clip_max_y
    IF (draw_max_y - draw_min_y) < 0 THEN EXIT SUB

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
    delta2.a = C.a - A.a

    ' Avoiding div by 0
    ' Entire Y height less than 1/256 would not have meaningful pixel color change
    IF delta2.y < (1 / 256) THEN EXIT SUB

    ' Determine vertical Y steps for DDA style math
    ' DDA is Digital Differential Analyzer
    ' It is an accumulator that counts from a known start point to an end point, in equal increments defined by the number of steps in-between.
    ' Probably faster nowadays to do the one division at the start, instead of Bresenham, anyway.
    STATIC legx1_step AS SINGLE
    STATIC legw1_step AS SINGLE, legu1_step AS SINGLE, legv1_step AS SINGLE
    STATIC legr1_step AS SINGLE, legg1_step AS SINGLE, legb1_step AS SINGLE
    STATIC lega1_step AS SINGLE

    STATIC legx2_step AS SINGLE
    STATIC legw2_step AS SINGLE, legu2_step AS SINGLE, legv2_step AS SINGLE
    STATIC legr2_step AS SINGLE, legg2_step AS SINGLE, legb2_step AS SINGLE
    STATIC lega2_step AS SINGLE

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y
    legr2_step = delta2.r / delta2.y
    legg2_step = delta2.g / delta2.y
    legb2_step = delta2.b / delta2.y
    lega2_step = delta2.a / delta2.y

    ' Leg 1, Draw top to middle
    ' For most triangles, draw downward from the apex A to a knee B.
    ' That knee could be on either the left or right side, but that is handled much later.
    STATIC draw_middle_y AS LONG
    draw_middle_y = _CEIL(B.y)
    IF draw_middle_y < clip_min_y THEN draw_middle_y = clip_min_y
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
    delta1.a = B.a - A.a

    ' If the triangle has no knee, this section gets skipped to avoid divide by 0.
    ' That is okay, because the recalculate Leg 1 from B to C triggers before actually drawing.
    IF delta1.y > (1 / 256) THEN
        ' Find Leg 1 steps in the y direction from A to B
        legx1_step = delta1.x / delta1.y
        legw1_step = delta1.w / delta1.y
        legu1_step = delta1.u / delta1.y
        legv1_step = delta1.v / delta1.y
        legr1_step = delta1.r / delta1.y
        legg1_step = delta1.g / delta1.y
        legb1_step = delta1.b / delta1.y
        lega1_step = delta1.a / delta1.y
    END IF

    ' Y Accumulators
    STATIC leg_x1 AS SINGLE
    STATIC leg_w1 AS SINGLE, leg_u1 AS SINGLE, leg_v1 AS SINGLE
    STATIC leg_r1 AS SINGLE, leg_g1 AS SINGLE, leg_b1 AS SINGLE
    STATIC leg_a1 AS SINGLE

    STATIC leg_x2 AS SINGLE
    STATIC leg_w2 AS SINGLE, leg_u2 AS SINGLE, leg_v2 AS SINGLE
    STATIC leg_r2 AS SINGLE, leg_g2 AS SINGLE, leg_b2 AS SINGLE
    STATIC leg_a2 AS SINGLE

    ' 11-4-2022 Prestep Y
    STATIC prestep_y1 AS SINGLE
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
    leg_a1 = A.a + prestep_y1 * lega1_step

    leg_x2 = A.x + prestep_y1 * legx2_step
    leg_w2 = A.w + prestep_y1 * legw2_step
    leg_u2 = A.u + prestep_y1 * legu2_step
    leg_v2 = A.v + prestep_y1 * legv2_step
    leg_r2 = A.r + prestep_y1 * legr2_step
    leg_g2 = A.g + prestep_y1 * legg2_step
    leg_b2 = A.b + prestep_y1 * legb2_step
    leg_a2 = A.a + prestep_y1 * lega2_step

    ' Inner loop vars
    STATIC row AS LONG
    STATIC col AS LONG
    STATIC draw_max_x AS LONG
    STATIC zbuf_index AS _UNSIGNED LONG ' Z-Buffer
    STATIC tex_z AS SINGLE ' 1/w helper (multiply by inverse is faster than dividing each time)
    STATIC pixel_value AS _UNSIGNED LONG ' The ARGB value to write to screen

    ' Stepping along the X direction
    STATIC delta_x AS SINGLE
    STATIC prestep_x AS SINGLE
    STATIC tex_w_step AS SINGLE, tex_u_step AS SINGLE, tex_v_step AS SINGLE
    STATIC tex_r_step AS SINGLE, tex_g_step AS SINGLE, tex_b_step AS SINGLE
    STATIC tex_a_step AS SINGLE

    ' X Accumulators
    STATIC tex_w AS SINGLE, tex_u AS SINGLE, tex_v AS SINGLE
    STATIC tex_r AS SINGLE, tex_g AS SINGLE, tex_b AS SINGLE
    STATIC tex_a AS SINGLE

    ' Work Screen Memory Pointers
    STATIC work_mem_info AS _MEM
    STATIC work_next_row_step AS _OFFSET
    STATIC work_row_base AS _OFFSET ' Calculated every row
    STATIC work_address AS _OFFSET ' Calculated at every starting column
    work_mem_info = _MEMIMAGE(WORK_IMAGE)
    work_next_row_step = 4 * Size_Render_X

    ' caching of 4 texels in bilinear mode
    STATIC T1_last_cache AS _UNSIGNED LONG
    T1_last_cache = &HFFFFFFFF ' invalidate

    ' Row Loop from top to bottom
    row = draw_min_y
    work_row_base = work_mem_info.OFFSET + row * work_next_row_step
    WHILE row <= draw_max_y

        IF row = draw_middle_y THEN
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
            delta1.a = C.a - B.a

            IF delta1.y = 0.0 THEN EXIT SUB

            ' Full steps in the y direction from B to C
            legx1_step = delta1.x / delta1.y
            legw1_step = delta1.w / delta1.y
            legu1_step = delta1.u / delta1.y
            legv1_step = delta1.v / delta1.y
            legr1_step = delta1.r / delta1.y ' vertex color
            legg1_step = delta1.g / delta1.y
            legb1_step = delta1.b / delta1.y
            lega1_step = delta1.a / delta1.y

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
            leg_a1 = B.a + prestep_y1 * lega1_step
        END IF

        ' Horizontal Scanline
        delta_x = ABS(leg_x2 - leg_x1)
        ' Avoid div/0, this gets tiring.
        IF delta_x >= (1 / 2048) THEN
            ' Calculate step, start, and end values.
            ' Drawing left to right, as in incrementing from a lower to higher memory address, is usually fastest.
            IF leg_x1 < leg_x2 THEN
                ' leg 1 is on the left
                tex_w_step = (leg_w2 - leg_w1) / delta_x
                tex_u_step = (leg_u2 - leg_u1) / delta_x
                tex_v_step = (leg_v2 - leg_v1) / delta_x
                tex_r_step = (leg_r2 - leg_r1) / delta_x
                tex_g_step = (leg_g2 - leg_g1) / delta_x
                tex_b_step = (leg_b2 - leg_b1) / delta_x
                tex_a_step = (leg_a2 - leg_a1) / delta_x

                ' Set the horizontal starting point to (1)
                col = _CEIL(leg_x1)
                IF col < clip_min_x THEN col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x1
                tex_w = leg_w1 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u1 + prestep_x * tex_u_step
                tex_v = leg_v1 + prestep_x * tex_v_step
                tex_r = leg_r1 + prestep_x * tex_r_step
                tex_g = leg_g1 + prestep_x * tex_g_step
                tex_b = leg_b1 + prestep_x * tex_b_step
                tex_a = leg_a1 + prestep_x * tex_a_step

                ' ending point is (2)
                draw_max_x = _CEIL(leg_x2)
                IF draw_max_x > clip_max_x THEN draw_max_x = clip_max_x

            ELSE
                ' Things are flipped. leg 1 is on the right.
                tex_w_step = (leg_w1 - leg_w2) / delta_x
                tex_u_step = (leg_u1 - leg_u2) / delta_x
                tex_v_step = (leg_v1 - leg_v2) / delta_x
                tex_r_step = (leg_r1 - leg_r2) / delta_x
                tex_g_step = (leg_g1 - leg_g2) / delta_x
                tex_b_step = (leg_b1 - leg_b2) / delta_x
                tex_a_step = (leg_a1 - leg_a2) / delta_x

                ' Set the horizontal starting point to (2)
                col = _CEIL(leg_x2)
                IF col < clip_min_x THEN col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x2
                tex_w = leg_w2 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step
                tex_r = leg_r2 + prestep_x * tex_r_step
                tex_g = leg_g2 + prestep_x * tex_g_step
                tex_b = leg_b2 + prestep_x * tex_b_step
                tex_a = leg_a2 + prestep_x * tex_a_step

                ' ending point is (1)
                draw_max_x = _CEIL(leg_x1)
                IF draw_max_x > clip_max_x THEN draw_max_x = clip_max_x

            END IF

            ' metrics
            IF col < draw_max_x THEN Pixels_Drawn_This_Frame = Pixels_Drawn_This_Frame + (draw_max_x - col)

            ' Draw the Horizontal Scanline
            ' Optimization: before entering this loop, must have done tex_z = 1 / tex_w
            ' Relies on some shared T1 variables over by Texture1
            work_address = work_row_base + 4 * col
            zbuf_index = row * Size_Render_X + col
            WHILE col < draw_max_x

                ' Check Z-Buffer early to see if we even need texture lookup and color combine
                ' Note: Only solid (non-transparent) pixels update the Z-buffer
                IF Screen_Z_Buffer(zbuf_index) = 0.0 OR tex_z < Screen_Z_Buffer(zbuf_index) THEN

                    ' Read Texel
                    ' Relies on shared T1_ variables
                    STATIC cc AS LONG
                    STATIC ccp AS LONG
                    STATIC rr AS LONG
                    STATIC rrp AS LONG

                    STATIC cm5 AS SINGLE
                    STATIC rm5 AS SINGLE

                    ' Recover U and V
                    ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                    cm5 = (tex_u * tex_z) - 0.5
                    rm5 = (tex_v * tex_z) - 0.5

                    IF Texture_options AND T1_option_clamp_width THEN
                        ' clamp
                        IF cm5 < 0.0 THEN cm5 = 0.0
                        IF cm5 >= T1_width_MASK THEN
                            ' 15.0 and up
                            cc = T1_width_MASK
                            ccp = T1_width_MASK
                        ELSE
                            ' 0 1 2 .. 13 14.999
                            cc = INT(cm5)
                            ccp = cc + 1
                        END IF
                    ELSE
                        ' tile
                        ' positive modulus
                        cc = INT(cm5) MOD T1_width
                        IF cc < 0 THEN cc = cc + T1_width

                        ccp = cc + 1
                        IF ccp > T1_width_MASK THEN ccp = 0
                    END IF

                    IF Texture_options AND T1_option_clamp_height THEN
                        ' clamp
                        IF rm5 < 0.0 THEN rm5 = 0.0
                        IF rm5 >= T1_height_MASK THEN
                            ' 15.0 and up
                            rr = T1_height_MASK
                            rrp = T1_height_MASK
                        ELSE
                            rr = INT(rm5)
                            rrp = rr + 1
                        END IF
                    ELSE
                        ' tile
                        ' positive modulus
                        rr = INT(rm5) MOD T1_height
                        IF rr < 0 THEN rr = rr + T1_height

                        rrp = (rr + 1)
                        IF rrp > T1_height_MASK THEN rrp = 0
                    END IF

                    ' 4 point bilinear temp vars
                    STATIC Frac_cc1_FIX7 AS INTEGER
                    STATIC Frac_rr1_FIX7 AS INTEGER
                    ' 0 1
                    ' . .
                    STATIC bi_r0 AS INTEGER
                    STATIC bi_g0 AS INTEGER
                    STATIC bi_b0 AS INTEGER
                    STATIC bi_a0 AS INTEGER
                    ' . .
                    ' 2 3
                    STATIC bi_r1 AS INTEGER
                    STATIC bi_g1 AS INTEGER
                    STATIC bi_b1 AS INTEGER
                    STATIC bi_a1 AS INTEGER

                    ' color blending
                    STATIC a0 AS INTEGER

                    Frac_cc1_FIX7 = (cm5 - INT(cm5)) * 128
                    Frac_rr1_FIX7 = (rm5 - INT(rm5)) * 128

                    ' Caching of 4 texels
                    STATIC T1_this_cache AS _UNSIGNED LONG
                    STATIC T1_uv_0_0 AS LONG
                    STATIC T1_uv_1_0 AS LONG
                    STATIC T1_uv_0_1 AS LONG
                    STATIC T1_uv_1_1 AS LONG

                    T1_this_cache = _SHL(rr, 16) OR cc
                    IF T1_this_cache <> T1_last_cache THEN

                        _MEMGET T1_mblock, T1_mblock.OFFSET + (cc + rr * T1_width) * 4, T1_uv_0_0
                        _MEMGET T1_mblock, T1_mblock.OFFSET + (ccp + rr * T1_width) * 4, T1_uv_1_0
                        _MEMGET T1_mblock, T1_mblock.OFFSET + (cc + rrp * T1_width) * 4, T1_uv_0_1
                        _MEMGET T1_mblock, T1_mblock.OFFSET + (ccp + rrp * T1_width) * 4, T1_uv_1_1

                        T1_last_cache = T1_this_cache
                    END IF

                    ' determine Alpha channel from texture
                    bi_a0 = _ALPHA32(T1_uv_0_0)
                    bi_a0 = _SHR((_ALPHA32(T1_uv_1_0) - bi_a0) * Frac_cc1_FIX7, 7) + bi_a0

                    bi_a1 = _ALPHA32(T1_uv_0_1)
                    bi_a1 = _SHR((_ALPHA32(T1_uv_1_1) - bi_a1) * Frac_cc1_FIX7, 7) + bi_a1

                    a0 = _SHR((bi_a1 - bi_a0) * Frac_rr1_FIX7, 7) + bi_a0

                    ' Color Combiner math for Alpha
                    a0 = a0 * T1_mod_A

                    IF a0 > 0 THEN

                        ' determine T1 RGB colors
                        bi_r0 = _RED32(T1_uv_0_0)
                        bi_r0 = _SHR((_RED32(T1_uv_1_0) - bi_r0) * Frac_cc1_FIX7, 7) + bi_r0

                        bi_g0 = _GREEN32(T1_uv_0_0)
                        bi_g0 = _SHR((_GREEN32(T1_uv_1_0) - bi_g0) * Frac_cc1_FIX7, 7) + bi_g0

                        bi_b0 = _BLUE32(T1_uv_0_0)
                        bi_b0 = _SHR((_BLUE32(T1_uv_1_0) - bi_b0) * Frac_cc1_FIX7, 7) + bi_b0

                        bi_r1 = _RED32(T1_uv_0_1)
                        bi_r1 = _SHR((_RED32(T1_uv_1_1) - bi_r1) * Frac_cc1_FIX7, 7) + bi_r1

                        bi_g1 = _GREEN32(T1_uv_0_1)
                        bi_g1 = _SHR((_GREEN32(T1_uv_1_1) - bi_g1) * Frac_cc1_FIX7, 7) + bi_g1

                        bi_b1 = _BLUE32(T1_uv_0_1)
                        bi_b1 = _SHR((_BLUE32(T1_uv_1_1) - bi_b1) * Frac_cc1_FIX7, 7) + bi_b1

                        pixel_value = _RGB32(_SHR((bi_r1 - bi_r0) * Frac_rr1_FIX7, 7) + bi_r0, _SHR((bi_g1 - bi_g0) * Frac_rr1_FIX7, 7) + bi_g0, _SHR((bi_b1 - bi_b0) * Frac_rr1_FIX7, 7) + bi_b0)

                        ' Color Combiner math for RGB
                        pixel_value = _RGB32(_RED32(pixel_value) * tex_r, _GREEN32(pixel_value) * tex_g, _BLUE32(pixel_value) * tex_b)

                        IF a0 < 255 THEN
                            ' Alpha blend
                            STATIC pixel_existing AS _UNSIGNED LONG
                            STATIC pixel_alpha AS SINGLE
                            pixel_alpha = a0 * oneOver255
                            pixel_existing = _MEMGET(work_mem_info, work_address, _UNSIGNED LONG)

                            pixel_value = _RGB32((  _red32(pixel_value) -  _Red32(pixel_existing))  * pixel_alpha +   _red32(pixel_existing), _
                                                 (_green32(pixel_value) - _Green32(pixel_existing)) * pixel_alpha + _green32(pixel_existing), _
                                                 ( _Blue32(pixel_value) - _Blue32(pixel_existing))  * pixel_alpha +  _blue32(pixel_existing))

                            _MEMPUT work_mem_info, work_address, pixel_value

                            IF (Texture_options AND T1_option_no_Z_write) = 0 THEN
                                IF a0 >= T1_Alpha_Threshold THEN Screen_Z_Buffer(zbuf_index) = tex_z + Z_Fight_Bias
                            END IF
                        ELSE
                            ' Solid
                            _MEMPUT work_mem_info, work_address, pixel_value
                            Screen_Z_Buffer(zbuf_index) = tex_z + Z_Fight_Bias
                        END IF

                    END IF ' a0
                END IF ' tex_z
                zbuf_index = zbuf_index + 1
                tex_w = tex_w + tex_w_step
                tex_z = 1 / tex_w ' floating point divide can be done in parallel when result not required immediately.
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                tex_r = tex_r + tex_r_step
                tex_g = tex_g + tex_g_step
                tex_b = tex_b + tex_b_step
                tex_a = tex_a + tex_a_step
                work_address = work_address + 4
                col = col + 1
            WEND ' col

        END IF ' end div/0 avoidance

        ' DDA next step
        leg_x1 = leg_x1 + legx1_step
        leg_w1 = leg_w1 + legw1_step
        leg_u1 = leg_u1 + legu1_step
        leg_v1 = leg_v1 + legv1_step
        leg_r1 = leg_r1 + legr1_step
        leg_g1 = leg_g1 + legg1_step
        leg_b1 = leg_b1 + legb1_step
        leg_a1 = leg_a1 + lega1_step

        leg_x2 = leg_x2 + legx2_step
        leg_w2 = leg_w2 + legw2_step
        leg_u2 = leg_u2 + legu2_step
        leg_v2 = leg_v2 + legv2_step
        leg_r2 = leg_r2 + legr2_step
        leg_g2 = leg_g2 + legg2_step
        leg_b2 = leg_b2 + legb2_step
        leg_a2 = leg_a2 + lega2_step

        work_row_base = work_row_base + work_next_row_step
        row = row + 1
    WEND ' row

END SUB

SUB TexturedNonlitTriangle (A AS vertex9, B AS vertex9, C AS vertex9)
    ' this is a reduced copy for skybox drawing
    ' Texture_options is ignored, Z depth is ignored.
    STATIC delta2 AS vertex5
    STATIC delta1 AS vertex5
    STATIC draw_min_y AS LONG, draw_max_y AS LONG

    ' Sort so that vertex A is on top and C is on bottom.
    ' This seems inverted from math class, but remember that Y increases in value downward on PC monitors
    IF B.y < A.y THEN
        SWAP A, B
    END IF
    IF C.y < A.y THEN
        SWAP A, C
    END IF
    IF C.y < B.y THEN
        SWAP B, C
    END IF

    ' integer window clipping
    draw_min_y = _CEIL(A.y)
    IF draw_min_y < clip_min_y THEN draw_min_y = clip_min_y
    draw_max_y = _CEIL(C.y) - 1
    IF draw_max_y > clip_max_y THEN draw_max_y = clip_max_y
    IF (draw_max_y - draw_min_y) < 0 THEN EXIT SUB

    ' Determine the deltas (lengths)
    ' delta 2 is from A to C (the full triangle height)
    delta2.x = C.x - A.x
    delta2.y = C.y - A.y
    delta2.w = C.w - A.w
    delta2.u = C.u - A.u
    delta2.v = C.v - A.v

    ' Avoiding div by 0
    ' Entire Y height less than 1/256 would not have meaningful pixel color change
    IF delta2.y < (1 / 256) THEN EXIT SUB

    ' Determine vertical Y steps for DDA style math
    ' DDA is Digital Differential Analyzer
    ' It is an accumulator that counts from a known start point to an end point, in equal increments defined by the number of steps in-between.
    ' Probably faster nowadays to do the one division at the start, instead of Bresenham, anyway.
    STATIC legx1_step AS SINGLE
    STATIC legw1_step AS SINGLE, legu1_step AS SINGLE, legv1_step AS SINGLE

    STATIC legx2_step AS SINGLE
    STATIC legw2_step AS SINGLE, legu2_step AS SINGLE, legv2_step AS SINGLE

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y

    ' Leg 1, Draw top to middle
    ' For most triangles, draw downward from the apex A to a knee B.
    ' That knee could be on either the left or right side, but that is handled much later.
    STATIC draw_middle_y AS LONG
    draw_middle_y = _CEIL(B.y)
    IF draw_middle_y < clip_min_y THEN draw_middle_y = clip_min_y
    ' Do not clip B to max_y. Let the y count expire before reaching the knee if it is past bottom of screen.

    ' Leg 1 is from A to B (right now)
    delta1.x = B.x - A.x
    delta1.y = B.y - A.y
    delta1.w = B.w - A.w
    delta1.u = B.u - A.u
    delta1.v = B.v - A.v

    ' If the triangle has no knee, this section gets skipped to avoid divide by 0.
    ' That is okay, because the recalculate Leg 1 from B to C triggers before actually drawing.
    IF delta1.y > (1 / 256) THEN
        ' Find Leg 1 steps in the y direction from A to B
        legx1_step = delta1.x / delta1.y
        legw1_step = delta1.w / delta1.y
        legu1_step = delta1.u / delta1.y
        legv1_step = delta1.v / delta1.y
    END IF

    ' Y Accumulators
    STATIC leg_x1 AS SINGLE
    STATIC leg_w1 AS SINGLE, leg_u1 AS SINGLE, leg_v1 AS SINGLE

    STATIC leg_x2 AS SINGLE
    STATIC leg_w2 AS SINGLE, leg_u2 AS SINGLE, leg_v2 AS SINGLE

    ' 11-4-2022 Prestep Y
    STATIC prestep_y1 AS SINGLE
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
    STATIC row AS LONG
    STATIC col AS LONG
    STATIC draw_max_x AS LONG
    STATIC tex_z AS SINGLE ' 1/w helper (multiply by inverse is faster than dividing each time)
    STATIC pixel_value AS _UNSIGNED LONG ' The ARGB value to write to screen

    ' Stepping along the X direction
    STATIC delta_x AS SINGLE
    STATIC prestep_x AS SINGLE
    STATIC tex_w_step AS SINGLE, tex_u_step AS SINGLE, tex_v_step AS SINGLE

    ' X Accumulators
    STATIC tex_w AS SINGLE, tex_u AS SINGLE, tex_v AS SINGLE

    ' Screen Memory Pointers
    STATIC screen_mem_info AS _MEM
    STATIC screen_next_row_step AS _OFFSET
    STATIC screen_row_base AS _OFFSET ' Calculated every row
    STATIC screen_address AS _OFFSET ' Calculated at every starting column
    screen_mem_info = _MEMIMAGE(WORK_IMAGE)
    screen_next_row_step = 4 * Size_Render_X

    ' caching of 4 texels in bilinear mode
    STATIC T1_last_cache AS _UNSIGNED LONG
    T1_last_cache = &HFFFFFFFF ' invalidate

    ' Row Loop from top to bottom
    row = draw_min_y
    screen_row_base = screen_mem_info.OFFSET + row * screen_next_row_step
    WHILE row <= draw_max_y

        IF row = draw_middle_y THEN
            ' Reached Leg 1 knee at B, recalculate Leg 1.
            ' This overwrites Leg 1 to be from B to C. Leg 2 just keeps continuing from A to C.
            delta1.x = C.x - B.x
            delta1.y = C.y - B.y
            delta1.w = C.w - B.w
            delta1.u = C.u - B.u
            delta1.v = C.v - B.v

            IF delta1.y = 0.0 THEN EXIT SUB

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

        END IF

        ' Horizontal Scanline
        delta_x = ABS(leg_x2 - leg_x1)
        ' Avoid div/0, this gets tiring.
        IF delta_x >= (1 / 2048) THEN
            ' Calculate step, start, and end values.
            ' Drawing left to right, as in incrementing from a lower to higher memory address, is usually fastest.
            IF leg_x1 < leg_x2 THEN
                ' leg 1 is on the left
                tex_w_step = (leg_w2 - leg_w1) / delta_x
                tex_u_step = (leg_u2 - leg_u1) / delta_x
                tex_v_step = (leg_v2 - leg_v1) / delta_x

                ' Set the horizontal starting point to (1)
                col = _CEIL(leg_x1)
                IF col < clip_min_x THEN col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x1
                tex_w = leg_w1 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u1 + prestep_x * tex_u_step
                tex_v = leg_v1 + prestep_x * tex_v_step

                ' ending point is (2)
                draw_max_x = _CEIL(leg_x2)
                IF draw_max_x > clip_max_x THEN draw_max_x = clip_max_x

            ELSE
                ' Things are flipped. leg 1 is on the right.
                tex_w_step = (leg_w1 - leg_w2) / delta_x
                tex_u_step = (leg_u1 - leg_u2) / delta_x
                tex_v_step = (leg_v1 - leg_v2) / delta_x

                ' Set the horizontal starting point to (2)
                col = _CEIL(leg_x2)
                IF col < clip_min_x THEN col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x2
                tex_w = leg_w2 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step

                ' ending point is (1)
                draw_max_x = _CEIL(leg_x1)
                IF draw_max_x > clip_max_x THEN draw_max_x = clip_max_x

            END IF

            ' metrics
            IF col < draw_max_x THEN Pixels_Drawn_This_Frame = Pixels_Drawn_This_Frame + (draw_max_x - col)

            ' Draw the Horizontal Scanline
            ' Optimization: before entering this loop, must have done tex_z = 1 / tex_w
            ' Relies on some shared T1 variables over by Texture1
            screen_address = screen_row_base + 4 * col
            WHILE col < draw_max_x

                STATIC cc AS _UNSIGNED INTEGER
                STATIC ccp AS _UNSIGNED INTEGER
                STATIC rr AS _UNSIGNED INTEGER
                STATIC rrp AS _UNSIGNED INTEGER

                STATIC cm5 AS SINGLE
                STATIC rm5 AS SINGLE

                ' Recover U and V
                ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                cm5 = (tex_u * tex_z) - 0.5
                rm5 = (tex_v * tex_z) - 0.5

                ' clamp
                IF cm5 < 0.0 THEN cm5 = 0.0
                IF cm5 >= T1_width_MASK THEN
                    ' 15.0 and up
                    cc = T1_width_MASK
                    ccp = T1_width_MASK
                ELSE
                    ' 0 1 2 .. 13 14.999
                    cc = INT(cm5)
                    ccp = cc + 1
                END IF

                ' clamp
                IF rm5 < 0.0 THEN rm5 = 0.0
                IF rm5 >= T1_height_MASK THEN
                    ' 15.0 and up
                    rr = T1_height_MASK
                    rrp = T1_height_MASK
                ELSE
                    rr = INT(rm5)
                    rrp = rr + 1
                END IF

                ' 4 point bilinear temp vars
                STATIC Frac_cc1_FIX7 AS INTEGER
                STATIC Frac_rr1_FIX7 AS INTEGER
                ' 0 1
                ' . .
                STATIC bi_r0 AS INTEGER
                STATIC bi_g0 AS INTEGER
                STATIC bi_b0 AS INTEGER
                ' . .
                ' 2 3
                STATIC bi_r1 AS INTEGER
                STATIC bi_g1 AS INTEGER
                STATIC bi_b1 AS INTEGER

                Frac_cc1_FIX7 = (cm5 - INT(cm5)) * 128
                Frac_rr1_FIX7 = (rm5 - INT(rm5)) * 128

                ' Caching of 4 texels
                STATIC T1_this_cache AS _UNSIGNED LONG
                STATIC T1_uv_0_0 AS LONG
                STATIC T1_uv_1_0 AS LONG
                STATIC T1_uv_0_1 AS LONG
                STATIC T1_uv_1_1 AS LONG

                T1_this_cache = _SHL(rr, 16) OR cc
                IF T1_this_cache <> T1_last_cache THEN

                    _MEMGET T1_mblock, T1_mblock.OFFSET + (cc + rr * T1_width) * 4, T1_uv_0_0
                    _MEMGET T1_mblock, T1_mblock.OFFSET + (ccp + rr * T1_width) * 4, T1_uv_1_0
                    _MEMGET T1_mblock, T1_mblock.OFFSET + (cc + rrp * T1_width) * 4, T1_uv_0_1
                    _MEMGET T1_mblock, T1_mblock.OFFSET + (ccp + rrp * T1_width) * 4, T1_uv_1_1

                    T1_last_cache = T1_this_cache
                END IF

                ' determine T1 RGB colors
                bi_r0 = _RED32(T1_uv_0_0)
                bi_r0 = _SHR((_RED32(T1_uv_1_0) - bi_r0) * Frac_cc1_FIX7, 7) + bi_r0

                bi_g0 = _GREEN32(T1_uv_0_0)
                bi_g0 = _SHR((_GREEN32(T1_uv_1_0) - bi_g0) * Frac_cc1_FIX7, 7) + bi_g0

                bi_b0 = _BLUE32(T1_uv_0_0)
                bi_b0 = _SHR((_BLUE32(T1_uv_1_0) - bi_b0) * Frac_cc1_FIX7, 7) + bi_b0

                bi_r1 = _RED32(T1_uv_0_1)
                bi_r1 = _SHR((_RED32(T1_uv_1_1) - bi_r1) * Frac_cc1_FIX7, 7) + bi_r1

                bi_g1 = _GREEN32(T1_uv_0_1)
                bi_g1 = _SHR((_GREEN32(T1_uv_1_1) - bi_g1) * Frac_cc1_FIX7, 7) + bi_g1

                bi_b1 = _BLUE32(T1_uv_0_1)
                bi_b1 = _SHR((_BLUE32(T1_uv_1_1) - bi_b1) * Frac_cc1_FIX7, 7) + bi_b1

                pixel_value = _RGB32(_SHR((bi_r1 - bi_r0) * Frac_rr1_FIX7, 7) + bi_r0, _SHR((bi_g1 - bi_g0) * Frac_rr1_FIX7, 7) + bi_g0, _SHR((bi_b1 - bi_b0) * Frac_rr1_FIX7, 7) + bi_b0)
                _MEMPUT screen_mem_info, screen_address, pixel_value
                'PSet (col, row), pixel_value

                tex_w = tex_w + tex_w_step
                tex_z = 1 / tex_w ' execution time for this can be absorbed when result not required immediately
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                screen_address = screen_address + 4
                col = col + 1
            WEND ' col

        END IF ' end div/0 avoidance

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
    WEND ' row

END SUB


SUB ReflectionMapTriangle (A AS vertex9, B AS vertex9, C AS vertex9)
    STATIC delta2 AS vertex9
    STATIC delta1 AS vertex9
    STATIC draw_min_y AS LONG, draw_max_y AS LONG

    ' Sort so that vertex A is on top and C is on bottom.
    ' This seems inverted from math class, but remember that Y increases in value downward on PC monitors
    IF B.y < A.y THEN
        SWAP A, B
    END IF
    IF C.y < A.y THEN
        SWAP A, C
    END IF
    IF C.y < B.y THEN
        SWAP B, C
    END IF

    ' integer window clipping
    draw_min_y = _CEIL(A.y)
    IF draw_min_y < clip_min_y THEN draw_min_y = clip_min_y
    draw_max_y = _CEIL(C.y) - 1
    IF draw_max_y > clip_max_y THEN draw_max_y = clip_max_y
    IF (draw_max_y - draw_min_y) < 0 THEN EXIT SUB

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
    delta2.a = C.a - A.a

    ' Avoiding div by 0
    ' Entire Y height less than 1/256 would not have meaningful pixel color change
    IF delta2.y < (1 / 256) THEN EXIT SUB

    ' Determine vertical Y steps for DDA style math
    ' DDA is Digital Differential Analyzer
    ' It is an accumulator that counts from a known start point to an end point, in equal increments defined by the number of steps in-between.
    ' Probably faster nowadays to do the one division at the start, instead of Bresenham, anyway.
    STATIC legx1_step AS SINGLE
    STATIC legw1_step AS SINGLE, legu1_step AS SINGLE, legv1_step AS SINGLE
    STATIC legr1_step AS SINGLE, legg1_step AS SINGLE, legb1_step AS SINGLE
    STATIC lega1_step AS SINGLE

    STATIC legx2_step AS SINGLE
    STATIC legw2_step AS SINGLE, legu2_step AS SINGLE, legv2_step AS SINGLE
    STATIC legr2_step AS SINGLE, legg2_step AS SINGLE, legb2_step AS SINGLE
    STATIC lega2_step AS SINGLE

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y
    legr2_step = delta2.r / delta2.y
    legg2_step = delta2.g / delta2.y
    legb2_step = delta2.b / delta2.y
    lega2_step = delta2.a / delta2.y

    ' Leg 1, Draw top to middle
    ' For most triangles, draw downward from the apex A to a knee B.
    ' That knee could be on either the left or right side, but that is handled much later.
    STATIC draw_middle_y AS LONG
    draw_middle_y = _CEIL(B.y)
    IF draw_middle_y < clip_min_y THEN draw_middle_y = clip_min_y
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
    delta1.a = B.a - A.a

    ' If the triangle has no knee, this section gets skipped to avoid divide by 0.
    ' That is okay, because the recalculate Leg 1 from B to C triggers before actually drawing.
    IF delta1.y > (1 / 256) THEN
        ' Find Leg 1 steps in the y direction from A to B
        legx1_step = delta1.x / delta1.y
        legw1_step = delta1.w / delta1.y
        legu1_step = delta1.u / delta1.y
        legv1_step = delta1.v / delta1.y
        legr1_step = delta1.r / delta1.y
        legg1_step = delta1.g / delta1.y
        legb1_step = delta1.b / delta1.y
        lega1_step = delta1.a / delta1.y
    END IF

    ' Y Accumulators
    STATIC leg_x1 AS SINGLE
    STATIC leg_w1 AS SINGLE, leg_u1 AS SINGLE, leg_v1 AS SINGLE
    STATIC leg_r1 AS SINGLE, leg_g1 AS SINGLE, leg_b1 AS SINGLE
    STATIC leg_a1 AS SINGLE

    STATIC leg_x2 AS SINGLE
    STATIC leg_w2 AS SINGLE, leg_u2 AS SINGLE, leg_v2 AS SINGLE
    STATIC leg_r2 AS SINGLE, leg_g2 AS SINGLE, leg_b2 AS SINGLE
    STATIC leg_a2 AS SINGLE

    ' 11-4-2022 Prestep Y
    STATIC prestep_y1 AS SINGLE
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
    leg_a1 = A.a + prestep_y1 * lega1_step

    leg_x2 = A.x + prestep_y1 * legx2_step
    leg_w2 = A.w + prestep_y1 * legw2_step
    leg_u2 = A.u + prestep_y1 * legu2_step
    leg_v2 = A.v + prestep_y1 * legv2_step
    leg_r2 = A.r + prestep_y1 * legr2_step
    leg_g2 = A.g + prestep_y1 * legg2_step
    leg_b2 = A.b + prestep_y1 * legb2_step
    leg_a2 = A.a + prestep_y1 * lega2_step

    ' Inner loop vars
    STATIC row AS LONG
    STATIC col AS LONG
    STATIC draw_max_x AS LONG
    STATIC zbuf_index AS _UNSIGNED LONG ' Z-Buffer
    STATIC tex_z AS SINGLE ' 1/w helper (multiply by inverse is faster than dividing each time)
    STATIC pixel_alpha AS SINGLE

    ' Stepping along the X direction
    STATIC delta_x AS SINGLE
    STATIC prestep_x AS SINGLE
    STATIC tex_w_step AS SINGLE, tex_u_step AS SINGLE, tex_v_step AS SINGLE
    STATIC tex_r_step AS SINGLE, tex_g_step AS SINGLE, tex_b_step AS SINGLE
    STATIC tex_a_step AS SINGLE

    ' X Accumulators
    STATIC tex_w AS SINGLE, tex_u AS SINGLE, tex_v AS SINGLE
    STATIC tex_r AS SINGLE, tex_g AS SINGLE, tex_b AS SINGLE
    STATIC tex_a AS SINGLE

    ' Work Screen Memory Pointers
    STATIC work_mem_info AS _MEM
    STATIC work_next_row_step AS _OFFSET
    STATIC work_row_base AS _OFFSET ' Calculated every row
    STATIC work_address AS _OFFSET ' Calculated at every starting column
    work_mem_info = _MEMIMAGE(WORK_IMAGE)
    work_next_row_step = 4 * Size_Render_X

    ' caching of 4 texels in bilinear mode
    STATIC T1_last_cache AS _UNSIGNED LONG
    T1_last_cache = &HFFFFFFFF ' invalidate

    ' Row Loop from top to bottom
    row = draw_min_y
    work_row_base = work_mem_info.OFFSET + row * work_next_row_step
    WHILE row <= draw_max_y

        IF row = draw_middle_y THEN
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
            delta1.a = C.a - B.a

            IF delta1.y = 0.0 THEN EXIT SUB

            ' Full steps in the y direction from B to C
            legx1_step = delta1.x / delta1.y
            legw1_step = delta1.w / delta1.y
            legu1_step = delta1.u / delta1.y
            legv1_step = delta1.v / delta1.y
            legr1_step = delta1.r / delta1.y ' vertex color
            legg1_step = delta1.g / delta1.y
            legb1_step = delta1.b / delta1.y
            lega1_step = delta1.a / delta1.y

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
            leg_a1 = B.a + prestep_y1 * lega1_step
        END IF

        ' Horizontal Scanline
        delta_x = ABS(leg_x2 - leg_x1)
        ' Avoid div/0, this gets tiring.
        IF delta_x >= (1 / 2048) THEN
            ' Calculate step, start, and end values.
            ' Drawing left to right, as in incrementing from a lower to higher memory address, is usually fastest.
            IF leg_x1 < leg_x2 THEN
                ' leg 1 is on the left
                tex_w_step = (leg_w2 - leg_w1) / delta_x
                tex_u_step = (leg_u2 - leg_u1) / delta_x
                tex_v_step = (leg_v2 - leg_v1) / delta_x
                tex_r_step = (leg_r2 - leg_r1) / delta_x
                tex_g_step = (leg_g2 - leg_g1) / delta_x
                tex_b_step = (leg_b2 - leg_b1) / delta_x
                tex_a_step = (leg_a2 - leg_a1) / delta_x

                ' Set the horizontal starting point to (1)
                col = _CEIL(leg_x1)
                IF col < clip_min_x THEN col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x1
                tex_w = leg_w1 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u1 + prestep_x * tex_u_step
                tex_v = leg_v1 + prestep_x * tex_v_step
                tex_r = leg_r1 + prestep_x * tex_r_step
                tex_g = leg_g1 + prestep_x * tex_g_step
                tex_b = leg_b1 + prestep_x * tex_b_step
                tex_a = leg_a1 + prestep_x * tex_a_step

                ' ending point is (2)
                draw_max_x = _CEIL(leg_x2)
                IF draw_max_x > clip_max_x THEN draw_max_x = clip_max_x

            ELSE
                ' Things are flipped. leg 1 is on the right.
                tex_w_step = (leg_w1 - leg_w2) / delta_x
                tex_u_step = (leg_u1 - leg_u2) / delta_x
                tex_v_step = (leg_v1 - leg_v2) / delta_x
                tex_r_step = (leg_r1 - leg_r2) / delta_x
                tex_g_step = (leg_g1 - leg_g2) / delta_x
                tex_b_step = (leg_b1 - leg_b2) / delta_x
                tex_a_step = (leg_a1 - leg_a2) / delta_x

                ' Set the horizontal starting point to (2)
                col = _CEIL(leg_x2)
                IF col < clip_min_x THEN col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x2
                tex_w = leg_w2 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step
                tex_r = leg_r2 + prestep_x * tex_r_step
                tex_g = leg_g2 + prestep_x * tex_g_step
                tex_b = leg_b2 + prestep_x * tex_b_step
                tex_a = leg_a2 + prestep_x * tex_a_step

                ' ending point is (1)
                draw_max_x = _CEIL(leg_x1)
                IF draw_max_x > clip_max_x THEN draw_max_x = clip_max_x

            END IF

            ' metrics
            IF col < draw_max_x THEN Pixels_Drawn_This_Frame = Pixels_Drawn_This_Frame + (draw_max_x - col)

            ' Draw the Horizontal Scanline
            ' Optimization: before entering this loop, must have done tex_z = 1 / tex_w
            work_address = work_row_base + 4 * col
            zbuf_index = row * Size_Render_X + col
            WHILE col < draw_max_x

                IF Screen_Z_Buffer(zbuf_index) = 0.0 OR tex_z < Screen_Z_Buffer(zbuf_index) THEN
                    IF (Texture_options AND T1_option_no_Z_write) = 0 THEN
                        Screen_Z_Buffer(zbuf_index) = tex_z + Z_Fight_Bias
                    END IF

                    ' YOU HAD THE RIGHT IDEA
                    STATIC cubemap_index AS INTEGER
                    STATIC cubemap_u AS SINGLE
                    STATIC cubemap_v AS SINGLE
                    ConvertXYZ_to_CubeIUV tex_r * tex_z, tex_g * tex_z, tex_b * tex_z, cubemap_index, cubemap_u, cubemap_v

                    ' Fill in Texture 1 data
                    T1_ImageHandle = SkyBoxRef(cubemap_index)
                    T1_mblock = _MEMIMAGE(T1_ImageHandle)
                    T1_width = _WIDTH(T1_ImageHandle): T1_width_MASK = T1_width - 1
                    T1_height = _HEIGHT(T1_ImageHandle): T1_height_MASK = T1_height - 1

                    '--- Begin Inline Texel Read
                    ' Originally function ReadTexel3Point& (ccol As Single, rrow As Single)
                    ' Relies on some shared T1 variables over by Texture1
                    STATIC cc AS INTEGER
                    STATIC rr AS INTEGER
                    STATIC cc1 AS INTEGER
                    STATIC rr1 AS INTEGER

                    STATIC Frac_cc1 AS SINGLE
                    STATIC Frac_rr1 AS SINGLE

                    STATIC Area_00 AS SINGLE
                    STATIC Area_11 AS SINGLE
                    STATIC Area_2f AS SINGLE

                    STATIC T1_address_pointer AS _OFFSET
                    STATIC uv_0_0 AS _UNSIGNED LONG
                    STATIC uv_1_1 AS _UNSIGNED LONG
                    STATIC uv_f AS _UNSIGNED LONG

                    STATIC r0 AS INTEGER
                    STATIC g0 AS INTEGER
                    STATIC b0 AS INTEGER

                    STATIC cm5 AS SINGLE
                    STATIC rm5 AS SINGLE

                    ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
                    cm5 = (cubemap_u * T1_width) - 0.5
                    rm5 = (cubemap_v * T1_height) - 0.5

                    ' clamp
                    IF cm5 < 0.0 THEN cm5 = 0.0
                    IF cm5 >= T1_width_MASK THEN
                        '15.0 and up
                        cc = T1_width_MASK
                        cc1 = T1_width_MASK
                    ELSE
                        '0 1 2 .. 13 14.999
                        cc = INT(cm5)
                        cc1 = cc + 1
                    END IF

                    ' clamp
                    IF rm5 < 0.0 THEN rm5 = 0.0
                    IF rm5 >= T1_height_MASK THEN
                        '15.0 and up
                        rr = T1_height_MASK
                        rr1 = T1_height_MASK
                    ELSE
                        rr = INT(rm5)
                        rr1 = rr + 1
                    END IF

                    'uv_0_0 = Texture1(cc, rr)
                    T1_address_pointer = T1_mblock.OFFSET + (cc + rr * T1_width) * 4
                    _MEMGET T1_mblock, T1_address_pointer, uv_0_0

                    'uv_1_1 = Texture1(cc1, rr1)
                    T1_address_pointer = T1_mblock.OFFSET + (cc1 + rr1 * T1_width) * 4
                    _MEMGET T1_mblock, T1_address_pointer, uv_1_1

                    Frac_cc1 = cm5 - INT(cm5)
                    Frac_rr1 = rm5 - INT(rm5)

                    IF Frac_cc1 > Frac_rr1 THEN
                        ' top-right
                        ' Area of a triangle = 1/2 * base * height
                        ' Using twice the areas (rectangles) to eliminate a multiply by 1/2 and a later divide by 1/2
                        Area_11 = Frac_rr1
                        Area_00 = 1.0 - Frac_cc1

                        'uv_f = Texture1(cc1, rr)
                        T1_address_pointer = T1_mblock.OFFSET + (cc1 + rr * T1_width) * 4
                        _MEMGET T1_mblock, T1_address_pointer, uv_f
                    ELSE
                        ' bottom-left
                        Area_00 = 1.0 - Frac_rr1
                        Area_11 = Frac_cc1

                        'uv_f = Texture1(cc, rr1)
                        T1_address_pointer = T1_mblock.OFFSET + (cc + rr1 * T1_width) * 4
                        _MEMGET T1_mblock, T1_address_pointer, uv_f

                    END IF

                    Area_2f = 1.0 - (Area_00 + Area_11) '1.0 here is twice the total triangle area.

                    r0 = _RED32(uv_f) * Area_2f + _RED32(uv_0_0) * Area_00 + _RED32(uv_1_1) * Area_11
                    g0 = _GREEN32(uv_f) * Area_2f + _GREEN32(uv_0_0) * Area_00 + _GREEN32(uv_1_1) * Area_11
                    b0 = _BLUE32(uv_f) * Area_2f + _BLUE32(uv_0_0) * Area_00 + _BLUE32(uv_1_1) * Area_11
                    '--- End Inline Texel Read

                    STATIC pixel_combine AS _UNSIGNED LONG
                    pixel_combine = _RGB32(r0 * T1_mod_R, g0 * T1_mod_G, b0 * T1_mod_B)

                    STATIC pixel_existing AS _UNSIGNED LONG
                    pixel_alpha = T1_mod_A
                    IF pixel_alpha < 0.998 THEN
                        pixel_existing = _MEMGET(work_mem_info, work_address, _UNSIGNED LONG)
                        pixel_combine = _RGB32((  _red32(pixel_combine) - _Red32(pixel_existing))   * pixel_alpha + _red32(pixel_existing), _
                                               (_green32(pixel_combine) - _Green32(pixel_existing)) * pixel_alpha + _green32(pixel_existing), _
                                               ( _Blue32(pixel_combine) - _Blue32(pixel_existing))  * pixel_alpha + _blue32(pixel_existing))

                        ' x = (p1 - p0) * ratio + p0 is equivalent to
                        ' x = (1.0 - ratio) * p0 + ratio * p1
                    END IF
                    _MEMPUT work_mem_info, work_address, pixel_combine
                    'If Dither_Selection > 0 Then
                    '    RGB_Dither555 col, row, pixel_value
                    'Else
                    '    PSet (col, row), pixel_value
                    'End If

                END IF ' tex_z
                zbuf_index = zbuf_index + 1
                tex_w = tex_w + tex_w_step
                tex_z = 1 / tex_w ' floating point divide can be done in parallel when result not required immediately.
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                tex_r = tex_r + tex_r_step
                tex_g = tex_g + tex_g_step
                tex_b = tex_b + tex_b_step
                tex_a = tex_a + tex_a_step
                work_address = work_address + 4
                col = col + 1
            WEND ' col

        END IF ' end div/0 avoidance

        ' DDA next step
        leg_x1 = leg_x1 + legx1_step
        leg_w1 = leg_w1 + legw1_step
        leg_u1 = leg_u1 + legu1_step
        leg_v1 = leg_v1 + legv1_step
        leg_r1 = leg_r1 + legr1_step
        leg_g1 = leg_g1 + legg1_step
        leg_b1 = leg_b1 + legb1_step
        leg_a1 = leg_a1 + lega1_step

        leg_x2 = leg_x2 + legx2_step
        leg_w2 = leg_w2 + legw2_step
        leg_u2 = leg_u2 + legu2_step
        leg_v2 = leg_v2 + legv2_step
        leg_r2 = leg_r2 + legr2_step
        leg_g2 = leg_g2 + legg2_step
        leg_b2 = leg_b2 + legb2_step
        leg_a2 = leg_a2 + lega2_step

        work_row_base = work_row_base + work_next_row_step
        row = row + 1
    WEND ' row

END SUB
