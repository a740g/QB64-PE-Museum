'3d Formula for Coordinate Axes
'perspx=perspective
'perspy=(perspx*xres)/yres
'a=x>yz angle , b=y>xz angle , c=z>xy angle
'x1=xpos-objectx
'y1=ypos-objecty
'z1=zpos-objectz
'y2=y1*cos(a)+z1*sin(a)
'z2=z1*cos(a)-y1*sin(a)
'x2=x1*cos(b)+z2*sin(b)
'z3=z2*cos(b)-x1*sin(b)
'y3=y2*cos(c)+x2*sin(c)
'x3=x2*cos(c)-y2*sin(c)
'rx=objectx-camerax
'ry=objectx-cameray
'rz=objectz-cameraz
'xf=rx+(perspx*x3)/(rz+z3)
'yf=ry+(perspy*y3)/(rz+z3)
'xdone=xf+xcentre
'ydone=yf+ycentre

'objectx,objecty,objectz - point of rotation of object
'camerax,cameray,cameraz - point of camera looking at the world you make
'xpos,ypos,zpos - position of pixel in the world coords
'xcentre,ycentre - centre of vision on the screen

'Coordinate Axes
'   ^y
'   |
'   |
'   |
'   ----->x
' /
'z
'Computer Axes
'----->x
'|\
'|  \z
'|
'y


'Sampling Computer Axes ...
'Press a key
Dim sine(359), cosine(359)
For i% = 0 To 359
    sine(i%) = Sin((CSng(i%) / 180) * 3.14)
    cosine(i%) = Cos((CSng(i%) / 180) * 3.14)
Next
Screen 9, , 1, 0
Type objects
    x As Single
    y As Single
    z As Single
    clr As Integer
End Type
Dim obj(18) As objects
For i% = 0 To UBound(obj)
    Randomize Timer
    Read obj(i%).x, obj(i%).y, obj(i%).z
    obj(i%).clr = i% Mod 256
Next

'Some initializations
perspx = 2500
perspy = (perspx * 320) / 200
objectx = 0
objecty = 0
objectz = 0
camerax = -100
cameray = -0
cameraz = -2000
xcentre = 150
ycentre = 200
a = 0
b = 2
c = 0

Dim xdone(UBound(obj)), ydone(UBound(obj))
i% = 1
a1 = Timer
t = .01
Do
    For j% = 0 To UBound(obj)
        x1 = obj(j%).x - objectx
        y1 = obj(j%).y - objecty
        z1 = obj(j%).z - objectz
        y2 = y1 * Cos(a) + z1 * Sin(a)
        z2 = z1 * Cos(a) - y1 * Sin(a)
        x2 = x1 * Cos(b) + z2 * Sin(b)
        z3 = z2 * Cos(b) - x1 * Sin(b)
        y3 = y2 * Cos(c) + x2 * Sin(c)
        x3 = x2 * Cos(c) - y2 * Sin(c)
        rx = objectx - camerax
        ry = objectx - cameray
        rz = objectz - cameraz
        xf = rx + (perspx * x3) / (rz + z3)
        yf = ry + (perspy * y3) / (rz + z3)
        xdone(j%) = xf + xcentre
        ydone(j%) = yf + ycentre
    Next
    k$ = InKey$
    k$ = LCase$(k$)
    Select Case k$
        Case Chr$(27)
            System
        Case "w"
            objecty = objecty + 2
        Case "s"
            objecty = objecty - 2
        Case "a"
            objectx = objectx - 2
        Case "d"
            objectx = objectx + 2
        Case "q"
            objectz = objectz - 2
        Case "e"
            objectz = objectz + 2
        Case "t"
            b = b + .1
        Case "g"
            b = b - .1
        Case "f"
            a = a - .1
        Case "h"
            a = a + .1
        Case "r"
            c = c - .1
        Case "y"
            c = c + .1
        Case "m"
            i% = (i% + 1) Mod 2
        Case Else
    End Select
    Cls
    Color 14
    Print "3D Experiment"
    Print
    Color 7
    Print "WSADQE - move"
    Print "TGFHRY - rotate"
    Select Case i%
        Case 0
            For k% = 0 To UBound(obj)
                Line (xcentre, ycentre)-(xdone(k%), ydone(k%)), obj(k%).clr
            Next
        Case 1
            Line (xcentre, ycentre)-(xcentre, ycentre), 0
            For k% = 0 To UBound(obj)
                Line -(xdone(k%), ydone(k%)), obj(k%).clr
            Next
        Case Else
    End Select
    PCopy 1, 0
    a = a + .01
    'b = b + .01
    'c = c + .01
    _Limit 60
Loop
'zxy
Data 0,0,0
Data 0,50,0
Data 0,50,50
Data 0,0,50
Data 0,0,0
Data 50,0,0
Data 50,50,0
Data 0,50,0
Data 0,0,0
Data 50,0,0
Data 50,0,50
Data 50,50,50
Data 50,50,0
Data 50,0,0
Data 50,0,50
Data 0,0,50
Data 0,50,50
Data 50,50,50
Data 50,0,50


