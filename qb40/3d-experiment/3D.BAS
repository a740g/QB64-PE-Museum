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
DIM sine(359), cosine(359)
FOR i% = 0 TO 359
sine(i%) = SIN((CSNG(i%) / 180) * 3.14)
cosine(i%) = COS((CSNG(i%) / 180) * 3.14)
NEXT
SCREEN 9, , 1, 0
TYPE objects
x AS SINGLE
y AS SINGLE
z AS SINGLE
clr AS INTEGER
END TYPE
DIM obj(18) AS objects
FOR i% = 0 TO UBOUND(obj)
RANDOMIZE TIMER
READ obj(i%).x, obj(i%).y, obj(i%).z
obj(i%).clr = i% MOD 256
NEXT

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

DIM xdone(UBOUND(obj)), ydone(UBOUND(obj))
i% = 1
a1 = TIMER
t = .01
DO
FOR j% = 0 TO UBOUND(obj)
x1 = obj(j%).x - objectx
y1 = obj(j%).y - objecty
z1 = obj(j%).z - objectz
y2 = y1 * COS(a) + z1 * SIN(a)
z2 = z1 * COS(a) - y1 * SIN(a)
x2 = x1 * COS(b) + z2 * SIN(b)
z3 = z2 * COS(b) - x1 * SIN(b)
y3 = y2 * COS(c) + x2 * SIN(c)
x3 = x2 * COS(c) - y2 * SIN(c)
rx = objectx - camerax
ry = objectx - cameray
rz = objectz - cameraz
xf = rx + (perspx * x3) / (rz + z3)
yf = ry + (perspy * y3) / (rz + z3)
xdone(j%) = xf + xcentre
ydone(j%) = yf + ycentre
NEXT
k$ = INKEY$
k$ = LCASE$(k$)
SELECT CASE k$
CASE CHR$(27)
SYSTEM
CASE "w"
objecty = objecty + 2
CASE "s"
objecty = objecty - 2
CASE "a"
objectx = objectx - 2
CASE "d"
objectx = objectx + 2
CASE "q"
objectz = objectz - 2
CASE "e"
objectz = objectz + 2
CASE "t"
b = b + .1
CASE "g"
b = b - .1
CASE "f"
a = a - .1
CASE "h"
a = a + .1
CASE "r"
c = c - .1
CASE "y"
c = c + .1
CASE "m"
i% = (i% + 1) MOD 2
CASE ELSE
END SELECT
CLS
COLOR 14
PRINT "3D Experiment"
PRINT
COLOR 7
PRINT "WSADQE - move"
PRINT "TGFHRY - rotate"
SELECT CASE i%
CASE 0
FOR k% = 0 TO UBOUND(obj)
LINE (xcentre, ycentre)-(xdone(k%), ydone(k%)), obj(k%).clr
NEXT
CASE 1
LINE (xcentre, ycentre)-(xcentre, ycentre), 0
FOR k% = 0 TO UBOUND(obj)
LINE -(xdone(k%), ydone(k%)), obj(k%).clr
NEXT
CASE ELSE
END SELECT
PCOPY 1, 0
a = a + .01
'b = b + .01
'c = c + .01
LOOP
'zxy
DATA 0,0,0
DATA 0,50,0
DATA 0,50,50
DATA 0,0,50
DATA 0,0,0
DATA 50,0,0
DATA 50,50,0
DATA 0,50,0
DATA 0,0,0
DATA 50,0,0
DATA 50,0,50
DATA 50,50,50
DATA 50,50,0
DATA 50,0,0
DATA 50,0,50
DATA 0,0,50
DATA 0,50,50
DATA 50,50,50
DATA 50,0,50


