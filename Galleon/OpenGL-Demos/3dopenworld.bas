'3D OpenWorld Terrain Demo
'Using Perlin Noise
'By Ashish Kushwaha
 
Randomize Timer
 
'$CONSOLE
 
_Title "3D OpenWorld Terrain"
Screen _NewImage(800, 600, 32)
 
 
 
Const sqrt2 = 2 ^ 0.5
Const mountHeightMax = 4
 
Type vec3
    x As Single
    y As Single
    z As Single
End Type
 
Type vec2
    x As Single
    y As Single
End Type
 
Type tree
    h As Single
    POS As vec3
    mpos As vec2
End Type
 
Type camera
    POS As vec3
    mpos As vec3
    target As vec3
End Type
 
Type blowMIND
    POS As vec3
    set As _Byte
End Type
 
Declare Library 'camera control function
    Sub gluLookAt (ByVal eyeX#, Byval eyeY#, Byval eyeZ#, Byval centerX#, Byval centerY#, Byval centerZ#, Byval upX#, Byval upY#, Byval upZ#)
End Declare
 
 
'noise function related variables
Dim Shared perlin_octaves As Single, perlin_amp_falloff As Single
 
Dim Shared mapW, mapH
mapW = 800: mapH = 800 'control the size of the map or world
 
'Terrain Map related variables
'terrainData(mapW,mapH) contain elevation data and moistureMap(mapW,mapH) contain moisture data
Dim Shared terrainMap(mapW, mapH), moistureMap(mapW, mapH), terrainData(mapW, mapH) As vec3
'these stored the 3 Dimensional coordinates of the objects. Used as a array buffer with glDrawArrays(). glDrawArrays() is faster than normal glBegin() ... glEnd() for rendering
Dim Shared mountVert(mapW * mapH * 6) As Single, mountColor(mapW * mapH * 6), mountNormal(mapW * mapH * 6)
 
'MODs
Dim Shared worldMOD
 
'map
Dim Shared worldMap&, myLocation& 'stored the 2D Map
worldMap& = _NewImage(mapW + 300, mapH + 300, 32)
myLocation& = _NewImage(10, 10, 32)
 
'surprise
Dim Shared Surprise As blowMIND, snowMount
 
'sky
Dim Shared worldTextures&(3), worldTextureHandle&(2)
 
tmp& = _LoadImage(WriteqbiconData$("qb.png"))
Kill "qb.png"
worldTextures&(1) = _NewImage(32, 32, 32) '3 32's
_PutImage (0, 32)-(32, 0), tmp&, worldTextures&(1)
 
_Dest worldMap&
Cls , _RGB(0, 0, 255)
 
'day sky containing some clouds
worldTextures&(2) = _NewImage(400, 400, 32)
 
_Dest worldTextures&(2)
Cls , _RGB(109, 164, 255)
For y = 0 To _Height - 1
    For x = 0 To _Width - 1
        j1# = map(Abs((_Width / 2) - x), _Width / 2, 70, 0, 1)
        j2# = map(Abs((_Height / 2) - y), _Height / 2, 70, 0, 1)
        noiseDetail 5, 0.46789
        k! = (Abs(noise(x * 0.04, y * 0.04, x / y * 0.01)) * 1.3) ^ 3 * j1# * j2#
        PSet (x, y), _RGBA(255, 255, 255, k! * 255)
Next x, y
'starry night sky texture
worldTextures&(3) = _NewImage(_Width * 3, _Height * 3, 32)
_Dest worldTextures&(3)
Cls , _RGB(7, 0, 102)
For i = 0 To 300
    cx = p5random(10, _Width - 10): cy = p5random(10, _Height - 10)
    CircleFill cx, cy, p5random(0, 2), _RGBA(255, 255, 255, p5random(0, 255))
Next
_Dest 0
Dim Shared Cam As camera, theta, phi
 
 
Dim Shared glAllow As _Byte
Restore blipicon
_Dest myLocation& 'Generating the blip icon
For i = 0 To 10
    For j = 0 To 10
        Read cx
        If cx = 1 Then PSet (j, i), _RGB(255, 0, 200)
Next j, i
_Dest 0
'image data of blip icon
blipicon:
Data 0,0,0,0,0,1,0,0,0,0,0
Data 0,0,0,0,0,1,0,0,0,0,0
Data 0,0,0,0,1,1,1,0,0,0,0
Data 0,0,0,1,1,1,1,1,0,0,0
Data 0,0,0,1,1,1,1,1,0,0,0
Data 0,0,1,1,1,1,1,1,1,0,0
Data 0,1,1,1,1,1,1,1,1,1,0
Data 0,1,1,1,1,1,1,1,1,1,0
Data 1,1,1,1,0,0,0,1,1,1,1
Data 1,1,0,0,0,0,0,0,0,1,1
Data 1,0,0,0,0,0,0,0,0,0,1
Data 0,0,0,0,0,0,0,0,0,0,0
 
 
'Map elevations and mositure calculation done here with the help of perlin noise
freq = 1
For y = 0 To mapH
    For x = 0 To mapW
        nx = x * 0.01
        ny = y * 0.01
        noiseDetail 2, 0.4
        v! = Abs(noise(nx * freq, ny * freq, 0)) * 1.5 + Abs(noise(nx * freq * 4, ny * freq * 4, 0)) * .25
        v! = v! ^ (3.9)
        elev = v! * 255
        noiseDetail 2, 0.4
        m! = Abs(noise(nx * 2, ny * 2, 0))
        m! = m! ^ 1.4
 
        ' PSET (x + mapW, y), _RGB(0, 0, m! * 255)
        moistureMap(x, y) = m!
 
        ' PSET (x, y), _RGB(elev, elev, elev)
        terrainMap(x, y) = (elev / 255) * mountHeightMax
        terrainData(x, y).x = map(x, 0, mapW, -mapW * 0.04, mapW * 0.04)
        terrainData(x, y).y = terrainMap(x, y)
        terrainData(x, y).z = map(y, 0, mapH, -mapH * 0.04, mapH * 0.04)
 
        setMountColor x, y, 0, (elev / 255) * mountHeightMax, mountHeightMax
        clr~& = _RGB(mountColor(0) * 255, mountColor(1) * 255, mountColor(2) * 255)
        PSet (x, y), clr~&
        _Dest worldMap&
        PSet (x + 150, y + 150), clr~&
        _Dest 0
 
        If terrainMap(x, y) <= 0.3 * mountHeightMax And Rnd > 0.99993 And Surprise.set = 0 Then
            Surprise.POS = terrainData(x, y)
            ' line(x-2,y-2)-step(4,4),_rgb(255,0,0),bf
            Surprise.set = 1
            sx = x: sy = y
        End If
 
    Next x
 
    'CLS
    'PRINT "Generating World..."
    'need to show a catchy progress bar
    For j = 0 To map(y, 0, mapH - 1, 0, _Width - 1): Line (j, _Height - 6)-(j, _Height - 1), hsb~&(map(j, 0, _Width - 1, 0, 255), 255, 128, 255): Next j
    _Display
Next y
' _TITLE "3D OpenWorld Mountails [Hit SPACE to switch between MODs]"
_Dest worldMap&
Line (sx - 3 + 150, sy - 3 + 150)-Step(6, 6), _RGB(255, 0, 0), BF
_Dest 0
generateTerrainData
Print "Hit Enter To Step In The World."
Print "Map size : "; (mapH * mapW * 24) / 1024; " kB"
_Display
Sleep
_MouseHide
Cls
_GLRender _Behind
 
glAllow = -1
Do
    While _MouseInput: Wend
    theta = (_MouseX / _Width) * _Pi(2.5) 'controls x-axis rotation
    phi = map(_MouseY, 0, _Height, -_Pi(0), _Pi(0.5)) 'controls y-axis rotation
 
    If Cam.mpos.z > mapH - 2 Then Cam.mpos.z = mapH - 2 'prevent reaching out of the world map
    If Cam.mpos.x > mapW - 2 Then Cam.mpos.x = mapW - 2 '
    If Cam.mpos.z < 2 Then Cam.mpos.z = 2 '
    If Cam.mpos.x < 2 Then Cam.mpos.x = 2 '
 
    If _KeyDown(Asc("w")) Or _KeyDown(Asc("W")) Then 'forward movement based on y-axis rotation
        Cam.mpos.z = Cam.mpos.z + Sin(theta) * 0.45: Cam.mpos.x = Cam.mpos.x + Cos(theta) * 0.45
    End If
    If _KeyDown(Asc("s")) Or _KeyDown(Asc("S")) Then ' backward movement based on y-axis rotation
        Cam.mpos.z = Cam.mpos.z - Sin(theta) * 0.45: Cam.mpos.x = Cam.mpos.x - Cos(theta) * 0.45
    End If
    If _KeyDown(Asc("a")) Or _KeyDown(Asc("A")) Then 'left movement based on y-axis rotation
        Cam.mpos.z = Cam.mpos.z + Sin(theta - _Pi(0.5)) * 0.45: Cam.mpos.x = Cam.mpos.x + Cos(theta - _Pi(0.5)) * 0.45
    End If
    If _KeyDown(Asc("d")) Or _KeyDown(Asc("D")) Then 'right movement based on y-axis rotation
        Cam.mpos.z = Cam.mpos.z + Sin(theta + _Pi(0.5)) * 0.45: Cam.mpos.x = Cam.mpos.x + Cos(theta + _Pi(0.5)) * 0.45
    End If
 
    If _KeyHit = Asc(" ") Then 'switching between MODs
        If worldMOD = 2 Or worldMOD = 3 Then worldMOD = 0 Else worldMOD = worldMOD + 1
    End If
 
    Cls , 1 'clear the screen and make it transparent so that GL context not get hidden.
    _Limit 60
 
    'rotation of world causes rotation of map too. calculation of the source points of map is done below
    sx1 = Cos(_Pi(.75) + theta) * 150 * sqrt2 + Cam.mpos.x + 150: sy1 = Sin(_Pi(.75) + theta) * 150 * sqrt2 + Cam.mpos.z + 150
    sx2 = Cos(_Pi(1.25) + theta) * 150 * sqrt2 + Cam.mpos.x + 150: sy2 = Sin(_Pi(1.25) + theta) * 150 * sqrt2 + Cam.mpos.z + 150
    sx3 = Cos(_Pi(1.75) + theta) * 150 * sqrt2 + Cam.mpos.x + 150: sy3 = Sin(_Pi(1.75) + theta) * 150 * sqrt2 + Cam.mpos.z + 150
    sx4 = Cos(_Pi(2.25) + theta) * 150 * sqrt2 + Cam.mpos.x + 150: sy4 = Sin(_Pi(2.25) + theta) * 150 * sqrt2 + Cam.mpos.z + 150
    'displaying the minimap
    _MapTriangle (sx3, sy3)-(sx4, sy4)-(sx2, sy2), worldMap& To(0, _Height - 150 * sqrt2)-(150 * sqrt2, _Height - 150 * sqrt2)-(0, _Height - 1)
    _MapTriangle (sx2, sy2)-(sx4, sy4)-(sx1, sy1), worldMap& To(0, _Height - 1)-(150 * sqrt2, _Height - 150 * sqrt2)-(150 * sqrt2, _Height - 1)
    'showing your location
    _PutImage (75 * sqrt2, _Height - 75 * sqrt2)-Step(10, 10), myLocation&
    'drawing red border along the map make it attractive
    Line (1, _Height - 150 * sqrt2)-Step(150 * sqrt2, 150 * sqrt2), _RGB(255, 0, 0), B
    _Display
   
    If snowMount = 1 Then
        For i = 1 To UBound(mountVert) Step 3
            setMountColor 0, 0, i - 1, mountVert(i), mountHeightMax
        Next
        snowMount = 2
    End If
 
Loop
 
Sub _GL () Static
 
    If glAllow = 0 Then Exit Sub 'we are not ready yet
 
    If Not glSetup Then
        glSetup = -1
        _glViewport 0, 0, _Width, _Height 'define our rendering area
 
        aspect# = _Width / _Height 'used to create perspective view
 
        rad = 1 'distance of camera from origin (0,0,0)
        farPoint = 1.0 'far point of camera target
 
        'initialize camera
        Cam.mpos.x = mapW / 2
        Cam.mpos.z = mapH / 2
        Cam.mpos.y = 8
        'initialize textures for sky
        For i = 1 To UBound(worldTextures&)
            _glGenTextures 1, _Offset(worldTextureHandle&(i - 1))
 
            Dim m As _MEM
            m = _MemImage(worldTextures&(i))
 
            _glBindTexture _GL_TEXTURE_2D, worldTextureHandle&(i - 1)
            _glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGB, _Width(worldTextures&(i)), _Height(worldTextures&(i)), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, m.OFFSET
 
            _MemFree m
 
            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
            _FreeImage worldTextures&(i)
        Next
    End If
 
    If worldMOD = 0 Then _glClearColor 0.7, 0.8, 1.0, 1.0 'this makes the background look sky blue.
    If worldMOD = 1 Then _glClearColor 0.031, 0.0, 0.307, 1.0 'night sky
    If worldMOD = 2 Then _glClearColor 0.0, 0.0, 0.0, 1.0
    If worldMOD = 3 Then
        v~& = hsb~&(clock# Mod 255, 255, 128, 255)
        kR = _Red(v~&) / 255: kG = _Green(v~&) / 255: kB = _Blue(v~&) / 255
        _glClearColor kR, kG, kB, 1
    End If
    '_glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT
 
    _glEnable _GL_DEPTH_TEST 'Of course, we are going to do 3D
    _glDepthMask _GL_TRUE
 
 
    _glEnable _GL_TEXTURE_2D 'so that we can use texture for our sky. :)
 
    If worldMOD <> 2 Then
        _glEnable _GL_LIGHTING 'Without light, everything dull.
        _glEnable _GL_LIGHT0
    End If
 
    If worldMOD = 1 Then
        'night MOD
        _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec4(0.05, 0.05, 0.33, 0)
        _glLightfv _GL_LIGHT0, _GL_DIFFUSE, glVec4(0.55, 0.55, 0.78, 0)
        _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec4(0.75, 0.75, 0.98, 0)
    ElseIf worldMOD = 0 Then
        _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec4(0.35, 0.35, 0.33, 0) 'gives a bit yellowing color to the light
        _glLightfv _GL_LIGHT0, _GL_DIFFUSE, glVec4(0.75, 0.75, 0.60, 0) 'so it will feel like sun is in the sky
        _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec4(0.95, 0.95, 0.80, 0)
    ElseIf worldMOD = 3 Then 'disco light
        _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec4(kR / 2, kG / 2, kB / 2, 0)
        _glLightfv _GL_LIGHT0, _GL_DIFFUSE, glVec4(kR * 0.9, kG * 0.9, kB * 0.9, 0)
        _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec4(kR, kG, kB, 0)
    End If
    _glShadeModel _GL_SMOOTH 'to make the rendering smooth
 
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 70, aspect#, 0.01, 15.0 'set up out perpective
 
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
 
    ' IF Cam.mpos.y > (terrainMap(Cam.mpos.x, Cam.mpos.z)) THEN Cam.mpos.y = Cam.mpos.y - 0.03 ELSE
    Cam.mpos.y = meanAreaHeight(1, Cam.mpos.x, Cam.mpos.z) 'if you are in air then you must fall.
 
    'calculation of camera eye, its target, etc...
    Cam.POS.x = map(Cam.mpos.x, 0, mapW, -mapW * 0.04, mapW * 0.04)
    Cam.POS.z = map(Cam.mpos.z, 0, mapH, -mapH * 0.04, mapH * 0.04)
    Cam.POS.y = Cam.mpos.y + 0.3
 
    Cam.target.y = Cam.POS.y * Cos(phi)
    Cam.target.x = Cam.POS.x + Cos(theta) * farPoint
    Cam.target.z = Cam.POS.z + Sin(theta) * farPoint
 
    gluLookAt Cam.POS.x, Cam.POS.y, Cam.POS.z, Cam.target.x, Cam.target.y, Cam.target.z, 0, 1, 0
 
 
 
    ' draw the world
    _glEnable _GL_COLOR_MATERIAL
    _glColorMaterial _GL_FRONT, _GL_AMBIENT_AND_DIFFUSE
 
    _glEnableClientState _GL_VERTEX_ARRAY
    _glVertexPointer 3, _GL_FLOAT, 0, _Offset(mountVert())
    _glEnableClientState _GL_COLOR_ARRAY
    _glColorPointer 3, _GL_FLOAT, 0, _Offset(mountColor())
    _glEnableClientState _GL_NORMAL_ARRAY
    _glNormalPointer _GL_FLOAT, 0, _Offset(mountNormal())
 
    If worldMOD = 2 Then _glDrawArrays _GL_LINE_STRIP, 1, (UBound(mountVert) / 3) - 1 Else _glDrawArrays _GL_TRIANGLE_STRIP, 1, (UBound(mountVert) / 3) - 1
    _glDisableClientState _GL_VERTEX_ARRAY
    _glDisableClientState _GL_COLOR_ARRAY
    _glDisableClientState _GL_NORMAL_ARRAY
    _glDisable _GL_COLOR_MATERIAL
 
 
    _glDisable _GL_LIGHTING
    If worldMOD <> 3 And snowMount <> 2 Then showSurprise 0.4, Cam.POS
 
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 70, aspect#, 0.01, 100
 
    _glMatrixMode _GL_MODELVIEW
 
    skybox 32.0 'sky
 
    _glFlush
 
    clock# = clock# + .5
End Sub
 
Function meanAreaHeight# (n%, x%, y%)
    $Checking:Off
    For i = y% - n% To y% + n%
        For j = x% - n% To x% + n%
            h# = h# + terrainMap(j, i)
            g% = g% + 1
    Next j, i
    meanAreaHeight# = (h# / g%)
    $Checking:On
End Function
 
Sub showSurprise (s, a As vec3)
    If a.x > Surprise.POS.x - s And a.x < Surprise.POS.x + s And a.z > Surprise.POS.z - s And a.z < Surprise.POS.z + s Then
        If Rnd > 0.5 Then
            worldMOD = 3
            _Title "You finally came to know that its QB64 Island!!"
        Else
            snowMount = 1
            _Title "Welcome to this new world..."
            Cam.mpos.y = 6
        End If
    End If
 
    _glBindTexture _GL_TEXTURE_2D, worldTextureHandle&(0)
 
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y + 2 * s, Surprise.POS.z - s 'front
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y, Surprise.POS.z - s
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y, Surprise.POS.z - s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y + 2 * s, Surprise.POS.z - s
    _glEnd
 
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y + 2 * s, Surprise.POS.z + s 'rear
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y, Surprise.POS.z + s
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y, Surprise.POS.z + s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y + 2 * s, Surprise.POS.z + s
    _glEnd
 
    _glBegin _GL_QUADS
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y + 2 * s, Surprise.POS.z + s 'left
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y, Surprise.POS.z + s
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y, Surprise.POS.z - s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y + 2 * s, Surprise.POS.z - s
    _glEnd
 
    _glBegin _GL_QUADS
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y + 2 * s, Surprise.POS.z + s 'right
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y, Surprise.POS.z + s
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y, Surprise.POS.z - s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y + 2 * s, Surprise.POS.z - s
    _glEnd
 
    _glBegin _GL_QUADS 'up
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y + 2 * s, Surprise.POS.z - s 'up
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y + 2 * s, Surprise.POS.z + s
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y + 2 * s, Surprise.POS.z + s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y + 2 * s, Surprise.POS.z - s
    _glEnd
 
    _glBegin _GL_QUADS 'down
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y, Surprise.POS.z - s 'up
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.POS.x - s, Surprise.POS.y, Surprise.POS.z + s
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y, Surprise.POS.z + s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.POS.x + s, Surprise.POS.y, Surprise.POS.z - s
    _glEnd
 
End Sub
 
'draws a beautiful sky
Sub skybox (s)
    If worldMOD > 1 Then Exit Sub
 
    _glDepthMask _GL_FALSE
 
    If worldMOD = 0 Then _glBindTexture _GL_TEXTURE_2D, worldTextureHandle&(1) Else _glBindTexture _GL_TEXTURE_2D, worldTextureHandle&(2)
 
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f -s, s, -s 'front
    _glTexCoord2f 0, 0
    _glVertex3f -s, -s, -s
    _glTexCoord2f 1, 0
    _glVertex3f s, -s, -s
    _glTexCoord2f 1, 1
    _glVertex3f s, s, -s
    _glEnd
 
    '_glBindTexture _GL_TEXTURE_2D, skyTextureHandle&(0)
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f -s, s, s 'rear
    _glTexCoord2f 0, 0
    _glVertex3f -s, -s, s
    _glTexCoord2f 1, 0
    _glVertex3f s, -s, s
    _glTexCoord2f 1, 1
    _glVertex3f s, s, s
    _glEnd
 
    '_glBindTexture _GL_TEXTURE_2D, skyTextureHandle&(1)
    _glBegin _GL_QUADS
    _glTexCoord2f 1, 0
    _glVertex3f -s, s, s 'left
    _glTexCoord2f 0, 0
    _glVertex3f -s, -s, s
    _glTexCoord2f 0, 1
    _glVertex3f -s, -s, -s
    _glTexCoord2f 1, 1
    _glVertex3f -s, s, -s
    _glEnd
 
    '_glBindTexture _GL_TEXTURE_2D, skyTextureHandle&(3)
    _glBegin _GL_QUADS
    _glTexCoord2f 1, 0
    _glVertex3f s, s, s 'right
    _glTexCoord2f 0, 0
    _glVertex3f s, -s, s
    _glTexCoord2f 0, 1
    _glVertex3f s, -s, -s
    _glTexCoord2f 1, 1
    _glVertex3f s, s, -s
    _glEnd
 
    '_glBindTexture _GL_TEXTURE_2D, skyTextureHandle&(2)
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f -s, s, -s 'up
    _glTexCoord2f 0, 0
    _glVertex3f -s, s, s
    _glTexCoord2f 1, 0
    _glVertex3f s, s, s
    _glTexCoord2f 1, 1
    _glVertex3f s, s, -s
    _glEnd
 
    _glDepthMask _GL_TRUE
End Sub
 
Sub setMountColor (xi, yi, i, h, h_max) 'assign color on the basis of height map and moisture map.
    If snowMount = 1 Then
        If h > 0.8 * h_max Then mountColor(i) = 0.439: mountColor(i + 1) = 0.988: mountColor(i + 2) = 0.988: Exit Sub
        mountColor(i) = 1: mountColor(i + 1) = 1: mountColor(i + 2) = 1
        Exit Sub
    End If
    If h > 0.8 * h_max Then
        If moistureMap(xi, yi) < 0.1 Then mountColor(i) = 0.333: mountColor(i + 1) = 0.333: mountColor(i + 2) = 0.333: Exit Sub 'scorched
        If moistureMap(xi, yi) < 0.2 Then mountColor(i) = 0.533: mountColor(i + 1) = 0.533: mountColor(i + 2) = 0.533: Exit Sub 'bare
        If moistureMap(xi, yi) < 0.5 Then mountColor(i) = 0.737: mountColor(i + 1) = 0.737: mountColor(i + 2) = 0.6705: Exit Sub 'tundra
        mountColor(i) = 0.8705: mountColor(i + 1) = 0.8705: mountColor(i + 2) = 0.898: Exit Sub 'snow
    End If
    If h > 0.6 * h_max Then
        If moistureMap(xi, yi) < 0.33 Then mountColor(i) = 0.788: mountColor(i + 1) = 0.823: mountColor(i + 2) = 0.607: Exit Sub 'temperate desert
        If moistureMap(xi, yi) < 0.66 Then mountColor(i) = 0.533: mountColor(i + 1) = 0.600: mountColor(i + 2) = 0.466: Exit Sub 'shrubland
        mountColor(i) = 0.6: mountColor(i + 1) = 0.6705: mountColor(i + 2) = 0.466: Exit Sub 'taiga
    End If
    If h > 0.3 * h_max Then
        If moistureMap(xi, yi) < 0.16 Then mountColor(i) = 0.788: mountColor(i + 1) = 0.823: mountColor(i + 2) = 0.607: Exit Sub 'temperate desert
        If moistureMap(xi, yi) < 0.50 Then mountColor(i) = 0.533: mountColor(i + 1) = 0.6705: mountColor(i + 2) = 0.333: Exit Sub 'grassland
        If moistureMap(xi, yi) < 0.83 Then mountColor(i) = 0.403: mountColor(i + 1) = 0.576: mountColor(i + 2) = 0.349: Exit Sub 'temperate deciduous forest
        mountColor(i) = 0.262: mountColor(i + 1) = 0.533: mountColor(i + 2) = 0.233: Exit Sub 'temperate rain forest
    End If
    If h < 0.01 * h_max Then mountColor(i) = 0.262: mountColor(i + 1) = 0.262: mountColor(i + 2) = 0.478: Exit Sub 'ocean
    If h < 0.07 * h_max Then mountColor(i) = 0.627: mountColor(i + 1) = 0.568: mountColor(i + 2) = 0.466: Exit Sub 'beach
    If h <= 0.3 * h_max Then
        If moistureMap(xi, yi) < 0.16 Then mountColor(i) = 0.823: mountColor(i + 1) = 0.725: mountColor(i + 2) = 0.545: Exit Sub 'subtropical desert
        If moistureMap(xi, yi) < 0.33 Then mountColor(i) = 0.533: mountColor(i + 1) = 0.6705: mountColor(i + 2) = 0.333: Exit Sub 'grassland
        If moistureMap(xi, yi) < 0.66 Then mountColor(i) = 0.337: mountColor(i + 1) = 0.600: mountColor(i + 2) = 0.266: Exit Sub 'tropical seasonal forest
        mountColor(i) = 0.2: mountColor(i + 1) = 0.466: mountColor(i + 2) = 0.333: Exit Sub 'tropical rain forest
    End If
End Sub
 
Sub generateTerrainData ()
    Dim A As vec3, B As vec3, C As vec3, R As vec3
    index = 0
 
    '##################################################################################################
    '# Note : The below method consumes more memory. It uses 3x more vertex array than the next one.  #
    '# So, use of this method was avoided by me.                                                      #
    '##################################################################################################
 
    ' _dest _console
    ' FOR z = 0 TO mapH - 1
    ' FOR x = 0 TO mapW - 1
    ' A = terrainData(x, z)
    ' B = terrainData(x, z + 1)
    ' C = terrainData(x + 1, z)
    ' D = terrainData(x+1,z+1)
 
    ' ' ?index
    ' ' OBJ_CalculateNormal A, B, C, R
 
    ' ' mountNormal(index) = R.x : mountNormal(index+1) = R.y : mountNormal(index+2) = R.z
    ' ' mountNormal(index+3) = R.x : mountNormal(index+4) = R.y : mountNormal(index+5) = R.z
    ' ' mountNormal(index+6) = R.x : mountNormal(index+7) = R.y : mountNormal(index+8) = R.z
 
    ' mountVert(index) = A.x : mountVert(index+1) = A.y : mountVert(index+2) = A.z : setMountColor x,z,index, A.y, mountHeightMax
    ' mountVert(index+3) = B.x : mountVert(index+4) = B.y : mountVert(index+5) = B.z :  setMountColor x,z+1,index+3, B.y, mountHeightMax
    ' mountVert(index+6) = C.x : mountVert(index+7) = C.y : mountVert(index+8) = C.z: setMountColor x+1,z,index+6, C.y, mountHeightMax
 
    ' ' OBJ_CalculateNormal C,B,D, R
 
    ' ' mountNormal(index+9) = R.x : mountNormal(index+10) = R.y : mountNormal(index+11) = R.z
    ' ' mountNormal(index+12) = R.x : mountNormal(index+13) = R.y : mountNormal(index+14) = R.z
    ' ' mountNormal(index+15) = R.x : mountNormal(index+16) = R.y : mountNormal(index+17) = R.z
 
    ' mountVert(index+9) = C.x : mountVert(index+10) = C.y : mountVert(index+11) = C.z: setMountColor x+1,z, index+9, C.y, mountHeightMax
    ' mountVert(index+12) = B.x : mountVert(index+13) = B.y : mountVert(index+14) = B.z: setMountColor x,z+1,index+12, B.y, mountHeightMax
    ' mountVert(index+15) = D.x : mountVert(index+16) = D.y : mountVert(index+17) = D.z: setMountColor x+1,z+1,index+15, D.y, mountHeightMax
    ' index = index+18
    ' NEXT x,z
 
    'this method is efficient than the above one.
    Do
        If z Mod 2 = 0 Then x = x + 1 Else x = x - 1
 
        A = terrainData(x, z) 'get out coordinates from our stored data
        B = terrainData(x, z + 1)
        C = terrainData(x + 1, z)
 
        OBJ_CalculateNormal A, B, C, R 'calculates the normal of a triangle
 
        'store color, coordinate & normal data in an array
        mountNormal(index) = R.x: mountNormal(index + 1) = R.y: mountNormal(index + 2) = R.z
        mountVert(index) = A.x: mountVert(index + 1) = A.y: mountVert(index + 2) = A.z: setMountColor x, z, index, A.y, mountHeightMax
 
        mountNormal(index + 3) = R.x: mountNormal(index + 4) = R.y: mountNormal(index + 5) = R.z
        mountVert(index + 3) = B.x: mountVert(index + 4) = B.y: mountVert(index + 5) = B.z: setMountColor x, z + 1, index + 3, B.y, mountHeightMax
 
        index = index + 6
 
        If x = mapW - 1 Then
            If z Mod 2 = 0 Then x = x + 1: z = z + 1
        End If
        If x = 1 Then
            If z Mod 2 = 1 Then x = x - 1: z = z + 1
        End If
        If z = mapH - 1 Then Exit Do
    Loop
    _Dest 0
End Sub
 
Function trimDecimal# (num, n%)
    d$ = RTrim$(Str$(num))
    dd$ = d$
    For i = 1 To Len(d$)
        cA$ = Mid$(d$, i, 1)
        If foundpoint = 1 Then k = k + 1
        If cA$ = "." Then foundpoint = 1
        If k = n% Then dd$ = Left$(dd$, i)
    Next i
    trimDecimal# = Val(dd$)
End Function
 
 
Function p5random! (mn!, mx!)
    If mn! > mx! Then
        Swap mn!, mx!
    End If
    p5random! = Rnd * (mx! - mn!) + mn!
End Function
 
 
Function map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
End Function
 
Sub CircleFill (CX As Long, CY As Long, R As Long, C As _Unsigned Long)
    'This sub from here: http://www.[abandoned, outdated and now likely malicious qb64 dot net website - don’t go there]/forum/index.php?topic=1848.msg17254#msg17254
    Dim Radius As Long
    Dim RadiusError As Long
    Dim X As Long
    Dim Y As Long
 
    Radius = Abs(R)
    RadiusError = -Radius
    X = Radius
    Y = 0
 
    If Radius = 0 Then PSet (CX, CY), C: Exit Sub
 
    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
    Line (CX - X, CY)-(CX + X, CY), C, BF
 
    While X > Y
 
        RadiusError = RadiusError + Y * 2 + 1
 
        If RadiusError >= 0 Then
 
            If X <> Y + 1 Then
                Line (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                Line (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            End If
 
            X = X - 1
            RadiusError = RadiusError - X * 2
 
        End If
 
        Y = Y + 1
 
        Line (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        Line (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
 
    Wend
 
End Sub
 
 
'coded in QB64 by Fellipe Heitor
'Can be found in p5js.bas library
'http://bit.ly/p5jsbas
Function noise! (x As Single, y As Single, z As Single)
    Static p5NoiseSetup As _Byte
    Static perlin() As Single
    Static PERLIN_YWRAPB As Single, PERLIN_YWRAP As Single
    Static PERLIN_ZWRAPB As Single, PERLIN_ZWRAP As Single
    Static PERLIN_SIZE As Single
 
    If p5NoiseSetup = 0 Then
        p5NoiseSetup = 1
 
        PERLIN_YWRAPB = 4
        PERLIN_YWRAP = Int(1 * (2 ^ PERLIN_YWRAPB))
        PERLIN_ZWRAPB = 8
        PERLIN_ZWRAP = Int(1 * (2 ^ PERLIN_ZWRAPB))
        PERLIN_SIZE = 4095
 
        perlin_octaves = 4
        perlin_amp_falloff = 0.5
 
        ReDim perlin(PERLIN_SIZE + 1) As Single
        Dim i As Single
        For i = 0 To PERLIN_SIZE + 1
            perlin(i) = Rnd
        Next
    End If
 
    x = Abs(x)
    y = Abs(y)
    z = Abs(z)
 
    Dim xi As Single, yi As Single, zi As Single
    xi = Int(x)
    yi = Int(y)
    zi = Int(z)
 
    Dim xf As Single, yf As Single, zf As Single
    xf = x - xi
    yf = y - yi
    zf = z - zi
 
    Dim r As Single, ampl As Single, o As Single
    r = 0
    ampl = .5
 
    For o = 1 To perlin_octaves
        Dim of As Single, rxf As Single
        Dim ryf As Single, n1 As Single, n2 As Single, n3 As Single
        of = xi + Int(yi * (2 ^ PERLIN_YWRAPB)) + Int(zi * (2 ^ PERLIN_ZWRAPB))
 
        rxf = 0.5 * (1.0 - Cos(xf * _Pi))
        ryf = 0.5 * (1.0 - Cos(yf * _Pi))
 
        n1 = perlin(of And PERLIN_SIZE)
        n1 = n1 + rxf * (perlin((of + 1) And PERLIN_SIZE) - n1)
        n2 = perlin((of + PERLIN_YWRAP) And PERLIN_SIZE)
        n2 = n2 + rxf * (perlin((of + PERLIN_YWRAP + 1) And PERLIN_SIZE) - n2)
        n1 = n1 + ryf * (n2 - n1)
 
        of = of + PERLIN_ZWRAP
        n2 = perlin(of And PERLIN_SIZE)
        n2 = n2 + rxf * (perlin((of + 1) And PERLIN_SIZE) - n2)
        n3 = perlin((of + PERLIN_YWRAP) And PERLIN_SIZE)
        n3 = n3 + rxf * (perlin((of + PERLIN_YWRAP + 1) And PERLIN_SIZE) - n3)
        n2 = n2 + ryf * (n3 - n2)
 
        n1 = n1 + (0.5 * (1.0 - Cos(zf * _Pi))) * (n2 - n1)
 
        r = r + n1 * ampl
        ampl = ampl * perlin_amp_falloff
        xi = Int(xi * (2 ^ 1))
        xf = xf * 2
        yi = Int(yi * (2 ^ 1))
        yf = yf * 2
        zi = Int(zi * (2 ^ 1))
        zf = zf * 2
 
        If xf >= 1.0 Then xi = xi + 1: xf = xf - 1
        If yf >= 1.0 Then yi = yi + 1: yf = yf - 1
        If zf >= 1.0 Then zi = zi + 1: zf = zf - 1
    Next
    noise! = r
End Function
 
Sub noiseDetail (lod!, falloff!)
    If lod! > 0 Then perlin_octaves = lod!
    If falloff! > 0 Then perlin_amp_falloff = falloff!
End Sub
 
'method adapted form http://stackoverflow.com/questions/4106363/converting-rgb-to-hsb-colors
Function hsb~& (__H As _Float, __S As _Float, __B As _Float, A As _Float)
    Dim H As _Float, S As _Float, B As _Float
 
    H = map(__H, 0, 255, 0, 360)
    S = map(__S, 0, 255, 0, 1)
    B = map(__B, 0, 255, 0, 1)
 
    If S = 0 Then
        hsb~& = _RGBA32(B * 255, B * 255, B * 255, A)
        Exit Function
    End If
 
    Dim fmx As _Float, fmn As _Float
    Dim fmd As _Float, iSextant As Integer
    Dim imx As Integer, imd As Integer, imn As Integer
 
    If B > .5 Then
        fmx = B - (B * S) + S
        fmn = B + (B * S) - S
    Else
        fmx = B + (B * S)
        fmn = B - (B * S)
    End If
 
    iSextant = Int(H / 60)
 
    If H >= 300 Then
        H = H - 360
    End If
 
    H = H / 60
    H = H - (2 * Int(((iSextant + 1) Mod 6) / 2))
 
    If iSextant Mod 2 = 0 Then
        fmd = (H * (fmx - fmn)) + fmn
    Else
        fmd = fmn - (H * (fmx - fmn))
    End If
 
    imx = _Round(fmx * 255)
    imd = _Round(fmd * 255)
    imn = _Round(fmn * 255)
 
    Select Case Int(iSextant)
        Case 1
            hsb~& = _RGBA32(imd, imx, imn, A)
        Case 2
            hsb~& = _RGBA32(imn, imx, imd, A)
        Case 3
            hsb~& = _RGBA32(imn, imd, imx, A)
        Case 4
            hsb~& = _RGBA32(imd, imn, imx, A)
        Case 5
            hsb~& = _RGBA32(imx, imn, imd, A)
        Case Else
            hsb~& = _RGBA32(imx, imd, imn, A)
    End Select
 
End Function
 
 
Sub OBJ_CalculateNormal (p1 As vec3, p2 As vec3, p3 As vec3, N As vec3)
    Dim U As vec3, V As vec3
 
    U.x = p2.x - p1.x
    U.y = p2.y - p1.y
    U.z = p2.z - p1.z
 
    V.x = p3.x - p1.x
    V.y = p3.y - p1.y
    V.z = p3.z - p1.z
 
    N.x = (U.y * V.z) - (U.z * V.y)
    N.y = (U.z * V.x) - (U.x * V.z)
    N.z = (U.x * V.y) - (U.y * V.x)
    OBJ_Normalize N
End Sub
 
Sub OBJ_Normalize (V As vec3)
    mag! = Sqr(V.x * V.x + V.y * V.y + V.z * V.z)
    V.x = V.x / mag!
    V.y = V.y / mag!
    V.z = V.z / mag!
End Sub
 
Function glVec4%& (x, y, z, w)
    Static internal_vec4(3)
    internal_vec4(0) = x
    internal_vec4(1) = y
    internal_vec4(2) = z
    internal_vec4(3) = w
    glVec4%& = _Offset(internal_vec4())
End Function
 
'============================================================
'=== This file was created with MakeDATA.bas by RhoSigma, ===
'=== you must $INCLUDE this at the end of your program.   ===
'============================================================
 
'=====================================================================
'Function to write the embedded DATAs back to disk. Call this FUNCTION
'once, before you will access the represented file for the first time.
'After the call always use the returned realFile$ ONLY to access the
'written file, as the filename was maybe altered in order to avoid the
'overwriting of an existing file of the same name in the given location.
'---------------------------------------------------------------------
'SYNTAX: realFile$ = WriteqbiconData$ (wantFile$)
'
'INPUTS: wantFile$ --> The filename you would like to write the DATAs
'                      to, can contain a full or relative path.
'
'RESULT: realFile$ --> On success the path and filename finally used
'                      after applied checks, use ONLY this returned
'                      name to access the file.
'                   -> On failure this FUNCTION will panic with the
'                      appropriate ERROR code, you may handle this as
'                      needed with your own ON ERROR GOTO... handler.
'=====================================================================
Function WriteqbiconData$ (file$)
    '--- separate filename body & extension ---
    For po% = Len(file$) To 1 Step -1
        If Mid$(file$, po%, 1) = "." Then
            body$ = Left$(file$, po% - 1)
            ext$ = Mid$(file$, po%)
            Exit For
        ElseIf Mid$(file$, po%, 1) = "\" Or Mid$(file$, po%, 1) = "/" Or po% = 1 Then
            body$ = file$
            ext$ = ""
            Exit For
        End If
    Next po%
    '--- avoid overwriting of existing files ---
    num% = 1
    While _FileExists(file$)
        file$ = body$ + "(" + LTrim$(Str$(num%)) + ")" + ext$
        num% = num% + 1
    Wend
    '--- write DATAs ---
    ff% = FreeFile
    Open file$ For Output As ff%
    Restore qbicon
    Read numL&, numB&
    For i& = 1 To numL&
        Read dat&
        Print #ff%, MKL$(dat&);
    Next i&
    If numB& > 0 Then
        For i& = 1 To numB&
            Read dat&
            Print #ff%, Chr$(dat&);
        Next i&
    End If
    Close ff%
    '--- set result ---
    WriteqbiconData$ = file$
    Exit Function
 
    '--- DATAs representing the contents of file qbicon32.png
    '---------------------------------------------------------------------
    qbicon:
    Data 144,4
    Data &H474E5089,&H0A1A0A0D,&H0D000000,&H52444849,&H20000000,&H20000000,&H00000608,&H7A7A7300
    Data &H000000F4,&H4D416704,&HB1000041,&H61FC0B8F,&H00000005,&H59487009,&H0E000073,&H0E0000C1
    Data &H91B801C1,&H0000ED6B,&H45741A00,&H6F537458,&H61777466,&H50006572,&H746E6961,&H54454E2E
    Data &H2E337620,&H30312E35,&HA172F430,&HC0010000,&H54414449,&H97C54758,&H20C371E1,&HA519850C
    Data &H064430A3,&HDB3124E8,&H823B3FB4,&H5D14C887,&H04A84D21,&H8C096308,&H87F6E2E0,&HD67E02F2
    Data &HBE7C5F13,&H6EE6318B,&H32F9F98D,&H4A6A13E6,&H66A141DF,&H060DE3F4,&H283CCDC8,&HA0AEB0D4
    Data &H869AC350,&HE1E5F0A0,&H42FAF78D,&H35621C7F,&HE71AB1F6,&H3CFE85F5,&H0F502444,&HA81115E9
    Data &H922AF485,&HE6F00828,&H8C2746EE,&H0F4B7EBA,&HEDCDE011,&H15184E93,&H25D3DCD7,&H0A938650
    Data &H1940834F,&H3D3C2A4E,&H551C3C02,&H6CBEC278,&H8E04EFFE,&H24E64F6A,&H92554702,&HBD808D39
    Data &HCD712195,&H2812A73D,&HA78549C3,&HF73DC047,&H9EE6B8E1,&H7F365D78,&HB54D0109,&H104A6808
    Data &H27157A98,&H62AF5302,&HDDC4A04E,&H11F35222,&H082D39E6,&HC89CE6F0,&HBCAE6276,&H020688E9
    Data &HB732A1F0,&H569436B4,&H8301F0E1,&HBCA6AC3A,&H00E288E9,&H5CB2C091,&H2EAD0057,&HD87DE3F4
    Data &HEF57B16C,&H5050FC1D,&H2616BDF8,&H237F613D,&HAA390B50,&H40244038,&H3878A98D,&H0230F4AA
    Data &H0BB9C03C,&HADA7B09D,&H9E953BE6,&H2FD8010E,&HD5B48E43,&H73D2A77C,&HFDB70122,&HCD7141C6
    Data &H39FAE93D,&HD2A680CF,&H9A026D70,&H24F0FBC2,&H2DAE13E5,&H6FEE0FBC,&H9F2E7013,&HB9AE2830
    Data &H66A75D27,&H52F6754D,&H0043A019,&HA93873F6,&HA90244F4,&H01CAA1D9,&H10DFFEC2,&H84039540
    Data &H033CD7FD,&H72A6AC3C,&H11BFB080,&HEB157B98,&HD75E3409,&H02184099,&H688E9A94,&H0854190E
    Data &H2FF0040F,&H46621E72,&H1B3509A1,&H05FDBBD5,&HF13FDC1C,&H6A6E33B4,&H00000000,&H444E4549
    Data &HAE,&H42,&H60,&H82
End Function
