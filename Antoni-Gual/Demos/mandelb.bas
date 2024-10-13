'MANDELBROT by Antoni Gual 2003
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

DIM AS LONG x, iter
DIM AS SINGLE im2, im, re

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DO
    iter = 0
    x = (x + 123) MOD 64000

    3 im2 = im * im

    IF iter THEN im = 2 * re * im + (CSNG(x \ 320) / 100 - 1) ELSE im = 0
    IF iter THEN re = re * re - im2 + (CSNG(x MOD 320) / 120 - 1.9) ELSE re = 0
    iter = iter + 1

    IF ABS(re) + ABS(im) > 2 OR iter > 254 THEN PSET (x MOD 320, x \ 320), iter ELSE GOTO 3
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
