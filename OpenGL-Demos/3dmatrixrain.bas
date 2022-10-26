'Moving into the Matrix Rain
'By Ashish Kushwaha
'23 Jun, 2019
'
'Inspire by B+ Matrix Rain.
_Title "Moving into the Matrix Rain"
 
Randomize Timer
 
Screen _NewImage(800, 600, 32)
 
Type matRain
    x As Single 'x location
    y As Single 'y location
    z As Single 'z location
    ay As Single 'rain velocity
    strData As String 'string data of each matrix rain
End Type
 
Dim Shared charImg(74) As Long, matRainWidth, matRainHeight 'ascii char from 48 to 122, i.e, total 75 type of chars
Dim Shared glAllow As _Byte, matrixRain(700) As matRain, matrixRainTex(74) As Long, mov
matRainWidth = _FontWidth * 0.005
matRainHeight = _FontHeight * 0.005
Cls , _RGB32(255)
tmp& = _NewImage(_FontWidth - 1, _FontHeight, 32)
For i = 0 To 74
    charImg(i) = _NewImage(_FontWidth * 5, _FontHeight * 5, 32)
    _Dest tmp&
    Cls , _RGBA(0, 0, 0, 0)
    Color _RGB32(0, 255, 0), 1
    _PrintString (0, 0), Chr$(i + 48)
    _Dest charImg(i)
    _PutImage , tmp&
    _Dest 0
Next
 
 
glAllow = -1
Do
    For i = 0 To UBound(matrixRain)
        matrixRain(i).y = matrixRain(i).y - matrixRain(i).ay
        If Rnd > 0.9 Then
            d$ = ""
            For k = 1 To Len(matrixRain(i).strData)
                d$ = d$ + Chr$(48 + p5random(0, 74)) 'change the character of rain randomly by a chance of 10%
            Next
            matrixRain(i).strData = d$
        End If
        matrixRain(i).z = matrixRain(i).z + 0.00566 'move into the rain
        If matrixRain(i).z > 0.1 Then 'when behind screen
            matrixRain(i).x = p5random(-2, 2)
            matrixRain(i).y = p5random(2, 3.7)
            matrixRain(i).z = map((i / UBound(matrixRain)), 0, 1, -8, -0.2)
            matrixRain(i).ay = p5random(0.006, 0.02)
        End If
    Next
    _Limit 60
Loop
 
Sub _GL ()
    Static glInit
    mov = mov + 0.01
    If Not glAllow Then Exit Sub
 
    If glInit = 0 Then
        glInit = 1
 
        For i = 0 To UBound(matrixRainTex) 'create texture for each ascii character
            _glGenTextures 1, _Offset(matrixRainTex(i))
 
            Dim m As _MEM
            m = _MemImage(charImg(i))
 
            _glBindTexture _GL_TEXTURE_2D, matrixRainTex(i)
            _glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGBA, _Width(charImg(i)), _Height(charImg(i)), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, m.OFFSET
 
            _MemFree m
 
            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_NEAREST
            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
            _FreeImage charImg(i)
        Next
 
        For i = 0 To UBound(matrixRain) 'initialization
            n = p5random(1, 15)
            For j = 1 To n
                v$ = Chr$(p5random(48, 122))
                matrixRain(i).strData = matrixRain(i).strData + v$
            Next
            matrixRain(i).x = p5random(-2, 2)
            matrixRain(i).y = p5random(2, 3.7)
            matrixRain(i).z = map((i / UBound(matrixRain)), 0, 1, -8, -0.2)
            matrixRain(i).ay = p5random(0.006, 0.02)
        Next
 
        _glViewport 0, 0, _Width, _Height
    End If
 
    _glEnable _GL_BLEND 'enabling necessary stuff
    _glEnable _GL_DEPTH_TEST
    _glEnable _GL_TEXTURE_2D
 
 
    _glClearColor 0, 0, 0, 1
    _glClear _GL_COLOR_BUFFER_BIT Or _GL_DEPTH_BUFFER_BIT
 
 
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 60, _Width / _Height, 0.01, 10.0
 
    _glRotatef Sin(mov) * 20, 1, 0, 0 'rotating x-axis a bit, just to get Depth effect.
 
 
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
 
    'rendering the rain
    For i = 0 To UBound(matrixRain)
        n = Len(matrixRain(i).strData)
        For j = 1 To n
            ca$ = Mid$(matrixRain(i).strData, j, 1)
            'selecting texture on the basis of ascii code.
            _glBindTexture _GL_TEXTURE_2D, matrixRainTex(Asc(ca$) - 48)
            _glBegin _GL_QUADS
            _glTexCoord2f 0, 1
            _glVertex3f matrixRain(i).x - matRainWidth, matrixRain(i).y - matRainHeight + 2 * (j - 1) * matRainHeight, matrixRain(i).z
            _glTexCoord2f 0, 0
            _glVertex3f matrixRain(i).x - matRainWidth, matrixRain(i).y + matRainHeight + 2 * (j - 1) * matRainHeight, matrixRain(i).z
            _glTexCoord2f 1, 0
            _glVertex3f matrixRain(i).x + matRainWidth, matrixRain(i).y + matRainHeight + 2 * (j - 1) * matRainHeight, matrixRain(i).z
            _glTexCoord2f 1, 1
            _glVertex3f matrixRain(i).x + matRainWidth, matrixRain(i).y - matRainHeight + 2 * (j - 1) * matRainHeight, matrixRain(i).z
            _glEnd
        Next
    Next
 
    _glFlush
End Sub
 
'taken from p5js.bas
'https://bit.ly/p5jsbas
Function map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
End Function
 
 
Function p5random! (mn!, mx!)
    If mn! > mx! Then
        Swap mn!, mx!
    End If
    p5random! = Rnd * (mx! - mn!) + mn!
End Function
 
