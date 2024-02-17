'**********************************************************************************************
'   Setup Engine Types and Variables
'**********************************************************************************************
TYPE tVECTOR2d
  x AS _FLOAT
  y AS _FLOAT
END TYPE

TYPE tLINE2d ' Not used
  a AS tVECTOR2d
  b AS tVECTOR2d
END TYPE

TYPE tFACE2d ' Not used
  f0 AS tVECTOR2d
  f1 AS tVECTOR2d
END TYPE

TYPE tTRIANGLE ' Not used
  a AS tVECTOR2d
  b AS tVECTOR2d
  c AS tVECTOR2d
END TYPE

TYPE tMATRIX2d
  m00 AS _FLOAT
  m01 AS _FLOAT
  m10 AS _FLOAT
  m11 AS _FLOAT
END TYPE

TYPE tELAPSEDTIMER
  start AS _FLOAT
  last AS _FLOAT
  duration AS _FLOAT
END TYPE

TYPE tFSM
  currentState AS LONG
  previousState AS LONG
  timerState AS tELAPSEDTIMER
  arg1 AS tVECTOR2d ' keep some info on goals
  arg2 AS tVECTOR2d
  arg3 AS _FLOAT
  arg4 AS LONG
END TYPE

TYPE tSHAPE
  ty AS LONG ' cSHAPE_CIRCLE = 1, cSHAPE_POLYGON = 2
  radius AS _FLOAT ' Only necessary for circle shapes
  max_dimension AS tVECTOR2d 'To optomize AABB for collision
  u AS tMATRIX2d ' Only necessary for polygons
  texture AS LONG
  textureID AS LONG
  renderOrder AS LONG 'Needs to be implemented to sort BACK TO FRONT
  timing AS LONG
  flipTexture AS LONG 'flag for flipping texture depending on direction
  scaleTextureX AS _FLOAT
  scaleTextureY AS _FLOAT
  offsetTextureX AS _FLOAT
  offsetTextureY AS _FLOAT
END TYPE

TYPE tPOLY 'list of vertices for all objects in simulation
  vert AS tVECTOR2d
  norm AS tVECTOR2d
END TYPE

TYPE tPOLYATTRIB 'keep track of polys in monlithic list of vertices
  start AS LONG ' starting vertex of the polygon
  count AS LONG ' number of vertices in polygon
END TYPE

TYPE tSPECIALFUNCTION
  func AS LONG
  arg AS LONG
END TYPE

TYPE tPHYSICS
  position AS tVECTOR2d
  velocity AS tVECTOR2d
  force AS tVECTOR2d
  angularVelocity AS _FLOAT
  torque AS _FLOAT
  orient AS _FLOAT
  mass AS _FLOAT
  invMass AS _FLOAT
  inertia AS _FLOAT
  invInertia AS _FLOAT
  staticFriction AS _FLOAT
  dynamicFriction AS _FLOAT
  restitution AS _FLOAT
END TYPE

TYPE tBODY
  objectName AS STRING * 64
  objectHash AS _INTEGER64
  entityID AS LONG
  fzx AS tPHYSICS
  shape AS tSHAPE
  pa AS tPOLYATTRIB
  c AS LONG ' color
  enable AS LONG 'Used to determine if body is active or not
  collisionMask AS _UNSIGNED INTEGER 'is a bit mask is used by 'AND'ing together to test collisions
  noPhysics AS LONG 'Allows collisions but does not apply any impulses
  specFunc AS tSPECIALFUNCTION 'Special Function - 0 - normal, 1 - Sensor
END TYPE

TYPE tMANIFOLD
  A AS LONG
  B AS LONG
  penetration AS _FLOAT
  normal AS tVECTOR2d
  contactCount AS LONG
  e AS _FLOAT
  df AS _FLOAT
  sf AS _FLOAT
  cv AS _FLOAT 'contact velocity
END TYPE

TYPE tHIT
  A AS LONG
  B AS LONG
  position AS tVECTOR2d
  cv AS _FLOAT
END TYPE

TYPE tJOINT
  jointName AS STRING * 64
  jointHash AS _INTEGER64
  M AS tMATRIX2d
  localAnchor1 AS tVECTOR2d
  localAnchor2 AS tVECTOR2d
  r1 AS tVECTOR2d
  r2 AS tVECTOR2d
  bias AS tVECTOR2d
  P AS tVECTOR2d
  body1 AS LONG
  body2 AS LONG
  biasFactor AS _FLOAT
  softness AS _FLOAT
  wireframe_color AS LONG
  max_bias AS _FLOAT
END TYPE

TYPE tCAMERA
  position AS tVECTOR2d
  zoom AS _FLOAT
  AABB AS tVECTOR2d
  AABB_size AS tVECTOR2d
  mode AS LONG 'use this to determine how the camera behaves
  fsm AS tFSM
END TYPE

TYPE tWORLD
  plusLimit AS tVECTOR2d
  minusLimit AS tVECTOR2d
  gravity AS tVECTOR2d
  spawn AS tVECTOR2d
  terrainPosition AS tVECTOR2d
END TYPE

TYPE tVEHICLE
  vehicleName AS STRING * 64
  vehicleHash AS _INTEGER64
  body AS LONG
  wheelOne AS LONG
  wheelTwo AS LONG
  axleJointOne AS LONG
  axleJointTwo AS LONG
  auxBodyOne AS LONG
  auxJointOne AS LONG
  wheelOneOffset AS tVECTOR2d
  wheelTwoOffset AS tVECTOR2d
  auxOneOffset AS tVECTOR2d
  torque AS _FLOAT
END TYPE

TYPE tBODYMANAGER
  objectCount AS LONG
  jointCount AS LONG
END TYPE

TYPE tINPUTDEVICE
  xy AS tVECTOR2d
  mouse AS tVECTOR2d ' mouse world position
  mouseMode AS LONG '0 - hidden, 1 - show
  mouseOnScreen AS INTEGER
  mouseIcon AS LONG ' mouse pointer tile
  mouseBody AS LONG ' mouse body used for sensor collisions
  b1 AS LONG
  lb1 AS LONG
  b1PosEdge AS LONG
  b1NegEdge AS LONG
  b2 AS LONG
  lb2 AS LONG
  b2PosEdge AS LONG
  b2NegEdge AS LONG
  b3 AS LONG
  lb3 AS LONG
  b3PosEdge AS LONG
  b3NegEdge AS LONG
  w AS LONG
  wCount AS LONG
  keyHit AS LONG
  lastKeyHit AS LONG
END TYPE

TYPE tNETWORK
  SorC AS LONG ' boolean Server or Client
  address AS STRING * 1024
  port AS LONG
  protocol AS STRING * 32
  HCHandle AS LONG
  connectionHandle AS LONG
END TYPE

TYPE tTILEMAP
  file AS STRING * 256
  tsxFile AS STRING * 256
  mapWidth AS LONG ' gamemap width
  mapHeight AS LONG ' gamemap height
  tileWidth AS LONG 'tile width in pixels
  tileHeight AS LONG 'tile height in pixels
  tileImageX AS LONG 'size of tilemap image in tiles
  tileCount AS LONG 'number of tiles in the image
  tileMap AS LONG ' tilemap image
  tileSize AS LONG 'same as tilewidth * tileheight, if square
  tilePadding AS LONG ' distance between tiles
  numberOfTilesX AS LONG 'same as w
  numberOfTilesY AS LONG 'same as h
  numberOfTiles AS LONG 'w*h
  tilescale AS LONG 'Tile to physics world scale
END TYPE

TYPE tTILE
  t AS _UNSIGNED LONG ' base tile layer
  t0 AS _UNSIGNED LONG ' second tile layer
  collision AS LONG ' collision
  id AS LONG
  class AS STRING * 32
  aniNextFrame AS LONG
  aniTiming AS LONG
  lightColor AS LONG
  glTexture AS LONG
END TYPE

TYPE tENTITYPARAMETERS
  maxForce AS tVECTOR2d
  movementSpeed AS _FLOAT ' time to traverse 1 square
  drunkiness AS _FLOAT ' 1-5 additional parameter for A-star
END TYPE

TYPE tENTITY
  objectID AS LONG
  objectType AS LONG
  parameters AS tENTITYPARAMETERS
  pathString AS STRING * 1024 ' for A* Path 'U'-Up 'D'-Down 'L'-Left 'R'-Right
  fsmPrimary AS tFSM
  fsmSecondary AS tFSM
END TYPE

TYPE tMESSAGE
  baseImage AS LONG
  fadeImage AS LONG
  fsm AS tFSM
  position AS tVECTOR2d
  scale AS _FLOAT
END TYPE

TYPE tMAPPARAMETERS
  maxLightDistance AS LONG
END TYPE

TYPE tENGINE
  displayClearColor AS LONG
  displayScr AS LONG
  hiddenScr AS LONG
  resting AS _FLOAT
  gameMode AS tFSM
  logFileName AS STRING * 64
  logFileNumber AS LONG
  displayMask AS LONG
  currentMap AS STRING * 64
  mapParameters AS tMAPPARAMETERS
END TYPE

TYPE tFPS
  fpsCount AS LONG
  fpsLast AS LONG
END TYPE

TYPE tTILEFONT
  t AS LONG
  c AS LONG
  id AS LONG
END TYPE

TYPE tPATH
  position AS tVECTOR2d
  parent AS tVECTOR2d
  g AS LONG
  h AS LONG
  f AS LONG
  status AS LONG
END TYPE

TYPE tSTRINGTUPLE
  contextName AS STRING * 64
  arg AS STRING * 4096
END TYPE

TYPE tSOUND
  fileName AS STRING * 64
  class AS STRING * 64
  fileHash AS _INTEGER64
  classHash AS _INTEGER64
  handle AS LONG
END TYPE

TYPE tPLAYLIST
  currentMusic AS LONG
  nextMusic AS LONG
  fsm AS tFSM
  vol AS _FLOAT
  bal AS _FLOAT
END TYPE

TYPE tCOLOR
  r AS _UNSIGNED _BYTE
  g AS _UNSIGNED _BYTE
  b AS _UNSIGNED _BYTE
  a AS _UNSIGNED _BYTE
END TYPE

TYPE tLIGHT
  position AS tVECTOR2d
  lightColor AS LONG
END TYPE

TYPE tLANDMARK
  position AS tVECTOR2d
  landmarkName AS STRING * 64
  landmarkHash AS _INTEGER64
END TYPE

TYPE tDOOR
  bodyId AS LONG
  map AS STRING * 64
  doorName AS STRING * 64
  doorHash AS _INTEGER64
  position AS tVECTOR2d
  size AS tVECTOR2d
  landmarkHash AS _INTEGER64
  status AS INTEGER
  tileOpen AS LONG
  tileClosed AS LONG
END TYPE

