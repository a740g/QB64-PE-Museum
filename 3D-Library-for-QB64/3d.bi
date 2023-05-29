$NoPrefix
Option _Explicit
'$DYNAMIC

Type OBJECT
    id As Integer
    polygon_index_start As Integer
    polygon_index_end As Integer
    x As Float
    y As Float
    z As Float
    rotx As Float
    roty As Float
    rotz As Float
    scalex As Float
    scaley As Float
    scalez As Float
    billboard As Integer
    hidden As Integer
End Type

Type CAM
    x As Float
    y As Float
    z As Float
    rotx As Float
    roty As Float
    rotz As Float
End Type

Type VEC3D
    obj_id As Integer
    x As Float
    y As Float
    z As Float
End Type

Type VEC2D
    obj_id As Integer
    x As Float
    y As Float
End Type

Type CBOX
    x As Integer
    y As Integer
    height As Integer
    width As Integer
End Type

Type POLYGON
    obj_id As Integer
    v0 As VEC3D
    v1 As VEC3D
    v2 As VEC3D
    v3 As VEC3D

    t0 As VEC2D
    t1 As VEC2D
    t2 As VEC2D
    t3 As VEC2D

    maxvert As Integer
End Type

'ON ERROR GOTO ERRHANDLER

Dim Shared g_objects(256) As OBJECT
Dim Shared g_polygons(1024) As POLYGON
Dim Shared g_obj_count As Integer
Dim Shared g_last_polygon As Integer
Dim Shared g_light As VEC3D
Dim Shared g_camX As Float
Dim Shared g_camY As Float
Dim Shared g_camZ As Float
Dim Shared g_cam As CAM
g_obj_count = 0
g_last_polygon = 0
g_light.x = -0.3: g_light.y = 0: g_light.z = 1
    normalize g_light


