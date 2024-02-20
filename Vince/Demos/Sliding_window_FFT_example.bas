CONST sw = 2048
CONST sh = 600

DIM SHARED pi AS DOUBLE
pi = 4 * ATN(1)

'declare sub rfft(xx_r(), xx_i(), x_r(), n)

DIM x_r(sw - 1), x_i(sw - 1)
DIM xx_r(sw - 1), xx_i(sw - 1)

DIM st_x_r(512 - 1), st_x_i(512 - 1)
DIM st_xx_r(512 - 1), st_xx_i(512 - 1)

DIM st_x_r2(sw - 1), st_x_i2(sw - 1)
DIM st_xx_r2(sw - 1), st_xx_i2(sw - 1)

DIM t AS DOUBLE

'create signal consisting of three sinewaves in RND noise
FOR i = 0 TO sw / 3 - 1
    x_r(i) = 100 * SIN(2 * pi * (sw * 1000 / 44000) * i / sw) '+ (100*rnd - 50)
NEXT
FOR i = sw / 3 TO 2 * sw / 3 - 1
    x_r(i) = 100 * SIN(2 * pi * (sw * 2000 / 44000) * i / sw) '+ (100*rnd - 50)
NEXT
FOR i = 2 * sw / 3 TO sw - 1
    x_r(i) = 100 * SIN(2 * pi * (sw * 8000 / 44000) * i / sw) '+ (100*rnd - 50)
NEXT


SCREEN _NEWIMAGE(sw / 2, sh, 32), , 1, 0

'plot signal
PSET (0, sh / 4 - x_r(0))
FOR i = 0 TO sw / 2 - 1
    LINE -(i, sh / 4 - x_r(i * 2)), _RGB(70, 0, 0)
NEXT
LINE (0, sh / 4)-STEP(sw, 0), _RGB(255, 0, 0), , &H5555

COLOR _RGB(255, 0, 0)
_PRINTSTRING (0, 0), "2048 samples of three sine waves (1 kHz, 2 kHz, 8 kHz) in RND noise sampled at 44 kHz"


rfft xx_r(), xx_i(), x_r(), sw

'plot its fft
'pset (0, 70+3*sh/4 - 0.005*sqr(xx_r(0)*xx_r(0) + xx_i(0)*xx_i(0)) )
FOR i = 0 TO sw / 2
    PSET (i * 2, 70 + 3 * sh / 4), _RGB(70, 70, 0)
    LINE -(i * 2, 70 + 3 * sh / 4 - 0.005 * SQR(xx_r(i) * xx_r(i) + xx_i(i) * xx_i(i))), _RGB(70, 70, 0)
NEXT
LINE (0, 70 + 3 * sh / 4)-STEP(sw, 0), _RGB(255, 255, 0), , &H5555

COLOR _RGB(70, 70, 0)
_PRINTSTRING (0, sh / 2), "its entire FFT first half"
COLOR _RGB(70, 0, 0)
_PRINTSTRING (0, sh / 2 + 16), "rectangular short time FFT"
COLOR _RGB(0, 70, 0)
_PRINTSTRING (0, sh / 2 + 32), "gaussian short time FFT"


SCREEN , , 0, 0
PCOPY 1, 0

mx = 0
DO
    DO
        mx = _MOUSEX
        my = _MOUSEY
        mbl = _MOUSEBUTTON(1)
        mbr = _MOUSEBUTTON(2)
        mw = mw + _MOUSEWHEEL
    LOOP WHILE _MOUSEINPUT

    PCOPY 1, 0


    'draw windows
    IF mx > sw / 2 - 256 THEN mx = sw / 2 - 256 - 1
    IF mx < 0 THEN mx = 0

    '''rectangular window
    LINE (mx, 1)-STEP(256, sh / 4 - 1), _RGB(255, 0, 0), B

    '''gaussian window
    z = (0 - mx - 128) / (128 / 2)
    PSET (mx, sh / 4 - (sh / 4) * EXP(-z * z / 2))
    FOR i = 0 TO sw / 2 - 1
        z = (i - mx - 128) / (128 / 2)
        LINE -(i, sh / 4 - (sh / 4) * EXP(-z * z / 2)), _RGB(0, 255, 0)
    NEXT


    'take it's windowed short time FFT
    FOR i = 0 TO 512 - 1
        'rectangular window -- do nothing
        st_x_r(i) = x_r(mx * 2 + i)
    NEXT

    FOR i = 0 TO sw - 1
        'gaussian window -- smooth out the edges
        z = (i - mx * 2 - 256) / (128 / 2)
        st_x_r2(i) = x_r(i) * EXP(-z * z / 2)
    NEXT

    '''plot signal rectangular
    PSET (mx, sh / 4 - st_x_r(0))
    FOR i = 0 TO 256 - 1
        LINE -(mx + i, sh / 4 - st_x_r(i * 2)), _RGB(255, 0, 0)
    NEXT
    LINE (0, sh / 4)-STEP(sw, 0), _RGB(255, 0, 0), , &H5555

    '''plot signal gaussian
    PSET (0, sh / 4 - st_x_r2(0))
    FOR i = 0 TO sw / 2 - 1
        LINE -(i, sh / 4 - st_x_r2(i * 2)), _RGB(0, 255, 0)
    NEXT
    LINE (0, sh / 4)-STEP(sw, 0), _RGB(255, 0, 0), , &H5555


    rfft st_xx_r(), st_xx_i(), st_x_r(), 512
    rfft st_xx_r2(), st_xx_i2(), st_x_r2(), sw


    'plot its short time fft rectangular
    PSET (0, 70 + 3 * sh / 4 - 0.015 * SQR(st_xx_r(0) * st_xx_r(0) + st_xx_i(0) * st_xx_i(0)))
    FOR i = 0 TO 128
        'pset (i*8, 70 + 3*sh/4), _rgb(256,256,0)
        LINE -(i * 8, 70 + 3 * sh / 4 - 0.015 * SQR(st_xx_r(i) * st_xx_r(i) + st_xx_i(i) * st_xx_i(i))), _RGB(256, 0, 0)
    NEXT

    '''parabolic tone finder
    DIM max AS DOUBLE, d AS DOUBLE
    max = 0
    m = 0
    FOR i = 0 TO 256
        d = SQR(st_xx_r(i) * st_xx_r(i) + st_xx_i(i) * st_xx_i(i))
        IF d > max THEN
            max = d
            m = i
        END IF
    NEXT

    DIM c AS DOUBLE
    DIM u_r AS DOUBLE, u_i AS DOUBLE
    DIM v_r AS DOUBLE, v_i AS DOUBLE

    u_r = st_xx_r(m - 1) - st_xx_r(m + 1)
    u_i = st_xx_i(m - 1) - st_xx_i(m + 1)
    v_r = 2 * st_xx_r(m) - st_xx_r(m - 1) - st_xx_r(m + 1)
    v_i = 2 * st_xx_i(m) - st_xx_i(m - 1) - st_xx_i(m + 1)
    c = (u_r * v_r + u_i * v_i) / (v_r * v_r + v_i * v_i)

    COLOR _RGB(70, 70, 0)
    _PRINTSTRING (sw / 4, sh / 2), "spectral parabolic interpolation tone detector"
    COLOR _RGB(255, 0, 0)
    _PRINTSTRING (sw / 4, sh / 2 + 16), "f_peak = " + STR$((m + c) * 44000 / 512) + " Hz"

    i = m
    PSET ((i + c) * 8, 70 + 3 * sh / 4), _RGB(256, 256, 0)
    LINE -((i + c) * 8, sh), _RGB(256, 0, 0)


    'plot its short time fft gaussian
    PSET (0, 70 + 3 * sh / 4 - 0.03 * SQR(st_xx_r2(0) * st_xx_r2(0) + st_xx_i2(0) * st_xx_i2(0)))
    FOR i = 0 TO sw / 2
        'pset (i*8, 70 + 3*sh/4), _rgb(256,256,0)
        LINE -(i * 2, 70 + 3 * sh / 4 - 0.03 * SQR(st_xx_r2(i) * st_xx_r2(i) + st_xx_i2(i) * st_xx_i2(i))), _RGB(0, 256, 0)
    NEXT

    '''parabolic tone finder
    max = 0
    m = 0
    FOR i = 0 TO sw / 2
        d = SQR(st_xx_r2(i) * st_xx_r2(i) + st_xx_i2(i) * st_xx_i2(i))
        IF d > max THEN
            max = d
            m = i
        END IF
    NEXT

    u_r = st_xx_r2(m - 1) - st_xx_r2(m + 1)
    u_i = st_xx_i2(m - 1) - st_xx_i2(m + 1)
    v_r = 2 * st_xx_r2(m) - st_xx_r2(m - 1) - st_xx_r2(m + 1)
    v_i = 2 * st_xx_i2(m) - st_xx_i2(m - 1) - st_xx_i2(m + 1)
    c = (u_r * v_r + u_i * v_i) / (v_r * v_r + v_i * v_i)

    COLOR _RGB(0, 256, 0)
    _PRINTSTRING (sw / 4, sh / 2 + 32), "f_peak = " + STR$((m + c) * 44000 / sw) + " Hz"

    i = m
    PSET ((i + c) * 2, 70 + 3 * sh / 4), _RGB(0, 256, 0)
    LINE -((i + c) * 2, sh), _RGB(0, 256, 0)


    _DISPLAY
    _LIMIT 30
LOOP UNTIL _KEYHIT = 27
SYSTEM


SUB rfft (xx_r(), xx_i(), x_r(), n)
    DIM w_r AS DOUBLE, w_i AS DOUBLE, wm_r AS DOUBLE, wm_i AS DOUBLE
    DIM u_r AS DOUBLE, u_i AS DOUBLE, v_r AS DOUBLE, v_i AS DOUBLE

    log2n = LOG(n / 2) / LOG(2)

    FOR i = 0 TO n / 2 - 1
        rev = 0
        FOR j = 0 TO log2n - 1
            IF i AND (2 ^ j) THEN rev = rev + (2 ^ (log2n - 1 - j))
        NEXT

        xx_r(i) = x_r(2 * rev)
        xx_i(i) = x_r(2 * rev + 1)
    NEXT

    FOR i = 1 TO log2n
        m = 2 ^ i
        wm_r = COS(-2 * pi / m)
        wm_i = SIN(-2 * pi / m)

        FOR j = 0 TO n / 2 - 1 STEP m
            w_r = 1
            w_i = 0

            FOR k = 0 TO m / 2 - 1
                p = j + k
                q = p + (m \ 2)

                u_r = w_r * xx_r(q) - w_i * xx_i(q)
                u_i = w_r * xx_i(q) + w_i * xx_r(q)
                v_r = xx_r(p)
                v_i = xx_i(p)

                xx_r(p) = v_r + u_r
                xx_i(p) = v_i + u_i
                xx_r(q) = v_r - u_r
                xx_i(q) = v_i - u_i

                u_r = w_r
                u_i = w_i
                w_r = u_r * wm_r - u_i * wm_i
                w_i = u_r * wm_i + u_i * wm_r
            NEXT
        NEXT
    NEXT

    xx_r(n / 2) = xx_r(0)
    xx_i(n / 2) = xx_i(0)

    FOR i = 1 TO n / 2 - 1
        xx_r(n / 2 + i) = xx_r(n / 2 - i)
        xx_i(n / 2 + i) = xx_i(n / 2 - i)
    NEXT

    DIM xpr AS DOUBLE, xpi AS DOUBLE
    DIM xmr AS DOUBLE, xmi AS DOUBLE

    FOR i = 0 TO n / 2 - 1
        xpr = (xx_r(i) + xx_r(n / 2 + i)) / 2
        xpi = (xx_i(i) + xx_i(n / 2 + i)) / 2

        xmr = (xx_r(i) - xx_r(n / 2 + i)) / 2
        xmi = (xx_i(i) - xx_i(n / 2 + i)) / 2

        xx_r(i) = xpr + xpi * COS(2 * pi * i / n) - xmr * SIN(2 * pi * i / n)
        xx_i(i) = xmi - xpi * SIN(2 * pi * i / n) - xmr * COS(2 * pi * i / n)
    NEXT

    'symmetry, complex conj
    'for i=0 to n/2 - 1
    '       xx_r(n/2 + i) = xx_r(n/2 - 1 - i)
    '       xx_i(n/2 + i) =-xx_i(n/2 - 1 - i)
    'next
END SUB
