' This example shows how models with textures or materials can be displayed with OpenGL using QB64
'
'IMPORTANT:
' Whilst the .X file loader is optimized for speed, it is very incomplete:
'  -only .X files in text file format
'  -only one object, not a cluster of objects
'  -if using a texture, use a single texture which will be applied to all materials
'  -all the 3D models in this example were exported from Blender, a free 3D creation tool
'   Blender tips: CTRL+J to amalgamate objects, select object to export first, in the UV/image-editor
'                 window you can export the textures built into your .blend file, apply the decimate
'                 modifier to reduce your polygon count to below 10000, preferably ~3000 or less
' This program is not a definitive guide to OpenGL in any way
' The GLH functions are something I threw together to stop people crashing their code by making
'  calls to OpenGL with incorrectly sized memory regions. The GLH... prefixed commands are not mandatory or
'  part of QB64, nor do they represent a complete library of helper commands.
' Lighting is not this example's strongest point, there's probably some work to do on light positioning
'  and vertex normals
'
'Finally, I hope you enjoy this program as much as I enjoyed piecing it together,
' Galleon

'###################################### GLH SETUP #############################################

'Used to manage textures
Type DONT_USE_GLH_Handle_TYPE
    in_use As _Byte
    handle As Long
End Type

'Used by GLH RGB/etc helper functions
Dim Shared DONT_USE_GLH_COL_RGBA(1 To 4) As Single

ReDim Shared DONT_USE_GLH_Handle(1000) As DONT_USE_GLH_Handle_TYPE

'.X Format Model Loading Data
Type VERTEX_TYPE
    X As Double
    Y As Double
    Z As Double
    NX As Double
    NY As Double
    NZ As Double
End Type
ReDim Shared VERTEX(1) As VERTEX_TYPE
Dim Shared VERTICES As Long
Type FACE_CORNER_TYPE
    V As Long 'the vertex index
    TX As Single 'texture X coordinate
    TY As Single 'texture Y coordinate
End Type
Type FACE_TYPE
    V1 As FACE_CORNER_TYPE
    V2 As FACE_CORNER_TYPE
    V3 As FACE_CORNER_TYPE
    Material As Long
    Index As Long
End Type
ReDim Shared FACE(1) As FACE_TYPE
Dim Shared FACES As Long
Type MATERIAL_RGBAI_TYPE
    R As Single
    G As Single
    B As Single
    A As Single
    Intensity As Single
End Type
Type MATERIAL_TYPE
    Diffuse As MATERIAL_RGBAI_TYPE 'regular col
    Specular As MATERIAL_RGBAI_TYPE 'hightlight/shine col
    Texture_Image As Long 'both an image and a texture handle are held
    Texture As Long 'if 0, there is no texture
End Type
ReDim Shared MATERIAL(1) As MATERIAL_TYPE
Dim Shared MATERIALS As Long

'##############################################################################################

Dim Shared AllowSubGL

Screen _NewImage(1024, 768, 32)

backdrop = _LoadImage("backdrop_tron.png")

Dim Shared rot1
Dim Shared rot2, rot3
Dim Shared scale: scale = 1

'Load (default) model
GLH_Load_Model_Format_X "marty.x", "marty_tmap.png"
'draw backdrop
_PutImage , backdrop: _DontBlend: Line (200, 200)-(500, 500), _RGBA(0, 255, 255, 0), BF: _Blend

AllowSubGL = 1

Do
    'This is our program's main loop
    _Limit 100
    Locate 1, 1
    Print "Mouse Input:"
    Print "{Horizonal Movement}Spin"
    Print "{Vertical Movement}Flip"
    Print "{Wheel}Scale"
    Print
    Print "Keyboard comands:"
    Print "Switch rendering order: {1}GL behind, {2}GL on top, {3}GL only, good for speed"
    Print "Switch/Load model: {A}Zebra, {B}Pig, {C}Car"

    k$ = InKey$
    If k$ = "1" Then _GLRender _Behind
    If k$ = "2" Then _GLRender _OnTop
    If k$ = "3" Then _GLRender _Only


    Print "Angles:"; rot1, rot2, rot3


    If UCase$(k$) = "A" Then
        AllowSubGL = 0
        GLH_Load_Model_Format_X "marty.x", "marty_tmap.png"
        _PutImage , backdrop: _DontBlend: Line (200, 200)-(500, 500), _RGBA(0, 255, 255, 0), BF: _Blend
        AllowSubGL = 1
    End If

    If UCase$(k$) = "B" Then
        AllowSubGL = 0
        GLH_Load_Model_Format_X "piggy_mini3.x", ""
        _PutImage , backdrop: _DontBlend: Line (200, 200)-(500, 500), _RGBA(0, 255, 255, 0), BF: _Blend
        AllowSubGL = 1
    End If

    If UCase$(k$) = "C" Then
        AllowSubGL = 0
        GLH_Load_Model_Format_X "gasprin.x", "gasprin_tmap.png"
        _PutImage , backdrop: _DontBlend: Line (200, 200)-(500, 500), _RGBA(0, 255, 255, 0), BF: _Blend
        AllowSubGL = 1
    End If

    Do While _MouseInput
        scale = scale * (1 - (_MouseWheel * .1))
        rot1 = _MouseX
        rot2 = _MouseY
    Loop

    If k$ = "." Then rot3 = rot3 + 1
    If k$ = "," Then rot3 = rot3 - 1




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
        '...
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

    _glMatrixMode _GL_MODELVIEW 'Select The Modelview Matrix
    _glLoadIdentity 'Reset The Modelview Matrix



    'setup our light
    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0
    _glLightfv _GL_LIGHT0, _GL_DIFFUSE, GLH_RGB(.8, .8, .8)
    _glLightfv _GL_LIGHT0, _GL_AMBIENT, GLH_RGB(0.1, 0.1, 0.1)
    _glLightfv _GL_LIGHT0, _GL_SPECULAR, GLH_RGB(0.3, 0.3, 0.3)

    light_rot = light_rot + ET#
    _glLightfv _GL_LIGHT0, _GL_POSITION, GLH_RGBA(Sin(light_rot) * 20, Cos(light_rot) * 20, 20, 1)


    _glTranslatef 0, 0, -20 'Translate Into The Screen
    _glRotatef rot1, 0, 1, 0
    _glRotatef rot2, 1, 0, 0
    _glRotatef rot3, 0, 0, 1



    current_m = -1
    For F = 1 To FACES

        m = FACE(F).Material
        If m <> current_m Then 'we don't switch materials unless we have to
            If current_m <> -1 Then _glEnd 'stop rendering triangles so we can change some settings
            current_m = m
            If MATERIAL(m).Texture_Image Then

                _glEnable _GL_TEXTURE_2D
                _glDisable _GL_COLOR_MATERIAL
                _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR 'seems these need to be respecified
                _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_LINEAR


                If MATERIAL(m).Texture = 0 Then
                    MATERIAL(m).Texture = GLH_Image_to_Texture(MATERIAL(m).Texture_Image)
                End If
                GLH_Select_Texture MATERIAL(m).Texture

                _glMaterialfv _GL_FRONT, _GL_DIFFUSE, GLH_RGBA(1, 1, 1, 1)

            Else
                'use materials, disable textures
                _glDisable _GL_TEXTURE_2D
                _glDisable _GL_COLOR_MATERIAL

                mult = MATERIAL(m).Diffuse.Intensity 'otherwise known as "power"
                r = MATERIAL(m).Diffuse.R * mult
                g = MATERIAL(m).Diffuse.G * mult
                b = MATERIAL(m).Diffuse.B * mult
                '            _glColor3f r, g, b
                _glMaterialfv _GL_FRONT, _GL_DIFFUSE, GLH_RGBA(r, g, b, 1)

                mult = MATERIAL(m).Specular.Intensity
                r = MATERIAL(m).Specular.R * mult
                g = MATERIAL(m).Specular.G * mult
                b = MATERIAL(m).Specular.B * mult
                _glMaterialfv _GL_FRONT, _GL_SPECULAR, GLH_RGBA(r, g, b, 1)

            End If

            _glBegin _GL_TRIANGLES

        End If

        For s = 1 To 3

            If s = 1 Then v = FACE(F).V1.V
            If s = 2 Then v = FACE(F).V2.V
            If s = 3 Then v = FACE(F).V3.V
            v = v + 1

            'vertex
            x = (VERTEX(v).X + 0) * scale
            y = (VERTEX(v).Y + 0) * scale
            z = (VERTEX(v).Z + 0) * scale
            'normal direction from vertex
            nx = VERTEX(v).NX: ny = VERTEX(v).NY: nz = VERTEX(v).NZ


            'corner's texture coordinates
            If MATERIAL(m).Texture Then
                If s = 1 Then tx = FACE(F).V1.TX: ty = FACE(F).V1.TY
                If s = 2 Then tx = FACE(F).V2.TX: ty = FACE(F).V2.TY
                If s = 3 Then tx = FACE(F).V3.TX: ty = FACE(F).V3.TY
                _glTexCoord2f tx, ty
            End If

            _glNormal3d nx, my, nz
            _glVertex3f x, y, z

        Next

    Next
    _glEnd

End Sub



'QB64 OPEN-GL HELPER MACROS (aka. GLH macros) #######################################################################

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




Sub GLH_Load_Model_Format_X (Filename$, Optional_Texture_Filename$)

    _AutoDisplay 'so loading messages can be seen

    DefLng A-Z

    If Len(Optional_Texture_Filename$) Then
        texture_image = _LoadImage(Optional_Texture_Filename$, 32)
        If texure_image = -1 Then texure_image = 0
    End If

    'temporary arrays
    Dim SIDE_LIST(10000) As Long 'used for wrangling triangle-fans/triangle-strips
    ReDim TEXCO_TX(1) As Single
    ReDim TEXCO_TY(1) As Single
    ReDim POLY_FACE_INDEX_FIRST(1) As Long
    ReDim POLY_FACE_INDEX_LAST(1) As Long

    'buffer file
    fh = FreeFile: Open Filename$ For Binary As #fh: file_data$ = Space$(LOF(fh)): Get #fh, , file_data$: Close #fh

    file_x = 1
    file_data$ = UCase$(file_data$)

    ASC_COMMA = 44
    ASC_SEMICOLON = 59
    ASC_LBRAC = 123
    ASC_RBRAC = 125
    ASC_SPACE = 32
    ASC_TAB = 9
    ASC_CR = 13
    ASC_LF = 10
    ASC_FSLASH = 47
    ASC_DOT = 46
    ASC_MINUS = 45

    Dim WhiteSpace(255) As Long
    WhiteSpace(ASC_LF) = -1
    WhiteSpace(ASC_CR) = -1
    WhiteSpace(ASC_SPACE) = -1
    WhiteSpace(ASC_TAB) = -1

    Dim FormattingCharacter(255) As Long
    FormattingCharacter(ASC_COMMA) = -1
    FormattingCharacter(ASC_SEMICOLON) = -1
    FormattingCharacter(ASC_LBRAC) = -1
    FormattingCharacter(ASC_RBRAC) = -1

    Dim Numeric(255) As Long
    For a = 48 To 57
        Numeric(a) = -1
    Next
    Numeric(ASC_DOT) = -1
    Numeric(ASC_MINUS) = -1

    Print "Loading model:"

    Do

        skip_comment:

        'find start of element
        x1 = -1
        For x = file_x To Len(file_data$)
            If WhiteSpace(Asc(file_data$, x)) = 0 Then x1 = x: Exit For
        Next
        If x1 = -1 Then Exit Do 'no more data

        a = Asc(file_data$, x1)
        If a = ASC_FSLASH Then 'commend
            If Asc(file_data$, x1 + 1) = ASC_FSLASH Then
                For x = x1 To Len(file_data$)
                    a = Asc(file_data$, x)
                    If a = ASC_CR Or a = ASC_LF Then file_x = x + 1: GoTo skip_comment '//.....
                Next
            End If
        End If

        'find end of element
        x2 = x1
        For x = x1 To Len(file_data$)
            a = Asc(file_data$, x)
            If WhiteSpace(a) Then
                If a = ASC_CR Or a = ASC_LF Then Exit For 'it is the end
            Else
                'not whitespace
                If FormattingCharacter(a) Then Exit For
                x2 = x
            End If
        Next
        file_x = x2 + 1

        a2$ = Mid$(file_data$, x1, x2 - x1 + 1)

        If Len(skip_until$) Then
            If a2$ <> skip_until$ Then GoTo skip_comment
            skip_until$ = ""
        End If



        a = Asc(a2$)

        If Numeric(a) And a <> ASC_DOT Then 'faster than VAL, value conversion
            v = 0
            dp = 0
            div = 1
            If a = ASC_MINUS Then neg = 1: x1 = 2 Else neg = 0: x1 = 1
            For x = x1 To Len(a2$)
                a2 = Asc(a2$, x)
                If a2 = ASC_DOT Then
                    dp = 1
                Else
                    v = v * 10 + (a2 - 48)
                    If dp Then div = div * 10
                End If
            Next

            If dp = 1 Then
                v# = v
                div# = div
                If neg Then value# = (-v#) / div# Else value# = v# / div#
            Else
                If neg Then value# = -v Else value# = v
            End If

        End If

        If face_input Then
            If face_input = 3 Then
                If a2$ = ";" Then
                    If last_a2$ = ";" Then face_input = 0
                    SLI = SLI + 1
                ElseIf a2$ = "," Then
                    face_input = 2
                    polygon = polygon + 1
                Else
                    SIDE_LIST(SLI) = value#
                    If SLI >= 3 Then
                        FACES = FACES + 1
                        If FACES > UBound(FACE) Then ReDim _Preserve FACE(UBound(FACE) * 2) As FACE_TYPE
                        FACE(FACES).V1.V = SIDE_LIST(1)
                        FACE(FACES).V2.V = SIDE_LIST(SLI - 1)
                        FACE(FACES).V3.V = SIDE_LIST(SLI)
                        If POLY_FACE_INDEX_FIRST(polygon) = 0 Then POLY_FACE_INDEX_FIRST(polygon) = FACES
                        POLY_FACE_INDEX_LAST(polygon) = FACES
                        FACE(FACES).Index = polygon
                    End If

                    file_x = file_x + 1: a2$ = ";": a = ASC_SEMICOLON: SLI = SLI + 1


                End If
                GoTo done
            End If
            If face_input = 2 Then
                SIDES = value#
                SLI = 0
                face_input = 3
                GoTo done
            End If
            If face_input = 1 Then
                POLYGONS = value#
                ReDim _Preserve FACE(POLYGONS * 4) As FACE_TYPE 'estimate triangles in polygons
                ReDim POLY_FACE_INDEX_FIRST(POLYGONS) As Long
                ReDim POLY_FACE_INDEX_LAST(POLYGONS) As Long
                polygon = 1
                face_input = 2
                FACES = 0
                GoTo done
            End If
        End If

        If mesh_input Then
            If mesh_input = 5 Then
                If a = ASC_SEMICOLON Then
                    mesh_input = 0: face_input = 1
                    If normals_input = 1 Then
                        face_input = 0 'face input is unrequired on 2nd pass
                        skip_until$ = "MESHMATERIALLIST"
                    End If
                End If
                GoTo done
            End If
            If mesh_input = 4 Then
                If a = ASC_SEMICOLON Then
                    'ignore
                ElseIf a = ASC_COMMA Then
                    vertex = vertex + 1
                Else
                    If normals_input = 1 Then
                        If plane = 1 Then VERTEX(vertex).NX = value#
                        If plane = 2 Then VERTEX(vertex).NY = value#
                        If plane = 3 Then VERTEX(vertex).NZ = value#
                    Else
                        If plane = 1 Then VERTEX(vertex).X = value#
                        If plane = 2 Then VERTEX(vertex).Y = value#
                        If plane = 3 Then VERTEX(vertex).Z = value#
                    End If

                    plane = plane + 1
                    If plane = 4 Then
                        plane = 1
                        If vertex = VERTICES Then mesh_input = 5
                    End If

                    file_x = file_x + 1 'skip next character (semicolon)

                End If
                GoTo done
            End If
            If mesh_input = 3 Then
                If a2$ = ";" Then mesh_input = 4
                GoTo done
            End If
            If mesh_input = 2 Then
                VERTICES = value#
                If normals_input = 0 Then
                    ReDim VERTEX(VERTICES) As VERTEX_TYPE
                    ReDim TEXCO_TX(VERTICES) As Single
                    ReDim TEXCO_TY(VERTICES) As Single
                End If
                mesh_input = 3
                GoTo done
            End If
            If mesh_input = 1 Then
                If a2$ = "{" Then mesh_input = 2: plane = 1: vertex = 1
                GoTo done
            End If
            GoTo done
        End If

        If matlist_input Then
            If matlist_input = 6 Then
                If a2$ = "," Then
                    'do nothing
                ElseIf a2$ = ";" Then
                    matlist_input = 0
                Else
                    polygon = polygon + 1: m = value#
                    For f = POLY_FACE_INDEX_FIRST(polygon) To POLY_FACE_INDEX_LAST(polygon)
                        FACE(f).Material = m + 1
                    Next
                End If
                GoTo done
            End If
            If matlist_input = 5 And a2$ = ";" Then matlist_input = 6: polygon = 0: face_search_start = 1: GoTo done
            If matlist_input = 4 Then matlist_input = 5: GoTo done
            If matlist_input = 3 And a2$ = ";" Then matlist_input = 4: GoTo done
            If matlist_input = 2 Then MATERIALS = value#: ReDim MATERIAL(MATERIALS) As MATERIAL_TYPE: matlist_input = 3: GoTo done
            If matlist_input = 1 And a2$ = "{" Then matlist_input = 2: GoTo done
            GoTo done
        End If

        If material_input Then
            If material_input = 2 Then
                If a2$ = ";" Then
                    'do nothing
                ElseIf a2$ = "}" Then
                    material_input = 0
                Else
                    N = material_n
                    If N = 1 Then MATERIAL(MATERIAL).Diffuse.R = value#
                    If N = 2 Then MATERIAL(MATERIAL).Diffuse.G = value#
                    If N = 3 Then MATERIAL(MATERIAL).Diffuse.B = value#
                    If N = 4 Then MATERIAL(MATERIAL).Diffuse.A = value#
                    If N = 5 Then MATERIAL(MATERIAL).Diffuse.Intensity = value# / 100
                    If N = 6 Then MATERIAL(MATERIAL).Specular.R = value#
                    If N = 7 Then MATERIAL(MATERIAL).Specular.G = value#
                    If N = 8 Then MATERIAL(MATERIAL).Specular.B = value#
                    If N = 9 Then MATERIAL(MATERIAL).Specular.A = value#
                    If N = 10 Then MATERIAL(MATERIAL).Specular.Intensity = MATERIAL(MATERIAL).Diffuse.Intensity

                    'if texture_image
                    material_n = N + 1

                End If
                GoTo done
            End If
            If material_input = 1 And a2$ = "{" Then material_input = 2: material_n = 1: GoTo done
            GoTo done
        End If

        If texco_input Then
            If texco_input = 4 Then
                If a2$ = ";" Then
                    If last_a2$ = ";" Then
                        texco_input = 0
                        GoTo finished
                    End If
                    plane = plane + 1: If plane = 3 Then plane = 1
                ElseIf a2$ = "," Then
                    vertex = vertex + 1
                Else
                    If plane = 1 Then
                        TEXCO_TX(vertex) = value#
                    Else
                        TEXCO_TY(vertex) = value#
                    End If
                End If
                GoTo done
            End If
            If texco_input = 3 Then
                If a2$ = ";" Then texco_input = 4: plane = 1: vertex = 1
                GoTo done
            End If
            If texco_input = 2 Then
                'vertices already known
                texco_input = 3
                GoTo done
            End If
            If texco_input = 1 Then
                If a2$ = "{" Then texco_input = 2
                GoTo done
            End If

            GoTo done
        End If

        'mode switch?
        If a2$ = "MESHTEXTURECOORDS" Then texco_input = 1: Print "[Texture Coordinates]";: GoTo done
        If a2$ = "MESHNORMALS" Then normals_input = 1: mesh_input = 1: face_input = 0: Print "[Normals]";: GoTo done
        If a2$ = "MESH" Then mesh_input = 1: Print "[Mesh Vertices & Faces]";: GoTo done
        If a2$ = "MESHMATERIALLIST" Then matlist_input = 1: Print "[Face Material Indexes]";: GoTo done
        If Left$(a2$, 9) = "MATERIAL " Then
            material_input = 1: MATERIAL = MATERIAL + 1
            MATERIAL(MATERIAL).Texture = 0: MATERIAL(MATERIAL).Texture_Image = texture_image
            Print "[Material]";: GoTo done
        End If
        done:

        progress = progress + 1: If progress > 5000 Then Print ".";: progress = 0

        If a = ASC_SEMICOLON Then
            last_a2$ = a2$
        Else
            If Len(last_a2$) Then last_a2$ = ""
        End If

    Loop
    finished:
    'change texture coords (with are organised per vertex to be organised by face side
    'that way one vertex can share multiple materials without duplicating the vertex
    Print "[Attaching Texture Coordinates to Face Cornders]";
    f = 1
    Do Until f > FACES
        v = FACE(f).V1.V + 1: FACE(f).V1.TX = TEXCO_TX(v): FACE(f).V1.TY = TEXCO_TY(v)
        v = FACE(f).V2.V + 1: FACE(f).V2.TX = TEXCO_TX(v): FACE(f).V2.TY = TEXCO_TY(v)
        v = FACE(f).V3.V + 1: FACE(f).V3.TX = TEXCO_TX(v): FACE(f).V3.TY = TEXCO_TY(v)
        f = f + 1
    Loop
    Print
    Print "Model loaded!"

    DefSng A-Z

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

