OPTION _EXPLICIT
'$DYNAMIC

TYPE OBJECT
    id AS INTEGER
    polygon_index_start AS INTEGER
    polygon_index_end AS INTEGER
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
    rotx AS _FLOAT
    roty AS _FLOAT
    rotz AS _FLOAT
    scalex AS _FLOAT
    scaley AS _FLOAT
    scalez AS _FLOAT
    billboard AS INTEGER
    hidden AS INTEGER
END TYPE

TYPE CAM
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
    rotx AS _FLOAT
    roty AS _FLOAT
    rotz AS _FLOAT
END TYPE

TYPE VEC3D
    obj_id AS INTEGER
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
END TYPE

TYPE VEC2D
    obj_id AS INTEGER
    x AS _FLOAT
    y AS _FLOAT
END TYPE

TYPE CBOX
    x AS INTEGER
    y AS INTEGER
    height AS INTEGER
    width AS INTEGER
END TYPE

TYPE POLYGON
    obj_id AS INTEGER
    v0 AS VEC3D
    v1 AS VEC3D
    v2 AS VEC3D
    v3 AS VEC3D

    t0 AS VEC2D
    t1 AS VEC2D
    t2 AS VEC2D
    t3 AS VEC2D

    maxvert AS INTEGER
END TYPE

'ON ERROR GOTO ERRHANDLER

DIM SHARED g_objects(256) AS OBJECT
DIM SHARED g_polygons(1024) AS POLYGON
DIM SHARED g_obj_count AS INTEGER
DIM SHARED g_last_polygon AS INTEGER
DIM SHARED g_light AS VEC3D
DIM SHARED g_camX AS _FLOAT
DIM SHARED g_camY AS _FLOAT
DIM SHARED g_camZ AS _FLOAT
DIM SHARED g_cam AS CAM
g_obj_count = 0
g_last_polygon = 0
g_light.x = -0.3: g_light.y = 0: g_light.z = 1
normalize g_light
