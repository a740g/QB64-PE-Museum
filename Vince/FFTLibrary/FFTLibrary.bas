CONST sw = 512
CONST sh = 600

DIM SHARED pi AS DOUBLE
'pi = 2*asin(1)
pi = 4 * ATN(1)

declare sub rfft(xx_r(), xx_i(), x_r(), n)
declare sub fft(xx_r(), xx_i(), x_r(), x_i(), n)
declare sub dft(xx_r(), xx_i(), x_r(), x_i(), n)


DIM x_r(sw - 1), x_i(sw - 1)
DIM xx_r(sw - 1), xx_i(sw - 1)
DIM t AS DOUBLE

FOR i = 0 TO sw - 1
    'x_r(i) = 100*sin(2*pi*62.27*i/sw) + 25*cos(2*pi*132.27*i/sw)
    x_r(i) = 100 * SIN(0.08 * i) + 25 * COS(i)
    x_i(i) = 0
NEXT


'screenres sw, sh, 32
SCREEN _NEWIMAGE(sw * 2, sh, 32)

'plot input signal
PSET (0, sh / 4 - x_r(0))
FOR i = 0 TO sw - 1
    LINE -(i, sh / 4 - x_r(i)), _RGB(255, 0, 0)
NEXT
LINE (0, sh / 4)-STEP(sw, 0), _RGB(255, 0, 0), , &H5555
COLOR _RGB(255, 0, 0)
_PRINTSTRING (0, 0), "input signal"

fft xx_r(), xx_i(), x_r(), x_i(), sw

'plot its fft
PSET (0, 50 + 3 * sh / 4 - 0.01 * SQR(xx_r(0) * xx_r(0) + xx_i(0) * xx_i(0))), _RGB(255, 255, 0)
FOR i = 0 TO sw / 2
    LINE -(i * 2, 50 + 3 * sh / 4 - 0.01 * SQR(xx_r(i) * xx_r(i) + xx_i(i) * xx_i(i))), _RGB(255, 255, 0)
NEXT
LINE (0, 50 + 3 * sh / 4)-STEP(sw, 0), _RGB(255, 255, 0), , &H5555


'set unwanted frequencies to zero
FOR i = 50 TO sw / 2
    xx_r(i) = 0
    xx_i(i) = 0
    xx_r(sw - i) = 0
    xx_i(sw - i) = 0
NEXT

'plot fft of filtered signal
PSET (sw, 50 + 3 * sh / 4 - 0.01 * SQR(xx_r(0) * xx_r(0) + xx_i(0) * xx_i(0))), _RGB(255, 255, 0)
FOR i = 0 TO sw / 2
    LINE -(sw + i * 2, 50 + 3 * sh / 4 - 0.01 * SQR(xx_r(i) * xx_r(i) + xx_i(i) * xx_i(i))), _RGB(0, 155, 255)
NEXT
LINE (sw, 50 + 3 * sh / 4)-STEP(sw, 0), _RGB(0, 155, 255), , &H5555

'take inverse fft
FOR i = 0 TO sw - 1
    xx_i(i) = -xx_i(i)
NEXT

fft x_r(), x_i(), xx_r(), xx_i(), sw

FOR i = 0 TO sw - 1
    x_r(i) = x_r(i) / sw
    x_i(i) = x_i(i) / sw
NEXT


'plot filtered signal
PSET (sw, sh / 4 - x_r(0))
FOR i = 0 TO sw - 1
    LINE -(sw + i, sh / 4 - x_r(i)), _RGB(0, 255, 0)
NEXT
LINE (sw, sh / 4)-STEP(sw, 0), _RGB(0, 255, 0), , &H5555

COLOR _RGB(0, 255, 0)
_PRINTSTRING (sw, 0), "filtered signal"

SLEEP
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
    FOR i = 0 TO n / 2 - 1
        xx_r(n / 2 + i) = xx_r(n / 2 - 1 - i)
        xx_i(n / 2 + i) = -xx_i(n / 2 - 1 - i)
    NEXT
END SUB

SUB fft (xx_r(), xx_i(), x_r(), x_i(), n)
    DIM w_r AS DOUBLE, w_i AS DOUBLE, wm_r AS DOUBLE, wm_i AS DOUBLE
    DIM u_r AS DOUBLE, u_i AS DOUBLE, v_r AS DOUBLE, v_i AS DOUBLE

    log2n = LOG(n) / LOG(2)

    'bit rev copy
    FOR i = 0 TO n - 1
        rev = 0
        FOR j = 0 TO log2n - 1
            IF i AND (2 ^ j) THEN rev = rev + (2 ^ (log2n - 1 - j))
        NEXT

        xx_r(i) = x_r(rev)
        xx_i(i) = x_i(rev)
    NEXT


    FOR i = 1 TO log2n
        m = 2 ^ i
        wm_r = COS(-2 * pi / m)
        wm_i = SIN(-2 * pi / m)

        FOR j = 0 TO n - 1 STEP m
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
END SUB

SUB dft (xx_r(), xx_i(), x_r(), x_i(), n)
    FOR i = 0 TO n - 1
        xx_r(i) = 0
        xx_i(i) = 0
        FOR j = 0 TO n - 1
            xx_r(i) = xx_r(i) + x_r(j) * COS(2 * pi * i * j / n) + x_i(j) * SIN(2 * pi * i * j / n)
            xx_i(i) = xx_i(i) - x_r(j) * SIN(2 * pi * i * j / n) + x_i(j) * COS(2 * pi * i * j / n)
        NEXT
    NEXT
END SUB
