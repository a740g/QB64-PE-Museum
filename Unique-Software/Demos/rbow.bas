' RBOW.BAS COPYRIGHT (c) 1987 by Unique Software
' Ported from TANDY 1000 Advanced BASIC to QB64-PE by a740g

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

_TITLE "The Rainbow Connection"

$RESIZE:SMOOTH

SCREEN 7
LOCATE 1, 1, 1, 0, 7
VIEW PRINT 1 TO 2

RESTORE data_rbow_bmp
DIM background AS LONG: background = _LOADIMAGE(Base64_LoadResourceData, 256, "memory")

DIM L$, L, M1$, M2$, M3$, M, P, P(29), T, V

GOTO 7

2:
READ L$, L, M1$, M2$, M3$, P
IF LEN(M1$) = 0 _ANDALSO LEN(M2$) = 0 _ANDALSO LEN(M3$) = 0 THEN GOTO 12
IF L = 0 THEN M = 14 - M: PALETTE 1, M
PALETTE P(P * 2), P(P * 2 + 1)
T = (T + 1) MOD 7
PALETTE 15, T + 9

4:
WHILE PLAY(0) > 0 _ORELSE PLAY(1) > 0 _ORELSE PLAY(2) > 0
    _LIMIT 60
WEND

PRINT L$; MID$(CHR$(13), 1, L MOD 2);
PLAY M1$, M2$, M3$: GOTO 2

7:
RESTORE data_rbow_pal: FOR P = 0 TO 29: READ P(P): NEXT P: FOR V = 1 TO 6: READ P, L: PALETTE P, L: NEXT V: _PUTIMAGE , background
RESTORE 15: PALETTE 8, 9
LINE (0, 0)-(319, 15), 0, BF
M = 2: V = 1: GOSUB 2

12:
WHILE PLAY(0) > 0 _ORELSE PLAY(1) > 0 _ORELSE PLAY(2) > 0
    _LIMIT 60
WEND

SLEEP 1

SYSTEM

data_rbow_pal:
DATA 00,00,13,11,13,14,03,11,03,14,08,02,08,15,14,14,12,12,05,05,09,09,14,11,12,11,05,11,09,11,6,15,4,12,1,12,13,11,3,11,8,2

15:
DATA "",2,"v10","v11","v12",00,"",2,"o3 p8. e16 >c#8.< e16 >c#8.< e16","o3 p8. p16 a8. p16 a8. p16","o2 a2.",00,"",2,"o3 p8. mlf#16 mna2","o4 p8. p16 d2.","o2 a2.",00,"",2,"o3 p8. e16 >c#8.< e16 >c#8.< e16"
DATA "o3 p8. p16 a8. p16 a8. p16","o2 a2.",00,"",2,"o3 p8. mlf#16 mna2","o4 p8. p16 d2.","o2 a2.",00,"Why are there ",0,"o3 c#4 e4 a4","o2 p4 mla8mn>c#8< mla8>mnc#8","o1 a4 >e4 e4",00,"so man-y ",0,"o3 b8.>c#16 c#2"
DATA "o3 p4 mlc#8mnf#8 mlc#8mne8","o2 f#4 a4 a4",00,"songs a-bout ",0,"o3 d4 e4 a4","o2 p4 mla8mn>d8< mla8mn>d8","o1 b4 >f#4 f#4",00,"rain-bows, and ",0,"o3 a4 b4. <b8","o3 f#4 e4 <b4","o2 e4 b4 g#4",00,"what's on the ",0,"o3 c#4 e4 g#4"
DATA "o2 p4 mla8>mnc#8< mlb8>mne8","o1 a4>e4 g#4",00,"oth-er ",0,"o3 a2 e4","o3 p4 mlc#8mne8 ml<a8>mnc#8","o2 f#2 e4",00,"side?",0,"o3 mlf#2.","o2 p4 mla8>mne8< mla8>mne8","o2 d2.",00,"",1,"o3 mnf#2 p4","o2 p4 mla8>mnd8< mla8mnb8"
DATA "o2 d2 p4",00,"Rain-bows are ",0,"o3 c#4 e4 a4","o2 p4 mla8>mnc#8< mla8>mnc#8","o1 a4 >e4 e4",00,"vis-ions, but ",0,"o3 b8 >mlc#8mnc#4 p8 <c#8","o3 g#8a8 mlc#8mne8 mlc#8mne8","o2 f#4 a4 a4",11,"on-ly il-",0,"o3 d4 e4 a4"
DATA "o2 p4 mlb8>mnd8< mlb8>mnd8","o1 b4 >f#4 f#4",14,"lu-sions. And ",0,"o3 a4 b4. <b8","o3 f#4 e4 <b4","o2 e4 b4 g#4",12,"rain-bows have ",0,"o3 c#4 e4 g#4","o2 p4 mla8>mnc#8< mlb8>mne8","o1 a4>e4 g#4",13,"noth-ing to ",0,"o3 a4 a4 e4"
DATA "o3 p4 mlc#8mne8 ml<a8>mnc#8","o2 f#2 e4",00,"hide.",0,"o3 mlf#2.","o2 p4 mla8>mne8< mla8>mne8","o2 d2.",00,"",1,"o3 mnf#2.","o2 p4 mla8>mne8< mla8>mne8","o1 a2.",00,"So we've been ",0,"o3 f#4 >c#4< f#4","o3 p8 c#8< a8 f#8 a8 f#8"
DATA "o2 d2.",00,"told, and some ",0,"o4 c#4 <f#4 >c#4","o3 p8 c#8< a8 f#8 a8 f#8","o2 d2.",00,"choose to be-",0,"o3 f#4 >c#4< f#4","o3 p8 c#8< a8 f#8 a8 f#8","o2 d2.",00,"lieve it,",1,"o4 c#4 <f#2","o3 p8 c#8< a8 f#8 a8 f#8","o2 d2.",00
DATA "I know they're ",0,"o3 g#4 g#4 g#4","o3 p8 d#8< b8 g#8 b8 g#8","o2 c#2.",00,"wrong, wait and ",0,"o3 b4 g#4 e4","o3 p8 d#8< b8 g#8 b8 g#8","o2 c#2.",00,"see.",0,"o3 mlg#2.","o3 p8 d#8< b8 g#8 b8 g#8","o2 c#2.",00
DATA "",1,"o3 mng#2 p4","o3 p8 d#8< b8 g#8 b8 g#8","o2 c#2.",00,"Some day we'll ",0,"o3 d4 f#4 a4","o2 p4 mla8mn>d8< mla8mn>d8","o1 b4 >f#4 f#4",00,"find it, the ",0,"o3 g#4 a4. e8","o2 p4 mla8mn>d8< mla8mn>d8","o1 e4 >f#4 f#4",00
DATA "Rain-bow Con-",0,"o3 e4 g#4 b4","o2 p4 mlb8>mne8< mlb8>mne8","o2 c#4 g#4 g#4",00,"nect-tion, the ",0,"o3 g#4 a#4. c#8","o3 e4 mlc#8mne8 mlc#8mne8","o2 f#2 p8 <a#8",00,"lov-ers, the ",0,"o3 d8 mlf#8 mnf#4 a4"
DATA "o2 p4 mla8>mnd8< mla8>mnd8","o2 b4 f#4 f#4",00,"dream-ers and ",0,"o4 c#8 mlc#8 mnc#4 <b4","o3 p4 mld8mne8 mld8mne8","o2 e2.",00,"me.",0,"o3 a8. e16 >c#8. <e16 >c#8. <e16","o3 p4 a8. p16 a8. p16","o2 a2.",00,"",2
DATA "o3 p8. mlf#16 mnf#2","o3 p8. p16 mla4>mnd4","o2 a2.",00,"",2,"o3 p8. e16 >c#8. <e16 >c#8. <e16","o3 p4 a8. p16 a8. p16","o2 a2.",00,"",1,"o3 p8. mlf#16 mnf#2","o3 p8. p16 mla4>mnd4","o2 a2.",00,"Who said that ",0,"o3 c#4 e4 a4"
DATA "o2 p4 mla8mn>c#8< mla8>mnc#8","o1 a4 >e4 e4",00,"ev-'ry wish would ",0,"o3 b8.>c#16 c#4. <c#8","o3 p4 mlc#8mnf#8 mlc#8mne8","o2 f#4 a4 a4",04,"be heard and ",0,"o3 d4 e4 a4","o2 p4 mla8mn>d8< mla8mn>d8","o1 b4 >f#4 f#4",00
DATA "an-swered when ",0,"o3 a4 b4. <b8","o3 f#4 e4 <b4","o2 e4 b4 g#4",00,"wished on the ",0,"o3 c#4 e4 g#4","o2 p4 mla8>mnc#8< mlb8>mne8","o1 a4>e4 g#4",00,"morn-ing ",0,"o3 a2 e4","o3 p4 mlc#8mne8 ml<a8>mnc#8","o2 f#2 e4",02,"star?"
DATA 0,"o3 mlf#2.","o2 p4 mla8>mne8< mla8>mne8","o2 d2.",00,"",1,"o3 mnf#2 p4","o2 p4 mla8>mnd8< mla8mnb8","o2 d2 p4",00,"Some-bod-y ",0,"o3 c#4 e4 a4","o2 p4 mla8>mnc#8< mla8>mnc#8","o1 a4 >e4 e4",00,"thought of that, and ",0
DATA "o3 b8 >mlc#8mnc#4 p8 <c#8","o3 g#8a8 mlc#8mne8 mlc#8mne8","o2 f#4 a4 a4",00,"some-one be-",0,"o3 d4 e4 a4","o2 p4 mlb8>mnd8< mlb8>mnd8","o1 b4 >f#4 f#4",00,"lieved it,",1,"o3 a4 b4. <b8","o3 f#4 e4 <b4","o2 e4 b4 g#4",00
DATA "Look what it's ",0,"o3 c#4 e4 g#4","o2 p4 mla8>mnc#8< mlb8>mne8","o1 a4>e4 g#4",00,"done so ",0,"o3 a4 a4 e4","o3 p4 mlc#8mne8 ml<a8>mnc#8","o2 f#2 e4",00,"far.",0,"o3 mlf#2.","o2 p4 mla8>mne8< mla8>mne8","o2 d2.",01
DATA "",1,"o3 mnf#2.","o2 p4 mla8>mne8< mla8>mne8","o1 a2.",00,"What's so a-",0,"o3 f#4 >c#4< f#4","o3 p8 c#8< a8 f#8 a8 f#8","o2 d2.",00,"maz-ing that ",0,"o4 c#4 <f#4 >c#4","o3 p8 c#8< a8 f#8 a8 f#8","o2 d2.",00
DATA "keeps us star-",0,"o3 f#4 >c#4< f#4","o3 p8 c#8< a8 f#8 a8 f#8","o2 d2.",02,"gaz-ing And ",1,"o4 c#4 <f#2","o3 p8 c#8< a8 f#8 a8 f#8","o2 d2.",00,"what do we ",0,"o3 g#4 g#4 g#4","o3 p8 d#8< b8 g#8 b8 g#8","o2 c#2.",00
DATA "think we might ",0,"o3 b4 g#4 e4","o3 p8 d#8< b8 g#8 b8 g#8","o2 c#2.",00,"see?",0,"o3 mlg#2.","o3 p8 d#8< b8 g#8 b8 g#8","o2 c#2.",00,"",1,"o3 mng#2 p4","o3 p8 d#8< b8 g#8 b8 g#8","o2 c#2.",00
DATA "Some day we'll ",0,"o3 d4 f#4 a4","o2 p4 mla8mn>d8< mla8mn>d8","o1 b4 >f#4 f#4",00,"find it, the ",0,"o3 g#4 a4. e8","o2 p4 mla8mn>d8< mla8mn>d8","o1 e4 >f#4 f#4",00,"Rain-bow Con-",0,"o3 e4 g#4 b4"
DATA "o2 p4 mlb8>mne8< mlb8>mne8","o2 c#4 g#4 g#4",00,"nect-tion, the ",0,"o3 g#4 a#4. c#8","o3 e4 mlc#8mne8 mlc#8mne8","o2 f#2 p8 <a#8",00,"lov-ers, the ",0,"o3 d8 mlf#8 mnf#4 a4","o2 p4 mla8>mnd8< mla8>mnd8","o2 b4 f#4 f#4",00
DATA "dream-ers and ",0,"o4 c#8 mlc#8 mnc#4 <b4","o3 p4 mld8mne8 mld8mne8","o2 e2.",00,"me.",1,"o3 a2.","o3 p4 mlc#8mne8 mlc#8mne8","o2 b2.",00,"All of us ",0,"o3 b4. a8 b4","o2 p4 ml b8>mne8< mlb8>mne8","o2 g#2.",00
DATA "un-der its ",0,"o4 c#4. <b8 a4","o3 p4 mlc#8mne8 mlc#8mne8","o2 f#2.",00,"spell, We ",0,"o3 e2 e4","o2 p4 mla8>mnc#8< mla8>mnc#8","o2 e2.",00,"know that it's ",0,"o3 f#4. g#8 a4","o2 p4 mla8>mne8< mla8>mne8","o2 d2.",00
DATA "prob-ab-ly ",0,"o3 e4. f#8 a8","o2 p4 mla8>mnc#8< mla8>mnc#8","o2 c#2.",00,"",2,"v11","v12","v13",00,"ma-",0,"o3 b2.","o3 mlf#8mna8 mld8mnf#8 mlf#8mna8","o1 e2.",00,"",2,"v12","v13","v14",00,"gic.",0,"o4 mlc2."
DATA "o3 mlg8mnb-8 mle-8mng8 mlb-8mnb-8","o1 f2.",05,"",1,"o4 c4 p4 p4","o3 mlg8mna8 mlc8mng8 mlf8mna8","o2 f2.",00,"Have you been ",0,"o3 d4 f4 b-4","o2 p4 mlb-8mn>d8< mlb-8>mnd8","o2 b-4 f4 f4",00,"half a-sleep and ",0
DATA "o4 c8 d8 d4. <d8","o3 a4 mld8mnf8 mld8mnf8","o2 g4 b-4 b-4",00,"have you heard ",0,"o3 e-4 f4 b-4","o2 p4 mlb-8mn>e-8< mlb-8>mne-8","o2 c4 g4 g4",00,"voic-es?",1,"o3 b-4 >c2","o3 g4 f4 c4","o2 f4 >c4 <a4",08,"I've heard them "
DATA 0,"o3 d4 f4 a4","o3 p4 mlb-8>mnd8 mlc8mnf8","o1 b-4 f4 a4",00,"call-ing my ",0,"o3 b-4 b-4 f4","o3 p4 mld8mnf8 ml<b-8>mnd8","o2 g2 f4",00,"name.",0,"o3 mlg2.","o2 p4 mlb-8>mnf8< mlb-8>mnf8","o2 e-2.",09
DATA "",1,"o3 mng2 p4","o2 p4 mlb-8>mnf8< mlb-8>mnc8","o2 f2 f4",00,"Is this the ",0,"o3 d4 f4 b-4","o2 p4 mlb-8mn>d8< mlb-8>mnd8","o2 b-4 f4 f4",00,"sweet sound, that ",0,"o4 c8 mld8 mnd4. <d8","o3 a4 mld8mnf8 mld8mnf8","o2 g4 b-4 b-4",10
DATA "calls the young ",0,"o3 e-4 f4 b-4","o2 p4 mlb-8mn>e-8< mlb-8>mne-8","o2 c4 g4 g4",00,"sail-ors? the ",0,"o3 b-4 >c2","o3 g4 f4 c4","o2 f4 >c4 <a4",00,"voice might be ",0,"o3 d4 f4 a4","o3 p4 mlb-8>mnd8 mlc8mnf8","o1 b-4 f4 a4",00
DATA "one and the ",0,"o3 b-4 b-4 f4","o3 p4 mld8mnf8 ml<b-8>mnd8","o2 g2 f4",00,"same.",0,"o3 mlg2.","o2 p4 mlb-8>mnf8< mlb-8>mnf8","o2 e-2.",07,"",1,"o3 mng2 p4","o2 p4 mlb-8>mnf8< mlb-8>mnf8","o2 e-2.",00
DATA "I've heard it ",0,"o3 g4 >d4 <g4","o3 p8 d8 <b-8 g8 b-8 g8","o2 e-2.",00,"too man-y ",0,"o4 d4 <g4 >d4 ","o3 p8 d8 <b-8 g8 b-8 g8","o2 e-2.",00,"times to ig-",0,"o3 g4 >d4 <g4","o3 p8 d8 <b-8 g8 b-8 g8","o2 e-2.",00
DATA "nore it. It's ",0,"o4 d4 <g4. g8 ","o3 p8 d8 <b-8 g8 b-8 g8","o2 e-2.",00,"some-thing that ",0,"o3 a4 a4 a4","o3 p8 e8 c8< a8 >c8< a8","o2 d2.",00,"I'm s'posed to ",0,"o4 c4 <a4 f4","o3 p8 e8 c8< a8 >c8< a8","o2 d2.",00
DATA "be.",0,"o3 mla2.","o3 p8 e8 c8< a8 >c8< a8","o2 d2.",00,"",1,"o3 mna2.","o3 p8 e8 c8< a8 >c8< a8","o2 d2.",00,"Some-day we'll ",0,"o3 e-4 g4 b-4","o2 p4 mlb-8mn>e-8< mlb-8mn>e-8","o2 c4 g4 g4",00,"find it, The "
DATA 0,"o3 a4 b-4. f4","o2 p4 mlb-8mn>e-8< mlb-8mn>e-8","o2 f4 g4 g4",00,"Rain-bow Con-",0,"o3 f4 a4 >c4","o3 p4 mlc8mnf8 mlc8mnf8","o2 d4 a4 a4",00,"nec-tion, the ",0,"o3 a4 b4. d8","o3 f4 mld8mnf8 mld8mnf8","o2 g2 p8 b8",06
DATA "lov-ers, the ",0,"o3 e-8 mlg8mng4. b-8","o2 p4 mlb-8mn>e-8< mlb-8mn>e-8","o2 c4 g4 g4",00,"dream-ers, and ",0,"o4 d8 mld8mnd4 c8","o3 p4 mle-8mnf8 mle-8mnf8","o2 f2.",00,"me.",0,"o3 b-2.","o3 p4 mld8mnf8 mld8mnf8","o2b-2.",00
DATA "",2,"o4 c4. <b-8> c4","o3 p4 mlc8mnf8 mlc8mnf8","o2 a2.",00,"",2,"o4 d4. c8 <b-4","o3 p4 mld8mnf8 mld8mnf8","o2 g2.",00,"",2,"o3 f2 f4","o2 p4 mlb-8mn>d8< mlb-8mn>d8","o2 f2.",00,"",2,"o3 g4. a8 b-4","o2 p4 mlb-8mn>f8< mlb-8mn>e-8"
DATA "o2 e2.",00,"",2,"o3 f4 b-4 a4","o2 p4 mlb-8mn>c8< mla8mn>e-8","o2 f2.",00,"",2,"o4 p4 mld8mnf8 mld8mnb-8","o3 mlb-2.","o1 mlb-2.",00,"",2,"o5 mld2<mnb-1","o3 mlb-1.","o1 mlb-1.",00,"",2,"v10","v11","v12",00
DATA "",0,"","","",0

data_rbow_bmp:
DATA 32094,2984,-1
DATA "eNokyTUBAkAUBuAPWdActEB2RtZrQqFXA011/uTX2z09gYQTLgv+WFgDeB/nb80v5dG2YYMQQwilD0YbES2u1NZBjqMwEAXQbPp+vfnGHMB1Awvl"
DATA "AEgsZ4Na3Hb85VIJ5DgmA6QzP0qFDot+qpiy/784CYAIP0VSyZf6Fgl2D78TgYMLLjmwKvlrBFnd+y0fgsPGRwrfovqGr7vat6Jpv+DMJ01fjJcJ"
DATA "CSl9IsLLnb7IXOor1p+90F5/XYf0ipf6uAIhQbQ4BL6zz+7VfIq8KhRQ6UQLbE1y3sDuPfPhQh8BVXo9XXyPzyE88UndNwwU9rjYB6n6XMO30LeY"
DATA "75NC37IsH+gbwBC29vWfYuTvOpuPUe2MGE88s+g2IYGF13qSCQgt352mwrf8YMBZEVDkVjubbWgtH+6KWjTsJvJX8USf2/pAGH2u4TNX6TuvgcS4"
DATA "sPU59UljJPdbnv7YZHaIJ/rgpPRxUaKaIdZ9YE7zSdE/fvCC9KqPQDz0zfnZOXHTJYUX4tTqEBq+Lm8Zhc+PyOlO9IE9lFR1tGQsU5/M5BS+aRph"
DATA "vu40X3EKbCUNZtJSWQWbzH1EynCaT17yEVTF2WPSDRHH4vh8rH2yy3dfD73+8WjsuQHSiHfFVv2GhwlF+MOj/0m+gcb3xMYK+hXPT766sQyRZ9cD"
DATA "ZwOI5PrCUW9Wn/JGjCNg8aZL+RkOtU+wmsntcNO4EwUjkDd5ayDSgFk2YfuO+8DsHSs2+ChNPFj//ASjWwdx3CfYl8WiYcdg68/OL+tk3+12yGdD"
DATA "5uXzlGf/9JF56JtB3e0r1QPrz+3yldttBiqq5vtOvlS+/sknpAXXfG5rPkwU1X3k0Xd72ecgyEcXNNvX3RfzbTl+mp76Mu8rVaSksst5g/mwJx3/"
DATA "0wMfM0KDra9PSfUPfSSCrcR3i6f9ZtPEveAj8JHPQ6NSu+u95x/0MQDXoC1DQktYfpjUx8dW/jJvBy9uG1EYwNcH/QEquNCrjGnv2kCPOkx6rp19"
DATA "i3ItxLnnsL6nDEyPXdr/t/qY8ce4z7OS8OSRDyQEYdFvvzcz3iTsTR++Ww7i0Ip8jJ5rH1HLfHj/dBGTvy3xmulOXzHpQEhLZivtNk3231vLT5b5"
DATA "GsGd9fGBPH4PMbNLIH2hHLaHFj4VAc/LQl96Mwg0oQG2lnYRM18gbhhvS5+uT8Y530OMkDddaTkmkdD+kEWa282xwNS4tAAWfB9+henK91fuY30p"
DATA "jaTO+I5k1Gnyvf4gMfh6FphOhfZ2gSLwvVPz9blvUC/lWS0Pc2kkbRyMMrHSI+4xccDbgm+X+3y8f+SfivLxrJ6hcd5ppsmXHrki6GsPV7bXruui"
DATA "T7KMyfePc05i3MM9abi14y5KJyhU9G1FWuSnjNdN2cuUI33ZfMVNeV/Jx2FGIKunr4UPyWz0oUXteyLwyQ13+xqoCFTbabOVlsC/2/Yt34gLqgRE"
DATA "k3f7wMp9TPK1ckjASUcfYOErlMoHFhIf7iow/+hJUpW2hY/5IfnwyXakLyXI6Kv7ONJ0fCofon0i2icBPHmirxKQqubWgBf6mMyH1CiQT7O+Nt8f"
DATA "s777C1SjruV7X9+H/D4/4FmfZL4pVX3NGt9xxvdkUOD9vroF6pAWs85nANwoH7LGN9j5OGBBFvrcd+oTxwItF+AKn22BaoP4pb7B0Pe61ofYLsAF"
DATA "PnftG6wX4Fu+R+1z37vPWQ+Yf6XU6eEJAT6bCa/zfYCPC5ExH3DZ9+j4g6BJgZsFPp/5eqEvi+UCVBtk9HJJ37/jOWMEfNvnr33gqfqQwXABcoPQ"
DATA "R2/PY1oDjQasfYHIZ1H1MZYDlkvGcOXzpfoQwwHvIw03XJcSQ7E+ZLAbMHwSok3oG68+5HSMF6AH6eJDkZ6HoLMD6gHTN5lgC/CFIIG8/tFZTnhT"
DATA "9PkRrujjdPspzgyofa88YICLPjiF9akCGasB7yGBLCBeQvT5yDMDlv+hUpDx4hvhiycOcIgrxGgHQ4SpMh5a8soFDhYDDjo+kGdeoBqwBiLklQtE"
DATA "jI7ojDUGZkGBg8GAkV8uvAy4qMDBYMAEiuC0icA/abMGbnSBESjHDgGQPMaVYlEgEjx4iHC4qkAT4Oa2T/ifhmPY9cuBg82A96gvRr52vY4rxmLA"
DATA "eyEP1DUFusGgwMj7+Xyx9vZA7WOBIIH3pQOwE1WgLVD5IJryBRcL1HFGQMo44Fjf5Qbfzh5YHvAEkiyoc+WE3TctUEa5ipeuMGEb4GaJb7cSaOo7"
DATA "Fgp8tAH+36cCHwu0B26W+Lp+5YSdsc8eyCzz7ayBhQK3BV/Xr12C1Q7qGR9wLNAcqArEbyAqH9IbAwu+588EcryrgUz9Af/4+Xw68ZfVWB8nvBI4"
DATA "VC4QvhcUKOC9fEJ9qkBr4JXvdD5H3+l0fvlE3GogU7NA+KbA93yamvwDrNKEGfd2hqoFwifwoUj6WOBqIPJbzRUIHnyAwlcDWNHHQxo+mPSE1wNr"
DATA "DhiBrwOvErD2j6n/FUsHNBBDIQyGi4Q+CUzC5l/bGbisGQH6K/hSIJn/qwHRPSB58n93BQj4B7wnfWAD8BG+5gFPHxCbA+atgf2+qF9YA9EQCxf+"
DATA "05gvBoEYGpBZAD7KtzBg3m/N+MAxIMYGZJaAz4QPLAPFhBgc8BSBT78PLAG1EJMDMqvAu9sHNgPvZl98BV5S+ChfA/AIoKjRB04AAd+F81r1gQNA"
DATA "NBbfgbnpA/uBsAOvBZ+68Mm3tM8MvNZ8YAmYa74oAq8lH1gEpvaZgdeOL8rAXPGBdeAlfAagEGKg0MCXtM8MzGvaB76Un4RwA4UQRqBo1Bck9RPq"
DATA "EeEGijAWX/P7BPDYfdEBhA9It08Cj9kHqtZ8UVuQR/rMCwoh/EBafQjqnD6QumP0gawL4QYKIXaBIpcPQdZGhBWoR4QbKIjYi586Wz4BFEgsFvwe"
DATA "3EARdvP7VP0+qxCGwu8T9ftcQLjy+0TR7zMIYa3ZZxDCnt+nCr9P5ffJ/D6d2VdQ/gDyjts/"

' Converts a base64 string to a normal string or binary data
FUNCTION Base64_Decode$ (s AS STRING)
    DIM srcSize AS _UNSIGNED LONG: srcSize = LEN(s)
    DIM buffer AS STRING: buffer = SPACE$((srcSize \ 4) * 3) ' preallocate complete buffer
    DIM j AS _UNSIGNED LONG: j = 1
    DIM AS _UNSIGNED _BYTE index, char1, char2, char3, char4

    DIM i AS _UNSIGNED LONG: FOR i = 1 TO srcSize STEP 4
        index = ASC(s, i): GOSUB find_index: char1 = index
        index = ASC(s, i + 1): GOSUB find_index: char2 = index
        index = ASC(s, i + 2): GOSUB find_index: char3 = index
        index = ASC(s, i + 3): GOSUB find_index: char4 = index

        ASC(buffer, j) = _SHL(char1, 2) OR _SHR(char2, 4)
        j = j + 1
        ASC(buffer, j) = _SHL(char2 AND 15, 4) OR _SHR(char3, 2)
        j = j + 1
        ASC(buffer, j) = _SHL(char3 AND 3, 6) OR char4
        j = j + 1
    NEXT i

    ' Remove padding
    IF RIGHT$(s, 2) = "==" THEN
        buffer = LEFT$(buffer, LEN(buffer) - 2)
    ELSEIF RIGHT$(s, 1) = "=" THEN
        buffer = LEFT$(buffer, LEN(buffer) - 1)
    END IF

    Base64_Decode = buffer
    EXIT FUNCTION

    find_index:
    IF index >= 65 AND index <= 90 THEN
        index = index - 65
    ELSEIF index >= 97 AND index <= 122 THEN
        index = index - 97 + 26
    ELSEIF index >= 48 AND index <= 57 THEN
        index = index - 48 + 52
    ELSEIF index = 43 THEN
        index = 62
    ELSEIF index = 47 THEN
        index = 63
    END IF
    RETURN
END FUNCTION

' Loads a binary file encoded with Bin2Data
' Usage:
'   1. Encode the binary file with Bin2Data
'   2. Include the file or it's contents
'   3. Load the file like so:
'       Restore label_generated_by_bin2data
'       Dim buffer As String
'       buffer = LoadResource   ' buffer will now hold the contents of the file
FUNCTION Base64_LoadResourceData$
    DIM ogSize AS _UNSIGNED LONG, resize AS _UNSIGNED LONG, isComp AS _BYTE
    READ ogSize, resize, isComp ' read the header

    DIM buffer AS STRING: buffer = SPACE$(resize) ' preallocate complete buffer

    ' Read the whole resource data
    DIM i AS _UNSIGNED LONG: DO WHILE i < resize
        DIM chunk AS STRING: READ chunk
        MID$(buffer, i + 1) = chunk
        i = i + LEN(chunk)
    LOOP

    ' Decode the data
    buffer = Base64_Decode(buffer)

    ' Expand the data if needed
    IF isComp THEN buffer = _INFLATE$(buffer, ogSize)

    Base64_LoadResourceData = buffer
END FUNCTION
