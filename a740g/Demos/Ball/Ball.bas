' QB64-PE port of Ball from https://github.com/zeque92/RealTime3DwithPython

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

SCREEN _NEWIMAGE(1280, 720, 32)
_TITLE "Textured Sphere with _MAPTRIANGLE"
$RESIZE:SMOOTH
_ALLOWFULLSCREEN OFF , _SMOOTH

CONST RADIUS_MAX! = 150!
CONST CENTERX! = 640!
CONST CENTERY! = 360!
CONST LAT_STEPS& = 18&
CONST LON_STEPS& = 36&
CONST MESH_LAT_MIN! = -90!
CONST MESH_LAT_MAX! = 90!
CONST TEX_LAT_MIN! = -85!
CONST TEX_LAT_MAX! = 85!
CONST DRAW_FPS& = 60&

DIM SHARED AS LONG texture, texWidth, texHeight

texture = _LOADIMAGE("Normal_Mercator_map_85deg.jpg", 32, "hardware")
IF texture >= -1 THEN
    PRINT "ERROR: texture failed to load. Ensure 'Normal_Mercator_map_85deg.jpg' is beside the EXE."
    SLEEP: SYSTEM
END IF
texWidth = _WIDTH(texture)
texHeight = _HEIGHT(texture)

TYPE Vector2D
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Vertex
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE Triangle
    v1 AS LONG
    v2 AS LONG
    v3 AS LONG
END TYPE

DIM SHARED nLat AS LONG: nLat = LAT_STEPS
DIM SHARED nLon AS LONG: nLon = LON_STEPS
DIM SHARED nVerts AS LONG: nVerts = (nLat + 1) * (nLon + 1)
DIM SHARED nTris AS LONG: nTris = 2 * nLat * nLon

REDIM SHARED vertices(0) AS Vertex
REDIM SHARED texCoords(0) AS Vector2D
REDIM SHARED screenCoords(0) AS Vertex
REDIM SHARED triangles(0) AS Triangle

DIM animCounter AS SINGLE
DIM AS Vector2D angle, currentCenter, c, s

InitMesh

_SNDLOOP _SNDOPEN("jb-alacrity.mod")

DO
    CLS

    animCounter = animCounter + 0.05!
    angle.x = angle.x + 0.01!
    angle.y = angle.y + 0.02!

    currentCenter.x = CENTERX + SIN(animCounter * 0.5!) * 200!
    currentCenter.y = CENTERY - ABS(SIN(animCounter)) * 100!
    DIM scaledRadius AS SINGLE: scaledRadius = RADIUS_MAX + SIN(animCounter * 0.7!) * 50!

    c.x = COS(angle.x): s.x = SIN(angle.x)
    c.y = COS(angle.y): s.y = SIN(angle.y)

    RotateAndProject c, s
    DrawMesh currentCenter, scaledRadius, texCoords(), screenCoords(), triangles()

    _PRINTSTRING (0, 0), _TOSTR$(CalculateFPS) + " FPS"

    _DISPLAY

    _LIMIT DRAW_FPS
LOOP UNTIL _KEYHIT = _KEY_ESC

SYSTEM

SUB InitMesh
    REDIM vertices(0 TO nVerts - 1) AS Vertex
    REDIM texCoords(0 TO nVerts - 1) AS Vector2D
    REDIM screenCoords(0 TO nVerts - 1) AS Vertex
    REDIM triangles(0 TO nTris - 1) AS Triangle

    DIM AS SINGLE dLatMesh, dLon, latDegMesh, lonDeg, latRadMesh, latDegTex, latRadTex
    dLatMesh = (MESH_LAT_MAX - MESH_LAT_MIN) / nLat
    dLon = 360! / nLon

    DIM tw AS SINGLE: tw = texWidth - 1
    DIM th AS SINGLE: th = texHeight - 1
    DIM phiMax AS SINGLE: phiMax = _D2R(TEX_LAT_MAX)
    DIM yMax AS SINGLE: yMax = LOG(TAN(_PI * 0.25! + phiMax * 0.5!))

    DIM v AS LONG: v = 0
    DIM iLat AS LONG, iLon AS LONG

    FOR iLat = 0 TO nLat
        latDegMesh = MESH_LAT_MIN + iLat * dLatMesh
        latRadMesh = _D2R(latDegMesh)
        DIM cLat AS SINGLE, sLat AS SINGLE
        cLat = COS(latRadMesh)
        sLat = SIN(latRadMesh)

        FOR iLon = 0 TO nLon
            lonDeg = iLon * dLon
            DIM lonRad AS SINGLE: lonRad = _D2R(lonDeg)
            DIM cLon AS SINGLE, sLon AS SINGLE
            cLon = COS(lonRad): sLon = SIN(lonRad)

            vertices(v).x = RADIUS_MAX * cLat * cLon
            vertices(v).y = RADIUS_MAX * sLat
            vertices(v).z = -RADIUS_MAX * cLat * sLon

            texCoords(v).x = (1! - (lonDeg / 360!)) * tw

            latDegTex = latDegMesh
            IF latDegTex > TEX_LAT_MAX! THEN latDegTex = TEX_LAT_MAX!
            IF latDegTex < TEX_LAT_MIN! THEN latDegTex = TEX_LAT_MIN!
            latRadTex = _D2R(latDegTex)

            DIM y AS SINGLE
            y = LOG(TAN(_PI * 0.25! + latRadTex * 0.5!))
            IF y > yMax THEN y = yMax
            IF y < -yMax THEN y = -yMax

            texCoords(v).y = (yMax - y) / (2! * yMax) * th

            v = v + 1
        NEXT
    NEXT

    DIM t AS LONG: t = 0
    DIM i00 AS LONG, i10 AS LONG, i11 AS LONG, i01 AS LONG
    FOR iLat = 0 TO nLat - 1
        FOR iLon = 0 TO nLon - 1
            i00 = iLat * (nLon + 1) + iLon
            i10 = (iLat + 1) * (nLon + 1) + iLon
            i11 = (iLat + 1) * (nLon + 1) + (iLon + 1)
            i01 = iLat * (nLon + 1) + (iLon + 1)

            triangles(t).v1 = i00: triangles(t).v2 = i10: triangles(t).v3 = i11: t = t + 1
            triangles(t).v1 = i00: triangles(t).v2 = i11: triangles(t).v3 = i01: t = t + 1
        NEXT
    NEXT
END SUB

SUB RotateAndProject (c AS Vector2D, s AS Vector2D)
    DIM i AS LONG
    DIM x AS SINGLE, y AS SINGLE, z AS SINGLE
    DIM ry AS SINGLE, rz AS SINGLE, rx AS SINGLE, rz2 AS SINGLE

    FOR i = 0 TO nVerts - 1
        x = vertices(i).x: y = vertices(i).y: z = vertices(i).z

        ry = y * c.x - z * s.x
        rz = y * s.x + z * c.x

        rx = x * c.y + rz * s.y
        rz2 = -x * s.y + rz * c.y

        screenCoords(i).x = rx
        screenCoords(i).y = ry
        screenCoords(i).z = rz2
    NEXT
END SUB

SUB DrawMesh (center AS Vector2D, radius AS SINGLE, tc() AS Vector2D, sc() AS Vertex, tris() AS Triangle)
    DIM i AS LONG, a AS LONG, b AS LONG, c AS LONG
    DIM avgZ AS SINGLE
    DIM scaleFactor AS SINGLE: scaleFactor = radius / RADIUS_MAX

    FOR i = 0 TO nTris - 1
        a = tris(i).v1: b = tris(i).v2: c = tris(i).v3

        avgZ = (sc(a).z + sc(b).z + sc(c).z) * 0.3333333!

        IF avgZ >= 0! THEN
            _MAPTRIANGLE (tc(a).x, tc(a).y)-(tc(b).x, tc(b).y)-(tc(c).x, tc(c).y), texture TO(center.x + sc(a).x * scaleFactor, center.y + sc(a).y * scaleFactor)-(center.x + sc(b).x * scaleFactor, center.y + sc(b).y * scaleFactor)-(center.x + sc(c).x * scaleFactor, center.y + sc(c).y * scaleFactor), _SMOOTH
        END IF
    NEXT
END SUB

FUNCTION CalculateFPS~&
    DECLARE LIBRARY
        FUNCTION GetTicks~&&
    END DECLARE

    STATIC AS _UNSIGNED LONG finalFPS, frameCount
    STATIC lastTime AS _UNSIGNED _INTEGER64

    DIM currentTime AS _UNSIGNED _INTEGER64: currentTime = GetTicks

    IF currentTime >= lastTime + 1000 THEN
        lastTime = currentTime
        finalFPS = frameCount
        frameCount = 0
    END IF

    frameCount = frameCount + 1

    CalculateFPS = finalFPS
END FUNCTION
