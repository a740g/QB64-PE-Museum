' QB64-PE port of Ball from https://github.com/zeque92/RealTime3DwithPython

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

SCREEN _NEWIMAGE(1280, 720, 32)
_TITLE "Textured Sphere with _MAPTRIANGLE (Optimized)"

CONST RADIUS! = 150!
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

TYPE Vector3D
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

DIM SHARED nLat AS LONG: nLat = LAT_STEPS
DIM SHARED nLon AS LONG: nLon = LON_STEPS
DIM SHARED nVerts AS LONG: nVerts = (nLat + 1) * (nLon + 1)
DIM SHARED nTris AS LONG: nTris = 2 * nLat * nLon

REDIM SHARED vx(0) AS SINGLE, vy(0) AS SINGLE, vz(0) AS SINGLE
REDIM SHARED vu(0) AS SINGLE, vv(0) AS SINGLE

REDIM SHARED sx(0) AS SINGLE, sy(0) AS SINGLE, sz(0) AS SINGLE

REDIM SHARED t1(0) AS LONG, t2(0) AS LONG, t3(0) AS LONG

DIM angleX AS SINGLE, angleY AS SINGLE

InitMesh

_SNDLOOP _SNDOPEN("jb-alacrity.mod")

DO
    CLS

    angleX = angleX + 0.01!
    angleY = angleY + 0.02!

    RotateAndProject angleX, angleY
    DrawMesh

    _PRINTSTRING (0, 0), _TOSTR$(CalculateFPS) + " FPS"

    _DISPLAY

    _LIMIT DRAW_FPS
LOOP UNTIL _KEYHIT = _KEY_ESC

SYSTEM

SUB InitMesh
    REDIM vx(0 TO nVerts - 1) AS SINGLE, vy(0 TO nVerts - 1) AS SINGLE, vz(0 TO nVerts - 1) AS SINGLE
    REDIM vu(0 TO nVerts - 1) AS SINGLE, vv(0 TO nVerts - 1) AS SINGLE
    REDIM sx(0 TO nVerts - 1) AS SINGLE, sy(0 TO nVerts - 1) AS SINGLE, sz(0 TO nVerts - 1) AS SINGLE
    REDIM t1(0 TO nTris - 1) AS LONG, t2(0 TO nTris - 1) AS LONG, t3(0 TO nTris - 1) AS LONG

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
            cLon = COS(lonRad)
            sLon = SIN(lonRad)

            vx(v) = RADIUS * cLat * cLon
            vy(v) = RADIUS * sLat
            vz(v) = -RADIUS * cLat * sLon

            vu(v) = (1! - (lonDeg / 360!)) * tw

            latDegTex = latDegMesh
            IF latDegTex > TEX_LAT_MAX! THEN latDegTex = TEX_LAT_MAX!
            IF latDegTex < TEX_LAT_MIN! THEN latDegTex = TEX_LAT_MIN!
            latRadTex = _D2R(latDegTex)

            DIM y AS SINGLE
            y = LOG(TAN(_PI * 0.25! + latRadTex * 0.5!))
            IF y > yMax THEN y = yMax
            IF y < -yMax THEN y = -yMax

            vv(v) = ((yMax - y) / (2! * yMax)) * th

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

            t1(t) = i00: t2(t) = i10: t3(t) = i11: t = t + 1
            t1(t) = i00: t2(t) = i11: t3(t) = i01: t = t + 1
        NEXT
    NEXT
END SUB

SUB RotateAndProject (ax AS SINGLE, ay AS SINGLE)
    DIM cx AS SINGLE, sx AS SINGLE, cy AS SINGLE, sy AS SINGLE
    cx = COS(ax): sx = SIN(ax)
    cy = COS(ay): sy = SIN(ay)

    DIM i AS LONG
    DIM x AS SINGLE, y AS SINGLE, z AS SINGLE
    DIM ry AS SINGLE, rz AS SINGLE, rx AS SINGLE, rz2 AS SINGLE

    FOR i = 0 TO nVerts - 1
        x = vx(i): y = vy(i): z = vz(i)

        ry = y * cx - z * sx
        rz = y * sx + z * cx

        rx = x * cy + rz * sy
        rz2 = -x * sy + rz * cy

        sx(i) = CENTERX + rx
        sy(i) = CENTERY + ry
        sz(i) = rz2
    NEXT
END SUB

SUB DrawMesh
    DIM i AS LONG, a AS LONG, b AS LONG, c AS LONG
    DIM avgZ AS SINGLE

    FOR i = 0 TO nTris - 1
        a = t1(i): b = t2(i): c = t3(i)
        avgZ = (sz(a) + sz(b) + sz(c)) * 0.3333333!

        IF avgZ >= 0! THEN
            _MAPTRIANGLE (vu(a), vv(a))-(vu(b), vv(b))-(vu(c), vv(c)), texture TO(sx(a), sy(a))-(sx(b), sy(b))-(sx(c), sy(c)), _SMOOTH
        END IF
    NEXT
END SUB

FUNCTION CalculateFPS~&
    DECLARE LIBRARY
        FUNCTION GetTicks~&&
    END DECLARE

    STATIC AS _UNSIGNED LONG counter, finalFPS
    STATIC lastTime AS _UNSIGNED _INTEGER64

    DIM currentTime AS _UNSIGNED _INTEGER64: currentTime = GetTicks

    IF currentTime >= lastTime + 1000 THEN
        lastTime = currentTime
        finalFPS = counter
        counter = 0
    END IF

    counter = counter + 1

    CalculateFPS = finalFPS
END FUNCTION
