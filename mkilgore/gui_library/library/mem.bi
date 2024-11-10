'MEM Library
'Copyright Matt Kilgore -- 2011/2013

'This program is free software, without any warranty of any kind.
'You are free to edit, copy, modify, and redistribute it under the terms
'of the Do What You Want Public License, Version 1, as published by Matt Kilgore
'See file COPYING that should have been included with this source.

$INCLUDEONCE

'DIM SHARED MEM_MEM_FOR_SIZEOF AS _MEM
'DIM SHARED MEM_FAKEMEM AS _MEM

DECLARE CUSTOMTYPE LIBRARY
    FUNCTION MEM_MALLOC%& ALIAS malloc (BYVAL bytes AS LONG)
    FUNCTION MEM_REALLOC%& ALIAS realloc (BYVAL src AS _UNSIGNED _OFFSET, BYVAL size AS _UNSIGNED LONG)
    SUB MEM_FREE ALIAS free (BYVAL off AS _OFFSET)
    SUB MEM_MEMCPY ALIAS memcpy (BYVAL dest AS _OFFSET, BYVAL src AS _OFFSET, BYVAL bytes AS LONG)
    SUB MEM_MEMSET ALIAS memset (BYVAL dest AS _OFFSET, BYVAL value AS LONG, BYVAL bytes AS LONG)
    SUB MEM_MEMMOVE ALIAS memmove (BYVAL dest AS _OFFSET, BYVAL src AS _OFFSET, BYVAL bytes AS LONG)
END DECLARE

$IF 32BIT THEN
    CONST MEM_SIZEOF_OFFSET = 4
$ELSE
    CONST MEM_SIZEOF_OFFSET = 8
$END IF

CONST MEM_SIZEOF_MEM_STRING = MEM_SIZEOF_OFFSET + 4 + 4 + 1
TYPE MEM_String
    mem AS _OFFSET
    length AS LONG
    allocated AS LONG
    is_allocated AS _BYTE
END TYPE

CONST MEM_SIZEOF_MEM_ARRAY = MEM_SIZEOF_OFFSET + 4 + 4 + 1 + 2 + 4
TYPE MEM_Array
    mem AS _OFFSET
    length AS LONG
    allocated AS _UNSIGNED LONG
    is_allocated AS _BYTE
    element_size AS INTEGER
    last_element AS LONG
END TYPE
