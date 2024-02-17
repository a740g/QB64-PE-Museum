$IF TYPESINCLUDE = UNDEFINED THEN
    $LET TYPESINCLUDE = TRUE

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

    TYPE tSHAPE
        ty AS INTEGER ' cSHAPE_CIRCLE = 1, cSHAPE_POLYGON = 2
        radius AS _FLOAT ' Only necessary for circle shapes
        u AS tMATRIX2d ' Only necessary for polygons
        texture AS LONG
        flipTexture AS INTEGER 'flag for flipping texture depending on direction
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
        start AS INTEGER ' starting vertex of the polygon
        count AS INTEGER ' number of vertices in polygon
    END TYPE

    TYPE tBODY
        objectName AS STRING * 64
        objectHash AS _INTEGER64
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
        shape AS tSHAPE
        pa AS tPOLYATTRIB
        c AS LONG ' color
        enable AS INTEGER 'Hide a body ;)
        collisionMask AS _UNSIGNED INTEGER
    END TYPE

    TYPE tMANIFOLD
        A AS INTEGER
        B AS INTEGER
        penetration AS _FLOAT
        normal AS tVECTOR2d
        contactCount AS INTEGER
        e AS _FLOAT
        df AS _FLOAT
        sf AS _FLOAT
        cv AS _FLOAT 'contact velocity
    END TYPE

    TYPE tHIT
        A AS INTEGER
        B AS INTEGER
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
        body1 AS INTEGER
        body2 AS INTEGER
        biasFactor AS _FLOAT
        softness AS _FLOAT
    END TYPE

    TYPE tCAMERA
        position AS tVECTOR2d
        zoom AS _FLOAT
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
        body AS INTEGER
        wheelOne AS INTEGER
        wheelTwo AS INTEGER
        axleJointOne AS INTEGER
        axleJointTwo AS INTEGER
        auxBodyOne AS INTEGER
        auxJointOne AS INTEGER
        wheelOneOffset AS tVECTOR2d
        wheelTwoOffset AS tVECTOR2d
        auxOneOffset AS tVECTOR2d
        torque AS _FLOAT
    END TYPE

    TYPE tOBJECTMANAGER
        objectCount AS INTEGER
        jointCount AS INTEGER
    END TYPE

    TYPE tINPUTDEVICE
        x AS INTEGER
        y AS INTEGER
        b1 AS INTEGER
        lb1 AS INTEGER
        b1PosEdge AS INTEGER
        b1NegEdge AS INTEGER
        b2 AS INTEGER
        lb2 AS INTEGER
        b2PosEdge AS INTEGER
        b2NegEdge AS INTEGER
        b3 AS INTEGER
        lb3 AS INTEGER
        b3PosEdge AS INTEGER
        b3NegEdge AS INTEGER
        w AS INTEGER
        wCount AS INTEGER
        keyHit AS LONG
        lastKeyHit AS LONG
    END TYPE

    TYPE tNETWORK
        SorC AS INTEGER ' boolean Host or client
        address AS STRING * 1024
        port AS LONG
        protocol AS STRING * 32
        HCHandle AS LONG
        connectionHandle AS LONG
    END TYPE
$END IF
