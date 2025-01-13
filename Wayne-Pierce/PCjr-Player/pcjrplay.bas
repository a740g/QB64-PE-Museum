10 DIM X$(100), A$(100), B$(100), C$(100)
20 J% = 0: MEASURE% = 1: I% = 0: PLAYLINES% = 0
30 GOSUB 390
40 COLOR 13: SOUND RESUME: PLAY "V25MB", "V25MB", "V25MB"
50
FOR J% = MEASURE% TO I%
    60 PRINT X$(J%)
    70 F$ = INKEY$: IF F$ <> "" THEN 170
    80 IF PLAY(0) > 0 OR PLAY(1) > 0 OR PLAY(2) > 0 THEN _LIMIT 60: GOTO 80
    90 PLAY A$(J%), B$(J%), C$(J%)
NEXT
100 GOTO 170
110 COLOR 13: SOUND RESUME: PLAY "V25MB", "V25MB", "V25MB"
120
FOR J% = MEASURE% TO I%
    130 PRINT X$(J%)
    140 F$ = INKEY$: IF F$ <> "" THEN 170
    150 IF PLAY(0) > 0 OR PLAY(1) > 0 OR PLAY(2) > 0 THEN _LIMIT 60: GOTO 150
    160 PRINT A$(J%); " /// "; B$(J%); " /// "; C$(J%): PLAY A$(J%), B$(J%), C$(J%)
NEXT
170 PRINT
180 COLOR 6: PRINT "Press:"
190 COLOR 2: PRINT "      SPACEBAR";: COLOR 6: PRINT " to";: COLOR 2: PRINT " PLAY AGAIN."
200 COLOR 2: PRINT "      B";: COLOR 6: PRINT " to drop to";: COLOR 2: PRINT " BASIC."
210 COLOR 2: PRINT "      D";: COLOR 6: PRINT " to drop to";: COLOR 2: PRINT " DOS."
220 COLOR 2: PRINT "      S";: COLOR 6: PRINT " to";: COLOR 2: PRINT " SELECT";: COLOR 6: PRINT " another song to play."
230 COLOR 2: PRINT "      M";: COLOR 6: PRINT " to change the";: COLOR 2: PRINT " MEASURE";: COLOR 6: PRINT " to start on."
240 COLOR 2: PRINT "      P";: COLOR 6: PRINT " to show the music";: COLOR 2: PRINT " PLAY LINES";: COLOR 6: PRINT " for debugging your music program."
250 PRINT
260 F$ = INKEY$
270 IF F$ = " " THEN 360
280 IF F$ = "B" OR F$ = "b" THEN END
290 IF F$ = "M" OR F$ = "m" THEN 340
300 IF F$ = "P" OR F$ = "p" THEN PLAYLINES% = NOT PLAYLINES%: GOTO 360
310 IF F$ = "S" OR F$ = "s" THEN 30
320 IF F$ = "D" OR F$ = "d" THEN SYSTEM
330 GOTO 260
340 PRINT "What measure do you want to start at (1 to "; I%; ")";
350 INPUT MEASURE%
360 PRINT
370 IF PLAYLINES% THEN 110
380 GOTO 40
390 CLS: WIDTH 80: COLOR 9: PRINT "          PCjr PLAYER"
400 PRINT "    Public Domain Version 1.1    "
410 PRINT "         by Wayne Pierce         "
420 PRINT
430 PRINT "These are the defined music files:"
440 PRINT
450 COLOR 2: FILES "*.mus"
460 COLOR 6: INPUT "What is the file name to play (leave off the .mus)"; F$
470 F$ = F$ + ".mus"
480 COLOR 1: PRINT: PRINT "Press any key to get the MAIN MENU."
490 OPEN F$ FOR INPUT AS #1
500 COLOR 12: PRINT
510 INPUT #1, X$(1): PRINT X$(1) 'Read the title of the song.
520 INPUT #1, X$(1): PRINT X$(1) 'Read the author of the song.
530 PRINT
540 COLOR 1: PRINT "Loading the music from:  ";: COLOR 17: PRINT F$;
550 I% = 0
560 WHILE NOT EOF(1)
    570 I% = I% + 1
    580 INPUT #1, X$(I%) 'Read the verse for the measure
    590 INPUT #1, A$(I%) 'Read the music data into A$,B$,C$
    600 INPUT #1, B$(I%)
    610 INPUT #1, C$(I%)
620 WEND
630 FOR J% = 1 TO 45: PRINT CHR$(29);: NEXT J%: PRINT "                                             "
640 CLOSE #1
650 RETURN
