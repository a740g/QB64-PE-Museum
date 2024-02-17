Dim Shared AllowSubGL 'we'll set this after we finish our setup immediately below, just in case
'there is anything here (there isn't currently though) that SUB _GL will depend on

Type DONT_USE_GLH_Handle_TYPE
    in_use As _Byte
    handle As Long
End Type
ReDim Shared DONT_USE_GLH_Handle(1000) As DONT_USE_GLH_Handle_TYPE


Screen _NewImage(1024, 768, 32)



backdrop = _LoadImage("xcom_backdrop.jpg")
_PutImage , backdrop
_FreeImage backdrop

_DontBlend
Line (200, 200)-(500, 500), _RGBA(0, 255, 255, 0), BF 'create a see-through window (press 1)
_Blend

AllowSubGL = 1

Do
    'This is our program's main loop
    _Limit 100
    Locate 1, 1
    c = c + 1: Print "Mainloop has done nothing"; c; "times"
    Print "Press 1[GL behind], 2[GL on top] or 3[GL only, good for speed] to switch rendering order."
    k$ = InKey$
    If k$ = "1" Then _GLRender _Behind
    If k$ = "2" Then _GLRender _OnTop
    If k$ = "3" Then _GLRender _Only
Loop Until k$ = Chr$(27)
End

'this specially named sub "_GL" is detected by QB64 and adds support for OpenGL commands
'it is called automatically whenever the underlying software deems an update is possible
'usually/ideally, this is in sync with your monitor's refresh rate
Sub _GL Static
    'STATIC was used above to make all variables in this sub maintain their values between calls to this sub

    If AllowSubGL = 0 Then Exit Sub 'we aren't ready yet!

    'timing is everything, we don't know how fast the 3D renderer will call this sub to we use timers to smooth things out
    T# = Timer(0.001)
    If ETT# = 0 Then ETT# = T#
    ET# = T# - ETT#
    ETT# = T#

    If sub_gl_called = 0 Then
        sub_gl_called = 1 'we only need to perform the following code once
        i = _LoadImage("xcom256.png", 32)
        mytex = GLH_Image_to_Texture(i) 'this helper function converts the image to a texture
        _FreeImage i
    End If

    'These settings affect how OpenGL will render our content
    '!!! THESE SETTINGS ARE TO SHOW HOW ALPHA CAN WORK, BUT IT IS 10x FASTER WHEN ALPHA OPTIONS ARE DISABLED !!!
    '*** every setting must be reset because SUB _GL cannot guarantee settings have not changed since last time ***
    _glMatrixMode _GL_PROJECTION 'Select The Projection Matrix
    _glLoadIdentity 'Reset The Projection Matrix
    _gluPerspective 45, _Width(0) / _Height(0), 1, 100 'QB64 internally supports this GLU command for convenience sake, but does not support GLU
    _glEnable _GL_TEXTURE_2D
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA 'how alpha values are interpretted
    _glEnable _GL_DEPTH_TEST 'use the zbuffer
    _glDepthMask _GL_TRUE
    _glAlphaFunc _GL_GREATER, 0.5 'dont do anything if alpha isn't greater than 0.5 (or 128)
    _glEnable _GL_ALPHA_TEST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_LINEAR
    '**************************************************************************************************************


    GLH_Select_Texture mytex

    _glMatrixMode _GL_MODELVIEW 'Select The Modelview Matrix
    _glLoadIdentity 'Reset The Modelview Matrix
    _glTranslatef 0, 0, -10 'Translate Into The Screen

    _glRotatef rotation1, 0, 1, 0 'spin, spin, spin...
    _glRotatef rotation2, 1, 0, 0

    _glBegin _GL_QUADS 'we will be drawing rectangles aka. QUADs
    _glTexCoord2f 0, 0: _glVertex3f 0, 0, 4 'the texture position and the position in 3D space of a vertex
    _glTexCoord2f 1, 0: _glVertex3f 5, 0, 4
    _glTexCoord2f 1, 1: _glVertex3f 5, -5, 4
    _glTexCoord2f 0, 1: _glVertex3f 0, -5, 4
    _glEnd

    Randomize Using 1 'generate the same set of random numbers each time
    _glBegin _GL_TRIANGLES 'the png (almost) only consumes a triangular region of its rectangle
    For t = 1 To 10
        _glTexCoord2f 0, 0: _glVertex3f Rnd * 6 - 3, Rnd * 6 - 3, Rnd * 6 - 3
        _glTexCoord2f 1, 0: _glVertex3f Rnd * 6 - 3, Rnd * 6 - 3, Rnd * 6 - 3
        _glTexCoord2f 0.5, 1: _glVertex3f Rnd * 6 - 3, Rnd * 6 - 3, Rnd * 6 - 3
    Next
    _glEnd

    rotation1 = rotation1 + 100 * ET#
    rotation2 = rotation2 + 200 * ET#

End Sub



'QB64 OPEN-GL HELPER MACROS (aka. GLH macros)

Sub GLH_Select_Texture (texture_handle As Long) 'turn an image handle into a texture handle
    If texture_handle < 1 Or texture_handle > UBound(DONT_USE_GLH_Handle) Then Error 258: Exit Sub
    If DONT_USE_GLH_Handle(texture_handle).in_use = 0 Then Error 258: Exit Sub
    _glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(texture_handle).handle
End Sub

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

