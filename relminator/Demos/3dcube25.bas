'3d cube
'polygon filled using paint. ;*)
'I could probably shorten the code in less than 20 lines but
'I'd rather make another 25 liner. ;*)
'Relsoft 2003

$RESIZE:SMOOTH
SCREEN 9, , 1, 0
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM CubeM!(8, 7), CubeV(12, 2)
FOR V = 1 TO 8 + 12
    IF V < 9 THEN READ CubeM!(V, 0), CubeM!(V, 1), CubeM!(V, 2) ELSE READ CubeV(V - 8, 0), CubeV(V - 8, 1), CubeV(V - 8, 2)
NEXT
DO
    ax! = (ax! + .01) * -(ax! < 6.283186)
    ay! = (ay! + .01) * -(ay! < 6.283186)
    az! = (az! + .01) * -(az! < 6.283186)
    FOR I = 1 TO 8
        CubeM!(I, 6) = (256 * ((CubeM!(I, 0) * (COS(ay!) * COS(az!)) + CubeM!(I, 1) * (COS(ax!) * -SIN(az!) + SIN(ax!) * SIN(ay!) * COS(az!)) + CubeM!(I, 2) * (-SIN(ax!) * -SIN(az!) + COS(ax!) * SIN(ay!) * COS(az!)))) \ (256 - ((CubeM!(I, 0) * (-SIN(ay!)) + CubeM!(I, 1) * (SIN(ax!) * COS(ay!)) + CubeM!(I, 2) * (COS(ax!) * COS(ay!)))))) + 320
        CubeM!(I, 7) = -(256 * ((CubeM!(I, 0) * (COS(ay!) * SIN(az!)) + CubeM!(I, 1) * (COS(ax!) * COS(az!) + SIN(ax!) * SIN(ay!) * SIN(az!)) + CubeM!(I, 2) * (-SIN(ax!) * COS(az!) + COS(az!) * SIN(ay!) * SIN(az!)))) \ (256 - ((CubeM!(I, 0) * (-SIN(ay!)) + CubeM!(I, 1) * (SIN(ax!) * COS(ay!)) + CubeM!(I, 2) * (COS(ax!) * COS(ay!)))))) + 175
    NEXT
    LINE (0, 0)-(639, 350), 0, BF
    FOR I = 1 TO 12
        IF (CubeM!(CubeV(I, 2), 6) - CubeM!(CubeV(I, 0), 6)) * (CubeM!(CubeV(I, 1), 7) - CubeM!(CubeV(I, 0), 7)) - (CubeM!(CubeV(I, 1), 6) - CubeM!(CubeV(I, 0), 6)) * (CubeM!(CubeV(I, 2), 7) - CubeM!(CubeV(I, 0), 7)) < -256 THEN
            LINE (CubeM!(CubeV(I, 0), 6), CubeM!(CubeV(I, 0), 7))-(CubeM!(CubeV(I, 1), 6), CubeM!(CubeV(I, 1), 7)), I + 2
            LINE (CubeM!(CubeV(I, 1), 6), CubeM!(CubeV(I, 1), 7))-(CubeM!(CubeV(I, 2), 6), CubeM!(CubeV(I, 2), 7)), I + 2
            LINE (CubeM!(CubeV(I, 2), 6), CubeM!(CubeV(I, 2), 7))-(CubeM!(CubeV(I, 0), 6), CubeM!(CubeV(I, 0), 7)), I + 2
            PAINT ((CubeM!(CubeV(I, 0), 6) + CubeM!(CubeV(I, 1), 6) + CubeM!(CubeV(I, 2), 6)) \ 3, (CubeM!(CubeV(I, 0), 7) + CubeM!(CubeV(I, 1), 7) + CubeM!(CubeV(I, 2), 7)) \ 3), I + 2
        END IF
    NEXT
    PCOPY 1, 0
    _LIMIT 60
LOOP UNTIL INKEY$ <> ""

SYSTEM 0

DATA -80,-80,-80,80,-80,-80,80,80,-80,-80,80,-80,-80,-80,80,80,-80,80,80,80,80,-80,80,80
DATA 5,1,8,1,4,8,6,5,7,5,8,7,2,6,3,6,7,3,1,2,4,2,3,4,4,3,8,3,7,8,5,6,1,6,2,1
