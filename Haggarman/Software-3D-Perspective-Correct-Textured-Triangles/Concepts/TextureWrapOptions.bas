' 2023 Haggarman
' 6/19/2023 Version 7
Option _Explicit
_Title "Texture Wrap Options - Press 1 2 3 4 5 or press ESC to exit"
Screen _NewImage(800, 600, 32)

' These are read from a sub later on, named ReadTexel
Dim Shared T1_width As Integer, T1_width_MASK As Integer, T1_width_mirror As Integer
Dim Shared T1_height As Integer, T1_height_MASK As Integer, T1_height_mirror As Integer
Dim Shared T1_Filter_Selection As Integer
Dim Shared Texture_options As _Unsigned Long
Const T1_option_clamp_width = 1
Const T1_option_clamp_height = 2
Const T1_option_mirror_width = 4
Const T1_option_mirror_height = 8

' Later optimization in ReadTexel requires these to be powers of 2.
' That means: 2,4,8,16,32,64,128,256...
T1_width = 16: T1_width_MASK = T1_width - 1: T1_width_mirror = T1_width + T1_width_MASK
T1_height = 16: T1_height_MASK = T1_height - 1: T1_height_mirror = T1_height + T1_height_MASK
Dim Shared Texture1(T1_width_MASK, T1_height_MASK) As _Unsigned Long

' Load Texture1 Array from Data
Restore Texture1Data

Dim dvalue As _Unsigned Long
Dim row As Integer, col As Integer
For row = 0 To T1_height_MASK
    For col = 0 To T1_width_MASK
        Read dvalue
        Texture1(col, row) = dvalue
        'PSet (col, row), dvalue
    Next col
Next row
_Display

' scale view
Dim x_zero_pixel As Single, x_pixels_per_div As Single, x_scaledown As Single
Dim y_zero_pixel As Single, y_pixels_per_div As Single, y_scaledown As Single

x_zero_pixel = 400 - 100
x_pixels_per_div = _Width / 4.0
x_scaledown = 4.0 / _Width

y_zero_pixel = 300 - 100
y_pixels_per_div = _Height / -3.0
y_scaledown = 3.0 / _Height

' dependent inner loop vars
Dim k$
Dim X As Single, Y As Single
T1_Filter_Selection = 0
Texture_options = T1_option_clamp_height

Do
    For row = 0 To _Height - 1
        For col = 0 To _Width - 1
            X = (col - x_zero_pixel) * x_scaledown
            Y = (row - y_zero_pixel) * y_scaledown

            dvalue = ReadTexel&(X * T1_width, Y * T1_height)
            PSet (col, row), dvalue

        Next col
    Next row

    ' gridlines
    Dim grid_color As _Unsigned Long
    grid_color = _RGB(28, 28, 28)

    Line (x_zero_pixel, 0)-(x_zero_pixel, _Height), grid_color
    Line (x_zero_pixel - x_pixels_per_div, 0)-(x_zero_pixel - x_pixels_per_div, _Height), grid_color, , &HCCCC
    Line (x_zero_pixel + x_pixels_per_div, 0)-(x_zero_pixel + x_pixels_per_div, _Height), grid_color, , &HCCCC

    Line (0, y_zero_pixel)-(_Width, y_zero_pixel), grid_color
    Line (0, y_zero_pixel - y_pixels_per_div)-(_Width, y_zero_pixel - y_pixels_per_div), grid_color, , &HCCCC
    Line (0, y_zero_pixel + y_pixels_per_div)-(_Width, y_zero_pixel + y_pixels_per_div), grid_color, , &HCCCC

    _Limit 20
    _Display

    k$ = InKey$
    If k$ = "1" Then
        Texture_options = Texture_options Xor T1_option_clamp_width
    ElseIf k$ = "2" Then
        Texture_options = Texture_options Xor T1_option_clamp_height
    ElseIf k$ = "3" Then
        T1_Filter_Selection = T1_Filter_Selection + 1
        If T1_Filter_Selection > 2 Then T1_Filter_Selection = 0
    ElseIf k$ = "4" Then
        Texture_options = Texture_options Xor T1_option_mirror_width
    ElseIf k$ = "5" Then
        Texture_options = Texture_options Xor T1_option_mirror_height
    End If
Loop Until k$ = Chr$(27)

End

'Texture1Data:
'Grass_Block_side', 16x16px
Data &HFF517b46,&HFF45693c,&HFF486d3e,&HFF43663a,&HFF517b46,&HFF45693c,&HFF517b46,&HFF486d3e,&HFF486d3e,&HFF4c7442,&HFF517b46,&HFF4c7442,&HFF55814a,&HFF3d5e36,&HFF4c7442,&HFF486d3e
Data &HFF517b46,&HFF43663a,&HFF517b46,&HFF45693c,&HFF55814a,&HFF593d29,&HFF517b46,&HFF3e5e36,&HFF55814a,&HFF486d3e,&HFF517b46,&HFF466b3d,&HFF517b46,&HFF43663a,&HFF517b46,&HFF42653a
Data &HFF486d3e,&HFF593d29,&HFF55814a,&HFF3f6037,&HFF517b46,&HFF593d29,&HFF45693c,&HFF593d29,&HFF517b46,&HFF4c7442,&HFF486d3e,&HFF527e48,&HFF593d29,&HFF395631,&HFF486d3e,&HFF593d29
Data &HFF593d29,&HFF6c6c6c,&HFF593d29,&HFF593d29,&HFF45693c,&HFF593d29,&HFF593d29,&HFF593d29,&HFF3d5c35,&HFF593d29,&HFF43663b,&HFF593d29,&HFF79553a,&HFF593d29,&HFF593d29,&HFF79553a
Data &HFF966c4a,&HFF79553a,&HFF966c4a,&HFFb9855c,&HFF593d29,&HFF966c4a,&HFF79553a,&HFF79553a,&HFF593d29,&HFF593d29,&HFF593d29,&HFF6c6c6c,&HFF79553a,&HFF966c4a,&HFF593d29,&HFF79553a
Data &HFF79553a,&HFF593d29,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF966c4a,&HFF593d29,&HFF593d29,&HFF593d29,&HFF79553a,&HFF79553a,&HFF593d29,&HFF79553a,&HFF79553a,&HFF79553a,&HFFb9855c
Data &HFFb9855c,&HFF79553a,&HFF79553a,&HFF79553a,&HFF878787,&HFF79553a,&HFF79553a,&HFFb9855c,&HFFb9855c,&HFF79553a,&HFFb9855c,&HFFb9855c,&HFF79553a,&HFF966c4a,&HFF79553a,&HFF966c4a
Data &HFF79553a,&HFF79553a,&HFFb9855c,&HFFb9855c,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF79553a,&HFF966c4a,&HFF593d29,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF79553a,&HFF966c4a,&HFF966c4a
Data &HFF966c4a,&HFF79553a,&HFF79553a,&HFF966c4a,&HFF79553a,&HFF966c4a,&HFF79553a,&HFF593d29,&HFF79553a,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF79553a,&HFF79553a,&HFF593d29,&HFF79553a
Data &HFF79553a,&HFF966c4a,&HFF593d29,&HFF79553a,&HFF79553a,&HFF593d29,&HFF593d29,&HFF79553a,&HFF79553a,&HFF79553a,&HFF79553a,&HFF79553a,&HFFb9855c,&HFFb9855c,&HFF79553a,&HFF966c4a
Data &HFF79553a,&HFF966c4a,&HFF79553a,&HFFb9855c,&HFFb9855c,&HFF79553a,&HFFb9855c,&HFF966c4a,&HFF593d29,&HFFb9855c,&HFFb9855c,&HFF593d29,&HFF966c4a,&HFF966c4a,&HFF878787,&HFF79553a
Data &HFF966c4a,&HFF79553a,&HFF79553a,&HFF966c4a,&HFF966c4a,&HFFb9855c,&HFF79553a,&HFF966c4a,&HFF6c6c6c,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF593d29,&HFF966c4a,&HFF79553a,&HFF593d29
Data &HFF79553a,&HFF593d29,&HFF966c4a,&HFF79553a,&HFF966c4a,&HFF966c4a,&HFFb9855c,&HFF79553a,&HFF79553a,&HFF79553a,&HFF79553a,&HFF79553a,&HFF79553a,&HFF79553a,&HFFb9855c,&HFFb9855c
Data &HFF79553a,&HFF966c4a,&HFF79553a,&HFF79553a,&HFF745844,&HFF79553a,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF593d29,&HFFb9855c,&HFF593d29,&HFF79553a,&HFFb9855c,&HFF966c4a,&HFF966c4a
Data &HFF966c4a,&HFF79553a,&HFF593d29,&HFFb9855c,&HFF79553a,&HFF593d29,&HFF79553a,&HFF593d29,&HFFb9855c,&HFFb9855c,&HFF79553a,&HFF966c4a,&HFF79553a,&HFF79553a,&HFF966c4a,&HFF966c4a
Data &HFF966c4a,&HFF79553a,&HFFb9855c,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF878787,&HFF79553a,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF79553a,&HFF966c4a,&HFF966c4a,&HFF79553a,&HFF593d29

'Red_Brick', 16x16px
Data &HFFd93f0f,&HFFdd340a,&HFFd93f0f,&HFFcfcbd2,&HFFd93f0f,&HFFdd3d1b,&HFFd93509,&HFFe04609,&HFFd93f0f,&HFFe14a1b,&HFFcf380a,&HFFd1d1d1,&HFFd93f0f,&HFFde4712,&HFFd93f0f,&HFFd93f0f
Data &HFFb33409,&HFFb33409,&HFFbe3912,&HFFdce1d7,&HFFe1501b,&HFFb33409,&HFFae2a0a,&HFFac2213,&HFFb33409,&HFFaa320f,&HFFbf3806,&HFFd6ceda,&HFFd93f0f,&HFFb73508,&HFFb33409,&HFFb43705
Data &HFFb33409,&HFFba3e19,&HFFac2903,&HFFd1d1d1,&HFFd93f0f,&HFFa93b13,&HFFb33409,&HFFa83207,&HFFb33409,&HFFb33409,&HFFb33409,&HFFd1d1d1,&HFFd12d02,&HFFc04110,&HFFb33409,&HFFbc4107
Data &HFFb89f91,&HFFb89a8a,&HFFae8e8f,&HFFd1d1d1,&HFFb29291,&HFFb3938b,&HFFb3938b,&HFFaf8f81,&HFFb3938b,&HFFbb9d8d,&HFFc3898d,&HFFd7dee4,&HFFb3938b,&HFFb3938b,&HFFaa8d8c,&HFFc8a597
Data &HFFd0320a,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFd73907,&HFFd93f0f,&HFFd1d1d1,&HFFde4619,&HFFd94915,&HFFe23d14,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFd0d0ca
Data &HFFd93f0f,&HFFb33409,&HFFc1481e,&HFFb33409,&HFFa92902,&HFFb33409,&HFFb73006,&HFFd1d1d1,&HFFd93f0f,&HFFb33409,&HFFaf2e05,&HFFb33409,&HFFac2b00,&HFFb33409,&HFFb33409,&HFFcbd9d5
Data &HFFd93f0f,&HFFa62600,&HFFb83c15,&HFFb02b00,&HFFb33409,&HFFaf2103,&HFFb33409,&HFFcfe0dd,&HFFdb4b15,&HFFaa2e02,&HFFb63b0f,&HFFad3209,&HFFb33409,&HFFb33409,&HFFb33409,&HFFd4cfd1
Data &HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFaa938b,&HFFb0918e,&HFFc1998f,&HFFb3938b,&HFFd1d1d1,&HFFb3938b,&HFFb3938b,&HFFb3878b,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFb69384,&HFFd1d1d1
Data &HFFdf3f14,&HFFd93f0f,&HFFd93f0f,&HFFd1d1d1,&HFFda3d08,&HFFd93f0f,&HFFda4515,&HFFee5519,&HFFde3f19,&HFFd93f0f,&HFFd93f0f,&HFFd1d1d1,&HFFd93f0f,&HFFd93f0f,&HFFe95407,&HFFc62f00
Data &HFFb33409,&HFFb33409,&HFFb33409,&HFFc8cfd1,&HFFde3419,&HFFb33409,&HFFb1350d,&HFFb33409,&HFFb93c0d,&HFFb64305,&HFFb92f0a,&HFFcfcacd,&HFFd93f0f,&HFFbb3a17,&HFFb33409,&HFFb33409
Data &HFFb14310,&HFFb33409,&HFFbc3b0f,&HFFd8dede,&HFFd93f0f,&HFFb33409,&HFFb0150c,&HFFb33409,&HFFb52500,&HFFb23a18,&HFFb33409,&HFFcad1d3,&HFFd93f0f,&HFFb33409,&HFFb53d0f,&HFFb33409
Data &HFFb3938b,&HFFb3938b,&HFFa58588,&HFFd1d1d1,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFb3938b,&HFFad9092,&HFFd1d5d8,&HFFba8e88,&HFFb99e96,&HFFa89283,&HFFaa9784
Data &HFFca4a0f,&HFFd84118,&HFFe14a18,&HFFd93f0f,&HFFd93f0f,&HFFd93f0f,&HFFcf3d06,&HFFc7cbcf,&HFFd93b02,&HFFdd561a,&HFFd93f0f,&HFFd93f0f,&HFFd83c15,&HFFd93f0f,&HFFdd3f12,&HFFdee0e0
Data &HFFd93f0f,&HFFb33409,&HFFa93515,&HFFae3709,&HFFb33409,&HFFb33409,&HFFaa2709,&HFFc4cdcc,&HFFd93f0f,&HFFbd2d09,&HFFb33409,&HFFb33409,&HFFb33409,&HFFb43507,&HFFb73510,&HFFd1d1d1
Data &HFFd93f0f,&HFFa61800,&HFFb93a1a,&HFFb33409,&HFFb33409,&HFFb33409,&HFFb33409,&HFFd1d3d4,&HFFd93f0f,&HFFb33409,&HFFb33409,&HFFb33409,&HFFb63521,&HFFb33409,&HFFaf3c0c,&HFFd1d1d1
Data &HFFb3938b,&HFFb59181,&HFFa5857c,&HFFb59895,&HFFb3938b,&HFFb09a96,&HFFb3938b,&HFFd1d1d1,&HFFbaa085,&HFFb3938b,&HFFad8c8a,&HFFb3938b,&HFFbc9a8e,&HFFb3938b,&HFFb3938b,&HFFbec7c9

Texture1Data:
'Origin16x16', 16x16px
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffdbc4,&HFFff7f27,&HFFffdbc4,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffac75,&HFFff7f27,&HFFffac75,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFff7f27,&HFFff7f27,&HFFff7f27,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFff7f27,&HFFffdbc4,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFFffffff,&HFF00a2e8,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFff7f27,&HFFffdbc4,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFF9de1ff,&HFF00a2e8,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFF9de1ff,&HFF00a2e8,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFFffffff,&HFF00a2e8,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff
Data &HFFffffff,&HFFff7f27,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFF64d0ff,&HFF9de1ff,&HFFffffff
Data &HFFffffff,&HFFa349a4,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8,&HFF00a2e8
Data &HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFFffffff,&HFF00a2e8,&HFF64d0ff,&HFF9de1ff,&HFFffffff


Function ReadTexel& (ccol As Single, rrow As Single)
    Select Case T1_Filter_Selection
        Case 0
            ReadTexel& = ReadTexelNearest&(ccol, rrow)
        Case 1
            ReadTexel& = ReadTexel3Point&(ccol, rrow)
        Case 2
            ReadTexel& = ReadTexelBiLinear&(ccol, rrow)
    End Select

End Function


Function ReadTexelNearest& (ccol As Single, rrow As Single)
    ' Relies on some shared variables over by Texture1
    Static cc As Integer
    Static rr As Integer


    If Texture_options And T1_option_clamp_width Then
        ' clamp
        If ccol < 0.0 Then
            cc = 0
        ElseIf ccol >= T1_width_MASK Then
            cc = T1_width_MASK
        Else
            cc = Int(ccol)
        End If
    Else
        ' tile
        If Texture_options And T1_option_mirror_width Then
            cc = Int(ccol) And T1_width_mirror
            ' butterfly mirror
            If cc > T1_width_MASK Then cc = T1_width_mirror - cc
        Else
            cc = Int(ccol) And T1_width_MASK
        End If
    End If

    If Texture_options And T1_option_clamp_height Then
        ' clamp
        If rrow < 0.0 Then
            rr = 0
        ElseIf rrow >= T1_height_MASK Then
            rr = T1_height_MASK
        Else
            rr = Int(rrow)
        End If
    Else
        ' tile
        If Texture_options And T1_option_mirror_height Then
            rr = Int(rrow) And T1_height_mirror
            ' butterfly mirror
            If rr > T1_height_MASK Then rr = T1_height_mirror - rr
        Else
            rr = Int(rrow) And T1_height_MASK
        End If
    End If

    ReadTexelNearest& = Texture1(cc, rr)
End Function


Function ReadTexel3Point& (ccol As Single, rrow As Single)
    ' Relies on some shared T1 variables over by Texture1
    Static cc As Integer
    Static rr As Integer
    Static cc1 As Integer
    Static rr1 As Integer

    Static Frac_cc1 As Single
    Static Frac_rr1 As Single

    Static Area_00 As Single
    Static Area_11 As Single
    Static Area_2f As Single

    Static uv_0_0 As Long
    Static uv_1_1 As Long
    Static uv_f As Long

    Static r0 As Long
    Static g0 As Long
    Static b0 As Long

    Static cm5 As Single
    Static rm5 As Single

    ' Offset so the transition appears in the center of an enlarged texel instead of a corner.
    cm5 = ccol - 0.5
    rm5 = rrow - 0.5

    If Texture_options And T1_option_clamp_width Then
        ' clamp
        If cm5 < 0.0 Then cm5 = 0.0
        If cm5 >= T1_width_MASK Then
            '15.0 and up
            cc = T1_width_MASK
            cc1 = T1_width_MASK
        Else
            '0 1 2 .. 13 14.999
            cc = Int(cm5)
            cc1 = cc + 1
        End If
    Else
        ' tile
        If Texture_options And T1_option_mirror_width Then
            cc = Int(cm5) And T1_width_mirror
            cc1 = (cc + 1) And T1_width_mirror
            ' butterfly mirror
            If cc1 > T1_width_MASK Then cc1 = T1_width_mirror - cc1
            If cc > T1_width_MASK Then cc = T1_width_mirror - cc
        Else
            cc = Int(cm5) And T1_width_MASK
            cc1 = (cc + 1) And T1_width_MASK
        End If
    End If

    If Texture_options And T1_option_clamp_height Then
        ' clamp
        If rm5 < 0.0 Then rm5 = 0.0
        If rm5 >= T1_height_MASK Then
            ' 15.0 and up
            rr = T1_height_MASK
            rr1 = T1_height_MASK
        Else
            rr = Int(rm5)
            rr1 = rr + 1
        End If
    Else
        ' tile
        If Texture_options And T1_option_mirror_height Then
            rr = Int(rm5) And T1_height_mirror
            rr1 = (rr + 1) And T1_height_mirror
            ' butterfly mirror
            If rr1 > T1_height_MASK Then rr1 = T1_height_mirror - rr1
            If rr > T1_height_MASK Then rr = T1_height_mirror - rr
        Else
            rr = Int(rm5) And T1_height_MASK
            rr1 = (rr + 1) And T1_height_MASK
        End If
    End If

    uv_0_0 = Texture1(cc, rr)
    uv_1_1 = Texture1(cc1, rr1)

    Frac_cc1 = cm5 - Int(cm5)
    Frac_rr1 = rm5 - Int(rm5)

    If Frac_cc1 > Frac_rr1 Then
        ' top-right
        ' Area of a triangle = 1/2 * base * height
        ' Using twice the areas (rectangles) to eliminate a multiply by 1/2 and a later divide by 1/2
        Area_11 = Frac_rr1
        Area_00 = 1.0 - Frac_cc1
        uv_f = Texture1(cc1, rr)
    Else
        ' bottom-left
        Area_00 = 1.0 - Frac_rr1
        Area_11 = Frac_cc1
        uv_f = Texture1(cc, rr1)
    End If

    Area_2f = 1.0 - (Area_00 + Area_11) '1.0 here is twice the total triangle area.

    r0 = _Red32(uv_f) * Area_2f + _Red32(uv_0_0) * Area_00 + _Red32(uv_1_1) * Area_11
    g0 = _Green32(uv_f) * Area_2f + _Green32(uv_0_0) * Area_00 + _Green32(uv_1_1) * Area_11
    b0 = _Blue32(uv_f) * Area_2f + _Blue32(uv_0_0) * Area_00 + _Blue32(uv_1_1) * Area_11

    ReadTexel3Point& = _RGB32(r0, g0, b0)
End Function


Function ReadTexelBiLinear& (ccol As Single, rrow As Single)
    ' Relies on some shared variables over by Texture1
    Dim cc As Integer
    Dim rr As Integer
    Dim cc1 As Integer
    Dim rr1 As Integer

    Dim Frac_cc As Single
    Dim Frac_rr As Single
    Dim Frac_cc1 As Single
    Dim Frac_rr1 As Single

    Dim uv_0_0 As Long
    Dim uv_0_1 As Long
    Dim uv_1_0 As Long
    Dim uv_1_1 As Long

    Dim r0 As Long
    Dim g0 As Long
    Dim b0 As Long
    Dim r1 As Long
    Dim g1 As Long
    Dim b1 As Long

    Dim cm5 As Single
    Dim rm5 As Single

    cm5 = ccol - 0.5
    rm5 = rrow - 0.5

    If Texture_options And T1_option_clamp_width Then
        ' clamp
        If cm5 < 0.0 Then cm5 = 0.0
        If cm5 >= T1_width_MASK Then
            ' 15.0 and up
            cc = T1_width_MASK
            cc1 = T1_width_MASK
        Else
            ' 0 1 2 .. 13 14.999
            cc = Int(cm5)
            cc1 = cc + 1
        End If
    Else
        ' tile
        If Texture_options And T1_option_mirror_width Then
            cc = Int(cm5) And T1_width_mirror
            cc1 = (cc + 1) And T1_width_mirror
            ' butterfly mirror
            If cc1 > T1_width_MASK Then cc1 = T1_width_mirror - cc1
            If cc > T1_width_MASK Then cc = T1_width_mirror - cc
        Else
            cc = Int(cm5) And T1_width_MASK
            cc1 = (cc + 1) And T1_width_MASK
        End If
    End If

    If Texture_options And T1_option_clamp_height Then
        ' clamp
        If rm5 < 0.0 Then rm5 = 0.0
        If rm5 >= T1_height_MASK Then
            ' 15.0 and up
            rr = T1_height_MASK
            rr1 = T1_height_MASK
        Else
            rr = Int(rm5)
            rr1 = rr + 1
        End If
    Else
        ' tile
        If Texture_options And T1_option_mirror_height Then
            rr = Int(rm5) And T1_height_mirror
            rr1 = (rr + 1) And T1_height_mirror
            ' butterfly mirror
            If rr1 > T1_height_MASK Then rr1 = T1_height_mirror - rr1
            If rr > T1_height_MASK Then rr = T1_height_mirror - rr
        Else
            rr = Int(rm5) And T1_height_MASK
            rr1 = (rr + 1) And T1_height_MASK
        End If
    End If

    uv_0_0 = Texture1(cc, rr)
    uv_1_0 = Texture1(cc1, rr)
    uv_0_1 = Texture1(cc, rr1)
    uv_1_1 = Texture1(cc1, rr1)

    Frac_cc1 = cm5 - Int(cm5)
    Frac_rr1 = rm5 - Int(rm5)
    Frac_cc = 1.0 - Frac_cc1
    Frac_rr = 1.0 - Frac_rr1

    r0 = _Red32(uv_0_0) * Frac_cc + _Red32(uv_1_0) * Frac_cc1
    g0 = _Green32(uv_0_0) * Frac_cc + _Green32(uv_1_0) * Frac_cc1
    b0 = _Blue32(uv_0_0) * Frac_cc + _Blue32(uv_1_0) * Frac_cc1

    r1 = _Red32(uv_0_1) * Frac_cc + _Red32(uv_1_1) * Frac_cc1
    g1 = _Green32(uv_0_1) * Frac_cc + _Green32(uv_1_1) * Frac_cc1
    b1 = _Blue32(uv_0_1) * Frac_cc + _Blue32(uv_1_1) * Frac_cc1

    ReadTexelBiLinear& = _RGB32(r0 * Frac_rr + r1 * Frac_rr1, g0 * Frac_rr + g1 * Frac_rr1, b0 * Frac_rr + b1 * Frac_rr1)
End Function
