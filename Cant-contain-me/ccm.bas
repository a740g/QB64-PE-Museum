'Can't Contain Me - A game developed in QB64
'@FellippeHeitor fellippeheitor@gmail.com

Const true = -1, false = Not true

Type vector
    x As Single
    y As Single
    z As Single
End Type

Type NewObject
    pos As vector
    dir As vector
    w As Integer
    h As Integer
    dragXoff As Integer
    dragYoff As Integer
    color As _Unsigned Long
    img As Long
    selected As _Byte
    lost As _Byte
    added As _Byte
End Type

Screen _NewImage(896, 504, 32)
Do Until _ScreenExists: Loop
_Title "Can't contain me"

Randomize Timer

Dim icon As Long
icon = _NewImage(64, 64, 32)
_Dest icon
Line (0, 0)-(63, 63), _RGB32(Rnd * 200, Rnd * 200, Rnd * 200), BF
Circle (32, 32), 5, _RGB32(255, 255, 255)
Paint (32, 32)
_Dest 0
_Icon icon
_FreeImage icon

Color , 0
Dim obj(1 To 10) As NewObject, barn As NewObject
Dim drag As _Byte, f As Long
Dim k As Long, i As Long

barn.w = 300
barn.h = 300
barn.pos.x = _Width / 2 - barn.w / 2
barn.pos.y = _Height / 2 - barn.h / 2

GoSub resetPieces

Do
    k = _KeyHit

    If k = 27 Then System

    If (_KeyDown(100305) Or _KeyDown(100306)) And (k = Asc("a") Or k = Asc("A")) Then
        For i = 1 To UBound(obj)
            obj(i).selected = true
        Next
    End If

    While _MouseInput: Wend

    If Not Won Then
        If _MouseButton(1) Then
            If Not drag Then
                drag = true
                dragSelect = true
                dragx = _MouseX
                dragy = _MouseY
                clickedBox = false
                For i = 1 To UBound(obj)
                    If hovering(obj(i)) And obj(i).added = false Then
                        dragSelect = false
                        clickedBox = true

                        obj(i).dragXoff = _MouseX - obj(i).pos.x
                        obj(i).dragYoff = _MouseY - obj(i).pos.y

                        For j = 1 To UBound(obj)
                            If j <> i Then
                                If Not _KeyDown(100305) And Not _KeyDown(100306) Then
                                    If obj(i).selected = false Then obj(j).selected = false
                                End If

                                obj(j).dragXoff = _MouseX - obj(j).pos.x
                                obj(j).dragYoff = _MouseY - obj(j).pos.y
                            End If
                        Next

                        obj(i).selected = true

                        Exit For
                    End If
                Next
            End If
        Else
            If drag Then
                drag = false
                dragSelect = false
            End If
        End If
    Else
        If _MouseButton(1) Then
            If Not mousepressed Then
                GoSub resetPieces
            Else
                drag = false
                dragSelect = false
            End If
        Else
            mousepressed = false
        End If
    End If

    Line (0, 0)-(_Width - 1, _Height - 1), _RGBA32(0, 0, 0, 30), BF

    For i = 1 To UBound(obj)
        If Not obj(i).lost Then
            obj(i).lost = obj(i).pos.x > _Width Or obj(i).pos.y > _Height Or obj(i).pos.x + obj(i).w < 0 Or obj(i).pos.y + obj(i).h < 0
            If obj(i).lost Then
                'score = score - 5
            End If
        End If

        If Not obj(i).lost Then
            If obj(i).img < -1 Then
            Else
                Line (obj(i).pos.x, obj(i).pos.y)-Step(obj(i).w - 1, obj(i).h - 1), obj(i).color, BF
                Circle (obj(i).pos.x + obj(i).w / 2, obj(i).pos.y + obj(i).h / 2), 2, _RGB32(255, 255, 255)
                Paint (obj(i).pos.x + obj(i).w / 2, obj(i).pos.y + obj(i).h / 2)
            End If

            If obj(i).selected Then
                If obj(i).img < -1 Then
                Else
                    Line (obj(i).pos.x - 2, obj(i).pos.y - 2)-Step(obj(i).w + 3, obj(i).h + 3), _RGBA32(255, 255, 255, 150), B , 21845
                End If
            ElseIf hovering(obj(i)) And Not Won Then
                If obj(i).img < -1 Then
                Else
                    Line (obj(i).pos.x, obj(i).pos.y)-Step(obj(i).w - 1, obj(i).h - 1), _RGBA32(255, 255, 255, 100), BF
                End If
            End If
        End If

        If drag And obj(i).selected And Not dragSelect Then
            obj(i).pos.x = dragx + (_MouseX - dragx) - obj(i).dragXoff
            obj(i).pos.y = dragy + (_MouseY - dragy) - obj(i).dragYoff
        End If

        If Not isInside(obj(i), barn) Then
            vector.add obj(i).pos, obj(i).dir
            If isInside(obj(i), barn) Then vector.mult obj(i).dir, -1
            Do While isInside(obj(i), barn)
                vector.add obj(i).pos, obj(i).dir
            Loop
        Else
            vector.add obj(i).pos, obj(i).dir
            If Not isInside(obj(i), barn) Then vector.mult obj(i).dir, -1
            Do While Not isInside(obj(i), barn)
                vector.add obj(i).pos, obj(i).dir
            Loop

            If obj(i).added = false Then
                score = score + 10
                obj(i).added = true

                'pieces get agitated when contained...
                obj(i).dir.x = obj(i).dir.x * 5
                obj(i).dir.y = obj(i).dir.y * 5
            Else
                obj(i).selected = false
            End If
        End If
    Next

    Line (barn.pos.x - obj(1).w / 2, barn.pos.y - obj(1).h / 2)-Step(barn.w + obj(1).w - 1, barn.h + obj(1).h - 1), _RGBA32(255, 255, 255, 100), BF

    If dragSelect Then
        Line (dragx, dragy)-(_MouseX, _MouseY), _RGBA32(127, 172, 255, 100), BF
        Line (dragx, dragy)-(_MouseX, _MouseY), _RGB32(127, 172, 255), B

        Dim rect As NewObject
        rect.pos.x = dragx
        rect.pos.y = dragy
        rect.w = _MouseX - dragx
        rect.h = _MouseY - dragy

        For i = 1 To UBound(obj)
            If isInside(obj(i), rect) And obj(i).added = false Then obj(i).selected = true Else obj(i).selected = false
        Next
    End If

    Won = true
    LostPieces = 0
    For i = 1 To UBound(obj)
        If Not obj(i).lost Then
            If Not obj(i).added Then Won = false: Exit For
        Else
            LostPieces = LostPieces + 1
        End If
    Next

    If Won Then
        If LostPieces = 1 Then
            m$ = "All but 1 piece contained!"
        ElseIf LostPieces = UBound(obj) Then
            m$ = "You lose... no pieces contained..."
        ElseIf LostPieces > 1 Then
            m$ = "All but" + Str$(LostPieces) + " pieces contained!"
        Else
            m$ = "All pieces contained!"
        End If
        Color _RGB32(0, 0, 0)
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2 + 1, _Height / 2 - _FontHeight - 1), m$
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2 - 1, _Height / 2 - _FontHeight - 1), m$
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2 + 1, _Height / 2 - _FontHeight + 1), m$
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2 - 1, _Height / 2 - _FontHeight + 1), m$
        Color _RGB32(255, 255, 255)
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2, _Height / 2 - _FontHeight), m$
        m$ = "Your score:" + Str$(score)
        Color _RGB32(0, 0, 0)
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2 - 1, _Height / 2 + _FontHeight - 1), m$
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2 + 1, _Height / 2 + _FontHeight + 1), m$
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2 + 1, _Height / 2 + _FontHeight - 1), m$
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2 - 1, _Height / 2 + _FontHeight + 1), m$
        Color _RGB32(255, 255, 255)
        _PrintString (_Width / 2 - _PrintWidth(m$) / 2, _Height / 2 + _FontHeight), m$
        If _MouseButton(1) Then mousepressed = true
    Else
        _PrintString (0, 0), "Score:" + Str$(score)
        _PrintString (0, _FontHeight), "Time:" + Str$(Int(Timer - start#))
    End If

    _Display

    _Limit 30
Loop

System

resetPieces:
For i = 1 To UBound(obj)
    obj(i).w = 40
    obj(i).h = 40
    obj(i).lost = false
    obj(i).added = false
    obj(i).selected = false
    createVector obj(i).dir, p5random(-1, 1), p5random(-1, 1)
    obj(i).color = _RGB32(Rnd * 200, Rnd * 200, Rnd * 200)
    Do
        createVector obj(i).pos, Rnd * (_Width - obj(i).w), Rnd * (_Height - obj(i).h)
    Loop While isInside(obj(i), barn)
Next

start# = Timer
Won = false
score = 0
Return

Function hovering%% (this As NewObject)
    hovering = _MouseX > this.pos.x And _MouseX < this.pos.x + this.w - 1 And _MouseY > this.pos.y And _MouseY < this.pos.y + this.h - 1
End Function

Function isInside%% (this As NewObject, __rect As NewObject)
    Dim rect As NewObject

    rect = __rect
    If rect.w < 0 Then rect.w = Abs(rect.w): rect.pos.x = rect.pos.x - rect.w
    If rect.h < 0 Then rect.h = Abs(rect.h): rect.pos.y = rect.pos.y - rect.h

    isInside%% = rect.pos.x < this.pos.x + this.w And rect.pos.x + rect.w > this.pos.x And rect.pos.y < this.pos.y + this.h And rect.pos.y + rect.h > this.pos.y
End Function

'Elements below have been borrowed from the p5js.bas library:
Function p5random! (mn!, mx!)
    If mn! > mx! Then
        Swap mn!, mx!
    End If
    p5random! = Rnd * (mx! - mn!) + mn!
End Function

Sub createVector (v As vector, x As Single, y As Single)
    v.x = x
    v.y = y
End Sub

Sub vector.add (v1 As vector, v2 As vector)
    v1.x = v1.x + v2.x
    v1.y = v1.y + v2.y
    v1.z = v1.z + v2.z
End Sub

Sub vector.mult (v As vector, n As Single)
    v.x = v.x * n
    v.y = v.y * n
    v.z = v.z * n
End Sub
