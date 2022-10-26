'OpenGL Lights & Material By Ashish
 
_Title "OpenGL Lights & Material"
 
Screen _NewImage(800, 600, 32)
 
Dim Shared glAllow As _Byte
Declare Library
    Sub gluLookAt (ByVal eyeX#, Byval eyeY#, Byval eyeZ#, Byval centerX#, Byval centerY#, Byval centerZ#, Byval upX#, Byval upY#, Byval upZ#)
    Sub glutSolidSphere (ByVal radius As Double, Byval slices As Long, Byval stack As Long)
End Declare
 
'Used by GLH RGB/etc helper functions
Dim Shared DONT_USE_GLH_COL_RGBA(1 To 4) As Single
 
'Used to manage textures
Type DONT_USE_GLH_Handle_TYPE
    in_use As _Byte
    handle As Long
End Type
 
Type vec3
    x As Single
    y As Single
    z As Single
End Type
 
 
'Used by GLH RGB/etc helper functions
ReDim Shared DONT_USE_GLH_Handle(1000) As DONT_USE_GLH_Handle_TYPE
 
Dim Shared redLight As vec3
Dim Shared greenLight As vec3
Dim Shared blueLight As vec3
 
 
 
glAllow = -1
Do
    _Limit 40
Loop Until k& = Asc(Chr$(27))
 
 
Sub _GL () Static
    If Not glAllow Then Exit Sub
 
    _glEnable _GL_DEPTH_TEST
    _glEnable _GL_LIGHTING

    _glEnable _GL_LIGHT0 'we need three lights, each for red, green & blue.
    _glEnable _GL_LIGHT1
    _glEnable _GL_LIGHT2
   
    _glLightfv _GL_LIGHT0, _GL_AMBIENT, GLH_RGB(0, 0, 0)
    _glLightfv _GL_LIGHT0, _GL_DIFFUSE, GLH_RGB(.5, 0, 0)
    _glLightfv _GL_LIGHT0, _GL_SPECULAR, GLH_RGB(1, 0, 0)
    _glLightfv _GL_LIGHT0, _GL_POSITION, GLH_RGBA(redLight.x, redLight.y, redLight.z, 0)
   
    _glLightfv _GL_LIGHT1, _GL_AMBIENT, GLH_RGB(0, 0, 0)
    _glLightfv _GL_LIGHT1, _GL_DIFFUSE, GLH_RGB(0, .5, 0)
    _glLightfv _GL_LIGHT1, _GL_SPECULAR, GLH_RGB(0, 1, 0)
    _glLightfv _GL_LIGHT1, _GL_POSITION, GLH_RGBA(greenLight.x, greenLight.y, greenLight.z, 0)
 
    _glLightfv _GL_LIGHT2, _GL_AMBIENT, GLH_RGB(0, 0, 0)
    _glLightfv _GL_LIGHT2, _GL_DIFFUSE, GLH_RGB(0, 0, .5)
    _glLightfv _GL_LIGHT2, _GL_SPECULAR, GLH_RGB(0, 0, 1)
    _glLightfv _GL_LIGHT2, _GL_POSITION, GLH_RGBA(blueLight.x, blueLight.y, blueLight.z, 0)
   
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
   
    If Not glSetup Then
        aspect# = _Width / _Height
        glSetup = -1
        _glViewport 0, 0, _Width, _Height
    End If
   
    _gluPerspective 45.0, aspect#, 1.0, 100.0
   
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
   
    gluLookAt 0, 0, 5, 0, 0, 0, 0, 1, 0
   
    _glColor3f 0, 0, 0
   
    _glMaterialfv _GL_FRONT_AND_BACK, _GL_AMBIENT, GLH_RGB(0, 0, 0)
    _glMaterialfv _GL_FRONT_AND_BACK, _GL_DIFFUSE, GLH_RGB(0.8, 0.8, 0.8)
    _glMaterialfv _GL_FRONT_AND_BACK, _GL_SPECULAR, GLH_RGB(.86, .86, .86)
    _glMaterialfv _GL_FRONT_AND_BACK, _GL_SHININESS, GLH_RGB(128 * .566, 0, 0)
   
    glutSolidSphere 1, 100, 100
   
    _glDisable _GL_LIGHTING
   
    _glPushMatrix
    _glTranslatef redLight.x, redLight.y, redLight.z
    _glColor3f 1, 0, 0
    glutSolidSphere .05, 20, 20
    _glPopMatrix
   
    _glPushMatrix
    _glTranslatef greenLight.x, greenLight.y, greenLight.z
    _glColor3f 0, 1, 0
    glutSolidSphere .05, 20, 20
    _glPopMatrix
   
    _glPushMatrix
    _glTranslatef blueLight.x, blueLight.y, .1
    _glColor3f 0, 0, 1
    glutSolidSphere .05, 20, 20
    _glPopMatrix
   
    _glFlush
   
    clock# = clock# + .01
   
    redLight.x = Sin(clock# * 1.5) * 1.5
    redLight.z = Cos(clock# * 1.5) * 1.5
   
    greenLight.y = Cos(clock# * .8) * 1.5
    greenLight.z = Sin(clock# * .8) * 1.5
   
    blueLight.x = Sin(clock#) * 1.5
    blueLight.y = Cos(clock#) * 1.5
End Sub
 
 
Function map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
End Function
 
 
'below, all functions are coded by Galleon
Function GLH_Image_to_Texture (image_handle As Long) 'turn an image handle into a texture handle
    If image_handle >= 0 Then Error 258: Exit Function 'don't allow screen pages
    Dim m As _MEM
    m = _MemImage(image_handle)
    Dim h As Long
    h = DONT_USE_GLH_New_Texture_Handle
    GLH_Image_to_Texture = h
    _glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(h).handle
    _glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGBA, _Width(image_handle), _Height(image_handle), 0, &H80E1&&, _GL_UNSIGNED_BYTE, m.OFFSET
    _MemFree m
End Function
 
Function DONT_USE_GLH_New_Texture_Handle
    handle&& = 0
    _glGenTextures 1, _Offset(handle&&)
    DONT_USE_GLH_New_Texture_Handle = handle&&
    For h = 1 To UBound(DONT_USE_GLH_Handle)
        If DONT_USE_GLH_Handle(h).in_use = 0 Then
            DONT_USE_GLH_Handle(h).in_use = 1
            DONT_USE_GLH_Handle(h).handle = handle&&
            DONT_USE_GLH_New_Texture_Handle = h
            Exit Function
        End If
    Next
    ReDim _Preserve DONT_USE_GLH_Handle(UBound(DONT_USE_GLH_Handle) * 2) As DONT_USE_GLH_Handle_TYPE
    DONT_USE_GLH_Handle(h).in_use = 1
    DONT_USE_GLH_Handle(h).handle = handle&&
    DONT_USE_GLH_New_Texture_Handle = h
End Function
 
Sub GLH_Select_Texture (texture_handle As Long) 'turn an image handle into a texture handle
    If texture_handle < 1 Or texture_handle > UBound(DONT_USE_GLH_Handle) Then Error 258: Exit Sub
    If DONT_USE_GLH_Handle(texture_handle).in_use = 0 Then Error 258: Exit Sub
    _glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(texture_handle).handle
End Sub
 
 
Function GLH_RGB%& (r As Single, g As Single, b As Single)
    DONT_USE_GLH_COL_RGBA(1) = r
    DONT_USE_GLH_COL_RGBA(2) = g
    DONT_USE_GLH_COL_RGBA(3) = b
    DONT_USE_GLH_COL_RGBA(4) = 1
    GLH_RGB = _Offset(DONT_USE_GLH_COL_RGBA())
End Function
 
Function GLH_RGBA%& (r As Single, g As Single, b As Single, a As Single)
    DONT_USE_GLH_COL_RGBA(1) = r
    DONT_USE_GLH_COL_RGBA(2) = g
    DONT_USE_GLH_COL_RGBA(3) = b
    DONT_USE_GLH_COL_RGBA(4) = a
    GLH_RGBA = _Offset(DONT_USE_GLH_COL_RGBA())
End Function
