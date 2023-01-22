'**********************************************************************************************
'   Setup Engine Types and Variables
'**********************************************************************************************
Type tVECTOR2d
    x As _Float
    y As _Float
End Type

Type tLINE2d ' Not used
    a As tVECTOR2d
    b As tVECTOR2d
End Type

Type tFACE2d ' Not used
    f0 As tVECTOR2d
    f1 As tVECTOR2d
End Type

Type tTRIANGLE ' Not used
    a As tVECTOR2d
    b As tVECTOR2d
    c As tVECTOR2d
End Type

Type tMATRIX2d
    m00 As _Float
    m01 As _Float
    m10 As _Float
    m11 As _Float
End Type

Type tELAPSEDTIMER
    start As _Float
    last As _Float
    duration As _Float
End Type

Type tFSM
    currentState As Long
    previousState As Long
    timerState As tELAPSEDTIMER
    arg1 As tVECTOR2d ' keep some info on goals
    arg2 As tVECTOR2d
    arg3 As _Float
    arg4 As Long
End Type

Type tSHAPE
    ty As Long ' cSHAPE_CIRCLE = 1, cSHAPE_POLYGON = 2
    radius As _Float ' Only necessary for circle shapes
    maxDimension As tVECTOR2d 'To optomize AABB for collision
    u As tMATRIX2d ' Only necessary for polygons
    texture As Long
    textureID As Long
    renderOrder As Long 'Needs to be implemented to sort BACK TO FRONT
    timing As Long
    flipTexture As Long 'flag for flipping texture depending on direction
    scaleTextureX As _Float
    scaleTextureY As _Float
    offsetTextureX As _Float
    offsetTextureY As _Float
End Type

Type tPOLY 'list of vertices for all objects in simulation
    vert As tVECTOR2d
    norm As tVECTOR2d
End Type

Type tPOLYATTRIB 'keep track of polys in monlithic list of vertices
    start As Long ' starting vertex of the polygon
    count As Long ' number of vertices in polygon
End Type

Type tSPECIALFUNCTION
    func As Long
    arg As Long
End Type

Type tPHYSICS
    position As tVECTOR2d
    velocity As tVECTOR2d
    force As tVECTOR2d
    angularVelocity As _Float
    torque As _Float
    orient As _Float
    mass As _Float
    invMass As _Float
    inertia As _Float
    invInertia As _Float
    staticFriction As _Float
    dynamicFriction As _Float
    restitution As _Float
End Type

Type tBODY
    objectName As String * 64
    objectHash As _Integer64
    entityID As Long
    fzx As tPHYSICS
    shape As tSHAPE
    pa As tPOLYATTRIB
    c As Long ' color
    enable As Long 'Used to determine if body is active or not
    collisionMask As _Unsigned Integer 'is a bit mask is used by 'AND'ing together to test collisions
    noPhysics As Long 'Allows collisions but does not apply any impulses
    specFunc As tSPECIALFUNCTION 'Special Function - 0 - normal, 1 - Sensor
End Type

Type tMANIFOLD
    A As Long
    B As Long
    penetration As _Float
    normal As tVECTOR2d
    contactCount As Long
    e As _Float
    df As _Float
    sf As _Float
    cv As _Float 'contact velocity
End Type

Type tHIT
    A As Long
    B As Long
    position As tVECTOR2d
    cv As _Float
End Type

Type tJOINT
    jointName As String * 64
    jointHash As _Integer64
    M As tMATRIX2d
    localAnchor1 As tVECTOR2d
    localAnchor2 As tVECTOR2d
    r1 As tVECTOR2d
    r2 As tVECTOR2d
    bias As tVECTOR2d
    P As tVECTOR2d
    body1 As Long
    body2 As Long
    biasFactor As _Float
    softness As _Float
    wireframe_color As Long
    max_bias As _Float
End Type

Type tCAMERA
    position As tVECTOR2d
    zoom As _Float
    AABB As tVECTOR2d
    AABB_size As tVECTOR2d
    mode As Long 'use this to determine how the camera behaves
    fsm As tFSM
End Type

Type tWORLD
    plusLimit As tVECTOR2d
    minusLimit As tVECTOR2d
    gravity As tVECTOR2d
    spawn As tVECTOR2d
    terrainPosition As tVECTOR2d
End Type

Type tVEHICLE
    vehicleName As String * 64
    vehicleHash As _Integer64
    body As Long
    wheelOne As Long
    wheelTwo As Long
    axleJointOne As Long
    axleJointTwo As Long
    auxBodyOne As Long
    auxJointOne As Long
    wheelOneOffset As tVECTOR2d
    wheelTwoOffset As tVECTOR2d
    auxOneOffset As tVECTOR2d
    torque As _Float
End Type

Type tBODYMANAGER
    objectCount As Long
    jointCount As Long
End Type

Type tINPUTDEVICE
    xy As tVECTOR2d
    mouse As tVECTOR2d ' mouse world position
    mouseMode As Long '0 - hidden, 1 - show
    mouseOnScreen As Integer
    mouseIcon As Long ' mouse pointer tile
    mouseBody As Long ' mouse body used for sensor collisions
    b1 As Long
    lb1 As Long
    b1PosEdge As Long
    b1NegEdge As Long
    b2 As Long
    lb2 As Long
    b2PosEdge As Long
    b2NegEdge As Long
    b3 As Long
    lb3 As Long
    b3PosEdge As Long
    b3NegEdge As Long
    w As Long
    wCount As Long
    keyHit As Long
    lastKeyHit As Long
End Type

Type tNETWORK
    SorC As Long ' boolean Server or Client
    address As String * 1024
    port As Long
    protocol As String * 32
    HCHandle As Long
    connectionHandle As Long
End Type

Type tTILEMAP
    file As String * 256
    tsxFile As String * 256
    mapWidth As Long ' gamemap width
    mapHeight As Long ' gamemap height
    tileWidth As Long 'tile width in pixels
    tileHeight As Long 'tile height in pixels
    tileImageX As Long 'size of tilemap image in tiles
    tileCount As Long 'number of tiles in the image
    tileMap As Long ' tilemap image
    tileSize As Long 'same as tilewidth * tileheight, if square
    tilePadding As Long ' distance between tiles
    numberOfTilesX As Long 'same as w
    numberOfTilesY As Long 'same as h
    numberOfTiles As Long 'w*h
    tilescale As Long 'Tile to physics world scale
End Type

Type tTILE
    t As _Unsigned Long ' base tile layer
    t0 As _Unsigned Long ' second tile layer
    collision As Long ' collision
    id As Long
    class As String * 32
    aniNextFrame As Long
    aniTiming As Long
    lightColor As Long
    glTexture As _Integer64
End Type

Type tGL_TEXTURE
    glText As _Integer64
End Type


Type tENTITYPARAMETERS
    maxForce As tVECTOR2d
    movementSpeed As _Float ' time to traverse 1 square
    drunkiness As _Float ' 1-5 additional parameter for A-star
End Type

Type tENTITY
    objectID As Long
    objectType As Long
    parameters As tENTITYPARAMETERS
    pathString As String * 1024 ' for A* Path 'U'-Up 'D'-Down 'L'-Left 'R'-Right
    fsmPrimary As tFSM
    fsmSecondary As tFSM
End Type

Type tMESSAGE
    baseImage As Long
    fadeImage As Long
    fsm As tFSM
    position As tVECTOR2d
    scale As _Float
End Type

Type tMAPPARAMETERS
    maxLightDistance As Long
End Type

Type tENGINE
    displayClearColor As Long
    displayScr As Long
    hiddenScr As Long
    resting As _Float
    gameMode As tFSM
    logFileName As String * 64
    logFileNumber As Long
    displayMask As Long
    currentMap As String * 64
    mapParameters As tMAPPARAMETERS
End Type

Type tFPS
    fpsCount As Long
    fpsLast As Long
End Type

Type tTILEFONT
    t As Long
    c As Long
    id As Long
End Type

Type tPATH
    position As tVECTOR2d
    parent As tVECTOR2d
    g As Long
    h As Long
    f As Long
    status As Long
End Type

Type tSTRINGTUPLE
    contextName As String * 64
    arg As String * 4096
End Type

Type tSOUND
    fileName As String * 64
    class As String * 64
    fileHash As _Integer64
    classHash As _Integer64
    handle As Long
End Type

Type tPLAYLIST
    currentMusic As Long
    nextMusic As Long
    fsm As tFSM
    vol As _Float
    bal As _Float
End Type

Type tCOLOR
    r As _Unsigned _Byte
    g As _Unsigned _Byte
    b As _Unsigned _Byte
    a As _Unsigned _Byte
End Type

Type tLIGHT
    position As tVECTOR2d
    lightColor As Long
End Type

Type tLANDMARK
    position As tVECTOR2d
    landmarkName As String * 64
    landmarkHash As _Integer64
End Type

Type tDOOR
    bodyId As Long
    map As String * 64
    doorName As String * 64
    doorHash As _Integer64
    position As tVECTOR2d
    size As tVECTOR2d
    landmarkHash As _Integer64
    status As Integer
    tileOpen As Long
    tileClosed As Long
End Type

Type tGAMEOPTIONS
    musicVolume As Single
    soundVolume As Single
End Type

