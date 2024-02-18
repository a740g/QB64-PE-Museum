
DIM SHARED lX, lY, rXx, rY, mX, mY, ballX AS INTEGER, ballY AS INTEGER, m&, leftplr, rightplr
m& = _NEWIMAGE(320, 240, 32)
lX = 10: lY = 10: rXx = 310: rY = 10
ballX = 160: ballY = 10: mY = -1: IF RND * 10 > 5 THEN mX = 1 ELSE mX = -1



DIM SHARED dub AS LONG, aluminium AS LONG

PRINT "Loading textures..."
'ExtractPMF ("textures.pmf")

aluminium& = Hload("alum.jpg")
podl& = Hload("plovoucka.jpg")
str& = strop&
tokno& = okno&
dvere& = spajz_dvere&
lednice& = Hload("lednice2.jpg")
orech& = Hload("dekor orech.jpg")
orechsv& = Zesvetli("dekor orech.jpg")
polstr& = Hload("polstr.jpg")
dub& = Hload("dub.jpg")
tdub& = Ztmav("dub.jpg")
pc& = SHload("pccs.png")
kbd& = SHload("kbd.jpg")
mys& = SHload("mys.jpg")
woof& = SHload("repro.png")
speak& = Hload("speaker.jpg")
dlazba& = Hload("obklad.jpg")
dlazba2& = Hload("obklad 2.jpg")
sporakcelo = Hload("sporak-celo.jpg")
sporakvrch = Hload("sporak-vrch.jpg")
mikro& = SHload("mikro2.jpg")

DIM SHARED N
SCREEN _NEWIMAGE(_DESKTOPWIDTH, _DESKTOPHEIGHT, 32)

CX = 0: CY = 0: CZ = -1 '                                                          rotation center point - CAMERA
N = 1116 '432 pri modernizaci do JK!


TYPE V
    X AS SINGLE '                                                                  source X points in standard view
    Y AS SINGLE '                                                                  source Y points in standard view
    Z AS SINGLE '                                                                  not use yet
    pi AS SINGLE '                                                                 start draw position on radius
    piH AS SINGLE '                                                                pi for point on circle circuit position for look up / dn
    Radius AS SINGLE '                                                             radius (every point use own, but if is CX and CY in middle, are all the same)
    RadiusH AS SINGLE '                                                            radius floor / ceiling
    wX AS SINGLE '                                                                 working coordinates X
    wY AS SINGLE '                                                                 Y axis
    wZ AS SINGLE '                                                                 first Z. Used for view in previous program
    wZ2 AS SINGLE '                                                                second Z calculated from wZ
    T AS LONG '                                                                    texture number for current triangle
    Tm AS SINGLE '                                                                 texture multiplicier. 1 for one.
END TYPE


DIM SHARED v(1 TO N) AS V
DIM SHARED OldMouseX AS INTEGER, OldMouseY AS INTEGER
WHILE _MOUSEINPUT: WEND
_FULLSCREEN
_MOUSEMOVE _DESKTOPWIDTH / 2, _DESKTOPHEIGHT / 2
OldMouseX = _DESKTOPWIDTH / 2
OldMouseY = _DESKTOPHEIGHT / 2


'         A          B        C         D
DATA -10,-2,-5,-10,-2,10,10,-2,-5,10,-2,10: ' floor coordinates
DATA -10,2,-5,-10,2,10,10,2,-5,10,2,10: '     roof coordinates
DATA -10,-2,-5,-10,-2,10,-10,2,-5,-10,2,10: ' wall + window
DATA -5,-2,8,-10,-2,8,-5,2,8,-10,2,8
'refrigerator
DATA -5,-2,8,-5,-2.1,10,-5,2.1,8,-5,2,10
DATA -5,-3,10,10,-3,10,-5,3,10,10,3,10
DATA -4.8,-2,8,-3,-2,8,-4.8,1,8,-3,1,8
DATA -5,1,8,-3,1,8,-5,1,10,-3,1,10
DATA -3,1,8,-3,1,10,-3,-2,8,-3,-2,10
DATA -4.8,1,8,-4.8,1,10,-4.8,-2,8,-4.8,-2,10
'bench
DATA -2.8,-1.5,8,-2.8,-1.5,9,-2.8,-2,8,-2.8,-2,9
DATA -2.7,-1.5,8,-2.7,-1.5,9,-2.7,-2,8,-2.7,-2,9
DATA 0.8,-1.5,8,0.8,-1.5,9,0.8,-2,8,0.8,-2,9
DATA 0.7,-1.5,8,0.7,-1.5,9,0.7,-2,8,0.7,-2,9
DATA 0.7,-1.5,8,0.8,-1.5,8,.7,-2,8,0.8,-2,8
DATA -2.7,-1.5,8,-2.8,-1.5,8,-2.7,-2,8,-2.8,-2,8
DATA 2,-1.5,8,-3.0,-1.5,8,2,-1.5,10.5,-3.0,-1.5,10.5
DATA 4.39,-1.5,9.5,-3,-1.5,9.5,4.39,0,10,-3,0,10
DATA 1.9,-1.5,10,4.4,-1.5,10,1.9,-1.5,3,4.4,-1.5,3
DATA 3.9,-1.5,10,3.9,-1.5,3,4.4,0,10,4.4,0,3
DATA 1.9,-1.5,8,3.9,-1.5,8,1.9,-2,8,3.9,-2,8
DATA 1.9,-1.5,7.9,3.9,-1.5,7.9,1.9,-2,7.9,3.9,-2,7.9
DATA 1.9,-1.5,8,1.9,-1.5,7.9,1.9,-2,8,1.9,-2,7.9
DATA 1.9,-2,3,4.4,-2,3,1.9,-1.5,3,4.4,-1.5,3
DATA 1.9,-2,3.1,4.4,-2,3.1,1.9,-1.5,3.1,4.4,-1.5,3.1
DATA 4.4,-2,3.1,4.4,-2,3,4.4,-1.5,3.1,4.4,-1.5,3
DATA 1.9,-2,3.1,1.9,-2,3,1.9,-1.5,3.1,1.9,-1.5,3
DATA 3.9,-1.5,3,4.4,-1.5,3,4.4,0,3,4.4,0,3
DATA 4.4,-2,10,4.4,-2,3,4.4,0,10,4.4,0,3
DATA 1.5,-2,7.5,1.7,-2,7.5,1.5,-1,7.5,1.7,-1,7.5
DATA 1.5,-2,7.3,1.7,-2,7.3,1.5,-1,7.3,1.7,-1,7.3
DATA 1.5,-2,7.3,1.5,-1,7.3,1.5,-2,7.5,1.5,-1,7.5
DATA 1.7,-2,7.3,1.7,-1,7.3,1.7,-2,7.5,1.7,-1,7.5
DATA -2,-2,7.5,-2.2,-2,7.5,-2,-1,7.5,-2.2,-1,7.5
DATA -2,-2,7.3,-2.2,-2,7.3,-2,-1,7.3,-2.2,-1,7.3
DATA -2,-2,7.3,-2,-1,7.3,-2,-2,7.5,-2,-1,7.5
DATA -2.2,-2,7.3,-2.2,-1,7.3,-2.2,-2,7.5,-2.2,-1,7.5
DATA 1.5,-2,3.5,1.7,-2,3.5,1.5,-1,3.5,1.7,-1,3.5
DATA 1.5,-2,3.7,1.7,-2,3.7,1.5,-1,3.7,1.7,-1,3.7
DATA 1.5,-2,3.7,1.5,-1,3.7,1.5,-2,3.5,1.5,-1,3.5
DATA 1.7,-2,3.7,1.7,-1,3.7,1.7,-2,3.5,1.7,-1,3.5
DATA -2,-2,3.5,-2.2,-2,3.5,-2,-1,3.5,-2.2,-1,3.5
DATA -2,-2,3.7,-2.2,-2,3.7,-2,-1,3.7,-2.2,-1,3.7
DATA -2,-2,3.7,-2,-1,3.7,-2,-2,3.5,-2,-1,3.5
DATA -2.2,-2,3.7,-2.2,-1,3.7,-2.2,-2,3.5,-2.2,-1,3.5
DATA 1.5,-1,3.5,-2,-1,3.5,1.5,-1.1,3.5,-2,-1.1,3.5
DATA 1.5,-1,7.5,-2,-1,7.5,1.5,-1.1,7.5,-2,-1.1,7.5
DATA 1.7,-1,3.5,1.7,-1,7.5,1.7,-1.1,3.5,1.7,-1.1,7.5
DATA -2.2,-1,3.5,-2.2,-1,7.5,-2.2,-1.1,3.5,-2.2,-1.1,7.5
'desk
DATA 1.8,-1,3.4,-2.3,-1,3.4,1.8,-1,7.6,-2.3,-1,7.6
DATA 1.8,-.9,3.4,-2.3,-.9,3.4,1.8,-.9,7.6,-2.3,-.9,7.6
DATA 1.8,-.9,3.4,-2.3,-.9,3.4,1.8,-1,3.4,-2.3,-1,3.4
DATA 1.8,-.9,7.6,-2.3,-.9,7.6,1.8,-1,7.6,-2.3,-1,7.6
DATA 1.8,-.9,3.4,1.8,-1,3.4,1.8,-.9,7.6,1.8,-1,7.6
DATA -2.3,-.9,3.4,-2.3,-1,3.4,-2.3,-.9,7.6,-2.3,-1,7.6
'chair
DATA .3,-2,3.9,.4,-2,3.9,.3,-1.5,3.9,.4,-1.5,3.9
DATA .3,-2,3.8,.4,-2,3.8,.3,-1.5,3.8,.4,-1.5,3.8
DATA .3,-2,3.8,.3,-2,3.9,.3,-1.5,3.8,.3,-1.5,3.9
DATA .4,-2,3.8,.4,-2,3.9,.4,-1.5,3.8,.4,-1.5,3.9
DATA -.7,-2,3.9,-.8,-2,3.9,-.7,-1.5,3.9,-.8,-1.5,3.9
DATA -.7,-2,3.8,-.8,-2,3.8,-.7,-1.5,3.8,-.8,-1.5,3.8
DATA -.7,-2,3.8,-.7,-2,3.9,-.7,-1.5,3.8,-.7,-1.5,3.9
DATA -.8,-2,3.8,-.8,-2,3.9,-.8,-1.5,3.8,-.8,-1.5,3.9
DATA .3,-2,3,.4,-2,3,.3,-1.5,3,.4,-1.5,3
DATA .3,-2,3.1,.4,-2,3.1,.3,-1.5,3.1,.4,-1.5,3.1
DATA .3,-2,3.1,.3,-2,3,.3,-1.5,3.1,.3,-1.5,3
DATA .4,-2,3.1,.4,-2,3,.4,-1.5,3.1,.4,-1.5,3
DATA -.7,-2,3,-.8,-2,3,-.7,-1.5,3,-.8,-1.5,3
DATA -.7,-2,3.1,-.8,-2,3.1,-.7,-1.5,3.1,-.8,-1.5,3.1
DATA -.7,-2,3.1,-.7,-2,3,-.7,-1.5,3.1,-.7,-1.5,3
DATA -.8,-2,3.1,-.8,-2,3,-.8,-1.5,3.1,-.8,-1.5,3
DATA .5,-1.5,4.1,-.9,-1.5,4.1,.5,-1.5,2.9,-.9,-1.5,2.9
DATA .5,-1.4,4.1,-.9,-1.4,4.1,.5,-1.4,2.9,-.9,-1.4,2.9
DATA .5,-1.5,4.1,-.9,-1.5,4.1,.5,-1.4,4.1,-.9,-1.4,4.1
DATA .5,-1.5,2.9,-.9,-1.5,2.9,.5,-1.4,2.9,-.9,-1.4,2.9
DATA -.9,-1.5,2.9,-.9,-1.4,2.9,-.9,-1.5,4.1,-.9,-1.4,4.1
DATA .5,-1.5,2.9,.5,-1.4,2.9,.5,-1.5,4.1,.5,-1.4,4.1
DATA -.9,-1.5,2.9,.5,-1.5,2.9,-.9,0,2.7,.5,0,2.7
DATA -.9,-1.5,3,.5,-1.5,3,-.9,0,2.8,.5,0,2.8
DATA -.9,-1.5,2.9,-.9,-1.5,3,-.9,0,2.7,-.9,0,2.8
DATA -.9,0,2.9,.5,0,2.9,-.9,0,2.7,.5,0,2.7
DATA .5,-1.5,2.9,.5,-1.5,3,.5,0,2.7,.5,0,2.8

'chair 2
DATA -1.3,-2,4.9,-1.4,-2,4.9,-1.3,-1.5,4.9,-1.4,-1.5,4.9
DATA -1.3,-2,4.8,-1.4,-2,4.8,-1.3,-1.5,4.8,-1.4,-1.5,4.8
DATA -1.3,-2,4.8,-1.3,-2,4.9,-1.3,-1.5,4.8,-1.3,-1.5,4.9
DATA -1.4,-2,4.8,-1.4,-2,4.9,-1.4,-1.5,4.8,-1.4,-1.5,4.9
DATA -1.3,-2,5.9,-1.4,-2,5.9,-1.3,-1.5,5.9,-1.4,-1.5,5.9
DATA -1.3,-2,5.8,-1.4,-2,5.8,-1.3,-1.5,5.8,-1.4,-1.5,5.8
DATA -1.3,-2,5.8,-1.3,-2,5.9,-1.3,-1.5,5.8,-1.3,-1.5,5.9
DATA -1.4,-2,5.8,-1.4,-2,5.9,-1.4,-1.5,5.8,-1.4,-1.5,5.9
DATA -2.3,-2,4.9,-2.4,-2,4.9,-2.3,-1.5,4.9,-2.4,-1.5,4.9
DATA -2.3,-2,4.8,-2.4,-2,4.8,-2.3,-1.5,4.8,-2.4,-1.5,4.8
DATA -2.3,-2,4.8,-2.3,-2,4.9,-2.3,-1.5,4.8,-2.3,-1.5,4.9
DATA -2.4,-2,4.8,-2.4,-2,4.9,-2.4,-1.5,4.8,-2.4,-1.5,4.9
DATA -2.3,-2,5.9,-2.4,-2,5.9,-2.3,-1.5,5.9,-2.4,-1.5,5.9
DATA -2.3,-2,5.8,-2.4,-2,5.8,-2.3,-1.5,5.8,-2.4,-1.5,5.8
DATA -2.3,-2,5.8,-2.3,-2,5.9,-2.3,-1.5,5.8,-2.3,-1.5,5.9
DATA -2.4,-2,5.8,-2.4,-2,5.9,-2.4,-1.5,5.8,-2.4,-1.5,5.9
DATA -1.2,-1.5,4.7,-2.5,-1.5,4.7,-1.2,-1.5,6,-2.5,-1.5,6
DATA -1.2,-1.4,4.7,-2.5,-1.4,4.7,-1.2,-1.4,6,-2.5,-1.4,6
DATA -1.2,-1.5,4.7,-2.5,-1.5,4.7,-1.2,-1.4,4.7,-2.5,-1.4,4.7
DATA -1.2,-1.5,6,-2.5,-1.5,6,-1.2,-1.4,6,-2.5,-1.4,6
DATA -1.2,-1.5,4.7,-1.2,-1.4,4.7,-1.2,-1.5,6,-1.2,-1.4,6
DATA -2.5,-1.5,4.7,-2.5,-1.4,4.7,-2.5,-1.5,6,-2.5,-1.4,6
DATA -2.3,-1.5,4.7,-2.3,-1.5,6,-2.5,0,4.7,-2.5,0,6
DATA -2.4,-1.5,4.7,-2.4,-1.5,6,-2.6,0,4.7,-2.6,0,6
DATA -2.3,-1.5,4.7,-2.5,-1.5,4.7,-2.5,0,4.7,-2.7,0,4.7
DATA -2.3,-1.5,6,-2.5,-1.5,6,-2.5,0,6,-2.7,0,6
'here is wall at the computer
DATA 10,-2,-5,10,-2,0,10,2.1,-5,10,2.1,0
DATA 10,-2,5,10,-2,0,10,2,5,10,2,0
DATA 10,-2,10,10,-2,5,10,2.1,10,10,2.1,5
'here is the PC table
DATA 10,-2,8,9.8,-2,8,10,-.7,8,9.8,-.7,8
DATA 9.8,-2,8,9.8,-.7,8,9.8,-2,10,9.8,-.7,10
DATA 4.4,-2,8,4.6,-2,8,4.4,-.7,8,4.6,-.7,8
DATA 4.6,-2,8,4.6,-.7,8,4.6,-2,10,4.6,-.7,10
DATA 9.8,-.7,9.8,4.6,-.7,9.8,9.8,-1.5,9.8,4.6,-1.5,9.8
DATA 9.8,-1.5,9.8,4.6,-1.5,9.8,9.8,-1.5,10,4.6,-1.5,10
DATA 7.5,-2,8,7.7,-2,8,7.5,-.7,8,7.7,-.7,8
DATA 7.5,-2,8,7.5,-.7,8,7.5,-2,9.8,7.5,-.7,9.8
DATA 7.7,-2,8,7.7,-.7,8,7.7,-2,9.8,7.7,-.7,9.8
DATA 9.8,-2,8.3,7.5,-2,8.3,9.8,-1.8,8.3,7.5,-1.8,8.3
DATA 9.8,-1.75,8.1,7.5,-1.75,8.1,9.8,-1.25,8.1,7.5,-1.25,8.1
DATA 9.8,-1.2,8.1,7.5,-1.2,8.1,9.8,-.9,8.1,7.5,-.9,8.1
DATA 9.8,-1.75,8.1,7.5,-1.75,8.1,9.8,-1.75,9,7.5,-1.75,9
DATA 9.8,-1.2,8.1,7.5,-1.2,8.1,9.8,-1.2,9,7.5,-1.2,9
DATA 9.8,-.9,8.1,7.5,-.9,8.1,9.8,-.9,9,7.5,-.9,9
DATA 9.8,-2,9.8,7.5,-2,9.8,9.8,-.7,9.8,7.5,-.7,9.8
DATA 10,-.7,7.9,4.4,-.7,7.9,10,-.5,7.9,4.4,-.5,7.9
DATA 10,-.7,7.9,4.4,-.7,7.9,10,-.7,10,4.4,-.7,10
DATA 10,-.5,7.9,4.4,-.5,7.9,10,-.5,10,4.4,-.5,10
'compputer
DATA 5,-2,8,5,-2,8.5,5,-1.5,8,5,-1.5,8.5
DATA 5,-1.5,8,5,-1.5,8.5,4.7,-1.5,8,4.7,-1.5,8.5
DATA 4.7,-2,8,4.7,-2,8.5,4.7,-1.5,8,4.7,-1.5,8.5
DATA 4.7,-2,8,5,-2,8,4.7,-1.5,8,5,-1.5,8
'monitor
DATA 9.7,-.3,8.5,7.7,-.3,9.6,9.7,1,8.5,7.7,1,9.6
DATA 9.7,-.3,8.6,9.7,1,8.6,7.7,-.3,9.7,7.7,1,9.7
DATA 7.7,-.3,9.6,7.7,1,9.6,7.7,-.3,9.7,7.7,1,9.7
DATA 9.7,-.3,8.6,9.7,-.5,8.6,7.7,-.3,9.7,7.7,-.5,9.7
DATA 9.2,-.49,8.6,8.2,-.49,8.6,9.2,-.49,10,8.2,-.49,10
'keyboard
DATA 6.5,-.45,7.9,5.7,-.45,7.9,6.5,-.39,8.2,5.7,-.39,8.2: 'just shifted in space a 2D texture, not really 3D
DATA 5.3,-.45,7.9,5,-.45,7.9,5.3,-.39,8,5,-.39,8: 'mouse - as keyboard
'subwoofer
DATA 7.4,-2,9.8,7.4,-2,9,7.4,-1.5,9.8,7.4,-1.5,9
DATA 7,-2,9.8,7,-2,9,7,-1.5,9.8,7,-1.5,9
DATA 7.4,-2,9.8,7,-2,9.8,7.4,-1.5,9.8,7,-1.5,9.8
DATA 7.4,-1.5,9.8,7,-1.5,9.8,7.4,-1.5,9,7,-1.5,9
DATA 7.4,-2,9,7,-2,9,7.4,-1.5,9,7,-1.5,9
'speaker right
DATA 4.7,-.5,10,4.7,0,10,4.7,-.5,9.7,4.7,0,9.7
DATA 4.41,-.5,10,4.41,0,10,4.41,-.5,9.7,4.41,0,9.7
DATA 4.41,0,10,4.41,0,9.7,4.7,0,10,4.7,0,9.7
DATA 4.7,-.5,9.7,4.41,-.5,9.7,4.7,0,9.7,4.41,0,9.7
'speaker left
DATA 6.7,-.5,10,6.7,0,10,6.7,-.5,9.7,6.7,0,9.7
DATA 6.41,-.5,10,6.41,0,10,6.41,-.5,9.7,6.41,0,9.7
DATA 6.41,0,10,6.41,0,9.7,6.7,0,10,6.7,0,9.7
DATA 6.7,-.5,9.7,6.41,-.5,9.7,6.7,0,9.7,6.41,0,9.7

'wall with kitchen unit, again walls with doors first
DATA 10,-2,-5,5,-2,-5,10,2,-5,5,2,-5
DATA -10,-2,-4.99,7,-2,-4.99,-10,1,-4.99,7,1,-4.99
DATA -10,2,-4.99,7,2,-4.99,-10,1,-4.99,7,1,-4.99
DATA 5,-2,-3.5,7,-2,-3.5,5,-0.5,-3.5,7,-0.5,-3.5
DATA 5,-.5,-3.5,7,-.5,-3.5,5,-.5,-4.9,7,-.5,-4.9
DATA 5,-2,-3.5,5,-.5,-3.5,5,-2,-4.9,5,-.5,-4.9
DATA 7,-2,-3.5,7,-.5,-3.5,7,-2,-4.9,7,-.5,-4.9
DATA 5,-2,-4.9,7,-2,-4.9,5,-0.5,-4.9,7,-0.5,-4.9

'gas cooker
DATA 4.9,-2,-4.9,4.9,-.5,-4.9,4.9,-2,-3.5,4.9,-.5,-3.5
DATA 4.9,-.5,-3.4,-2.99,-.5,-3.4,4.9,-.5,-4.9,-2.99,-.5,-4.9
DATA 4.9,-.6,-3.4,-2.99,-.6,-3.4,4.9,-.6,-4.9,-2.99,-.6,-4.9
DATA 4.9,-.6,-3.4,-2.99,-.6,-3.4,4.9,-.5,-3.4,-2.99,-.5,-3.4
DATA 4.9,1.6,-3.7,-9.99,1.6,-3.7,4.9,1.6,-4.9,-9.99,1.6,-4.9
DATA 4.9,1.7,-3.7,-9.99,1.7,-3.7,4.9,1.7,-4.9,-9.99,1.7,-4.9
DATA 4.9,1.7,-3.7,-9.99,1.7,-3.7,4.9,1.6,-3.7,-9.99,1.6,-3.7
DATA 4.9,.6,-3.7,-9.99,.6,-3.7,4.9,.6,-4.9,-9.99,.6,-4.9
DATA 4.9,.7,-3.7,-9.99,.7,-3.7,4.9,.7,-4.9,-9.99,.7,-4.9
DATA 4.9,.7,-3.7,-9.99,.7,-3.7,4.9,.6,-3.7,-9.99,.6,-3.7
DATA 4.9,-2,-3.5,4.9,-.5,-3.5,4.8,-2,-3.5,4.8,-.5,-3.5
DATA 4.9,1.7,-3.7,4.9,.6,-3.7,4.9,1.7,-4.9,4.9,.6,-4.9
DATA 4.9,1.7,-3.7,4.9,.6,-3.7,4.8,1.7,-3.7,4.8,.6,-3.7
DATA 1.9,1.7,-3.7,1.9,.6,-3.7,1.8,1.7,-3.7,1.8,.6,-3.7
DATA 1.9,-2,-3.7,1.9,-.6,-3.7,1.8,-2,-3.7,1.8,-.6,-3.7
DATA 2.9,1.7,-3.7,2.9,.6,-3.7,2.8,1.7,-3.7,2.8,.6,-3.7
DATA 2.9,-2,-3.7,2.9,-.6,-3.7,2.8,-2,-3.7,2.8,-.6,-3.7
DATA 3.9,1.7,-3.7,3.9,.6,-3.7,3.8,1.7,-3.7,3.8,.6,-3.7
DATA 3.9,-2,-3.7,3.9,-.6,-3.7,3.8,-2,-3.7,3.8,-.6,-3.7
DATA 0.9,1.7,-3.7,0.9,.6,-3.7,0.8,1.7,-3.7,0.8,.6,-3.7
DATA 0.9,-2,-3.7,0.9,-.6,-3.7,0.8,-2,-3.7,0.8,-.6,-3.7
DATA -5.9,1.7,-3.7,-5.9,.6,-3.7,-5.8,1.7,-3.7,-5.8,.6,-3.7
DATA -5.9,-2,-3.7,-5.9,-.6,-3.7,-5.8,-2,-3.7,-5.8,-.6,-3.7
DATA -1.9,1.7,-3.7,-1.9,.6,-3.7,-1.8,1.7,-3.7,-1.8,.6,-3.7
DATA -1.9,-2,-3.7,-1.9,-.6,-3.7,-1.8,-2,-3.7,-1.8,-.6,-3.7
DATA -2.9,1.7,-3.7,-2.9,.6,-3.7,-2.8,1.7,-3.7,-2.8,.6,-3.7
DATA -2.9,-2,-3.7,-2.9,-.6,-3.7,-2.8,-2,-3.7,-2.8,-.6,-3.7
DATA -3.9,1.7,-3.7,-3.9,.6,-3.7,-3.8,1.7,-3.7,-3.8,.6,-3.7
DATA -3.9,-2,-3.7,-3.9,-.6,-3.7,-3.8,-2,-3.7,-3.8,-.6,-3.7
DATA -4.9,1.7,-3.7,-4.9,.6,-3.7,-4.8,1.7,-3.7,-4.8,.6,-3.7
DATA -4.9,-2,-3.7,-4.9,-.6,-3.7,-4.8,-2,-3.7,-4.8,-.6,-3.7
DATA -0.9,1.7,-3.7,-0.9,.6,-3.7,-0.8,1.7,-3.7,-0.8,.6,-3.7
DATA -0.9,-2,-3.7,-0.9,-.6,-3.7,-0.8,-2,-3.7,-0.8,-.6,-3.7
DATA -5.9,1.7,-3.7,-5.9,.6,-3.7,-5.8,1.7,-3.7,-5.8,.6,-3.7
DATA -5.9,-2,-3.7,-5.9,-.6,-3.7,-5.8,-2,-3.7,-5.8,-.6,-3.7
DATA -6.9,1.7,-3.7,-6.9,.6,-3.7,-6.8,1.7,-3.7,-6.8,.6,-3.7
DATA -6.9,-2,-3.7,-6.9,-.6,-3.7,-6.8,-2,-3.7,-6.8,-.6,-3.7
DATA -9.99,-.5,-3.4,-3.7,-.5,-3.4,-9.99,-.5,-4.9,-3.7,-.5,-4.9
DATA -9.99,-.6,-3.4,-3.7,-.6,-3.4,-9.99,-.6,-4.9,-3.7,-.6,-4.9
DATA -9.99,-.6,-3.4,-3.7,-.6,-3.4,-9.99,-.5,-3.4,-3.7,-.5,-3.4
DATA -3.7,-.6,-3.4,-2.99,-.6,-3.4,-3.7,-.5,-3.4,-2.99,-.5,-3.4
DATA -3.7,-.5,-3.4,-2.99,-.5,-3.4,-3.7,-.5,-3.75,-2.99,-.5,-3.75
DATA -3.7,-.5,-4.7,-2.99,-.5,-4.7,-3.7,-.5,-4.9,-2.99,-.5,-4.9
'SINK:
DATA -3.7,-.5,-3.75,-2.99,-.5,-3.75,-3.7,-.9,-3.75,-2.99,-.9,-3.75
DATA -3.7,-.5,-4.7,-2.99,-.5,-4.7,-3.7,-.9,-4.7,-2.99,-.9,-4.7
DATA -3.7,-.5,-3.75,-3.7,-.5,-4.7,-3.7,-.9,-3.75,-3.7,-.9,-4.7
DATA -2.99,-.5,-3.75,-2.99,-.5,-4.7,-2.99,-.9,-3.75,-2.99,-.9,-4.7
DATA -3.7,-.9,-3.75,-3.7,-.9,-4.7,-2.99,-.9,-3.75,-2.99,-.9,-4.7


DATA -3.2,-.1,-4.89,-3.5,-.1,-4.89,-3.2,-.1,-4.69,-3.5,-.1,-4.69
DATA -3.2,-.2,-4.89,-3.5,-.2,-4.89,-3.2,-.2,-4.69,-3.5,-.2,-4.69
DATA -3.2,-.1,-4.69,-3.5,-.1,-4.69,-3.2,-.2,-4.69,-3.5,-.2,-4.69
DATA -3.2,-.1,-4.69,-3.2,-.2,-4.69,-3.2,-.1,-4.89,-3.2,-.2,-4.89
DATA -3.5,-.1,-4.69,-3.5,-.2,-4.69,-3.5,-.1,-4.89,-3.5,-.2,-4.89

DATA -10.1,-2,-4.9,4.9,-2,-4.9,-10.1,-.49,-4.9,4.9,-.49,-4.9
DATA -10.1,-1.99,-5,4.9,-1.99,-5,-10.1,-1.99,-3.7,4.9,-1.99,-3.7
DATA -10.1,.8,-4.9,4.9,.8,-4.9,-10.1,1.6,-4.9,4.9,1.6,-4.9
'cabinet doors
DATA 1.85,1.55,-3.71,1.85,0.6,-3.71,2.8,1.55,-3.71,2.8,0.6,-3.71
DATA 1.85,-1.9,-3.71,1.85,-0.6,-3.71,2.8,-1.9,-3.71,2.8,-.6,-3.71
DATA 2.85,1.55,-3.71,2.85,0.6,-3.71,3.8,1.55,-3.71,3.8,0.6,-3.71
DATA 2.85,-1.9,-3.71,2.85,-0.6,-3.71,3.8,-1.9,-3.7,3.8,-.6,-3.71
DATA 3.85,1.55,-3.71,3.85,0.6,-3.71,4.8,1.55,-3.71,4.8,0.6,-3.71
DATA 3.85,-1.9,-3.71,3.85,-0.6,-3.71,4.8,-1.9,-3.71,4.8,-.6,-3.71
DATA .85,1.55,-3.71,.85,0.6,-3.71,1.8,1.55,-3.71,1.8,0.6,-3.71
DATA .85,-1.9,-3.71,.85,-0.6,-3.71,1.8,-1.9,-3.71,1.8,-.6,-3.71
DATA -1.85,1.55,-3.71,-1.85,0.6,-3.71,-2.8,1.55,-3.71,-2.8,0.6,-3.71
DATA -1.85,-1.9,-3.71,-1.85,-0.6,-3.71,-2.8,-1.9,-3.71,-2.8,-.6,-3.71
DATA -2.85,1.55,-3.71,-2.85,0.6,-3.71,-3.8,1.55,-3.71,-3.8,0.6,-3.71
DATA -2.85,-1.9,-3.71,-2.85,-0.6,-3.71,-3.8,-1.9,-3.7,-3.8,-.6,-3.71
DATA -3.85,1.55,-3.71,-3.85,0.6,-3.71,-4.8,1.55,-3.71,-4.8,0.6,-3.71
DATA -3.85,-1.9,-3.71,-3.85,-0.6,-3.71,-4.8,-1.9,-3.71,-4.8,-.6,-3.71
DATA -.85,1.55,-3.71,-.85,0.6,-3.71,-1.8,1.55,-3.71,-1.8,0.6,-3.71
DATA -.85,-1.9,-3.71,-.85,-0.6,-3.71,-1.8,-1.9,-3.71,-1.8,-.6,-3.71
DATA -4.85,1.55,-3.71,-4.85,0.6,-3.71,-5.8,1.55,-3.71,-5.8,0.6,-3.71
DATA -4.85,-1.9,-3.71,-4.85,-0.6,-3.71,-5.8,-1.9,-3.7,-5.8,-.6,-3.71
DATA -5.85,1.55,-3.71,-5.85,0.6,-3.71,-6.8,1.55,-3.71,-6.8,0.6,-3.71
DATA -5.85,-1.9,-3.71,-5.85,-0.6,-3.71,-6.8,-1.9,-3.71,-6.8,-.6,-3.71
DATA -6.85,1.55,-3.71,-6.85,0.6,-3.71,-7.8,1.55,-3.71,-7.8,0.6,-3.71
DATA -6.85,-1.9,-3.71,-6.85,-0.6,-3.71,-7.8,-1.9,-3.71,-7.8,-.6,-3.71
DATA -9.98,-2,-5,-9.98,1,-5,-9.98,-2,0,-9.98,1,0
DATA -9.97,-0.5,-3.4,-8.47,-.5,-3.4,-9.97,-0.5,0,-8.47,-.5,0
DATA -9.97,-0.6,-3.4,-8.47,-.6,-3.4,-9.97,-0.6,0,-8.47,-.6,0
DATA -9.97,.6,-3.7,-8.77,.6,-3.7,-9.97,.6,0,-8.77,.6,0
DATA -9.97,.7,-3.7,-8.77,.7,-3.7,-9.97,.7,0,-8.77,.7,0
DATA -9.97,1.6,-3.7,-8.77,1.6,-3.7,-9.97,1.6,0,-8.77,1.6,0
DATA -9.97,1.7,-3.7,-8.77,1.7,-3.7,-9.97,1.7,0,-8.77,1.7,0
DATA -9.97,-2,0,-8.77,-2,0,-9.97,-0.6,0,-8.77,-0.6,0
DATA -9.97,1.6,0,-8.77,1.6,0,-9.97,0.7,0,-8.77,0.7,0
DATA -9.97,-2,-.2,-8.77,-2,-.2,-9.97,-0.6,-.2,-8.77,-0.6,-.2
DATA -9.97,1.6,-.2,-8.77,1.6,-.2,-9.97,0.7,-.2,-8.77,0.7,-.2
DATA -9.97,1.7,0,-8.77,1.7,0,-9.97,1.6,0,-8.77,1.6,0
DATA -9.97,-.5,0,-8.47,-.5,0,-9.97,-.6,0,-8.47,-.6,0
DATA -9.97,.6,0,-8.77,.6,0,-9.97,.7,0,-8.77,.7,0
DATA -8.77,1.7,0,-8.77,1.6,0,-8.77,1.7,-3.7,-8.77,1.6,-3.7
DATA -8.47,-.5,0,-8.47,-.6,0,-8.47,-0.5,-3.7,-8.47,-0.6,-3.7
DATA -8.77,.7,0,-8.77,.6,0,-8.77,.7,-3.7,-8.77,.6,-3.7
DATA -8.77,-2,0,-8.77,-.6,0,-8.77,-2,-0.2,-8.77,-.6,-0.2
DATA -8.77,1.6,0,-8.77,.7,0,-8.77,1.6,-0.2,-8.77,.7,-0.2
DATA -8.77,-2,-1.9,-8.77,-.6,-1.9,-8.77,-2,-2,-8.77,-.6,-2
DATA -8.77,1.6,-1.9,-8.77,.7,-1.9,-8.77,1.6,-2,-8.77,.7,-2
DATA -8.77,-1.99,0,-9.97,-1.99,0,-8.77,-1.99,-3.7,-9.97,-1.99,-3.7
DATA -9.97,-2,0,-9.97,-2,-4.9,-9.97,-.5,0,-9.97,-.5,-4.9
DATA -9.97,1.6,0,-9.97,1.6,-4.9,-9.97,.6,0,-9.97,.6,-4.9
DATA -8.77,-2,-3.7,-8.77,-.6,-3.7,-8.77,-2,-3.6,-8.77,-.6,-3.6
DATA -8.77,1.6,-3.7,-8.77,.7,-3.7,-8.77,1.6,-3.6,-8.77,.7,-3.6

DATA -8.77,-1.9,-2,-8.77,-.6,-2,-8.77,-1.9,-3.6,-8.77,-.6,-3.6
DATA -8.77,1.6,-2,-8.77,.7,-2,-8.77,1.6,-3.6,-8.77,.7,-3.6

DATA -8.77,-1.9,-.2,-8.77,-.6,-.2,-8.77,-1.9,-1.9,-8.77,-.6,-1.9
DATA -8.77,1.6,-.2,-8.77,.7,-.2,-8.77,1.6,-1.9,-8.77,.7,-1.9: 'glased doors
DATA -7.85,1.55,-3.71,-7.85,0.6,-3.71,-8.8,1.55,-3.71,-8.8,0.6,-3.71
DATA -7.85,-1.9,-3.71,-7.85,-0.6,-3.71,-8.8,-1.9,-3.71,-8.8,-.6,-3.71
DATA .85,1.55,-3.71,.85,0.6,-3.71,-.85,1.55,-3.71,-.85,0.6,-3.71
DATA .85,-1.9,-3.71,.85,-0.6,-3.71,-.85,-1.9,-3.71,-.85,-.6,-3.71

'microwave

DATA -9,-.5,-4.1,-8,-.5,-4.1,-9,0,-4.1,-8,0,-4.1
DATA -9,-.5,-4.9,-8,-.5,-4.9,-9,0,-4.9,-8,0,-4.9
DATA -9,0,-4.1,-8,0,-4.1,-9,0,-4.9,-8,0,-4.9
DATA -9,0,-4.1,-9,-.5,-4.1,-9,0,-4.9,-9,-.5,-4.9
DATA -8,0,-4.1,-8,-.5,-4.1,-8,0,-4.9,-8,-.5,-4.9





FOR r = 1 TO N
    READ v(r).X, v(r).Y, v(r).Z 'all is placed on the same Y = the same floor
NEXT r

Set_texture podl&, 1, 4, 15 'set image img as texture for bottom  (triangles 1 to 4)
Set_texture str&, 5, 8, 3
Set_texture tokno&, 9, 12, 1
Set_texture dvere&, 13, 16, 1
Set_texture white&, 17, 20, 1
Set_texture white&, 21, 24, 1
Set_texture lednice&, 25, 28, 1
Set_texture white&, 29, 32, 1
Set_texture Swhite&, 33, 36, 1
Set_texture Swhite&, 37, 40, 1
Set_texture orech&, 41, 44, 10
Set_texture orech&, 45, 48, 10

Set_texture orech&, 49, 52, 10
Set_texture orech&, 53, 56, 10
Set_texture orech&, 57, 60, 10
Set_texture orech&, 61, 64, 10
Set_texture polstr&, 65, 68, 3

Set_texture polstr&, 69, 72, 3
Set_texture polstr&, 73, 76, 3
Set_texture polstr&, 77, 80, 3
Set_texture orech&, 81, 84, 10
Set_texture orech&, 85, 88, 10
Set_texture orech&, 89, 92, 10
Set_texture orech&, 93, 96, 3
Set_texture orech&, 97, 100, 3
Set_texture orech&, 101, 104, 1
Set_texture orech&, 105, 108, 1
Set_texture orech&, 109, 112, 1
Set_texture orech&, 113, 116, 7

Set_texture orech&, 117, 120, 1
Set_texture orech&, 121, 204, 2
Set_texture orechsv&, 205, 220, 1
Set_texture orech&, 221, 292, 1

Set_texture orechsv&, 293, 308, 1
Set_texture orech&, 309, 316, 1
Set_texture orechsv&, 317, 328, 1
Set_texture orech&, 329, 400, 1
Set_texture orechsv&, 401, 416, 1
Set_texture orech&, 417, 424, 1
Set_texture orechsv&, 425, 432, 1
'po upgradu
Set_texture white&, 433, 437, 1
Set_texture dvere&, 437, 440, 1
Set_texture white&, 441, 444, 1
Set_texture dub&, 445, 453, 1
Set_texture tdub&, 454, 462, 1
Set_texture dub&, 463, 480, 1
Set_texture tdub&, 481, 484, 1
Set_texture dub&, 485, 492, 1
Set_texture tdub&, 493, 512, 1
Set_texture dub&, 513, 520, 1
Set_texture Black&, 521, 524, 1
Set_texture SBlack&, 525, 528, 1
Set_texture Black&, 529, 532, 1
Set_texture pc&, 533, 536, 1
Set_texture SBlack&, 537, 540, 1 'MONITOR
Set_texture Black&, 541, 548, 1 'MONITOR
Set_texture Noha&, 549, 552, 1 'MONITOR
Set_texture Black&, 553, 556, 1
Set_texture kbd&, 557, 560, 1 'keyboard
Set_texture mys&, 561, 564, 1 'keyboard
Set_texture Black, 565, 576, 1 'woof
Set_texture SBlack, 577, 580, 1 'woof
Set_texture woof&, 581, 584, 1 'woof
Set_texture Black, 585, 596, 1
Set_texture speak&, 597, 600, 1
Set_texture Black, 601, 612, 1
Set_texture speak&, 613, 616, 1
'strana s linkou
Set_texture dvere&, 617, 620, 1
Set_texture dlazba&, 621, 624, 10
Set_texture white&, 625, 628, 1
Set_texture sporakcelo, 629, 632, 1
Set_texture sporakvrch, 633, 636, 1
Set_texture white&, 637, 648, 1
Set_texture dub&, 649, 652, 1
Set_texture tdub&, 653, 656, 5
Set_texture dub&, 657, 676, 5
Set_texture tdub&, 677, 680, 5
Set_texture dub&, 681, 796, 5
Set_texture tdub&, 797, 800, 5
Set_texture dub&, 801, 809, 5
Set_texture dub&, 809, 812, 5
Set_texture tdub&, 813, 816, 5
Set_texture tdub&, 817, 820, 5
Set_texture Silver&, 821, 836, 1
Set_texture SilverC&, 837, 840, 1
Set_texture SilverB&, 841, 860, 1
Set_texture dub&, 861, 872, 1
Set_texture tdub&, 873, 960, 1
Set_texture dlazba2&, 961, 964, 10
Set_texture tdub&, 965, 1004, 1
Set_texture dub&, 1005, 1064, 1
Set_texture tdub&, 1065, 1076, 1
Set_texture Sklo&, 1077, 1080, 1
Set_texture tdub&, 1081, 1096, 1
Set_texture mikro&, 1097, 1100, 1
Set_texture SilverB&, 1101, 1116, 1

valec -1, -.8, 4.7, -.6, 10, SilverB&
valec 6, -.5, 9, -.35, 10, Silver&
valec -3.35, -.2, -4.8, -.3, 40, SilverB&
Zvalec -3.35, -.3, -4.8, -4.1, 40, SilverB&
valec -3.35, -.29, -4.1, -.4, 40, SilverB&


talir -9.1, .8, -1.45
talir -9.1, .8, -1.05
talir -9.1, .8, -.65

madlo -7.9, .8, -3.6
madlo -7.45, .8, -3.6
madlo -7.9, -.8, -3.4
madlo -7.45, -.8, -3.4

madlo -6, -.8, -3.4
madlo -5.45, -.8, -3.4
madlo -6, .8, -3.6
madlo -5.45, .8, -3.6

madlo -4.1, -.8, -3.4
madlo -3.45, -.8, -3.4
madlo -4.1, .8, -3.6
madlo -3.45, .8, -3.6

madlo -2.2, -.8, -3.4
madlo -1.45, -.8, -3.4
madlo -2.2, .8, -3.6
madlo -1.45, .8, -3.6

madlo -.3, -.8, -3.4
madlo -.3, .8, -3.6

madlo 1, -.8, -3.4
madlo 1, .8, -3.6

madlo 2, -.8, -3.4
madlo 2, .8, -3.6

madlo 3, -.8, -3.4
madlo 3, .8, -3.6

madlo 4, -.8, -3.4
madlo 4, .8, -3.6

madlo 8.5, -1, 7.9
madlo 8.5, -1.3, 7.9

Zmadlo -8.77, .8, -1 'glases doors
Zmadlo -8.77, .8, -2.75

Zmadlo -8.77, -.8, -1
Zmadlo -8.77, -.8, -2.75


minRadius = 1000
start = 1
_MOUSEHIDE

DO


    WHILE _MOUSEINPUT: WEND
    i$ = INKEY$

    FOR r = 1 TO N
        LenX = v(r).X - CX '                                                           calculate line lenght between CX and X - point (X1, X2...)
        LenY = v(r).Y - CY
        LenZ = v(r).Z - CZ '                                                           calculate line lenght between CY (center Y) and Y - point

        radius = SQR(LenX ^ 2 + LenZ ^ 2) '                                            calculate radius using Pythagoras
        IF minRadius < .4 THEN minRadius = 1000
        IF minRadius > radius THEN minRadius = radius
        radiusH = SQR(LenY ^ 2 + LenZ ^ 2)
        v(r).Radius = radius
        v(r).RadiusH = radiusH

        v(r).pi = JK!(CX, CZ, v(r).X, v(r).Z, radius) ' point on circle calculation based on binary circle    https://matematika.cz/jednotkova-kruznice,  this is for X / Z rotation
    NEXT r

    IF ABS(rot) > _PI(2) THEN rot = 0

    oldposZ = posZ
    oldposX = posX




    'upgrade: add mouse support!
    rot = rot + MOUSEMOVEMENTX / 30 '                                                      rot is move rotation X / Z
    roth = roth + MOUSEMOVEMENTY / 30 '

    IF roth > _PI / 2 THEN roth = _PI / 2 '                                                roth is rotation for Y / Z (look up and down)
    IF roth < -_PI / 2 THEN roth = -_PI / 2


    SELECT CASE i$
        CASE CHR$(0) + CHR$(72): posZ = posZ + COS(rot) / 2: posX = posX + -SIN(rot) / 2
        CASE CHR$(0) + CHR$(80): posZ = posZ - COS(rot) / 2: posX = posX - -SIN(rot) / 2
        CASE CHR$(0) + CHR$(77): posZ = posZ + COS(rot + _PI / 2): posX = posX - SIN(rot + _PI / 2) ' sidestep
        CASE CHR$(0) + CHR$(75): posZ = posZ - COS(rot + _PI / 2): posX = posX + SIN(rot + _PI / 2) ' sidestep

        CASE "A", "a" '                look up/dn from keyboard
            roth = roth - .02

        CASE "Z", "z":
            roth = roth + .02

        CASE CHR$(27): Destructor ("textures.pmf"): SYSTEM
    END SELECT
    IF _EXIT THEN Destructor ("textures.pmf")


    'primitive collision detection
    IF posZ > 3 THEN posZ = 3
    IF posZ < -7 THEN posZ = -7
    IF posX < -7 THEN posX = -7
    IF posX > 7 THEN posX = 7


    SELECT CASE posX
        CASE -7 TO -5: IF posZ < -7 THEN posX = oldposX: posZ = oldposZ
        CASE -5 TO 3: IF posZ < -2 THEN posX = oldposX: posZ = oldposZ
        CASE 3 TO 6: IF posZ < -7 THEN posX = oldposX: posZ = oldposZ
    END SELECT
    '-----------------------------

    IF _MOUSEBUTTON(1) THEN rot = rot - .02
    IF _MOUSEBUTTON(2) THEN rot = rot + .02

    CZ = -posZ 'This is very important. Note that you do not actually turn the camera in space, but you turn the space for camera.
    CX = -posX
    CY = -posY

    FOR r = 1 TO N 'STEP 1: FIRST rotate space for move (Z / X rotation)
        x = CX + SIN(rot + v(r).pi) * v(r).Radius
        Z = CZ + COS(rot + v(r).pi) * v(r).Radius


        v(r).wX = x + posX
        v(r).wZ = Z '                   posZ is add later, after Z / Y calculation
        v(r).wY = v(r).Y + posY


        'STEP 2: rotate space for look to UP / DOWN (Z / Y) BUT USE CORRECT COORDINATES CALCULATED IN STEP 1 FOR ROTATION Z / X as in this program:


        LenY2 = v(r).Y - CY
        LenZ2 = v(r).wZ - CZ

        radiusH = SQR(LenY2 ^ 2 + LenZ2 ^ 2)
        v(r).RadiusH = radiusH

        v(r).piH = JK!(CY, CZ, v(r).Y, v(r).wZ, radiusH) 'As you see here, JK! use previous calculated rotated coordinate wZ (working Z coordinate)

        z2 = CZ + COS(roth + v(r).piH) * v(r).RadiusH ' CX, CY, CZ is CAMERA. RadiusH is radius for point between floor and ceiling
        y2 = CY + SIN(roth + v(r).piH) * v(r).RadiusH

        v(r).wY = y2 + posY
        v(r).wZ2 = z2 + posZ

    NEXT r
    i$ = ""

    minigame
    m33& = _COPYIMAGE(m&, 33)
    Set_texture m33&, 537, 540, 1 'MONITOR


    REM INFOBOX posX, posY, posZ, rot, minRadius


    FOR zz = 1 TO N STEP 4
        IF v(zz).T THEN
            img& = v(zz).T
            w = _WIDTH(img&)
            h = _HEIGHT(img&)
            num = v(zz).Tm
            IF num = 0 THEN num = 1
            _MAPTRIANGLE (0, h * num)-(w * num, h * num)-(0, 0), img& TO(v(zz).wX, v(zz).wY, v(zz).wZ2)-(v(zz + 1).wX, v(zz + 1).wY, v(zz + 1).wZ2)-(v(zz + 2).wX, v(zz + 2).wY, v(zz + 2).wZ2), 0, _SMOOTH
            _MAPTRIANGLE (w * num, h * num)-(0, 0)-(w * num, 0), img& TO(v(zz + 1).wX, v(zz + 1).wY, v(zz + 1).wZ2)-(v(zz + 2).wX, v(zz + 2).wY, v(zz + 2).wZ2)-(v(zz + 3).wX, v(zz + 3).wY, v(zz + 3).wZ2), 0, _SMOOTH
        END IF
    NEXT zz

    _DISPLAY
    _FREEIMAGE m33&
    _LIMIT 50
LOOP


SUB INFOBOX (posx, posy, posz, rot, u)
    nfo& = _NEWIMAGE(640, 480, 32)
    W = 639: H = 479: X = -.5: Y = 0: Z = -1
    de = _DEST
    _DEST nfo&
    COLOR _RGB32(22, 61, 78)
    _PRINTMODE _KEEPBACKGROUND
    PRINT "INFOBOX:"
    PRINT "Position X: "; posx
    PRINT "Position Y: "; posy
    PRINT "Position Z: "; posz
    PRINT "Angle: "; ABS(_R2D(rot))
    PRINT u

    _CLEARCOLOR _RGB32(0, 0, 0)
    _DEST de
    hnfo& = _COPYIMAGE(nfo&, 33)
    _FREEIMAGE nfo&
    _MAPTRIANGLE (0, 0)-(W, 0)-(0, H), hnfo& TO(-2 + X, 2 + Y, -2 + Z)-(2 + X, 2 + Y, -2 + Z)-(-2 + X, -2 + Y, -2 + Z)
    _MAPTRIANGLE (W, 0)-(0, H)-(W, H), hnfo& TO(2 + X, 2 + Y, -2 + Z)-(-2 + X, -2 + Y, -2 + Z)-(2 + X, -2 + Y, -2 + Z)
    _FREEIMAGE hnfo&
END SUB




SUB madlo (x, y, z)
    tt = UBOUND(v) + 1

    REDIM _PRESERVE v(1 TO tt - 1 + 12) AS V
    N = N + 12
    IF SGN(x) >= 0 THEN x2 = x + .2 ELSE x2 = x - .2
    IF SGN(y) >= 0 THEN y2 = y + .05 ELSE y2 = y - .05
    IF SGN(z) < 0 THEN z2 = z - .1 ELSE z2 = z + .1


    v(tt).X = x
    v(tt).Y = y
    v(tt).Z = z

    v(tt + 1).X = x
    v(tt + 1).Y = y2
    v(tt + 1).Z = z

    v(tt + 2).X = x2
    v(tt + 2).Y = y
    v(tt + 2).Z = z

    v(tt + 3).X = x2
    v(tt + 3).Y = y2
    v(tt + 3).Z = z

    '------------

    v(tt + 4).X = x
    v(tt + 4).Y = y
    v(tt + 4).Z = z

    v(tt + 5).X = x
    v(tt + 5).Y = y2
    v(tt + 5).Z = z

    v(tt + 6).X = x
    v(tt + 6).Y = y
    v(tt + 6).Z = z2

    v(tt + 7).X = x
    v(tt + 7).Y = y2
    v(tt + 7).Z = z2

    '------------

    v(tt + 8).X = x2
    v(tt + 8).Y = y
    v(tt + 8).Z = z

    v(tt + 9).X = x2
    v(tt + 9).Y = y2
    v(tt + 9).Z = z

    v(tt + 10).X = x2
    v(tt + 10).Y = y
    v(tt + 10).Z = z2

    v(tt + 11).X = x2
    v(tt + 11).Y = y2
    v(tt + 11).Z = z2


    Set_texture aluminium&, tt - 1, tt + 11, 1

END SUB


SUB Zmadlo (x, y, z)
    'X udava hloubku, Z udava sirku
    '  x    y   z       x      y2 z         x2   y   z2          x2    y2   z2
    'DATA -8.77, 1.7, 0,    -8.77, 1.6, 0,     -8.77,1.7, -3.7,     - 8.77, 1.6, -3.7


    tt = UBOUND(v) + 1

    REDIM _PRESERVE v(1 TO tt - 1 + 12) AS V '16 a 16
    N = N + 12
    'zapisu zkusebne jeden CTVEREC

    IF SGN(z) <= 0 THEN z2 = z - .2 ELSE z2 = z + .2 'sirka
    IF SGN(y) >= 0 THEN y2 = y + .05 ELSE y2 = y - .05
    IF SGN(x) <= 0 THEN x2 = x + .1 ELSE x2 = x - .1 'hloubka


    'predni obdelnik
    v(tt).X = x2
    v(tt).Y = y
    v(tt).Z = z

    v(tt + 1).X = x2
    v(tt + 1).Y = y2
    v(tt + 1).Z = z

    v(tt + 2).X = x2
    v(tt + 2).Y = y
    v(tt + 2).Z = z2

    v(tt + 3).X = x2
    v(tt + 3).Y = y2
    v(tt + 3).Z = z2

    '------------

    v(tt + 4).X = x
    v(tt + 4).Y = y2
    v(tt + 4).Z = z

    v(tt + 5).X = x2
    v(tt + 5).Y = y2
    v(tt + 5).Z = z

    v(tt + 6).X = x
    v(tt + 6).Y = y
    v(tt + 6).Z = z

    v(tt + 7).X = x2
    v(tt + 7).Y = y
    v(tt + 7).Z = z

    '------------

    v(tt + 8).X = x
    v(tt + 8).Y = y2
    v(tt + 8).Z = z2

    v(tt + 9).X = x2
    v(tt + 9).Y = y2
    v(tt + 9).Z = z2

    v(tt + 10).X = x
    v(tt + 10).Y = y
    v(tt + 10).Z = z2

    v(tt + 11).X = x2
    v(tt + 11).Y = y
    v(tt + 11).Z = z2

    Set_texture aluminium&, tt - 1, tt + 11, 1
END SUB

SUB Set_texture (num, start, eend, much)
    FOR s = start TO eend
        v(s).T = num
        v(s).Tm = much
    NEXT s
END SUB

FUNCTION Hload& (fileName AS STRING)
    h& = _LOADIMAGE(fileName$, 32)
    '    PRINT h&: SLEEP
    ' _setalpha 0, _rgb32(255,255,255) to _rgb32 (250,250,250), h&
    Hload& = _COPYIMAGE(h&, 33)
    _FREEIMAGE h&
END FUNCTION

FUNCTION SHload& (fileName AS STRING)
    h& = _LOADIMAGE(fileName$, 32)
    _SETALPHA 0, _RGB32(255, 255, 255) TO _RGB32(200, 200, 200), h&
    SHload& = _COPYIMAGE(h&, 33)
    _FREEIMAGE h&
END FUNCTION

FUNCTION strop&
    lamp& = _LOADIMAGE("bodovka mala.jpg", 32)
    temp& = _NEWIMAGE(1024, 768, 32)
    de = _DEST
    _DEST temp&
    CLS , _RGB32(255, 255, 255)
    rX = 1024 / 4
    rY = 768 / 3
    FOR x = rX TO 1024 - rX STEP rX
        FOR y = rY TO 768 - rY STEP rY
            _PUTIMAGE (rX, rY), lamp&, temp&
    NEXT y, x
    _DEST de
    _FREEIMAGE lamp&
    strop& = _COPYIMAGE(temp&, 33)
END FUNCTION

FUNCTION okno&
    ok& = _LOADIMAGE("okn.jpg", 32)
    topco& = _LOADIMAGE("topco.jpg", 32)
    temp& = _NEWIMAGE(1024, 512, 32)
    de = _DEST
    _DEST temp&
    CLS , _RGB32(250, 245, 255)
    _PUTIMAGE (512 - 150, 206 - 132), ok&, temp& '300x265

    _PUTIMAGE (380, 370), topco&, temp&
    _DEST de
    _FREEIMAGE ok&
    _FREEIMAGE topco&
    okno& = _COPYIMAGE(temp&, 33)
END FUNCTION

FUNCTION white&
    'IF white& = 0 THEN
    whit& = _NEWIMAGE(100, 100, 32)
    de = _DEST
    _DEST whit&
    CLS , _RGB32(250, 240, 250)
    _DEST de
    white& = _COPYIMAGE(whit&, 33)
    _FREEIMAGE whit&
    'END IF
END FUNCTION

FUNCTION Swhite&
    'IF Swhite& = 0 THEN
    whit& = _NEWIMAGE(100, 100, 32)
    de = _DEST
    _DEST whit&
    CLS , _RGB32(255, 255, 255)
    _DEST de
    Swhite& = _COPYIMAGE(whit&, 33)
    _FREEIMAGE whit&
    'END IF
END FUNCTION


FUNCTION Braun&
    'IF Braun& = 0 THEN
    brau& = _NEWIMAGE(100, 100, 32)
    de = _DEST
    _DEST brau&
    CLS , _RGB32(111, 17, 39)
    _DEST de
    Braun& = _COPYIMAGE(brau&, 33)
    _FREEIMAGE brau&
    'END IF
END FUNCTION


FUNCTION Black&
    'IF Black& = 0 THEN
    blk& = _NEWIMAGE(100, 100, 32)
    de = _DEST
    _DEST blk&
    CLS , _RGB32(6, 17, 28)
    _DEST de
    Black& = _COPYIMAGE(blk&, 33)
    _FREEIMAGE blk&
    'END IF
END FUNCTION

FUNCTION SBlack&
    'IF SBlack& = 0 THEN
    blk& = _NEWIMAGE(100, 100, 32)
    de = _DEST
    _DEST blk&
    CLS , _RGB32(33, 28, 28)
    _DEST de
    SBlack& = _COPYIMAGE(blk&, 33)
    _FREEIMAGE blk&
    'END IF
END FUNCTION

FUNCTION Silver&
    'IF Silver& = 0 THEN
    blk& = _NEWIMAGE(100, 100, 32)
    de = _DEST
    _DEST blk&
    e = 127 / 100
    FOR l = 0 TO 99
        LINE (0, l)-(99, l), _RGB32(255 - f, 255 - f, 255 - f)
        f = f + e
    NEXT l
    _DEST de
    Silver& = _COPYIMAGE(blk&, 33)
    _FREEIMAGE blk&
    'END IF
END FUNCTION

FUNCTION SilverB&
    'IF SilverB& = 0 THEN
    blk& = _NEWIMAGE(100, 100, 32)
    de = _DEST
    _DEST blk&
    e = 127 / 50
    FOR l = 0 TO 50
        LINE (l, l)-(100 - l, 100 - l), _RGB32(127 + f, 127 + f, 127 + f), B
        f = f + e
    NEXT l
    _DEST de
    SilverB& = _COPYIMAGE(blk&, 33)
    _FREEIMAGE blk&
    'END IF
END FUNCTION


FUNCTION SilverC&
    'IF SilverC& = 0 THEN
    blk& = _NEWIMAGE(100, 100, 32)
    de = _DEST
    _DEST blk&
    e = 127 / 50
    FOR l = 0 TO 50
        LINE (l, l)-(100 - l, 100 - l), _RGB32(255 - f, 255 - f, 255 - f), B
        f = f + e
    NEXT l
    _DEST de
    SilverC& = _COPYIMAGE(blk&, 33)
    _FREEIMAGE blk&
    'END IF
END FUNCTION


FUNCTION spajz_dvere&
    dv& = _LOADIMAGE("dvere.jpg", 32) '192 x 426
    de = _DEST
    spajz_dvere32& = _NEWIMAGE(640, 480, 32)
    _DEST spajz_dvere32&
    CLS , _RGB32(241, 244, 251)
    _PUTIMAGE (140, 54), dv&
    _DEST de
    spajz_dvere& = _COPYIMAGE(spajz_dvere32&, 33)
    _FREEIMAGE spajz_dvere32&
END FUNCTION

FUNCTION Zesvetli& (file AS STRING)
    t& = _LOADIMAGE(file$, 32)
    'IF Zesvetli& < -1 THEN _FREEIMAGE Zesvetli&
    w = _WIDTH(t&)
    h = _HEIGHT(t&)
    zesvetli32& = _NEWIMAGE(w, h, 32)
    de = _DEST
    _DEST zesvetli32&
    _PUTIMAGE , t&, zesvetli32&
    LINE (0, 0)-(w - 1, h - 1), _RGBA32(255, 255, 255, 30), BF
    _DEST de

    Zesvetli& = _COPYIMAGE(zesvetli32&, 33)
    _FREEIMAGE t&
    _FREEIMAGE zesvetli32&
END FUNCTION

FUNCTION Ztmav& (file AS STRING)
    t& = _LOADIMAGE(file$, 32)
    'IF Ztmav& < -1 THEN _FREEIMAGE Ztmav&
    w = _WIDTH(t&)
    h = _HEIGHT(t&)
    ztmav32& = _NEWIMAGE(w, h, 32)
    de = _DEST
    _DEST ztmav32&
    _PUTIMAGE , t&, ztmav32&
    LINE (0, 0)-(w - 1, h - 1), _RGBA32(0, 0, 0, 30), BF
    _DEST de

    Ztmav& = _COPYIMAGE(ztmav32&, 33)
    _FREEIMAGE t&
    _FREEIMAGE ztmav32&
END FUNCTION

FUNCTION Noha&
    'IF Noha& = 0 THEN
    de = _DEST
    noh& = _NEWIMAGE(100, 100, 32)
    _DEST noh&
    LINE (0, 40)-(100, 60), _RGB32(0, 22, 32), BF
    _CLEARCOLOR _RGB32(0, 0, 0), noh&
    _DEST de
    Noha& = _COPYIMAGE(noh&, 33)
    _FREEIMAGE noh&
    'END IF
END FUNCTION

FUNCTION Noha2&
    'IF Noha2& = 0 THEN
    de = _DEST
    noh& = _NEWIMAGE(100, 100, 32)
    _DEST noh&
    LINE (30, 30)-(70, 70), _RGB32(0, 2, 12), BF
    _CLEARCOLOR _RGB32(0, 0, 0), noh&
    _DEST de
    Noha2& = _COPYIMAGE(noh&, 33)
    _FREEIMAGE noh&
    'END IF
END FUNCTION





FUNCTION JK! (cx, cy, px, py, R)
    '  podle definice jednotkove kruznice musim nejprve hodnoty prevest na rozsah od -1 do 1 pro x i pro y.
    '  R urcuje velikost kruznice, cili jR bude 1/R
    LenX = cx - px
    LenY = cy - py
    jR = 1 / R

    jX = LenX * jR
    jY = LenY * jR

    sinusAlfa = jX
    Alfa = ABS(_ASIN(sinusAlfa))

    Q = 1
    IF px >= cx AND py <= cy THEN Q = 1 ' select angle to quadrant
    IF px >= cx AND py <= cy THEN Q = 2
    IF px <= cx AND py <= cy THEN Q = 3
    IF px <= cx AND py >= cy THEN Q = 4
    SELECT CASE Q
        CASE 1: alfaB = Alfa
        CASE 2: alfaB = _PI / 2 + (_PI / 2 - Alfa)
        CASE 3: alfaB = _PI + Alfa
        CASE 4: alfaB = _PI(1.5) + (_PI / 2 - Alfa)
    END SELECT
    JK! = alfaB
END FUNCTION

SUB valec (xs, ys, zs, ye, R, t&) 'start x, y, z, konec x, y, z, polomer, textura

    tt = UBOUND(v) + 1
    polomer = R

    REDIM _PRESERVE v(1 TO tt - 1 + 64) AS V '16 a 16

    polo = _PI(2) / 16
    N = N + 64

    FOR s = 0 TO _PI(2) STEP polo
        ott = tt
        v(tt).X = xs + SIN(s) / polomer
        v(tt).Y = ys
        v(tt).Z = zs + COS(s) / polomer
        tt = tt + 1
        v(tt).X = xs + SIN(s) / polomer
        v(tt).Y = ye
        v(tt).Z = zs + COS(s) / polomer
        tt = tt + 1
        v(tt).X = xs + SIN(s + polo) / polomer
        v(tt).Y = ys
        v(tt).Z = zs + COS(s + polo) / polomer
        tt = tt + 1
        v(tt).X = xs + SIN(s + polo) / polomer
        v(tt).Y = ye
        v(tt).Z = zs + COS(s + polo) / polomer
        Set_texture t&, ott, tt, 1
        tt = tt + 1
    NEXT
END SUB

SUB Zvalec (xs, ys, zs, ze, R, t&) 'start x, y, z, konec x, y, z, polomer, textura
    tt = UBOUND(v) + 1
    polomer = R

    REDIM _PRESERVE v(1 TO tt - 1 + 64) AS V '16 a 16

    polo = _PI(2) / 16
    N = N + 64

    FOR s = 0 TO _PI(2) STEP polo
        ott = tt
        v(tt).X = xs + SIN(s) / polomer
        v(tt).Y = ys + COS(s) / polomer
        v(tt).Z = zs
        tt = tt + 1
        v(tt).X = xs + SIN(s) / polomer
        v(tt).Y = ys + COS(s) / polomer
        v(tt).Z = ze
        tt = tt + 1
        v(tt).X = xs + SIN(s + polo) / polomer
        v(tt).Y = ys + COS(s + polo) / polomer
        v(tt).Z = zs
        tt = tt + 1
        v(tt).X = xs + SIN(s + polo) / polomer
        v(tt).Y = ys + COS(s + polo) / polomer
        v(tt).Z = ze
        Set_texture t&, ott, tt, 1
        tt = tt + 1
    NEXT
END SUB






SUB talir (x, y, z)

    radius0 = 0
    radius1 = .05
    radius2 = .1
    radius3 = .2
    ys = -ABS(y) 'puvodni zs bude ys
    ye = y - .1
    ys2 = ye
    ye2 = y + .2

    tt = UBOUND(v) + 1
    '32 zaznamu pro jeden obvod kruhu (16 * 2 body) jeden radius, dalsich 32 druhy, dalsich 32 treti (ten se opakuje jako druhy) a 32 ctvrty.

    REDIM _PRESERVE v(1 TO tt - 1 + 64) AS V '16 a 16

    polo = _PI(2) / 16
    N = N + 64

    FOR s = 0 TO _PI(2) STEP polo
        ott = tt
        IF SGN(x) >= 0 THEN v(tt).X = x + (SIN(s) * radius2 + SIN(s) * radius0) ELSE v(tt).X = x - (SIN(s) * radius2 - SIN(s) * radius0)
        v(tt).Y = ys2
        IF SGN(z) >= 0 THEN v(tt).Z = z + (COS(s) * radius2 + COS(s) * radius0) ELSE v(tt).Z = z - (COS(s) * radius2 - COS(s) * radius0)
        tt = tt + 1
        IF SGN(x) >= 0 THEN v(tt).X = x + (SIN(s) * radius3 + SIN(s) * radius1) ELSE v(tt).X = x - (SIN(s) * radius3 - SIN(s) * radius1)
        v(tt).Y = ye2
        IF SGN(z) >= 0 THEN v(tt).Z = z + (COS(s) * radius3 + COS(s) * radius1) ELSE v(tt).Z = z - (COS(s) * radius3 - COS(s) * radius1)
        tt = tt + 1
        IF SGN(x) >= 0 THEN v(tt).X = x + (SIN(s + polo) * radius2 + SIN(s + polo) * radius0) ELSE v(tt).X = x - (SIN(s + polo) * radius2 - SIN(s + polo) * radius0)
        v(tt).Y = ys2
        IF SGN(z) >= 0 THEN v(tt).Z = z + (COS(s + polo) * radius2 + COS(s + polo) * radius0) ELSE v(tt).Z = z - (COS(s + polo) * radius2 - COS(s + polo) * radius0)
        tt = tt + 1
        IF SGN(x) >= 0 THEN v(tt).X = x + (SIN(s + polo) * radius3 + SIN(s + polo) * radius1) ELSE v(tt).X = x - (SIN(s + polo) * radius3 - SIN(s + polo) * radius1)
        v(tt).Y = ye2
        IF SGN(z) >= 0 THEN v(tt).Z = z + (COS(s + polo) * radius3 + COS(s + polo) * radius1) ELSE v(tt).Z = z - (COS(s + polo) * radius3 - COS(s + polo) * radius1)
        tt = tt + 1
        Set_texture SilverC&, ott, tt - 1, 1
    NEXT
END SUB









FUNCTION Sklo&
    'IF Sklo& = 0 THEN
    de = _DEST
    skl = _NEWIMAGE(150, 100, 32)
    _DEST skl
    alfa = 127 / 25
    a = 120
    FOR x = 1 TO 50
        a = a - alfa
        LINE (0, x)-(150, x), _RGBA32(127, 127, 127, a)
    NEXT x

    FOR x = 50 TO 100
        a = a + alfa
        LINE (0, x)-(150, x), _RGBA32(127, 127, 127, a)
    NEXT x
    _DEST de
    Sklo& = _COPYIMAGE(skl, 33)
    _FREEIMAGE skl
    'END IF
END FUNCTION

SUB minigame
    de = _DEST
    _DEST m&
    CLS , _RGB32(127, 120, 120)


    IF ballX > 160 THEN
        IF rY + 25 < ballY THEN rY = rY + 1 ELSE rY = rY - 1
        IF ballX > (rXx - 10) THEN
            IF ballY > rY AND ballY < rY + 50 THEN mX = mX * -1
        END IF
    END IF

    IF ballX < 160 THEN
        IF lY + 25 < ballY THEN lY = lY + 1 ELSE lY = lY - 1
        IF ballX < 20 THEN

            IF ballY > lY AND ballY < lY + 50 THEN mX = mX * -1

        END IF
    END IF

    ballX = ballX + mX
    ballY = ballY + mY

    IF ballX > 315 THEN mX = mX * -1: rightplr = rightplr + 1: ballX = ballX + mX + SIN(_ATAN2(ballY, ballX))
    IF ballX < 5 THEN mX = mX * -1: leftplr = leftplr + 1: ballY = ballY + mY + COS(_ATAN2(ballY, ballX))

    IF ballY > 235 THEN mY = mY * -1 - _ATAN2(ballY, ballX) / 2: ballY = ballY + mY
    IF ballY < 5 THEN mY = mY * -1 + _ATAN2(ballY, ballX) / 2: ballY = ballY + mY

    'boky tahel - odrazy Y:
    IF ballY >= lY AND ballY <= lY + 60 AND ballX <= 10 THEN mY = mY * -1: ballY = ballY + mY - _ATAN2(ballY, ballX)
    IF ballY >= rY AND ballY <= rY + 60 AND ballX >= 300 THEN mY = mY * -1: ballY = ballY + mY + _ACOS(_ATAN2(ballY, ballX))




    IF lY > 180 THEN lY = 180
    IF lY < 10 THEN lY = 10
    IF rY > 180 THEN rY = 180
    IF rY < 10 THEN rY = 10

    IF ballX - 2 > lX AND ballX + 2 < lX + 10 AND ballY - 2 >= lY AND ballY + 2 <= lY + 50 THEN COLOR _RGB32(255, 0, 0): _PRINTSTRING (130, 112), "ERROR!!!!": COLOR _RGB32(255, 255, 255)
    IF ballX - 2 > rX - 10 AND ballX + 2 < rX AND ballY - 2 >= rY AND ballY + 2 <= rY + 50 THEN COLOR _RGB32(255, 0, 0): _PRINTSTRING (130, 112), "ERROR!!!!": COLOR _RGB32(255, 255, 255)

    IF ABS(mX) > 2 THEN mX = mX / 2
    IF ABS(mY) > 2 THEN mY = mY / 2


    IF ballX > 157 AND ballX < 163 THEN
        IF ballY > 60 AND ballY < 180 THEN mX = mX * -1
        IF ballY = 64 OR ballY = 180 THEN mY = mY * -1
    END IF



    LINE (ballX - 2, ballY - 2)-(ballX + 2, ballY + 2), , B

    LINE (3, 3)-(317, 237), , B
    LINE (lX, lY)-(lX + 10, lY + 50), , B
    LINE (rXx, rY)-(rXx - 10, rY + 50), , B
    LINE (160, 60)-(160, 180)
    _PRINTMODE _KEEPBACKGROUND
    popis = _PRINTWIDTH(STR$(leftplr) + " - " + STR$(rightplr))

    _PRINTSTRING (160 - popis / 2, 5), STR$(leftplr) + " - " + STR$(rightplr)
    _DEST de
END SUB

FUNCTION MOUSEMOVEMENTX
    SELECT CASE OldMouseX
        CASE IS > _MOUSEX: MOUSEMOVEMENTX = -1: _MOUSEMOVE OldMouseX, OldMouseY '= _MOUSEX
        CASE IS < _MOUSEX: MOUSEMOVEMENTX = 1: _MOUSEMOVE OldMouseX, OldMouseY '= _MOUSEX
        CASE ELSE: MOUSEMOVEMENTX = 0
    END SELECT
END FUNCTION

FUNCTION MOUSEMOVEMENTY
    SELECT CASE OldMouseY
        CASE IS > _MOUSEY: MOUSEMOVEMENTY = -1: _MOUSEMOVE OldMouseX, OldMouseY ' = _MOUSEY
        CASE IS < _MOUSEY: MOUSEMOVEMENTY = 1: _MOUSEMOVE OldMouseX, OldMouseY '= _MOUSEY
        CASE ELSE: MOUSEMOVEMENTY = 0
    END SELECT
END FUNCTION


SUB ExtractPMF (Vystup AS STRING) ' here insert PMF file name for extracting files
    IF _FILEEXISTS(Vystup) THEN
        PRINT "Extracting files from "; Vystup$
        TYPE head
            identity AS STRING * 16
            much AS LONG
        END TYPE
        DIM head AS head
        e = FREEFILE
        OPEN Vystup$ FOR BINARY AS #e
        GET #e, , head
        IF head.identity = "Petr's MultiFile" THEN PRINT "Head PASS" ELSE PRINT "Head Failure": SLEEP 3: END
        PRINT "Total records in file:"; head.much
        DIM starts(head.much) AS LONG

        FOR celek = 1 TO head.much
            GET #e, , starts(celek)
        NEXT

        SEEK #e, 21 + head.much * 4 ' start DATA area
        FOR total = 1 TO head.much
            IF total = 1 THEN velikost& = starts(1) - (21 + head.much * 4) ELSE velikost& = starts(total) - starts(total - 1)
            record$ = SPACE$(velikost&)
            GET #e, , record$
            i = FREEFILE
            jmeno$ = "$Ext" + LTRIM$(STR$(total))
            OPEN jmeno$ FOR OUTPUT AS #i: CLOSE #i: OPEN jmeno$ FOR BINARY AS #i
            PUT #i, , record$
            CLOSE #i
        NEXT total

        DIM NamesLenght(head.much) AS INTEGER
        FOR NameIt = 1 TO head.much
            GET #e, , NamesLenght(NameIt)
        NEXT NameIt

        CLOSE #i
        FOR Name2 = 1 TO head.much
            s$ = SPACE$(NamesLenght(Name2))
            GET #e, , s$
            jm$ = "$Ext" + LTRIM$(STR$(Name2))
            erh:
            IF _FILEEXISTS(s$) THEN
                BEEP: INPUT "Warnig! Extracted file the same name already exists!!!! (O)verwrite, (R)ename or (E)xit? "; er$
                SELECT CASE LCASE$(er$)
                    CASE "o": KILL s$: NAME jm$ AS s$
                    CASE "r": INPUT "Input new name"; s$: GOTO erh
                    CASE "e": SYSTEM
                END SELECT
            ELSE
                NAME jm$ AS s$
            END IF
        NEXT Name2
        CLOSE #e
        PRINT "All ok."
    ELSE
        PRINT "File "; Vystup$; " not found.": END
    END IF
END SUB

SUB Destructor (vystup AS STRING) 'delete files created by ExtractPMF
    TYPE head2
        identity AS STRING * 16
        much AS LONG
    END TYPE
    IF INSTR(1, LCASE$(vystup$), ".pmf") THEN ELSE vystup$ = vystup$ + ".PMF"
    IF _FILEEXISTS(vystup$) THEN
        CLOSE
        DIM head AS head2
        e = FREEFILE
        OPEN vystup$ FOR BINARY AS #e
        GET #e, , head
        DIM starts(head.much) AS LONG

        FOR celek = 1 TO head.much
            GET #e, , starts(celek)
        NEXT

        SEEK #e, starts(head.much) ' start DATA area
        DIM NamesLenght(head.much) AS INTEGER
        FOR NameIt = 1 TO head.much
            GET #e, , NamesLenght(NameIt)
        NEXT NameIt
        FOR Name2 = 1 TO head.much
            s$ = SPACE$(NamesLenght(Name2))
            GET #e, , s$
            IF _FILEEXISTS(s$) THEN KILL s$
        NEXT Name2
        CLOSE #e
    ELSE
        PRINT "Specified file not found": SLEEP 3
    END IF
END SUB
