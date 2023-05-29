# 3D-Library-for-QB64
Simple to use 3d library for qb64. Uses map triangle to display polygons. Simple shading on models. Load multiple 3d objects into the scene and move the camera. Supports loading of wavefront obj files and texture mapping.

![screen](https://raw.githubusercontent.com/creamcast/3D-Library-for-QB64/master/screenshot1.png "sample 1")

![screen](https://raw.githubusercontent.com/creamcast/3D-Library-for-QB64/master/screenshot2.png "sample 2")

![screen](https://raw.githubusercontent.com/creamcast/3D-Library-for-QB64/master/screenshot3.png "sample 3")

# Subs and functions:
* loadObj (filename AS STRING) load a WAVEFRONT obj file, returns the ID of the object as an integer to be used for the 3d commands
* createTexture (filename AS STRING, image_array() AS LONG) loads and creates the texture for 3d objects. Provide an 1D array where the textures will be generated and stored
* DISPOBJ (objid AS INTEGER, texture() AS LONG) display the 3d object, provide an object id and texture array that was created using createTexture()
* SETOBJHIDDEN (objid AS INTEGER, n AS INTEGER) Set to 0 for object to be hidden, set to 1 to be rendered
* SETOBJX (objid AS INTEGER, x AS FLOAT) set object x coord on the 3d plane
* SETOBJY (objid AS INTEGER, y AS FLOAT) set object y coord on the 3d plane
* SETOBJZ (objid AS INTEGER, z AS FLOAT) set object z coord on the 3d plane
* SETOBJPOS (objid AS INTEGER, x AS FLOAT, y AS FLOAT, z AS FLOAT) set object x y z coord on the 3d plane
* SETOBJROT (objid AS INTEGER, xr AS FLOAT, yr AS FLOAT, zr AS FLOAT) set object x, y, z rotation
* ROTATEOBJX (objid AS INTEGER, deg AS FLOAT) rotate the object on its x axis by degrees
* ROTATEOBJY (objid AS INTEGER, deg AS FLOAT) rotate the object on its y axis by degrees
* ROTATEOBJZ (objid AS INTEGER, deg AS FLOAT) rotate the object on its z axis by degrees
* MOVEOBJX (objid AS INTEGER, n AS FLOAT) move object x position by n
* MOVEOBJY (objid AS INTEGER, n AS FLOAT) move object y position by n
* MOVEOBJZ (objid AS INTEGER, n AS FLOAT) move object z position by n
* SETOBJSCALE (objid AS INTEGER, x AS FLOAT, y AS FLOAT, z AS FLOAT) set object xyz scale. set all to 1 for original size. 
* ROTATECAMX (deg AS FLOAT) rotate the camera x by degrees
* ROTATECAMY (deg AS FLOAT) rotate the camera y by degrees
* ROTATECAMZ (deg AS FLOAT) rotate the camera z by degrees
* MOVECAMX (n AS FLOAT) move cam x position
* MOVECAMY (n AS FLOAT) move cam y position
* MOVECAMZ (n AS FLOAT) move cam z position

You can also modify the object through the global variable g_objects:
```
TYPE OBJECT
    id AS INTEGER
    polygon_index_start AS INTEGER
    polygon_index_end AS INTEGER
    x AS FLOAT
    y AS FLOAT
    z AS FLOAT
    rotx AS FLOAT
    roty AS FLOAT
    rotz AS FLOAT
    scalex AS FLOAT
    scaley AS FLOAT
    scalez AS FLOAT
    billboard AS INTEGER
    hidden AS INTEGER
END TYPE
```
