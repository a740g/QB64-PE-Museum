'$INCLUDE: '3d.bi'

Dim Shared G_MAINSCREEN
G_MAINSCREEN = NewImage(1024, 768, 32)
Screen G_MAINSCREEN

Dim obj, obj2
Dim tex(0) As Long
createTexture "dice.png", tex()
obj = loadObj("dice.obj")
obj2 = loadObj("arm.obj")
g_cam.x = -1000
g_cam.z = 1000
g_cam.y = 0
g_cam.rotx = 0
g_cam.roty = -45
g_objects(2).x = -250
SETOBJHIDDEN 2, 0

Do
    Cls , RGB(0, 0, 0)
    ROTATEOBJX 1, -1
    ROTATEOBJY 2, -2

    g_cam.x = g_cam.x + Sin(Deg2Rad(45)) * 3
    g_cam.z = g_cam.z - Cos(Deg2Rad(45)) * 3

    DISPOBJ 1, tex()
    DISPOBJ 2, tex()

    Limit 60
    Display
Loop

End

'$INCLUDE: '3d.bm'
