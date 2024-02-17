'@Author:Ashish Kushwaha
'28 Feb, 2020s
_Title "Menger Sponge"
Screen _NewImage(600, 600, 32)
 
Type vec3
    x As Single
    y As Single
    z As Single
End Type
 
Declare Library
    Sub glutSolidCube (ByVal dsize As Double) 'use to draw a solid cube by taking the side length as its arguement
End Declare
 
'Algorithm
'1. We take a cube.
'2. We divide it into 27 equal cubical parts.
'3. Out of this 27 cubes, 7 cubes are removed.
'4. In the remaining 20 cubes, Step-1 is repeated for each cube.
iteration = 3 'no. of iteration. At each iteration, 7 cubes are removed from parent cube.
size = 0.5 'the size of our first cube
n = (20 ^ iteration) - 1
 
Dim Shared glAllow, cubeLoc(n) As vec3, fundamentalCubeSize 'cubeLoc array store the location of cubes to be rendered. They are the smallest cube which are formed in the last iteration
fundamentalCubeSize = size / (3 ^ iteration) 'the size the smallest cube which is formed in the last iteration
initFractal 0, 0, 0, size, iteration 'this sub done all calculation for cube location & other stuff.
 
Print (n + 1); " Cubes will rendered with total of "; 8 * (n + 1); " vertices"
Print "Hit a Key"
Sleep
glAllow = 1 'to start rendering in the SUB _GL
Do
    While _MouseInput: Wend
    _Limit 40
Loop
 
Sub _GL () Static
    Dim clr(3)
    If glAllow = 0 Then Exit Sub 'So that rendering will start as soon as initialization is done.
    If glInit = 0 Then
        _glViewport 0, 0, _Width, _Height 'this defines the area in the screen where GL rendering will occur
        aspect# = _Width / _Height

        glInit = 1
    End If
 
    _glEnable _GL_DEPTH_TEST 'this enable Z-buffer. So that we can do 3D things.
    _glClear _GL_DEPTH_BUFFER_BIT Or _GL_COLOR_BUFFER_BIT 'Not required unless we do softwre rendering as well.
 
    'LIGHTS CONFIG
    _glEnable _GL_LIGHTING 'this enable us to use light. There are max of 8 lights in GL
    _glEnable _GL_LIGHT0
    clr(0) = 0.2: clr(1) = 0.2: clr(2) = 0.2: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_AMBIENT, _Offset(clr()) 'this define the color of the material where light can hardly reach.
    clr(0) = 0.8: clr(1) = 0.8: clr(2) = 0.8: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_SPECULAR, _Offset(clr()) 'this define the color of the material where light is directly reflected & reach your eye.
    _glLightfv _GL_LIGHT0, _GL_DIFFUSE, _Offset(clr()) 'this define the default/usual color of the light on the material.
    clr(0) = 0: clr(1) = 0: clr(2) = 0: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_POSITION, _Offset(clr()) 'use to define the direction of light when 4th component is 0. When 4th component is 1, it defines the position of light. In this case, the light looses its intensity as distance increases.
 
    _glMatrixMode _GL_PROJECTION 'usually used for setting up perspective etc.
    _gluPerspective 60, aspect#, 0.1, 10 'first arguement tell angle for FOV (Field of View, for human it is round 70degree for one eye.LOL) next one aspect ratio, next 2 are near & far distance. Objects which are not between these distance are clipped. (or are not rendered.)
 
    _glMatrixMode _GL_MODELVIEW 'rendering takes place here
    _glLoadIdentity
 
    _glTranslatef 0, 0, -1 'move the origin forward by 1 unit
    _glRotatef _MouseX, 0, 1, 0 'these are for rotation by the movement of mouse.
    _glRotatef _MouseY, 1, 0, 0
 
    drawFractal 'draws the fractal
    _glFlush 'force all the GL command to complete in finite amount of time
End Sub
 
Sub initFractal (x, y, z, s, N) 'x-position, y-position, z-position, size, N-> iteration
    Static i
    'As we divide the cube, value of N decreases.
    If N = 0 Then 'when the division is done N times (no. of iteration)
        cubeLoc(i).x = x 'store the coordinates of cube
        cubeLoc(i).y = y
        cubeLoc(i).z = z
        i = i + 1
        ' ? "Added #",i
        ' sleep
        Exit Sub
    End If
    'top section
    'front row, left to right
    initFractal (x - s / 3), (y + s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x), (y + s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z + s / 3), s / 3, N - 1
    'behind the previous row, left to right
    initFractal (x - s / 3), (y + s / 3), (z), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z), s / 3, N - 1
    'behind the previous row, left to right
    initFractal (x - s / 3), (y + s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x), (y + s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z - s / 3), s / 3, N - 1
    'middle section
    'front row, left to right
    initFractal (x - s / 3), (y), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y), (z + s / 3), s / 3, N - 1
    'behind the previous row (last one as middle one contain no cube ;) ), left to right
    initFractal (x - s / 3), (y), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y), (z - s / 3), s / 3, N - 1
    'bottom section
    'front row, left to right
    initFractal (x - s / 3), (y - s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x), (y - s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z + s / 3), s / 3, N - 1
    'behind the previous row, left to right
    initFractal (x - s / 3), (y - s / 3), (z), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z), s / 3, N - 1
    'behind the previous row, left to right
    initFractal (x - s / 3), (y - s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x), (y - s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z - s / 3), s / 3, N - 1 '20
 
End Sub
 
Sub drawFractal ()
    For i = 0 To UBound(cubeLoc)
        _glPushMatrix 'save the previous transformation configuration
        _glTranslatef cubeLoc(i).x, cubeLoc(i).y, cubeLoc(i).z 'move at given location
        glutSolidCube fundamentalCubeSize 'draws the solid cube of smallest size which is formed in the last iteration
        _glPopMatrix 'restore the original transformation configuration
    Next
End Sub
 
