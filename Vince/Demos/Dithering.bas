DEFLNG A-Z

img1 = _LOADIMAGE("nefertiti.jpg", 32)

w = _WIDTH(img1)
h = _HEIGHT(img1)

img2 = _NEWIMAGE(w, h, 32)
img3 = _NEWIMAGE(w, h, 32)
img4 = _NEWIMAGE(w, h, 32)

img5 = _NEWIMAGE(w, h, 32)
img6 = _NEWIMAGE(w, h, 32)
img7 = _NEWIMAGE(w, h, 32)

img8 = _NEWIMAGE(w, h, 32)
img9 = _NEWIMAGE(w, h, 32)
img10 = _NEWIMAGE(w, h, 32)

SCREEN _NEWIMAGE(w * 3, h * 3, 32)

REDIM h(2, 1) AS SINGLE
h(0, 0) = 0: h(1, 0) = -1: h(2, 0) = 7 / 16
h(0, 1) = 3 / 16: h(1, 1) = 5 / 16: h(2, 1) = 1 / 16

dither_bw img1, img2, 0.1, h()
dither img1, img3, 2, h()
dither img1, img4, 4, h()

REDIM h(4, 2) AS SINGLE
h(0, 0) = 0: h(1, 0) = 0: h(2, 0) = -1: h(3, 0) = 7 / 48: h(4, 0) = 5 / 48
h(0, 1) = 3 / 48: h(1, 1) = 5 / 48: h(2, 1) = 7 / 48: h(3, 1) = 5 / 48: h(4, 1) = 3 / 48
h(0, 2) = 1 / 48: h(1, 2) = 3 / 48: h(2, 2) = 5 / 48: h(3, 2) = 3 / 48: h(4, 2) = 1 / 48

dither_bw img1, img5, 0.1, h()
dither img1, img6, 2, h()
dither img1, img7, 4, h()

REDIM h(3, 2) AS SINGLE
h(0, 0) = 0: h(1, 0) = -1: h(2, 0) = 1 / 8: h(3, 0) = 1 / 8
h(0, 1) = 1 / 8: h(1, 1) = 1 / 8: h(2, 1) = 1 / 8: h(3, 1) = 0
h(0, 2) = 0: h(1, 2) = 1 / 8: h(2, 2) = 0: h(3, 2) = 0

dither_bw img1, img8, 0.1, h()
dither img1, img9, 2, h()
dither img1, img10, 4, h()

_DEST 0
_PUTIMAGE (0, 0), img2
_PUTIMAGE (w, 0), img3
_PUTIMAGE (2 * w, 0), img4
_PRINTSTRING (0, 0), "Floyd-Steinberg"

_PUTIMAGE (0, h), img5
_PUTIMAGE (w, h), img6
_PUTIMAGE (2 * w, h), img7
_PRINTSTRING (0, h), "Jarvis, Judice, and Ninke"

_PUTIMAGE (0, 2 * h), img8
_PUTIMAGE (w, 2 * h), img9
_PUTIMAGE (2 * w, 2 * h), img10
_PRINTSTRING (0, 2 * h), "Atkinson"


DO
LOOP UNTIL _KEYHIT = 27
SYSTEM

'colour dither
'source image, destination image, number of colours per channel, diffusion matrix
SUB dither (img1, img2, num, h() AS SINGLE)
    w = _WIDTH(img1)
    h = _HEIGHT(img1)

    _DEST img2
    _SOURCE img2

    _PUTIMAGE , img1

    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1

            z = POINT(x, y)

            r = (_RED(z) * num \ 255) * 255 \ num
            g = (_GREEN(z) * num \ 255) * 255 \ num
            b = (_BLUE(z) * num \ 255) * 255 \ num

            PSET (x, y), _RGB(r, g, b)

            qr = _RED(z) - r
            qg = _GREEN(z) - g
            qb = _BLUE(z) - b

            conv_ed img2, x, y, h(), qr, qg, qb
        NEXT
    NEXT
END SUB

'black and white dither
'source image, destination image, bw threshold percent, diffusion matrix
SUB dither_bw (img1, img2, t AS DOUBLE, h() AS SINGLE)
    w = _WIDTH(img1)
    h = _HEIGHT(img1)

    _DEST img2
    _SOURCE img2

    _PUTIMAGE , img1

    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1

            z = POINT(x, y)

            c = -((_RED(z) + _GREEN(z) + _BLUE(z)) / 3 > 255 * t) * 255

            PSET (x, y), _RGB(c, c, c)

            qr = _RED(z) - c
            qg = _GREEN(z) - c
            qb = _BLUE(z) - c

            conv_ed img2, x, y, h(), qr, qg, qb
        NEXT
    NEXT
END SUB

SUB conv_ed (img, x0, y0, h() AS SINGLE, qr, qg, qb)
    FOR y = 0 TO UBOUND(h, 2)
        FOR x = 0 TO UBOUND(h, 1)
            IF h(x, y) = -1 THEN
                xx = x
                yy = y
            END IF
        NEXT
    NEXT

    _SOURCE img
    _DEST img

    FOR y = 0 TO UBOUND(h, 2)
        FOR x = 0 TO UBOUND(h, 1)
            IF h(x, y) > 0 THEN
                r = _RED(POINT(x0 - xx + x, y0 - yy + y)) + qr * h(x, y)
                g = _GREEN(POINT(x0 - xx + x, y0 - yy + y)) + qg * h(x, y)
                b = _BLUE(POINT(x0 - xx + x, y0 - yy + y)) + qb * h(x, y)

                PSET (x0 - xx + x, y0 - yy + y), _RGB(r, g, b)
            END IF
        NEXT
    NEXT
END SUB

