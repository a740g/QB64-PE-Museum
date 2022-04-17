'This is my starfield entry hacked down to 25 lines
'It needs a pretty fast computer...looks OK on my 1.5 GHz
'JKC 2003

$NoPrefix

$Resize:Smooth

Type star
    x As Integer
    y As Integer
    z As Integer
End Type

6 Dim astar(0 To 300) As star
7 Dim oldstar(0 To 300) As star
8 For i = 0 To 300
    9 astar(i).x = Rnd * 640
    10 astar(i).y = Rnd * 480
    11 astar(i).z = Rnd * 300
12 Next i

Screen 11
FullScreen SquarePixels , Smooth

14 Do
    15 For i = 0 To 300
        16 If astar(i).z < 1 Then astar(i).z = 300 Else astar(i).z = astar(i).z - 1
        17 For p% = 0 To oldstar(i).z
            18 Circle (oldstar(i).x, oldstar(i).y), p%, 0
            19 If astar(i).z <> 300 Then Circle (Int(2 * astar(i).z + astar(i).x / (1 + astar(i).z / 30)), Int(astar(i).z + astar(i).y / (1 + astar(i).z / 30))), p%
        20 Next p%
        21 oldstar(i).x = Int(2 * astar(i).z + astar(i).x / (1 + astar(i).z / 30))
        22 oldstar(i).y = Int(astar(i).z + astar(i).y / (1 + astar(i).z / 30))
        23 oldstar(i).z = 5 / (1 + astar(i).z / 20)
    24 Next i
    Limit 60
25 Loop Until InKey$ <> ""

System 0
