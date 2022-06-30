'adding a to a until it overflow in wich case we carry
'a byte should be 8 bits value but for some reason,
'QB64 doesn't overflow in it's c++ code emission
'we still have to check for carry with a modulo operation
'instead of just checking if the result is lesser than the original value

DIM A AS _BYTE

A = &H21
Carry = 0
PRINT HEX$(A), Carry ' definitively should not carry
orig = A
result = A + A
IF result MOD 256 < orig THEN Carry = 1 ' should not carry
A = result
PRINT HEX$(A), Carry
orig = A
result = A + A
IF result MOD 256 < orig THEN Carry = 1 ' still should not carry yet
A = result
PRINT HEX$(A), Carry
orig = A
result = A + A
IF result MOD 256 < orig THEN Carry = 1 ' should carry
A = result
PRINT HEX$(A), Carry


