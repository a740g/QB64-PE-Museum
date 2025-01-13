Option _Explicit
_Title "Two Triangles - Move with arrows, scale with + or - , press ESC to exit"
' 2024 Haggarman
'
' Flipbook Between Two Perspective Correct Triangles
' Opposing triangles that make a square.
' The point is to stress test the triangle drawing routine, looking for gaps or overdraw or texel weirness.
'
Dim Shared DISP_IMAGE As Long
Dim Shared WORK_IMAGE As Long
Dim Shared Size_Screen_X As Integer, Size_Screen_Y As Integer
Dim Shared Size_Render_X As Integer, Size_Render_Y As Integer

' MODIFY THESE if you want.
Size_Screen_X = 800
Size_Screen_Y = 600
Size_Render_X = Size_Screen_X \ 8 ' render size
Size_Render_Y = Size_Screen_Y \ 8 ' think of it as the number of screen pixels that one rendered pixel takes

DISP_IMAGE = _NewImage(Size_Screen_X, Size_Screen_Y, 32)
Screen DISP_IMAGE
_DisplayOrder _Software

WORK_IMAGE = _NewImage(Size_Render_X, Size_Render_Y, 32)
_DontBlend


Type vec3d
    x As Single
    y As Single
    z As Single
End Type

Type vec4d
    x As Single
    y As Single
    z As Single
    w As Single
End Type

Type vertex5
    x As Single
    y As Single
    w As Single
    u As Single
    v As Single
End Type

' Viewing area clipping
Dim Shared clip_min_y As Long, clip_max_y As Long
Dim Shared clip_min_x As Long, clip_max_x As Long
clip_min_y = 0
clip_max_y = Size_Render_Y - 1
clip_min_x = 0
clip_max_x = Size_Render_X ' not (-1) because rounding rule drops one pixel on right

' Fog color is used as the background color
Dim Shared Fog_color As Long
Fog_color = _RGB32(47, 78, 105)

' Load textures from file
Dim Shared TextureCatalog_lastIndex As Integer
TextureCatalog_lastIndex = 0
Dim Shared TextureCatalog(TextureCatalog_lastIndex) As Long
TextureCatalog(0) = _LoadImage("Origin16x16.png", 32)

' Error _LoadImage returns -1 as an invalid handle if it cannot load the image.
Dim refIndex As Integer
For refIndex = 0 To TextureCatalog_lastIndex
    If TextureCatalog(refIndex) = -1 Then
        Print "Could not load texture file for index: "; refIndex
        End
    End If
Next refIndex

' These T1 Texture characteristics are read later on during drawing.
Dim Shared T1_CatalogIndex As Long
Dim Shared T1_ImageHandle As Long
Dim Shared T1_width As Integer, T1_width_MASK As Integer
Dim Shared T1_height As Integer, T1_height_MASK As Integer
Dim Shared T1_mblock As _MEM
' Give sensible defaults to avoid crashes
' Optimization requires that width and height be powers of 2.
'  That means: 2,4,8,16,32,64,128,256...
T1_SelectCatalogTexture 0

' Screen Scaling
Dim halfWidth As Single
Dim halfHeight As Single
halfWidth = Size_Render_X / 2
halfHeight = Size_Render_Y / 2

' Triangle Vertex List
Dim vertexA As vertex5
Dim vertexB As vertex5
Dim vertexC As vertex5

' code execution time
Dim start_ms As Double
Dim finish_ms As Double

' Main loop stuff
Dim KeyNow As String
Dim ExitCode As Integer
Dim FrameCounter As Long
Dim depth_w As Single
Dim myscale As Single, tri2_yoffset As Single
Dim pin As vec3d

main:
ExitCode = 0
FrameCounter = 0
myscale = 32 ' scale up a "unit right triangle" that is otherwise 0..1

' screen pin location of the triangles
pin.x = 0.0
pin.y = 0.0
pin.z = 1.0 ' cannot be 0


Do
    ' Normally we would project the triangle points from 3D to 2D.
    ' Here we are just hardcoding the values.
    '
    depth_w = 1.0 / pin.z ' w = 1 / z
    tri2_yoffset = myscale + 4.0 ' just a small gap below triangle 1

    start_ms = Timer(.001)

    _Dest WORK_IMAGE
    Cls , Fog_color

    T1_SelectCatalogTexture 0 ' choose the first loaded texture and set the T1_ texture vars

    If FrameCounter < 60 Then

        ' Triangle 1 at Top left /
        vertexA.x = pin.x + 0 * myscale
        vertexA.y = pin.y + 0 * myscale
        vertexA.w = depth_w
        vertexA.u = 0 * T1_width * depth_w
        vertexA.v = 0 * T1_height * depth_w

        vertexB.x = pin.x + 1 * myscale
        vertexB.y = pin.y + 0 * myscale
        vertexB.w = depth_w
        vertexB.u = 1 * T1_width * depth_w
        vertexB.v = 0 * T1_height * depth_w

        vertexC.x = pin.x + 0 * myscale
        vertexC.y = pin.y + 1 * myscale
        vertexC.w = depth_w
        vertexC.u = 0 * T1_width * depth_w
        vertexC.v = 1 * T1_height * depth_w

        TexturedNonlitTriangle vertexA, vertexB, vertexC


        ' Triangle 2 at Bottom left \
        vertexA.x = pin.x + 0 * myscale
        vertexA.y = pin.y + 0 * myscale + tri2_yoffset
        vertexA.w = depth_w
        vertexA.u = 0 * T1_width * depth_w
        vertexA.v = 0 * T1_height * depth_w

        vertexB.x = pin.x + 1 * myscale
        vertexB.y = pin.y + 1 * myscale + tri2_yoffset
        vertexB.w = depth_w
        vertexB.u = 1 * T1_width * depth_w
        vertexB.v = 1 * T1_height * depth_w

        vertexC.x = pin.x + 0 * myscale
        vertexC.y = pin.y + 1 * myscale + tri2_yoffset
        vertexC.w = depth_w
        vertexC.u = 0 * T1_width * depth_w
        vertexC.v = 1 * T1_height * depth_w

        TexturedNonlitTriangle vertexA, vertexB, vertexC

    Else

        ' Triangle 1 at Bottom right /
        vertexA.x = pin.x + 0 * myscale
        vertexA.y = pin.y + 1 * myscale
        vertexA.w = depth_w
        vertexA.u = 0 * T1_width * depth_w
        vertexA.v = 1 * T1_height * depth_w

        vertexB.x = pin.x + 1 * myscale
        vertexB.y = pin.y + 0 * myscale
        vertexB.w = depth_w
        vertexB.u = 1 * T1_width * depth_w
        vertexB.v = 0 * T1_height * depth_w

        vertexC.x = pin.x + 1 * myscale
        vertexC.y = pin.y + 1 * myscale
        vertexC.w = depth_w
        vertexC.u = 1 * T1_width * depth_w
        vertexC.v = 1 * T1_height * depth_w

        TexturedNonlitTriangle vertexA, vertexB, vertexC


        ' Triangle 2 at Top right \
        vertexA.x = pin.x + 0 * myscale
        vertexA.y = pin.y + 0 * myscale + tri2_yoffset
        vertexA.w = depth_w
        vertexA.u = 0 * T1_width * depth_w
        vertexA.v = 0 * T1_height * depth_w

        vertexB.x = pin.x + 1 * myscale
        vertexB.y = pin.y + 0 * myscale + tri2_yoffset
        vertexB.w = depth_w
        vertexB.u = 1 * T1_width * depth_w
        vertexB.v = 0 * T1_height * depth_w

        vertexC.x = pin.x + 1 * myscale
        vertexC.y = pin.y + 1 * myscale + tri2_yoffset
        vertexC.w = depth_w
        vertexC.u = 1 * T1_width * depth_w
        vertexC.v = 1 * T1_height * depth_w

        TexturedNonlitTriangle vertexA, vertexB, vertexC

    End If

    finish_ms = Timer(.001)

    _PutImage , WORK_IMAGE, DISP_IMAGE
    _Dest DISP_IMAGE
    Locate Int(Size_Screen_Y \ 16) - 2, 1
    Color _RGB32(177, 227, 255)
    Print Using "render time #.###"; finish_ms - start_ms
    Color _RGB32(249, 244, 17)
    Print "ESC to exit. ";

    _Limit 60
    _Display

    FrameCounter = FrameCounter + 1
    If FrameCounter >= 120 Then FrameCounter = 0

    KeyNow = UCase$(InKey$)
    If KeyNow <> "" Then

        If Asc(KeyNow) = 27 Then
            ExitCode = 1
        ElseIf KeyNow = "+" Then
            myscale = myscale + 1
        ElseIf KeyNow = "=" Then
            myscale = myscale + 1
        ElseIf KeyNow = "-" Then
            myscale = myscale - 1
        End If
    End If

    If _KeyDown(19712) Then
        ' Right arrow
        pin.x = pin.x + 1.0
    End If

    If _KeyDown(19200) Then
        ' Left arrow
        pin.x = pin.x - 1.0
    End If

    If _KeyDown(18432) Then
        ' Up arrow
        pin.y = pin.y - 1.0
    End If

    If _KeyDown(20480) Then
        ' Down arrow
        pin.y = pin.y + 1.0
    End If

Loop Until ExitCode <> 0


For refIndex = TextureCatalog_lastIndex To 0 Step -1
    _FreeImage TextureCatalog(refIndex)
Next refIndex

End

' u,v texture coords use fencepost counting.
'
'   0    1    2    3    4    u
' 0 +----+----+----+----+
'   |    |    |    |    |
'   |    |    |    |    |
' 1 +----+----+----+----+
'   |    |    |    |    |
'   |    |    |    |    |
' 2 +----+----+----+----+
'   |    |    |    |    |
'   |    |    |    |    |
' 3 +----+----+----+----+
'   |    |    |    |    |
'   |    |    |    |    |
' 4 +----+----+----+----+
'
'
' v

Sub T1_SelectCatalogTexture (texnum As Integer)
    ' Fill in Texture 1 data
    If (texnum >= 0) And (texnum <= TextureCatalog_lastIndex) Then
        T1_CatalogIndex = texnum
    Else
        ' default
        T1_CatalogIndex = 0
    End If
    T1_ImageHandle = TextureCatalog(T1_CatalogIndex)
    T1_mblock = _MemImage(T1_ImageHandle)
    T1_width = _Width(T1_ImageHandle): T1_width_MASK = T1_width - 1
    T1_height = _Height(T1_ImageHandle): T1_height_MASK = T1_height - 1
End Sub

Sub TexturedNonlitTriangle (A As vertex5, B As vertex5, C As vertex5)
    ' this draws texture T1 using point (nearest) sampling
    ' Required Global Vars:
    '  WORK_IMAGE, clip_min_y, clip_max_y, clip_min_x, clip_max_x, Size_Render_X,
    '  T1_mblock, T1_width, T1_width_MASK, T1_height, T1_height_MASK

    Static delta2 As vertex5
    Static delta1 As vertex5
    Static draw_min_y As Long, draw_max_y As Long

    ' Sort so that vertex A is on top and C is on bottom.
    ' This seems inverted from math class, but remember that Y increases in value downward on PC monitors
    If B.y < A.y Then
        Swap A, B
    End If
    If C.y < A.y Then
        Swap A, C
    End If
    If C.y < B.y Then
        Swap B, C
    End If

    ' integer window clipping
    draw_min_y = _Ceil(A.y)
    If draw_min_y < clip_min_y Then draw_min_y = clip_min_y
    draw_max_y = _Ceil(C.y) - 1
    If draw_max_y > clip_max_y Then draw_max_y = clip_max_y
    If (draw_max_y - draw_min_y) < 0 Then Exit Sub

    ' Determine the deltas (lengths)
    ' delta 2 is from A to C (the full triangle height)
    delta2.x = C.x - A.x
    delta2.y = C.y - A.y
    delta2.w = C.w - A.w
    delta2.u = C.u - A.u
    delta2.v = C.v - A.v

    ' Avoiding div by 0
    ' Entire Y height less than 1/256 would not have meaningful pixel color change
    If delta2.y < (1 / 256) Then Exit Sub

    ' Determine vertical Y steps for DDA style math
    ' DDA is Digital Differential Analyzer
    ' It is an accumulator that counts from a known start point to an end point, in equal increments defined by the number of steps in-between.
    ' Probably faster nowadays to do the one division at the start, instead of Bresenham, anyway.
    Static legx1_step As Single
    Static legw1_step As Single, legu1_step As Single, legv1_step As Single

    Static legx2_step As Single
    Static legw2_step As Single, legu2_step As Single, legv2_step As Single

    ' Leg 2 steps from A to C (the full triangle height)
    legx2_step = delta2.x / delta2.y
    legw2_step = delta2.w / delta2.y
    legu2_step = delta2.u / delta2.y
    legv2_step = delta2.v / delta2.y

    ' Leg 1, Draw top to middle
    ' For most triangles, draw downward from the apex A to a knee B.
    ' That knee could be on either the left or right side, but that is handled much later.
    Static draw_middle_y As Long
    draw_middle_y = _Ceil(B.y)
    If draw_middle_y < clip_min_y Then draw_middle_y = clip_min_y
    ' Do not clip B to max_y. Let the y count expire before reaching the knee if it is past bottom of screen.

    ' Leg 1 is from A to B (right now)
    delta1.x = B.x - A.x
    delta1.y = B.y - A.y
    delta1.w = B.w - A.w
    delta1.u = B.u - A.u
    delta1.v = B.v - A.v

    ' If the triangle has no knee, this section gets skipped to avoid divide by 0.
    ' That is okay, because the recalculate Leg 1 from B to C triggers before actually drawing.
    If delta1.y > (1 / 256) Then
        ' Find Leg 1 steps in the y direction from A to B
        legx1_step = delta1.x / delta1.y
        legw1_step = delta1.w / delta1.y
        legu1_step = delta1.u / delta1.y
        legv1_step = delta1.v / delta1.y
    End If

    ' Y Accumulators
    Static leg_x1 As Single
    Static leg_w1 As Single, leg_u1 As Single, leg_v1 As Single

    Static leg_x2 As Single
    Static leg_w2 As Single, leg_u2 As Single, leg_v2 As Single

    ' 11-4-2022 Prestep Y
    Static prestep_y1 As Single
    ' Basically we are sampling pixels on integer exact rows.
    ' But we only are able to know the next row by way of forward interpolation. So always round up.
    ' To get to that next row, we have to prestep by the fractional forward distance from A. _Ceil(A.y) - A.y
    prestep_y1 = draw_min_y - A.y

    leg_x1 = A.x + prestep_y1 * legx1_step
    leg_w1 = A.w + prestep_y1 * legw1_step
    leg_u1 = A.u + prestep_y1 * legu1_step
    leg_v1 = A.v + prestep_y1 * legv1_step

    leg_x2 = A.x + prestep_y1 * legx2_step
    leg_w2 = A.w + prestep_y1 * legw2_step
    leg_u2 = A.u + prestep_y1 * legu2_step
    leg_v2 = A.v + prestep_y1 * legv2_step

    ' Inner loop vars
    Static row As Long
    Static col As Long
    Static draw_max_x As Long
    Static tex_z As Single ' 1/w helper (multiply by inverse is faster than dividing each time)
    Static pixel_value As _Unsigned Long ' The ARGB value to write to screen

    ' Stepping along the X direction
    Static delta_x As Single
    Static prestep_x As Single
    Static tex_w_step As Single, tex_u_step As Single, tex_v_step As Single

    ' X Accumulators
    Static tex_w As Single, tex_u As Single, tex_v As Single

    ' Screen Memory Pointers
    Static screen_mem_info As _MEM
    Static screen_next_row_step As _Offset
    Static screen_row_base As _Offset ' Calculated every row
    Static screen_address As _Offset ' Calculated at every starting column
    screen_mem_info = _MemImage(WORK_IMAGE)
    screen_next_row_step = 4 * Size_Render_X

    ' Row Loop from top to bottom
    row = draw_min_y
    screen_row_base = screen_mem_info.OFFSET + row * screen_next_row_step
    While row <= draw_max_y

        If row = draw_middle_y Then
            ' Reached Leg 1 knee at B, recalculate Leg 1.
            ' This overwrites Leg 1 to be from B to C. Leg 2 just keeps continuing from A to C.
            delta1.x = C.x - B.x
            delta1.y = C.y - B.y
            delta1.w = C.w - B.w
            delta1.u = C.u - B.u
            delta1.v = C.v - B.v

            If delta1.y = 0.0 Then Exit Sub

            ' Full steps in the y direction from B to C
            legx1_step = delta1.x / delta1.y
            legw1_step = delta1.w / delta1.y
            legu1_step = delta1.u / delta1.y
            legv1_step = delta1.v / delta1.y

            ' 11-4-2022 Prestep Y
            ' Most cases has B lower downscreen than A.
            ' B > A usually. Only one case where B = A.
            prestep_y1 = draw_middle_y - B.y

            ' Re-Initialize DDA start values
            leg_x1 = B.x + prestep_y1 * legx1_step
            leg_w1 = B.w + prestep_y1 * legw1_step
            leg_u1 = B.u + prestep_y1 * legu1_step
            leg_v1 = B.v + prestep_y1 * legv1_step

        End If

        ' Horizontal Scanline
        delta_x = Abs(leg_x2 - leg_x1)
        ' Avoid div/0, this gets tiring.
        If delta_x >= (1 / 2048) Then
            ' Calculate step, start, and end values.
            ' Drawing left to right, as in incrementing from a lower to higher memory address, is usually fastest.
            If leg_x1 < leg_x2 Then
                ' leg 1 is on the left
                tex_w_step = (leg_w2 - leg_w1) / delta_x
                tex_u_step = (leg_u2 - leg_u1) / delta_x
                tex_v_step = (leg_v2 - leg_v1) / delta_x

                ' Set the horizontal starting point to (1)
                col = _Ceil(leg_x1)
                If col < clip_min_x Then col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x1
                tex_w = leg_w1 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u1 + prestep_x * tex_u_step
                tex_v = leg_v1 + prestep_x * tex_v_step

                ' ending point is (2)
                draw_max_x = _Ceil(leg_x2)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            Else
                ' Things are flipped. leg 1 is on the right.
                tex_w_step = (leg_w1 - leg_w2) / delta_x
                tex_u_step = (leg_u1 - leg_u2) / delta_x
                tex_v_step = (leg_v1 - leg_v2) / delta_x

                ' Set the horizontal starting point to (2)
                col = _Ceil(leg_x2)
                If col < clip_min_x Then col = clip_min_x

                ' Prestep to find pixel starting point
                prestep_x = col - leg_x2
                tex_w = leg_w2 + prestep_x * tex_w_step
                tex_z = 1 / tex_w ' this can be absorbed
                tex_u = leg_u2 + prestep_x * tex_u_step
                tex_v = leg_v2 + prestep_x * tex_v_step

                ' ending point is (1)
                draw_max_x = _Ceil(leg_x1)
                If draw_max_x > clip_max_x Then draw_max_x = clip_max_x

            End If

            ' Draw the Horizontal Scanline
            ' Optimization: before entering this loop, must have done tex_z = 1 / tex_w
            screen_address = screen_row_base + 4 * col
            While col < draw_max_x

                Static cc As Integer
                Static rr As Integer

                ' Relies on some shared T1 variables over by Texture1
                Static T1_address_pointer As _Offset

                Static cm5 As Single
                Static rm5 As Single

                ' Recover U and V
                cm5 = (tex_u * tex_z)
                rm5 = (tex_v * tex_z)

                ' clamp
                If cm5 < 0.0 Then cm5 = 0.0
                If cm5 >= T1_width_MASK Then
                    ' 15.0 and up
                    cc = T1_width_MASK
                Else
                    ' 0 1 2 .. 13 14.999
                    cc = Int(cm5)
                End If

                ' clamp
                If rm5 < 0.0 Then rm5 = 0.0
                If rm5 >= T1_height_MASK Then
                    ' 15.0 and up
                    rr = T1_height_MASK
                Else
                    rr = Int(rm5)
                End If

                'uv_0_0 = Texture1(cc, rr)
                T1_address_pointer = T1_mblock.OFFSET + (cc + rr * T1_width) * 4
                _MemGet T1_mblock, T1_address_pointer, pixel_value

                _MemPut screen_mem_info, screen_address, pixel_value
                'PSet (col, row), pixel_value

                tex_w = tex_w + tex_w_step
                tex_z = 1 / tex_w ' execution time for this can be absorbed when result not required immediately
                tex_u = tex_u + tex_u_step
                tex_v = tex_v + tex_v_step
                screen_address = screen_address + 4
                col = col + 1
            Wend ' col

        End If ' end div/0 avoidance

        ' DDA next step
        leg_x1 = leg_x1 + legx1_step
        leg_w1 = leg_w1 + legw1_step
        leg_u1 = leg_u1 + legu1_step
        leg_v1 = leg_v1 + legv1_step

        leg_x2 = leg_x2 + legx2_step
        leg_w2 = leg_w2 + legw2_step
        leg_u2 = leg_u2 + legu2_step
        leg_v2 = leg_v2 + legv2_step

        screen_row_base = screen_row_base + screen_next_row_step
        row = row + 1
    Wend ' row

End Sub

