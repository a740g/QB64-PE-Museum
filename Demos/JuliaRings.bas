' The Lord of the Julia Rings
' The Fellowship of the Julia Ring
' Free Basic
' Relsoft
' Rel.BetterWebber.com
'
' Converted to QB64 format by Galleon (FB specific code commented)

DefLng A-Z

''$include: 'TinyPTC.bi'
''$include: 'user32.bi'

'option explicit

Const SCR_WIDTH = 320 * 2
Const SCR_HEIGHT = 240 * 2

Const SCR_SIZE = SCR_WIDTH * SCR_HEIGHT
Const SCR_MIDX = SCR_WIDTH \ 2
Const SCR_MIDY = SCR_HEIGHT \ 2

Const FALSE = 0, TRUE = Not FALSE

Const PI = 3.141593
Const MAXITER = 20
Const MAXSIZE = 4

Dim Buffer(SCR_SIZE - 1) As Long
Dim Lx(SCR_WIDTH - 1) As Single
Dim Ly(SCR_HEIGHT - 1) As Single
Dim sqrt(SCR_SIZE - 1) As Single

'if( ptc_open( "FreeBASIC Julia (Relsoft)", SCR_WIDTH, SCR_HEIGHT ) = 0 ) then
'   end -1
'end if

Screen _NewImage(SCR_WIDTH, SCR_HEIGHT, 32), , 1, 0

Dim px As Long, py As Long
Dim p As Single, q As Single
Dim xmin As Single, xmax As Single, ymin As Single, ymax As Single
Dim theta As Single
Dim deltax As Single, deltay As Single
Dim x As Single, y As Single
Dim xsquare As Single, ysquare As Single
Dim ytemp As Single
Dim temp1 As Single, temp2 As Single
Dim i As Long, pixel As Long
Dim t As _Unsigned Long, frame As _Unsigned Long
Dim ty As Single
Dim r As Long, g As Long, b As Long
Dim red As Long, grn As Long, blu As Long
Dim tmp As Long, i_last As Long

Dim cmag As Single
Dim cmagsq As Single
Dim zmag As Single
Dim drad As Single
Dim drad_L As Single
Dim drad_H As Single
Dim ztot As Single
Dim ztoti As Long

'pointers to array "buffer"
'dim p_buffer as long ptr, p_bufferl as long ptr

xmin = -2.0
xmax = 2.0
ymin = -1.5
ymax = 1.5

deltax = (xmax - xmin) / (SCR_WIDTH - 1)
deltay = (ymax - ymin) / (SCR_HEIGHT - 1)

For i = 0 To SCR_WIDTH - 1
    Lx(i) = xmin + i * deltax
Next i

For i = 0 To SCR_HEIGHT - 1
    Ly(i) = ymax - i * deltay
Next i

For i = 0 To SCR_SIZE - 1
    sqrt(i) = Sqr(i)
Next i

'dim hwnd as long
'hwnd = GetActiveWindow

Dim stime As Long, Fps As Single, Fps2 As Single

stime = Timer

Do

    '    p_buffer = @buffer(0)
    '    p_bufferl = @buffer(SCR_SIZE-1)

    frame = (frame + 1) And &H7FFFFFFF
    theta = frame * PI / 180

    p = Cos(theta) * Sin(theta * .7)
    q = Sin(theta) + Sin(theta)
    p = p * .6
    q = q * .6

    cmag = Sqr(p * p + q * q)
    cmagsq = (p * p + q * q)
    drad = 0.04
    drad_L = (cmag - drad)
    drad_L = drad_L * drad_L
    drad_H = (cmag + drad)
    drad_H = drad_H * drad_H

    For py = 0 To (SCR_HEIGHT \ 2) - 1
        ty = Ly(py)
        For px = 0 To SCR_WIDTH - 1
            x = Lx(px)
            y = ty
            xsquare = 0
            ysquare = 0
            ztot = 0
            i = 0
            While (i < MAXITER) And ((xsquare + ysquare) < MAXSIZE)
                xsquare = x * x
                ysquare = y * y
                ytemp = x * y * 2
                x = xsquare - ysquare + p
                y = ytemp + q
                zmag = (x * x + y * y)
                If (zmag < drad_H) And (zmag > drad_L) And (i > 0) Then
                    ztot = ztot + (1 - (Abs(zmag - cmagsq) / drad))
                    i_last = i
                End If
                i = i + 1
                If zmag > 4.0 Then
                    Exit While
                End If
            Wend

            If ztot > 0 Then
                i = CInt(Sqr(ztot) * 500)
            Else
                i = 0
            End If
            If i < 256 Then
                red = i
            Else
                red = 255
            End If

            If i < 512 And i > 255 Then
                grn = i - 256
            Else
                If i >= 512 Then
                    grn = 255
                Else
                    grn = 0
                End If
            End If

            If i <= 768 And i > 511 Then
                blu = i - 512
            Else
                If i >= 768 Then
                    blu = 255
                Else
                    blu = 0
                End If
            End If

            tmp = Int((red + grn + blu) \ 3)
            red = Int((red + grn + tmp) \ 3)
            grn = Int((grn + blu + tmp) \ 3)
            blu = Int((blu + red + tmp) \ 3)

            Select Case (i_last Mod 3)
                Case 1
                    tmp = red
                    red = grn
                    grn = blu
                    blu = tmp
                Case 2
                    tmp = red
                    blu = grn
                    red = blu
                    grn = tmp
            End Select

            'pixel = red shl 16 or grn shl 8 or blu
            '*p_buffer = pixel
            '*p_bufferl = pixel
            'p_buffer = p_buffer + Len(long)
            'p_bufferl = p_bufferl - Len(long)
            pixel = _RGB32(red, grn, blu)
            PSet (px, py), pixel
            PSet (SCR_WIDTH - 1 - px, SCR_HEIGHT - 1 - py), pixel

        Next px
    Next py

    'calc fps
    Fps = Fps + 1
    If stime + 1 < Timer Then
        Fps2 = Fps
        Fps = 0
        stime = Timer
    End If

    '    SetWindowText hwnd, "FreeBasic Julia Rings FPS:" + str$(Fps2)
    Locate 1, 1: Print "QB64 Julia Rings FPS:" + Str$(Fps2)

    'ptc_update @buffer(0)
    PCopy 1, 0

Loop Until InKey$ <> ""

'ptc_close

End
