' ===========================================================================
'
' MOUSE.BI
'
'  Copyright (C) 1989 Microsoft Corporation, All Rights Reserved
'  Copyright (C) 2023 Samuel Gomes
'
' ===========================================================================

$INCLUDEONCE

'$INCLUDE:'General.bi'

TYPE MousePrivateType
    bL AS LONG
    bT AS LONG
    bR AS LONG
    bB AS LONG
END TYPE

DIM MousePrivate AS MousePrivateType
