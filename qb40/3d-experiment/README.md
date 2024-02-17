Experimentation with 3d formulae in DOS.

The program demonstrates a cuboid which can be rotated and translated using
mentioned keys. The 3d formulae used are:

<br>

| Symbols                   | Meaning                                       |
| ------------------------- | --------------------------------------------- |
| objectx, objecty, objectz | point of rotation of object                   |
| camerax, cameray, cameraz | point of camera looking at the world you make |
| xpos, ypos, zpos          | position of pixel in the world coords         |
| a, b, c                   | angles around x, y, z axes                    |
| xscale, yscale            | scale factors for x, y axes                   |
| xcentre, ycentre          | centre of vision on the screen                |
| x, y                      | position of pixel on screen                   |

<br>

```
x1 = xpos - objectx
y1 = ypos - objecty
z1 = zpos - objectz
y2 = y1*cos(a) + z1*sin(a)
z2 = z1*cos(a) - y1*sin(a)
x2 = x1*cos(b) + z2*sin(b)
z3 = z2*cos(b) - x1*sin(b)
y3 = y2*cos(c) + x2*sin(c)
x3 = x2*cos(c) - y2*sin(c)
rx = objectx - camerax
ry = objectx - cameray
rz = objectz - cameraz
xf = rx + (xscale*x3) / (rz+z3)
yf = ry + (perspy*y3) / (rz+z3)
x = xf + xcentre
y = yf + ycentre
```

<br>

<img src="https://raw.githubusercontent.com/qb40/3d-experiment/gh-pages/0/image/0.png" width="70%"><br>
Cuboid in default position (keeps rotating).
<br>
<br>


<img src="https://raw.githubusercontent.com/qb40/3d-experiment/gh-pages/0/image/0.png" width="70%"><br>
Cuboid in moved position (translated, rotated).
<br>
<br>


[![qb40](https://i.imgur.com/xAWLn0I.jpg)](https://qb40.github.io)
