'$INCLUDE: '3d.bi'

DIM SHARED G_MAINSCREEN
G_MAINSCREEN = NEWIMAGE(1024, 768, 32)
SCREEN G_MAINSCREEN

DIM obj, obj2
DIM tex(0) AS LONG
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

DO
    CLS , RGB(0, 0, 0)
    ROTATEOBJX 1, -1
    ROTATEOBJY 2, -2

    g_cam.x = g_cam.x + SIN(Deg2Rad(45)) * 3
    g_cam.z = g_cam.z - COS(Deg2Rad(45)) * 3

    DISPOBJ 1, tex()
    DISPOBJ 2, tex()

    LIMIT 60
    DISPLAY
LOOP

END
'$INCLUDE: '3d.bm'
