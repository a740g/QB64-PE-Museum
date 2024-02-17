'==========================================================================================================================================================

OPTION _EXPLICIT

'==========================================================================================================================================================

_TITLE "QB64pe Morphing"
SCREEN _NEWIMAGE(800, 600, 32)

'==========================================================================================================================================================

CONST FALSE = 0
CONST TRUE = NOT FALSE

'==========================================================================================================================================================

CONST HARDWARECULLING = FALSE

'==========================================================================================================================================================

CONST CUBESIZE = 300 '                              The cube is of dimensions CUBESIZE x CVUBESIZE x CUBESIZE
CONST TESSELATION = 5 '                             How far we're going to break the cube's faces down - the higher the breakdown the more vertices and textures and the better the sphere
CONST SPHERERADIUS = SQR(3 * (CUBESIZE / 2) ^ 2) '  Make it so the corners of the cube lie on the surface of the sphere
CONST VERTICESPERFACE = (TESSELATION + 1) ^ 2 '     Number of vertices in each face
CONST TRIANGLESPERFACE = TESSELATION ^ 2 * 2 '      Number of triangles to render for each face

'==========================================================================================================================================================

TYPE POINT3 '                                       A type that holds a 3D coordinate
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE ANGLE3 '                                       A type that holds x, y and z rotations
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE VECTOR3 '                                      A type that holders a 3D vector
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE TEXTUREUV '                                    A type to hold texture coordinates for a vertex
    u AS SINGLE
    v AS SINGLE
END TYPE

TYPE TRIANGLE '                                     A type that holds three vertex indexes to make up a triangle
    p1 AS INTEGER
    p2 AS INTEGER
    p3 AS INTEGER
    texture AS LONG
END TYPE

'==========================================================================================================================================================

DIM images(6) AS LONG '                             For storing the image handles
DIM cubeVertices(VERTICESPERFACE * 6) AS POINT3 '   All the vertices in the tesselated cube
DIM morphRatio(VERTICESPERFACE * 6) AS SINGLE '     The factor to multiple each point on the cube by to convert to a sphere
DIM uvs(VERTICESPERFACE * 6) AS TEXTUREUV '         UV texture coordinates for each vertex
DIM triangles(TRIANGLESPERFACE * 6) AS TRIANGLE '   A list of all triangles to render for the cube
DIM rotatedVertices(VERTICESPERFACE * 6) AS POINT3 'Holds the rotated and transformed vertices for rendering
DIM angle AS ANGLE3 '                               The x, y and z rotations to render the cube in
DIM deltaAngle AS ANGLE3 '                          The speed at which the x, y and z rotations change per frame

'==========================================================================================================================================================

angle.x = 0 '                                       I don't really care what rotation values we start at but I'm initilising them anyway
angle.y = 0
angle.z = 0

deltaAngle.x = 2 '                                  Arbitrarily chosen delta rotation values
deltaAngle.y = 1
deltaAngle.z = 3

LoadImages '                                        Load the textures into memory
CreateShapes '                                      Create the vertexes, uv points etc for the cube

DO
    _LIMIT 30 '                                     30FPS seems reasonable
    CLS '                                           Clear the screen prior to rendering anything
    RotateShape angle '                             Rotate all vertices
    MorphShape 0.5 + 0.5 * SIN(TIMER * 1) '         Morph to a state between a cube and a sphere (based on time)
    DrawShape '                                     Render to the screen
    _DISPLAY '                                      Update the sreen

    IF NOT HARDWARECULLING THEN
        angle.x = angle.x + deltaAngle.x '              Update the rotation angles
        angle.y = angle.y + deltaAngle.y
        angle.z = angle.z + deltaAngle.z
    END IF
LOOP

'===== Helper functions for 3D manipulations ==============================================================================================================

SUB SetAngle3 (x AS SINGLE, y AS SINGLE, z AS SINGLE, a AS ANGLE3) '        Set an ANGLE3 type with x, y and z components
    a.x = x
    a.y = y
    a.z = z
END SUB

FUNCTION Deg2Rad! (degrees AS SINGLE) '                                     Convert a value in degrees to one in radians
    Deg2Rad! = degrees * _PI / 180
END FUNCTION

SUB Deg2Rad3 (degrees AS ANGLE3, radians AS ANGLE3) '                       Convert the x, y and z components of an ANGLE3 from degrees to radians
    radians.x = Deg2Rad(degrees.x)
    radians.y = Deg2Rad(degrees.y)
    radians.z = Deg2Rad(degrees.z)
END SUB

SUB VectorSubtract3 (v1 AS POINT3, v2 AS POINT3, difference AS VECTOR3) '   Perform 3D vector subtraction
    difference.x = v1.x - v2.x
    difference.y = v1.y - v2.y
    difference.z = v1.z - v2.z
END SUB

SUB CrossProduct3 (v1 AS VECTOR3, v2 AS VECTOR3, crossProduct AS VECTOR3) ' Perform a 3D cross product
    crossProduct.x = v1.y * v2.z - v1.z * v2.y
    crossProduct.y = v1.z * v2.x - v1.x * v2.z
    crossProduct.z = v1.x * v2.y - v1.y * v2.x
END SUB

SUB Rotate3 (p AS POINT3, angle AS ANGLE3, rotatedPoint AS POINT3) '        Rotate a 3D point
    DIM px AS POINT3
    DIM py AS POINT3
    DIM pz AS POINT3
    DIM a AS ANGLE3

    Deg2Rad3 angle, a
    px.x = p.x
    px.y = p.y * COS(a.x) - p.z * SIN(a.x)
    px.z = p.y * SIN(a.x) + p.z * COS(a.x)
    py.x = px.x * COS(a.y) + px.z * SIN(a.y)
    py.y = px.y
    py.z = px.z * COS(a.y) - px.x * SIN(a.y)
    pz.x = py.x * COS(a.z) - py.y * SIN(a.z)
    pz.y = py.x * SIN(a.z) + py.y * COS(a.z)
    pz.z = py.z
    rotatedPoint = pz
END SUB

'===== Subroutines for construction of shape data =========================================================================================================

SUB CreateShapes
    SHARED cubeVertices() AS POINT3
    SHARED morphRatio() AS SINGLE
    SHARED uvs() AS TEXTUREUV
    SHARED images() AS LONG
    SHARED triangles() AS TRIANGLE
    DIM v AS INTEGER
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM t AS INTEGER

    ' This section of code creates the vertices, uv coordinates and triagle list for a single face of a tesselated cube

    v = 0
    t = 0
    FOR i = 0 TO TESSELATION
        FOR j = 0 TO TESSELATION
            cubeVertices(v).x = -CUBESIZE / 2 + CUBESIZE * i / TESSELATION
            cubeVertices(v).y = CUBESIZE / 2 - CUBESIZE * j / TESSELATION
            cubeVertices(v).z = CUBESIZE / 2
            morphRatio(v) = SPHERERADIUS / SQR(cubeVertices(v).x ^ 2 + cubeVertices(v).y ^ 2 + cubeVertices(v).z ^ 2)
            uvs(v).u = _WIDTH(images(1)) * i / TESSELATION
            uvs(v).v = _HEIGHT(images(1)) - _HEIGHT(images(1)) * j / TESSELATION
            IF i < TESSELATION AND j < TESSELATION THEN
                triangles(t).p1 = v
                triangles(t).p2 = v + 1
                triangles(t).p3 = v + TESSELATION + 1
                triangles(t).texture = images(1)
                t = t + 1
                triangles(t).p1 = v + 1
                triangles(t).p2 = v + TESSELATION + 2
                triangles(t).p3 = v + TESSELATION + 1
                triangles(t).texture = images(1)
                t = t + 1
            END IF
            v = v + 1
        NEXT j
    NEXT i

    ' Rather than doing this for each side we can simply rotate the coordinates for the created face to create the other five faces of the cube

    CreateRotatedSide 0, 90, 0, VERTICESPERFACE
    CreateRotatedSide 0, 180, 0, VERTICESPERFACE * 2
    CreateRotatedSide 0, 270, 0, VERTICESPERFACE * 3
    CreateRotatedSide 90, 90, 0, VERTICESPERFACE * 4
    CreateRotatedSide 270, 0, 0, VERTICESPERFACE * 5

    ' Similarly, we don't need to mess around to create triangles to render for the other sides - we can base them upon the ones we've already constructed for the first side

    FOR j = 1 TO 5
        FOR i = 0 TO TRIANGLESPERFACE - 1
            triangles(i + j * TRIANGLESPERFACE).p1 = triangles(i).p1 + j * VERTICESPERFACE
            triangles(i + j * TRIANGLESPERFACE).p2 = triangles(i).p2 + j * VERTICESPERFACE
            triangles(i + j * TRIANGLESPERFACE).p3 = triangles(i).p3 + j * VERTICESPERFACE
            triangles(i + j * TRIANGLESPERFACE).texture = images(j + 1)
        NEXT i
    NEXT j
END SUB

SUB CreateRotatedSide (x AS SINGLE, y AS SINGLE, z AS SINGLE, offset AS INTEGER)
    SHARED cubeVertices() AS POINT3
    SHARED morphRatio() AS SINGLE
    SHARED uvs() AS TEXTUREUV
    DIM angle AS ANGLE3
    DIM v AS INTEGER
    SetAngle3 x, y, z, angle
    FOR v = 0 TO VERTICESPERFACE - 1
        Rotate3 cubeVertices(v), angle, cubeVertices(v + offset)
        uvs(v + offset) = uvs(v)
        morphRatio(v + offset) = morphRatio(v)
    NEXT v
END SUB

'==========================================================================================================================================================

SUB LoadImages '                                                            Load images for each side of the cube
    SHARED images() AS LONG
    DIM i AS INTEGER
    DIM fname AS STRING
    DIM image AS LONG
    FOR i = 1 TO 6
        fname = "./assets/side" + CHR$(48 + i) + ".png"
        image = _LOADIMAGE(fname, 32)
        IF image = -1 THEN
            PRINT "Unable to load "; fname
            PRINT "Please make sure EXE is in same folder as morph.BAS"
            PRINT "(Set Run/Output EXE to Source Folder option in the IDE before compiling)"
            END
        END IF
        IF HARDWARECULLING THEN
            images(i) = _COPYIMAGE(image, 33) '                                 Copy to hardware image
            _FREEIMAGE (image)
        ELSE
            images(i) = image
        END IF
    NEXT i
END SUB

SUB RotateShape (angle AS ANGLE3) '                                         Rotate all vertices in the model
    SHARED rotatedVertices() AS POINT3
    SHARED cubeVertices() AS POINT3
    DIM i AS INTEGER
    DIM p AS POINT3
    FOR i = 0 TO UBOUND(cubeVertices) - 1
        p.x = cubeVertices(i).x
        p.y = cubeVertices(i).y
        p.z = cubeVertices(i).z
        Rotate3 p, angle, rotatedVertices(i)
    NEXT i
END SUB

SUB MorphShape (morphAmount AS SINGLE) '                                    Perform the necessary tweening between a cube and a sphere
    SHARED rotatedVertices() AS POINT3
    SHARED morphRatio() AS SINGLE
    DIM i AS INTEGER
    FOR i = 0 TO UBOUND(rotatedVertices) - 1
        rotatedVertices(i).x = rotatedVertices(i).x * (1 + (morphRatio(i) - 1) * morphAmount)
        rotatedVertices(i).y = rotatedVertices(i).y * (1 + (morphRatio(i) - 1) * morphAmount)
        rotatedVertices(i).z = rotatedVertices(i).z * (1 + (morphRatio(i) - 1) * morphAmount)
        IF HARDWARECULLING THEN
            rotatedVertices(i).x = rotatedVertices(i).x * 0.7
            rotatedVertices(i).y = rotatedVertices(i).y * 0.7
            rotatedVertices(i).z = rotatedVertices(i).z * 0.7
        END IF
    NEXT i
END SUB

SUB DrawShape '                                                             Render all the triangles in the model
    SHARED triangles() AS TRIANGLE
    SHARED uvs() AS TEXTUREUV
    SHARED rotatedVertices() AS POINT3
    DIM i AS INTEGER
    DIM p1 AS INTEGER
    DIM p2 AS INTEGER
    DIM p3 AS INTEGER
    DIM v1 AS VECTOR3
    DIM v2 AS VECTOR3
    DIM crossProduct AS VECTOR3

    FOR i = 0 TO UBOUND(triangles) - 1
        p1 = triangles(i).p1
        p2 = triangles(i).p2
        p3 = triangles(i).p3
        VectorSubtract3 rotatedVertices(p2), rotatedVertices(p1), v1
        VectorSubtract3 rotatedVertices(p3), rotatedVertices(p1), v2
        CrossProduct3 v1, v2, crossProduct '                                The vector subtractions and the cross multiply allow us to see which direction the surface normal is pointing in (for back face culling)
        IF HARDWARECULLING THEN
            _MAPTRIANGLE _CLOCKWISE (uvs(p1).u, uvs(p1).v)-(uvs(p2).u, uvs(p2).v)-(uvs(p3).u, uvs(p3).v), triangles(i).texture TO(200 + rotatedVertices(p1).x, 300 + rotatedVertices(p1).y)-(200 + rotatedVertices(p2).x, 300 + rotatedVertices(p2).y)-(200 + rotatedVertices(p3).x, 300 + rotatedVertices(p3).y)
            _MAPTRIANGLE _ANTICLOCKWISE (uvs(p1).u, uvs(p1).v)-(uvs(p2).u, uvs(p2).v)-(uvs(p3).u, uvs(p3).v), triangles(i).texture TO(600 + rotatedVertices(p1).x, 300 + rotatedVertices(p1).y)-(600 + rotatedVertices(p2).x, 300 + rotatedVertices(p2).y)-(600 + rotatedVertices(p3).x, 300 + rotatedVertices(p3).y)
        ELSE
            IF crossProduct.z > 0 THEN
                _MAPTRIANGLE (uvs(p1).u, uvs(p1).v)-(uvs(p2).u, uvs(p2).v)-(uvs(p3).u, uvs(p3).v), triangles(i).texture TO(400 + rotatedVertices(p1).x, 300 + rotatedVertices(p1).y)-(400 + rotatedVertices(p2).x, 300 + rotatedVertices(p2).y)-(400 + rotatedVertices(p3).x, 300 + rotatedVertices(p3).y)
            END IF
        END IF
    NEXT i
END SUB

'==========================================================================================================================================================

