'-----------------------------------------------------------------------------------------------------------------------
' QB64-PE v4.0.0 multi-voice PLAY Demo by a740g
'-----------------------------------------------------------------------------------------------------------------------

$IF VERSION < 4.0.0 THEN
    $ERROR This requires the latest version of QB64-PE from https://github.com/QB64-Phoenix-Edition/QB64pe/releases/latest
$END IF

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

CONST APP_NAME = "Multi-voice PLAY Demo"
CONST LOOPS = 3

_TITLE APP_NAME

DIM AS STRING CH0Verse_1, CH0Verse_2, CH1Verse_1, CH1Verse_2, CH2Verse_1, CH2Verse_2, CH2Verse_3, CH3Verse_1
DIM AS STRING Channel_0, Channel_1, Channel_2, Channel_3, Caption
DIM c AS LONG

DO
    DO
        CLS
        PRINT
        PRINT "Enter number for a tune to play."
        PRINT
        PRINT "1. Demo 1 by J. Baker"
        PRINT "2. Demo 2 by Wilbert Brants"
        PRINT "3. Demo 3 by Wilbert Brants"
        PRINT "4. Demo 4 by J. Baker"
        PRINT "5. Demo 5 by Wilbert Brants"
        PRINT
        INPUT "Your choice (0 exits)"; c
    LOOP WHILE c < 0 OR c > 7

    SELECT CASE c
        CASE 1
            Caption = "Demo 1 by J. Baker"

            144
            CH0Verse_1 = "t144 l4 q0 w1 o0 ^75_100 v32 w1 ^75_100 o0 dd2 w8 ^100_80 o4 c"
            CH0Verse_2 = "w4 ^75_100 o0 d2 w8 ^100_80 o4 cd"

            CH1Verse_1 = "t144 q0 w1 o2 /1^100_99 v31 l1 gba /1\20^25_79 l4 gab2"
            CH1Verse_2 = "v40 /9^100\1 l1 gba \2 l4 gab2"

            CH2Verse_1 = "t144 l4 w2 o3 q20 v33 r1r1"
            CH2Verse_2 = "cd>d<e"
            CH2Verse_3 = "cd>d2<"

            CH3Verse_1 = "t144 q0 w9 y15 o3 _100 v29 l8 d"

            Channel_0 = RepeatVerse(CH0Verse_1 + CH0Verse_1 + CH0Verse_1 + CH0Verse_1 + CH0Verse_1 + CH0Verse_1 + CH0Verse_1 + CH0Verse_1 + CH0Verse_2 + CH0Verse_2 + CH0Verse_2 + CH0Verse_2, LOOPS)
            Channel_1 = RepeatVerse(CH1Verse_1 + CH1Verse_1 + CH1Verse_2, LOOPS)
            Channel_2 = RepeatVerse(CH2Verse_1 + CH2Verse_1 + CH2Verse_1 + CH2Verse_1 + CH2Verse_2 + CH2Verse_2 + CH2Verse_2 + CH2Verse_3, LOOPS)
            Channel_3 = RepeatVerse(CH3Verse_1, 96 * LOOPS)

        CASE 2
            Caption = "Demo 2 by Wilbert Brants"

            CH0Verse_1 = "t103 w2 o0 q8 v38 L8 G4B-B-G4B-B-  G4>E-E-<G4>E-E-<  A>CF4<A>CF4<  F4AAGB->D4<"
            CH1Verse_1 = "t103 w1 o1 q2 v33 L8 GB->D4<GB->D4<  GB->E-<B-GB->E-<B-  A>CF4<A>CF4<  FA>C<AGB->D4<"
            CH2Verse_1 = "t103 w1 o3 q1 v35 L4 GG2G8F8 E-E-2E-8D8 CCCD E-2D2"
            CH2Verse_2 = "B-B-2B-8A8 GG2G8F8 CCCD E-2D2"
            CH2Verse_3 = "B-B-2B-8A8 GG2G8F8 ACFA G2D2"

            Channel_0 = CH0Verse_1 + CH0Verse_1 + CH0Verse_1 + CH0Verse_1
            Channel_1 = CH1Verse_1 + CH1Verse_1 + CH1Verse_1 + CH1Verse_1
            Channel_2 = CH2Verse_1 + CH2Verse_2 + CH2Verse_1 + CH2Verse_3
            Channel_3 = _STR_EMPTY

        CASE 3
            Caption = "Demo 3 by Wilbert Brants"

            CH0Verse_1 = "t144 w2 o0 q16 v22 l8 v+cv-ceeg4 v+ f v- faa>cc< v+ c v- ceeg4 v+ f v- faa>cc< ggbb>d4< q8 g4c2"
            CH1Verse_1 = "t144 w1 o1 q2 v20 l4 gec f2a8c8 gec f2a8c8 gbd ec2"
            CH2Verse_1 = "t144 w3 o3 q2 v22 l8 cegceg l4 caf l8 cegceg l4 caf l8 gbdgbd l4 cgg"

            Channel_0 = RepeatVerse(CH0Verse_1, LOOPS)
            Channel_1 = RepeatVerse(CH1Verse_1, LOOPS)
            Channel_2 = RepeatVerse(CH2Verse_1, LOOPS)
            Channel_3 = _STR_EMPTY

        CASE 4
            Caption = "Demo 4 by J. Baker"

            Channel_0 = "t120 w1 o0 q2 v20 l8 <dced> dcge4 l4 q1 <d1> r8 l8 q2 dg l4 q1 <d1> l8 q2 dge q1 <d1> q2 dcdrr v+ <<dd>> v- r"
            Channel_1 = "t120 w1 o1 q1 v21 l8 >dcde< dcde#4 l4 >d1< l8 de l4 >f1 l8 ddfe1< dedfe dd r4"
            Channel_2 = _STR_EMPTY
            Channel_3 = _STR_EMPTY

        CASE 5
            Caption = "Demo 5 by Wilbert Brants"

            CH0Verse_1 = "T103 q16 O0 V22 W2 L4 V+CV-E8E8 <FA> <V+GV-B8B8> CE"
            CH1Verse_1 = "T103 q8 O2 V22 W1 L8 CEG>C< <FA>CF <GB>DG CEG>C<"
            CH2Verse_1 = "T103 q1 O3 v60 W4 L4 CEC<G> CEC2 CEC<G> CE16R16E16R16C2 CEC<G> CEC2 CEC<G> C<G16>R16E16R16C2"

            Channel_0 = RepeatVerse(CH0Verse_1, 4 * LOOPS)
            Channel_1 = RepeatVerse(CH1Verse_1, 4 * LOOPS)
            Channel_2 = RepeatVerse(CH2Verse_1, LOOPS)
            Channel_3 = _STR_EMPTY

        CASE ELSE
            EXIT DO ' Exit program
    END SELECT

    PlayMML Channel_0, Channel_1, Channel_2, Channel_3, Caption
LOOP

SYSTEM

SUB PlayMML (chan0 AS STRING, chan1 AS STRING, chan2 AS STRING, chan3 AS STRING, caption AS STRING)
    PLAY chan0, chan1, chan2, chan3

    PRINT
    PRINT "Playing "; caption; "..."

    DIM curLine AS LONG: curLine = CSRLIN

    DO
        _LIMIT 15

        LOCATE curLine, 1
    LOOP WHILE DisplayVoiceStats

    SLEEP 1
    _KEYCLEAR
END SUB

FUNCTION RepeatVerse$ (verse AS STRING, count AS _UNSIGNED LONG)
    DIM buffer AS STRING

    DIM i AS _UNSIGNED LONG

    WHILE i < count
        buffer = buffer + verse
        i = i + 1
    WEND

    RepeatVerse = buffer
END FUNCTION

FUNCTION DisplayVoiceStats%%
    STATIC voiceTotalTime(0 TO 3) AS DOUBLE

    DIM voiceElapsedTime(0 TO 3) AS DOUBLE
    DIM i AS LONG

    FOR i = 0 TO 3
        voiceElapsedTime(i) = PLAY(i)

        IF voiceElapsedTime(i) > voiceTotalTime(i) THEN
            voiceTotalTime(i) = voiceElapsedTime(i)
        END IF

        PRINT USING "Voice #: ### of ### seconds left"; i; voiceElapsedTime(i); voiceTotalTime(i)
    NEXT i

    DIM playing AS _BYTE: playing = voiceElapsedTime(0) > 0 _ORELSE voiceElapsedTime(1) > 0 _ORELSE voiceElapsedTime(2) > 0 _ORELSE voiceElapsedTime(3) > 0

    IF NOT playing THEN
        FOR i = 0 TO 3
            voiceTotalTime(i) = 0
        NEXT i
    END IF

    DisplayVoiceStats = playing
END FUNCTION
