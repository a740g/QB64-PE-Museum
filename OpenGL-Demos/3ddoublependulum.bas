'Coded By Ashish on 4 March, 2018
 
_Title "3D Double Pendulum [Press Space for new settings]"
Screen _NewImage(800, 600, 32)
 
Type vec3
    x As Double
    y As Double
    z As Double
End Type
 
Type pendlm
    POS As vec3
    r As Double
    ang As Double
    angInc As Double
    angSize As Double
End Type
 
Declare Library
    Sub gluLookAt (ByVal eyeX#, Byval eyeY#, Byval eyeZ#, Byval centerX#, Byval centerY#, Byval centerZ#, Byval upX#, Byval upY#, Byval upZ#)
    Sub glutSolidSphere (ByVal radius As Double, Byval slices As Long, Byval stack As Long)
End Declare
 
Dim Shared glAllow As _Byte
Dim Shared pendulum(1) As pendlm, t1 As vec3, t2 As vec3
Dim Shared tracer(3000) As vec3, tracerSize As _Unsigned Long
Randomize Timer
 
settings:
tracerSize = 0
g = 0
 
pendulum(0).POS.x = 0
pendulum(0).POS.y = 0
pendulum(0).POS.z = 0
pendulum(0).r = p5random(.7, 1.1)
pendulum(0).angInc = p5random(0, _Pi(2))
pendulum(0).angSize = p5random(_Pi(.3), _Pi(.6))
 
pendulum(1).r = p5random(.25, .5)
pendulum(1).angInc = p5random(0, _Pi(2))
pendulum(1).angSize = p5random(_Pi(.3), _Pi(1.1))
 
glAllow = -1
_GLRender _Behind
Do
    k& = _KeyHit
    If k& = Asc(" ") Then GoTo settings
    pendulum(0).ang = Sin(pendulum(0).angInc) * pendulum(0).angSize + _Pi(.5)
 
    t1.x = Cos(pendulum(0).ang) * pendulum(0).r + pendulum(0).POS.x
    t1.y = Sin(pendulum(0).ang) * pendulum(0).r + pendulum(0).POS.y
    t1.z = Cos(pendulum(0).ang) * pendulum(0).r + pendulum(0).POS.z
 
    pendulum(1).POS = t1
 
    pendulum(1).ang = Sin(pendulum(1).angInc) * pendulum(1).angSize + pendulum(0).ang
 
    t2.x = Cos(pendulum(1).ang) * pendulum(1).r + pendulum(1).POS.x
    t2.y = Sin(pendulum(1).ang) * pendulum(1).r + pendulum(1).POS.y
    t2.z = Sin(pendulum(1).ang) * pendulum(1).r + pendulum(1).POS.z
 
    pendulum(0).angInc = pendulum(0).angInc + .02
    pendulum(1).angInc = pendulum(1).angInc + .043
 
    If tracerSize < UBound(tracer) - 1 And g > 40 Then tracer(tracerSize) = t2
    If g > 40 And tracerSize < UBound(tracer) - 1 Then tracerSize = tracerSize + 1
 
    g = g + 1
    _Limit 60
Loop
 
Sub _GL () Static
    If Not glAllow Then Exit Sub
 
    If Not glInit Then
        glInit = -1
        aspect# = _Width / _Height
        _glViewport 0, 0, _Width, _Height
    End If
 
    _glEnable _GL_BLEND
    _glEnable _GL_DEPTH_TEST
 
 
    _glShadeModel _GL_SMOOTH
 
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1.0, 1000.0
 
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
 
    gluLookAt 0, 0, -4, 0, 1, 0, 0, -1, 0
 
    _glRotatef clock# * 90, 0, 1, 0
    _glLineWidth 3.0
 
    _glPushMatrix
 
    _glColor4f 1, 1, 1, .7
 
    _glBegin _GL_LINES
    _glVertex3f pendulum(0).POS.x, pendulum(0).POS.y, pendulum(0).POS.z
    _glVertex3f t1.x, t1.y, t1.z
    _glEnd
    _glPopMatrix
 
    _glPushMatrix
 
    _glBegin _GL_LINES
    _glVertex3f t1.x, t1.y, t1.z
    _glVertex3f t2.x, t2.y, t2.z
    _glEnd
 
    If tracerSize > 3 Then
        _glBegin _GL_LINES
        For i = 0 To tracerSize - 2
            _glColor3f 0, map(tracer(i).x, -1, 1, .5, 1), map(tracer(i).y, -1, 1, .5, 1)
            _glVertex3f tracer(i).x, tracer(i).y, tracer(i).z
            _glColor3f 0, map(tracer(i + 1).x, -1, 1, .5, 1), map(tracer(i + 1).y, -1, 1, .5, 1)
            _glVertex3f tracer(i + 1).x, tracer(i + 1).y, tracer(i + 1).z
        Next
        _glEnd
    End If
    _glPopMatrix
 
    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0
    _glPushMatrix
    _glTranslatef t1.x, t1.y, t1.z
 
    _glColor3f .8, .8, .8
    glutSolidSphere .1, 15, 15
    _glPopMatrix
 
    _glPushMatrix
    _glTranslatef t2.x, t2.y, t2.z
 
    _glColor3f .8, .8, .8
    glutSolidSphere .1, 15, 15
    _glPopMatrix
 
    clock# = clock# + .01
 
    _glFlush
End Sub
 
 
 
'taken from p5js.bas
'https://bit.y/p5jsbas
Function p5random! (mn!, mx!)
    If mn! > mx! Then
        Swap mn!, mx!
    End If
    p5random! = Rnd * (mx! - mn!) + mn!
End Function
 
Function map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
End Function
 
