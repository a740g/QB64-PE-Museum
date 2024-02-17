'Coded in QB64 by Ashish on 9 March, 2018
'http://paulbourke.net/geometry/knots/
_Title "3D Knot [Press space for next knot]"
 
Screen _NewImage(700, 700, 32)
 
Type vec3
    x As Single
    y As Single
    z As Single
End Type
Declare Library 'used for camera.
    Sub gluLookAt (ByVal eyeX#, Byval eyeY#, Byval eyeZ#, Byval centerX#, Byval centerY#, Byval centerZ#, Byval upX#, Byval upY#, Byval upZ#)
End Declare
 
Dim Shared glAllow As _Byte, knot_type, ma 'knot_type store the type knot being drawn. ma store percentage of knot which is being drawn.
knot_type = 1
glAllow = -1
 
Do
    k& = _KeyHit
    If k& = Asc(" ") Then
        knot_type = knot_type + 1
        ma = 0
        If knot_type > 7 Then knot_type = 1 '7 knots are there.
    End If
    _Limit 60
Loop
 
Sub _GL ()
    Static glInit, clock
    ' static r, pos, theta, phi, beta
 
    If Not glAllow Then Exit Sub
 
    If Not glInit Then
        glInit = -1
        aspect# = _Width / _Height
        _glViewport 0, 0, _Width, _Height
    End If
 
    _glEnable _GL_DEPTH_TEST 'We are doing 3D. This enables Z-Buffer.
 
    'set perspective configuration
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1.0, 100.0
 
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
    ' gluLookAt 0,0,-1,0,0,0,0,1,0
 
    _glColor3f 1, 1, 1 'set color
    _glTranslatef 0, 0, 0 'not require. becoz, origin is already at 0,0,0
    _glRotatef clock * 90, 0, 1, 0 'rotation along Y-axis
    _glLineWidth 3.0 'width of the line.
 
    Select Case knot_type
        Case 7 'equations are knots are taken from paulbourke site
            _glBegin _GL_LINE_STRIP
            'for animation, value of ma is gradually increased till a certain constant. In this case, it is pi.
            For beta = 0 To ma Step .005
                r = .3 + .6 * Sin(6 * beta)
                theta = 2 * beta
                phi = _Pi(.6) * Sin(12 * beta)
                x = r * Cos(phi) * Cos(theta)
                y = r * Cos(phi) * Sin(theta)
                z = r * Sin(phi)
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z 'draws it.
            Next
            _glEnd
            If ma <= _Pi Then ma = ma + .005
            'others are made to be rendered in the same way.
        Case 6
            _glBegin _GL_LINE_STRIP
            For beta = 0 To ma Step .005
                r = 1.2 * 0.6 * Sin(_Pi(.5) * 6 * beta)
                theta = 4 * beta
                phi = _Pi(.2) * Sin(6 * beta)
                x = r * Cos(phi) * Cos(theta)
                y = r * Cos(phi) * Sin(theta)
                z = r * Sin(phi)
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            Next
            _glEnd
            If ma <= _Pi(2) Then ma = ma + .005
        Case 5
            k = 1
            _glBegin _GL_LINE_STRIP
            For u = 0 To ma Step .005
                x = Cos(u) * (2 - Cos(2 * u / (2 * k + 1))) / 5
                y = Sin(u) * (2 - Cos(2 * u / (2 * k + 1))) / 5
                z = -Sin(2 * u / (2 * k + 1)) / 5
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            Next
            _glEnd
            If ma < _Pi(4 * k + 2) Then ma = ma + .045
        Case 4
            k = 2
            _glBegin _GL_LINE_STRIP
            For u = 0 To ma Step .005
                x = Cos(u) * (2 - Cos(2 * u / (2 * k + 1))) / 5
                y = Sin(u) * (2 - Cos(2 * u / (2 * k + 1))) / 5
                z = -Sin(2 * u / (2 * k + 1)) / 5
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            Next
            _glEnd
            If ma < _Pi(4 * k + 2) Then ma = ma + .045
        Case 3
            k = 3
            _glBegin _GL_LINE_STRIP
            For u = 0 To ma Step .005
                x = Cos(u) * (2 - Cos(2 * u / (2 * k + 1))) / 5
                y = Sin(u) * (2 - Cos(2 * u / (2 * k + 1))) / 5
                z = -Sin(2 * u / (2 * k + 1)) / 5
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            Next
            _glEnd
            If ma < _Pi(4 * k + 2) Then ma = ma + .045
        Case 2
            _glBegin _GL_LINE_STRIP
            For u = 0 To ma Step .005
                x = (41 * Cos(u) - 18 * Sin(u) - 83 * Cos(2 * u) - 83 * Sin(2 * u) - 11 * Cos(3 * u) + 27 * Sin(3 * u)) / 200
                y = (36 * Cos(u) + 27 * Sin(u) - 113 * Cos(2 * u) + 30 * Sin(2 * u) + 11 * Cos(3 * u) - 27 * Sin(3 * u)) / 200
                z = (45 * Sin(u) - 30 * Cos(2 * u) + 113 * Sin(2 * u) - 11 * Cos(3 * u) + 27 * Sin(3 * u)) / 200
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            Next
            _glEnd
            If ma < _Pi(2) Then ma = ma + .005
        Case 1
            _glBegin _GL_LINE_STRIP
            For u = 0 To ma Step .005
                x = (-22 * Cos(u) - 128 * Sin(u) - 44 * Cos(3 * u) - 78 * Sin(3 * u)) / 200
                y = (-10 * Cos(2 * u) - 27 * Sin(2 * u) + 38 * Cos(4 * u) + 46 * Sin(4 * u)) / 200
                z = (70 * Cos(3 * u) - 40 * Sin(3 * u)) / 200
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            Next
            _glEnd
            If ma < _Pi(2) Then ma = ma + .005
    End Select
    _glFlush
 
    clock = clock + .01
End Sub
 
Function map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
End Function
 
