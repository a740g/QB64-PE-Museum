'Coded By Ashish on 4 March, 2018
 
_TITLE "3D Double Pendulum [Press Space for new settings]"
SCREEN _NEWIMAGE(800, 600, 32)
 
TYPE vec3
    x AS DOUBLE
    y AS DOUBLE
    z AS DOUBLE
END TYPE
 
TYPE pendlm
    POS AS vec3
    r AS DOUBLE
    ang AS DOUBLE
    angInc AS DOUBLE
    angSize AS DOUBLE
END TYPE
 
DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
    SUB glutSolidSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
END DECLARE
 
DIM SHARED glAllow AS _BYTE
DIM SHARED pendulum(1) AS pendlm, t1 AS vec3, t2 AS vec3
DIM SHARED tracer(3000) AS vec3, tracerSize AS _UNSIGNED LONG
RANDOMIZE TIMER
 
settings:
tracerSize = 0
g = 0
 
pendulum(0).POS.x = 0
pendulum(0).POS.y = 0
pendulum(0).POS.z = 0
pendulum(0).r = p5random(.7, 1.1)
pendulum(0).angInc = p5random(0, _PI(2))
pendulum(0).angSize = p5random(_PI(.3), _PI(.6))
 
pendulum(1).r = p5random(.25, .5)
pendulum(1).angInc = p5random(0, _PI(2))
pendulum(1).angSize = p5random(_PI(.3), _PI(1.1))
 
glAllow = -1
_GLRENDER _BEHIND
DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN GOTO settings
    pendulum(0).ang = SIN(pendulum(0).angInc) * pendulum(0).angSize + _PI(.5)
 
    t1.x = COS(pendulum(0).ang) * pendulum(0).r + pendulum(0).POS.x
    t1.y = SIN(pendulum(0).ang) * pendulum(0).r + pendulum(0).POS.y
    t1.z = COS(pendulum(0).ang) * pendulum(0).r + pendulum(0).POS.z
 
    pendulum(1).POS = t1
 
    pendulum(1).ang = SIN(pendulum(1).angInc) * pendulum(1).angSize + pendulum(0).ang
 
    t2.x = COS(pendulum(1).ang) * pendulum(1).r + pendulum(1).POS.x
    t2.y = SIN(pendulum(1).ang) * pendulum(1).r + pendulum(1).POS.y
    t2.z = SIN(pendulum(1).ang) * pendulum(1).r + pendulum(1).POS.z
 
    pendulum(0).angInc = pendulum(0).angInc + .02
    pendulum(1).angInc = pendulum(1).angInc + .043
 
    IF tracerSize < UBOUND(tracer) - 1 AND g > 40 THEN tracer(tracerSize) = t2
    IF g > 40 AND tracerSize < UBOUND(tracer) - 1 THEN tracerSize = tracerSize + 1
 
    g = g + 1
    _LIMIT 60
LOOP
 
SUB _GL () STATIC
    IF NOT glAllow THEN EXIT SUB
 
    IF NOT glInit THEN
        glInit = -1
        aspect# = _WIDTH / _HEIGHT
        _GLVIEWPORT 0, 0, _WIDTH, _HEIGHT
    END IF
 
    _GLENABLE _GL_BLEND
    _GLENABLE _GL_DEPTH_TEST
 
 
    _GLSHADEMODEL _GL_SMOOTH
 
    _GLMATRIXMODE _GL_PROJECTION
    _GLLOADIDENTITY
    _GLUPERSPECTIVE 45.0, aspect#, 1.0, 1000.0
 
    _GLMATRIXMODE _GL_MODELVIEW
    _GLLOADIDENTITY
 
    gluLookAt 0, 0, -4, 0, 1, 0, 0, -1, 0
 
    _GLROTATEF clock# * 90, 0, 1, 0
    _GLLINEWIDTH 3.0
 
    _GLPUSHMATRIX
 
    _GLCOLOR4F 1, 1, 1, .7
 
    _GLBEGIN _GL_LINES
    _GLVERTEX3F pendulum(0).POS.x, pendulum(0).POS.y, pendulum(0).POS.z
    _GLVERTEX3F t1.x, t1.y, t1.z
    _GLEND
    _GLPOPMATRIX
 
    _GLPUSHMATRIX
 
    _GLBEGIN _GL_LINES
    _GLVERTEX3F t1.x, t1.y, t1.z
    _GLVERTEX3F t2.x, t2.y, t2.z
    _GLEND
 
    IF tracerSize > 3 THEN
        _GLBEGIN _GL_LINES
        FOR i = 0 TO tracerSize - 2
            _GLCOLOR3F 0, map(tracer(i).x, -1, 1, .5, 1), map(tracer(i).y, -1, 1, .5, 1)
            _GLVERTEX3F tracer(i).x, tracer(i).y, tracer(i).z
            _GLCOLOR3F 0, map(tracer(i + 1).x, -1, 1, .5, 1), map(tracer(i + 1).y, -1, 1, .5, 1)
            _GLVERTEX3F tracer(i + 1).x, tracer(i + 1).y, tracer(i + 1).z
        NEXT
        _GLEND
    END IF
    _GLPOPMATRIX
 
    _GLENABLE _GL_LIGHTING
    _GLENABLE _GL_LIGHT0
    _GLPUSHMATRIX
    _GLTRANSLATEF t1.x, t1.y, t1.z
 
    _GLCOLOR3F .8, .8, .8
    glutSolidSphere .1, 15, 15
    _GLPOPMATRIX
 
    _GLPUSHMATRIX
    _GLTRANSLATEF t2.x, t2.y, t2.z
 
    _GLCOLOR3F .8, .8, .8
    glutSolidSphere .1, 15, 15
    _GLPOPMATRIX
 
    clock# = clock# + .01
 
    _GLFLUSH
END SUB
 
 
 
'taken from p5js.bas
'https://bit.y/p5jsbas
FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION
 
FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION
