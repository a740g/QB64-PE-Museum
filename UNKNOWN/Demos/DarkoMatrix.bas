$Resize:Smooth
Screen _NewImage(_DesktopWidth, _DesktopHeight, 32)
_FullScreen _SquarePixels , _Smooth
Dim m(1 To Int(_Width / _FontWidth))

For i = 1 To UBound(m)
    m(i) = -Int(Rnd * _Height)
Next

Color _RGB32(0, 255, 0)

Do
    _Limit 15
    Line (0, 0)-(_Width, _Height), _RGBA32(0, 0, 0, 20), BF

    For i = 1 To UBound(m)
        m(i) = m(i) + _FontHeight
        If m(i) > 0 Then
            If m(i) > _Height Then m(i) = -Int(Rnd * _Height)
            _PrintString (i * _FontWidth - _FontWidth, m(i)), Chr$(_Ceil(Rnd * 254))
        End If
    Next

    _Display
Loop Until _KeyHit = 27
System

