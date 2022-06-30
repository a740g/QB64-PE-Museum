'
'MADMIX GAME VER 1.2 MODIFIED 11/27/00
'
'BY ENRIQUE HUERTA MEZQUITA
'
'FEEL FREE TO CONTACT ME AT ENRIQUEMAIL@MIXMAIL.COM
'
'THIS PROGRAM IS FREE AND YOU ARE WELCOME TO USE ITS CODE IN YOUR
'OWN AS LONG AS YOU CREDIT ENRIQUE HUERTA MEZQUITA AS THE CONTRIBUTER.
'
'FOR MORE FUN VISIT MY OWN PAGE HTTP://WWW11.BRINKSTER.COM/FREESOURCE
'
'THE DEFAULT KEYS CANNOT BE CHANGED AND THESE ARE:
'
'       PLAYER CONTROL          OTHER
'       LEFT:  4                F8:    EXIT TO MENU
'       RIGHT: 6                ESC:   CANCEL
'       UP:    8                ENTER: ACCEPT
'       DOWN:  2
'
$Resize:Smooth

On Error GoTo errortrapping

'defines map and tile dimensions
Const memph = 20 'maximum number of phantoms
Dim Shared map(34, 30) As Integer, tiles(50, 65), door(50, 12)
Dim Shared boxes(8, 9)
Dim Shared font(8, 53), chrcodes(256) As Integer
Dim Shared mouth(8, 3, 3, 3) As Integer, sheet(8, 3, 3, 3) As Integer, ass(8, 3, 3) As Integer
Dim Shared corners(3, 3, 4) As Integer, dinner(3, 3, 2) As Integer
Dim Shared pacdeath(25) As Integer, phantomdeath(14) As Integer
Dim Shared Abefore As Integer, Bbefore As Integer
Dim Shared tryadda As Integer, tryaddb As Integer
Dim Shared A As Integer, B As Integer
Dim Shared adda As Integer, addb As Integer
Dim Shared doadda As Integer, doaddb As Integer, dopath As Integer
Dim Shared ghosta(memph) As Integer, ghostb(memph) As Integer
Dim Shared addgha(memph) As Integer, addghb(memph) As Integer
Dim Shared pathsa(4) As Integer, pathsb(4) As Integer
Dim Shared points As Integer, realpoints As Integer, foodleft As Integer, lives As Integer
Dim Shared name$, hallnames$(6), hallpoints(6) As Integer
Dim Shared accuracy As Integer
Dim Shared phantoms As Integer, bugs As Integer
Dim Shared flip As Integer, factor As Integer
Dim Shared character As Integer, timeleft As Integer
Dim Shared rewind(memph) As Integer, kickrewind(memph) As Integer
Dim Shared xx(170) As Integer, yy(170) As Integer, angle(170) As Integer
Dim Shared font$(50), C(94) As Integer
Dim Shared chosen As Integer
Dim Shared i As Integer
Dim Shared phantom(54, 16), bug(48, 4), pac(54, 24)
Dim Shared dooropening As Integer, xopening As Integer, yopening As Integer
Dim Shared stagename$, stagetext$
Dim Shared addlife As Integer
Dim Shared xdatabase As Integer, ydatabase As Integer
Dim Shared aghost As Integer, bghost As Integer
Dim Shared xprison As Integer, yprison As Integer
Dim Shared startdemo As Integer
Dim Shared badpactime As Integer, dist
Dim Shared ega(16) As Integer
Dim opendoor As Integer, nextone(2) As Integer, openorclose As Integer
Dim levnum As Integer, maxlev As Integer
Dim compressed(300) As Integer
Dim side As Integer, kind As Integer
Dim death(60, 21)
Dim kickghosta(memph) As Integer, kickghostb(memph) As Integer
Dim kickass(memph) As Integer
Dim ddd As Integer, TIMERbefore As Single
Dim file$

'defines type for LoadPcx
Type TH
    MAN As String * 1
    VER As String * 1
    ENC As String * 1
    BIT As String * 1
    XLS As Integer
    YLS As Integer
    XMS As Integer
    YMS As Integer
    HRE As Integer
    VRE As Integer
    col As String * 48
    RES As String * 1
    PLA As String * 1
    BYT As Integer
    PAL As Integer
    FIL As String * 58
End Type

Randomize Timer 'ensure true random

For kind = 0 To 15 'this is for LoadPcx sub. makes my own ega palette
    Read ega(kind)
Next kind

Data 11,0,0,14,10,12,8,7,3,0,0,0,0,0,0,0

For kind = 0 To 24 'pac death animation
    Read pacdeath(kind)
Next kind
          
Data 0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,4,5,6,7,8,10,9,11,13,12

For kind = 0 To 13 'phantom and bug death animation
    Read phantomdeath(kind)
Next kind

Data 12,20,19,18,17,16,15,14,12,13,11,9,10,8

nextone(0) = 10: nextone(1) = 9 'phantom prison door animation

For kind = 0 To 2 'pac animation
    For ydatabase = 0 To 2
        For xdatabase = 0 To 2
            For side = 0 To 7
                Read mouth(side, xdatabase, ydatabase, kind)
            Next side
        Next xdatabase
    Next ydatabase
Next kind
'order will be: up left right down (good/medium/bad)
Data 00,00,00,00,00,00,00,00,09,10,11,10,09,10,11,10,00,00,00,00,00,00,00,00,00,01,02,01,00,01,02,01,00,00,00,00,00,00,00,00,06,07,08,07,06,07,08,07,00,00,00,00,00,00,00,00,03,04,05,04,03,04,05,04,00,00,00,00,00,00,00,00
Data 00,00,00,00,00,00,00,00,21,10,23,10,21,10,23,10,00,00,00,00,00,00,00,00,12,01,14,01,12,01,14,01,00,00,00,00,00,00,00,00,18,07,20,07,18,07,20,07,00,00,00,00,00,00,00,00,15,04,17,04,15,04,17,04,00,00,00,00,00,00,00,00
Data 00,00,00,00,00,00,00,00,21,22,23,22,21,22,23,22,00,00,00,00,00,00,00,00,12,13,14,13,12,13,14,13,00,00,00,00,00,00,00,00,18,19,20,19,18,19,20,19,00,00,00,00,00,00,00,00,15,16,17,16,15,16,17,16,00,00,00,00,00,00,00,00

For kind = 0 To 2 'phantom animation
    For ydatabase = 0 To 2
        For xdatabase = 0 To 2
            For side = 0 To 7
                Read sheet(side, xdatabase, ydatabase, kind)
            Next side
        Next xdatabase
    Next ydatabase
Next kind
                                                                                                                         
Data 00,00,00,00,00,00,00,00,06,06,07,07,06,06,07,07,00,00,00,00,00,00,00,00,00,00,01,01,00,00,01,01,00,00,00,00,00,00,00,00,04,04,05,05,04,04,05,05,00,00,00,00,00,00,00,00,02,02,03,03,02,02,03,03,00,00,00,00,00,00,00,00
Data 00,00,00,00,00,00,00,00,14,06,15,07,14,06,15,07,00,00,00,00,00,00,00,00,08,00,09,01,08,00,09,01,00,00,00,00,00,00,00,00,12,04,13,05,12,04,13,05,00,00,00,00,00,00,00,00,10,02,11,03,10,02,11,03,00,00,00,00,00,00,00,00
Data 00,00,00,00,00,00,00,00,14,14,15,15,14,14,15,15,00,00,00,00,00,00,00,00,08,08,09,09,08,08,09,09,00,00,00,00,00,00,00,00,12,12,13,13,12,12,13,13,00,00,00,00,00,00,00,00,10,10,11,11,10,10,11,11,00,00,00,00,00,00,00,00

For ydatabase = 0 To 2 'bug animation
    For xdatabase = 0 To 2
        For side = 0 To 7
            Read ass(side, xdatabase, ydatabase)
        Next side
    Next xdatabase
Next ydatabase

Data 00,00,00,00,00,00,00,00,03,03,03,03,03,03,03,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,02,02,02,02,02,02,02,00,00,00,00,00,00,00,00,01,01,01,01,01,01,01,01,00,00,00,00,00,00,00,00

'this is for LoadMap and RandomMove subs. defines pac direction
pathsa(0) = -1: pathsa(1) = 0: pathsa(2) = 0: pathsa(3) = 1
pathsb(0) = 0: pathsb(1) = -1: pathsb(2) = 1: pathsb(3) = 0

For kind = 0 To 255 'these codes identify which letter must be printed
    Read chrcodes(kind)
Next kind
                                                                                                   
'<SPACE>'()¥,-./0123456789:;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\
Data 50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,49,50,50,36,50,50,50,39,42,43,51,50,44,45,37,40,00,01,02,03,04,05,06,07,08,09,38,46,50,50,50,41,47,10,11,12,13,14,15,16
Data 17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,50,48,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
Data 50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,52,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
Data 50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
                                                                                           
For ydatabase = 0 To 2 'this is for Wall and Find subs
    For xdatabase = 0 To 2
        For side = 0 To 3
            Read corners(xdatabase, ydatabase, side)
        Next side
    Next xdatabase
Next ydatabase

Data 0,0,0,0,24,24,38,24,0,0,0,0,24,24,24,38,0,0,0,0,38,24,38,38,0,0,0,0,24,38,38,38,0,0,0,0

For ydatabase = 0 To 2 'this is for HaveLunch sub
    For xdatabase = 0 To 2
        For side = 0 To 1
            Read dinner(xdatabase, ydatabase, side)
        Next side
    Next xdatabase
Next ydatabase

Data 0,0,24,30,0,0,30,24,0,0,32,24,0,0,24,32,0,0

For readfont = 0 To 49 'this is the database for the draw function in ViewWavyText sub
    Read font$(readfont)
Next readfont

Data "bl6bd4c10u8e4r4f4d8g4l4h4be3bu1u3e1r3g4bd4br2e4d3g1l3"
Data "bl6bd8c10u4r4u8l4e4r4d12r4d4l12"
Data "bl6bu4c10u2e3r6f3d3g6r6d4l12u4e8l4d2l4"
Data "bl6bd4c10u4r4d2f1r2e1u2h1l1u2r1e1u2h1l2g1d2l4u4e2r8f2d5g1f1d5g2l8h2"
Data "bl6bd4c10u6e6r4d8r2d4l2d4l4u4l6be4e2d2l2"
Data "bl6bd4c10d4r10e2u6h2l6u2r8u4l12d8f2r5d2l7"
Data "bl6bd6c10f2r8e2u4h2l6u3e1r2f1r4u3h2l8g2d12bu2br4u1r3f1g1l2h1"
Data "bl6bd8c10r4u4e8u4l12d4r8g8d4"
Data "bl6bd6c10f2r8e2u4h2e2u4h2l8g2d4f2g2d4be2br2u1e1r2f1d1l4bu7u1e1r2f1d1l4"
Data "bl6bd8c10f2r8e2u12h2l8g2d4f2r6d3g1l2h1l4d3bu10br4e1r2f1d1l3h1"
Data "bl2bd4c10d4l4u10e6f6d10l4u4l4bu4r4h2g2bg1"
Data "bl6bd8c10u16r9f3d2g3f3d2g3l9bu6br6l2bu6r2br2"
Data "bl6bd4c10u8e4r4f4d2l4u2l4d8r4u2r4d2g4l4h4br2"
Data "bl6bd8c10u16r8f4d8g4l8be4bu1u6r3f1d4g1l3bd2"
Data "bl6bd8c10u16r12d4l8d2r4d4l4d2r8d4l12be2"
Data "bl6bd8c10u16r12d4l8d2r4d4l4d6L4be2"
Data "bl6bd4c10u8e4r4f4l8d8r4u4r4d4g4l4h4br2"
Data "bl6bd8c10u16r4d6r4u6r4d16l4u6l4d6l4be2"
Data "bl6bd8c10u4r4u8l4u4r12d4l4d8r4d4l12be2"
Data "bl6bd4c10u4r4d4r4u8l8u4r12d12g4l4h4br2"
Data "bl6bd8c10u16r4d8e4r4g6f6l4h4d4l4be2"
Data "bl6bd8c10u16r4d12r8d4l12be2"
Data "bl6bd8c10u16r4f2e2r4d16l4u8g2h2d8l4be2"
Data "bl6bd8c10u16r4f4u4r4d16l4u6h4d10l4be2"
Data "bl6bd4c10u8e4r4f4d8g4l4h4be2br2u4e1r2f1d4g1l2h1bd2"
Data "bl6bd8c10u16r8f4d4g4l4d4l4bu8br4u4r3f1d2g1l3bd2"
Data "bl6bd4c10u8e4r4f4d8g2f2l8h4be2br2u4e1r2f1d4g1l2h1bd2"
Data "bl6bd8c10u16r8f4d4g4f4l4h4d4l4bu8br4u4r3f1d2g1l3bd2"
Data "bl6bd8c10u4r6u2l4h2u6e2r10d4l6d2r4f2d6g2l10be2"
Data "bl6bd8br4c10u12l4u4r12d4l4d12l4be2"
Data "bl6bd6c10u14r4d12r4u12r4d14g2l8h2be2"
Data "bl6bd4c10u12r4d10f2e2u10r4d12g4l4h4br2"
Data "bl6bd8c10u16r4d10e2f2u10r4d16l4h2g2l4be2"
Data "bl6bd8c10u4e4h4u4r2f4e4r2d4g4f4d4l2h4g4l2be2"
Data "bl6bd8br4c10u8h4u4r2f4e4r2d4g4d8l4be2"
Data "bl6bd8c10u4e8l8u4r12d4g8r8d4l12be2"
Data "bl6bd8c10u10r4f4u4r4d10l4u2h4d6l4be2bu10c10l2u4r12d4l10bu2"
Data "bl6bd8br4c10u4r4d4l4be2"
Data "bl6bd8br4c10u4r4d4l4bu8u4r4d4l4"
Data "bl6bd8br4c10bu12u4r4d6g4u2e2u2l2"
Data "bl6bd8c10u4e12d4g12"
Data "bl6bd8bu8c10u4e4r4f4d2g4d2l4u2e4h2l2d4l4br4bd6r4d2l4u2"
Data "bl6bd8br5c10h5u6e5r5g5d6f5l5"
Data "bl6bd8br7c10e5u6h5l5f5d6g5r5"
Data "bl6bd8br4c10u4r4d6g4u2e2u2l2"
Data "bl6bd2c10u4r12d4l12"
Data "bl6bd8br4c10u4r4d6g4u2e2u2l2bu8u4r4d4l4"
Data "bl6bd6c10f2r11e2u2l2d2l9h2u10e2r6f2d4g2u2h2l2g2d2f2r4e4u6h2l10g2d14"
Data "bl6bu8c10d4f12u4h12"
Data ""

For kind = 0 To 169
    Read xx(kind), yy(kind), angle(kind)
Next kind

Data -08,-07,057,-06,-05,054,-04,-04,051,-02,-02,048,000,000,045,002,001,042,004,003,039,006,005,036,008,006,033,010,008,030,012
Data 010,027,014,011,024,016,012,021,018,014,018,020,015,015,022,016,012,024,017
Data 009,026,018,006,028,018,003,030,019,000,032,019,-03,034,019,-06,036,020,-09
Data 038,019,-12,040,019,-15,042,019,-18,044,018,-21,046,018,-24,048,017,-27,050
Data 016,-30,052,015,-33,054,014,-36,056,012,-39,058,011,-42,060,010,-45,062,008
Data -48,064,006,-51,066,005,-54,068,003,-57,070,001,-60,072,-01,-57,074,-02,-54
Data 076,-04,-51,078,-06,-48,080,-07,-45,082,-09,-42,084,-10,-39,086,-12,-36,088
Data -13,-33,090,-15,-30,092,-16,-27,094,-17,-24,096,-18,-21,098,-19,-18,100,-19
Data -15,102,-20,-12,104,-20,-09,106,-20,-06,108,-20,-03,110,-20,000,112,-20,003
Data 114,-20,006,116,-19,009,118,-19,012,120,-18,015,122,-17,018,124,-16,021,126
Data -15,024,128,-13,027,130,-12,030,132,-10,033,134,-09,036,136,-07,039,138,-06,042,140,-04,045,142
Data -02,048,144,000,048,146,001,045,148,003,042,150,005,039,152,006,036,154,008,033
Data 156,010,030,158,011,027,160,012,024,162,014,021,164,015,018,166,016,015,168
Data 017,012,170,018,009,172,018,006,174,019,003,176,019,000,178,019,-03,180,020,-06
Data 182,019,-09,184,019,-12,186,019,-15,188,018,-18,190,018,-21,192,017,-24,194
Data 016,-27,196,015,-30,198,014,-33,200,012,-36,202,011,-39,204,010,-42,206,008,-45
Data 208,006,-48,210,005,-51,212,003,-54,214,001,-57,216,-01,-54,218,-02,-51,220
Data -04,-48,222,-06,-45,224,-07,-42,226,-09,-39,228,-10,-36,230,-12,-33,232,-13,-30
Data 234,-15,-27,236,-16,-24,238,-17,-21,240,-18,-18,242,-19,-15,244,-19,-12,246
Data -20,-09,248,-20,-06,250,-20,-03,252,-20,000,254,-20,003,256,-20,006,258,-20,009
Data 260,-19,012,262,-19,015,264,-18,018,266,-17,021,268,-16,024,270,-15,027,272
Data -13,030,274,-12,033,276,-10,036,278,-09,039,280,-07,042,282,-06,045,284,-04,048
Data 286,-02,051,288,000,051,290,001,048,292,003,045,294,005,042,296,006,039,298
Data 008,036,300,010,033,302,011,030,304,012,027,306,014,024,308,015,021,310,016,018
Data 312,017,015,314,018,012,316,018,009,318,019,006,320,019,003,322,019,000,324
Data 020,-03,326,019,-06,328,019,-09,330,019,-12

Screen 7, , 0, 1 '320x200 16 colors mode initialization
_FullScreen _SquarePixels , _Smooth

LoadPcx "default.pcx" 'graphics loading

Get (68, 92)-(83, 107), tiles(0, 3) 'red face tile getting

Get (86, 124)-(95, 137), tiles(0, 4) 'food tile getting

Get (52, 109)-(65, 121), tiles(0, 5) 'arrow tiles getting
Get (69, 109)-(81, 121), tiles(0, 6)
Get (86, 109)-(99, 121), tiles(0, 7)
Get (103, 109)-(116, 121), tiles(0, 8)

Get (86, 58)-(101, 71), tiles(0, 9) 'phantom prison door tiles getting
Get (69, 75)-(84, 90), tiles(0, 10)

Get (35, 75)-(50, 90), tiles(0, 11) 'first map tiles getting
Get (52, 92)-(67, 107), tiles(0, 12)
Get (1, 109)-(16, 122), tiles(0, 13)
Get (18, 109)-(33, 122), tiles(0, 14)
Get (1, 58)-(16, 71), tiles(0, 15)
Get (18, 58)-(33, 71), tiles(0, 16)
Get (35, 58)-(50, 71), tiles(0, 17)
Get (52, 58)-(67, 73), tiles(0, 18)
Get (1, 75)-(16, 90), tiles(0, 19)
Get (18, 75)-(33, 90), tiles(0, 20)
Get (52, 75)-(67, 90), tiles(0, 21)
Get (1, 92)-(16, 107), tiles(0, 22)
Get (18, 92)-(33, 107), tiles(0, 23)
Get (35, 92)-(50, 105), tiles(0, 24)
Get (35, 109)-(48, 122), tiles(0, 25)

Get (230, 18)-(245, 33), tiles(0, 26) 'second map tiles getting
Get (247, 35)-(262, 50), tiles(0, 27)
Get (196, 52)-(211, 65), tiles(0, 28)
Get (213, 52)-(228, 65), tiles(0, 29)
Get (196, 1)-(211, 14), tiles(0, 30)
Get (213, 1)-(228, 14), tiles(0, 31)
Get (230, 1)-(245, 14), tiles(0, 32)
Get (247, 1)-(262, 16), tiles(0, 33)
Get (196, 18)-(211, 33), tiles(0, 34)
Get (213, 18)-(228, 33), tiles(0, 35)
Get (247, 18)-(262, 33), tiles(0, 36)
Get (196, 35)-(211, 50), tiles(0, 37)
Get (213, 35)-(228, 50), tiles(0, 38)
Get (230, 35)-(245, 48), tiles(0, 39)
Get (230, 52)-(243, 65), tiles(0, 40)

Get (230, 84)-(245, 99), tiles(0, 41) 'third map tiles getting
Get (247, 101)-(262, 116), tiles(0, 42)
Get (196, 118)-(211, 131), tiles(0, 43)
Get (213, 118)-(228, 131), tiles(0, 44)
Get (196, 67)-(211, 80), tiles(0, 45)
Get (213, 67)-(228, 80), tiles(0, 46)
Get (230, 67)-(245, 80), tiles(0, 47)
Get (247, 67)-(262, 82), tiles(0, 48)
Get (196, 84)-(211, 99), tiles(0, 49)
Get (213, 84)-(228, 99), tiles(0, 50)
Get (247, 84)-(262, 99), tiles(0, 51)
Get (196, 101)-(211, 116), tiles(0, 52)
Get (213, 101)-(228, 116), tiles(0, 53)
Get (230, 101)-(245, 114), tiles(0, 54)
Get (230, 118)-(243, 131), tiles(0, 55)

Get (103, 58)-(118, 73), tiles(0, 56) 'common tiles getting
Get (103, 75)-(116, 90), tiles(0, 57)
Get (86, 92)-(101, 105), tiles(0, 58)
Get (103, 92)-(116, 105), tiles(0, 59)
Get (69, 58)-(84, 71), tiles(0, 60)
Get (86, 75)-(101, 90), tiles(0, 61)

Get (267, 101)-(282, 116), tiles(0, 62) 'central tiles getting
Get (284, 101)-(299, 116), tiles(0, 63)
Get (301, 101)-(316, 116), tiles(0, 64)

Get (204, 142)-(211, 155), door(0, 0) 'L door graphics getting
Get (212, 142)-(227, 155), door(0, 1)
Get (204, 156)-(211, 171), door(0, 2)
Get (212, 156)-(227, 171), door(0, 3)
Get (261, 142)-(276, 155), door(0, 4)
Get (277, 142)-(286, 155), door(0, 5)
Get (261, 156)-(276, 171), door(0, 6)
Get (277, 156)-(286, 171), door(0, 7)
Get (228, 142)-(243, 155), door(0, 8)
Get (244, 142)-(260, 155), door(0, 9)
Get (228, 156)-(243, 171), door(0, 10)
Get (244, 156)-(260, 171), door(0, 11)

Get (196, 133)-(203, 140), boxes(0, 0) 'window boxes graphics getting
Get (205, 133)-(212, 140), boxes(0, 1)
Get (214, 133)-(221, 140), boxes(0, 2)
Get (223, 133)-(230, 140), boxes(0, 3)
Get (232, 133)-(239, 140), boxes(0, 4)
Get (241, 133)-(248, 140), boxes(0, 5)
Get (250, 133)-(257, 140), boxes(0, 6)
Get (259, 133)-(266, 140), boxes(0, 7)
Get (268, 133)-(275, 140), boxes(0, 8)

Get (2, 124)-(9, 131), font(0, 0) 'font graphics getting
Get (10, 124)-(17, 131), font(0, 1)
Get (18, 124)-(25, 131), font(0, 2)
Get (26, 124)-(33, 131), font(0, 3)
Get (34, 124)-(41, 131), font(0, 4)
Get (42, 124)-(49, 131), font(0, 5)
Get (50, 124)-(57, 131), font(0, 6)
Get (58, 124)-(65, 131), font(0, 7)
Get (66, 124)-(73, 131), font(0, 8)
Get (74, 124)-(81, 131), font(0, 9)
Get (2, 133)-(9, 140), font(0, 10)
Get (10, 133)-(17, 140), font(0, 11)
Get (18, 133)-(25, 140), font(0, 12)
Get (26, 133)-(33, 140), font(0, 13)
Get (34, 133)-(41, 140), font(0, 14)
Get (42, 133)-(49, 140), font(0, 15)
Get (50, 133)-(57, 140), font(0, 16)
Get (58, 133)-(65, 140), font(0, 17)
Get (66, 133)-(73, 140), font(0, 18)
Get (74, 133)-(81, 140), font(0, 19)
Get (2, 142)-(9, 149), font(0, 20)
Get (10, 142)-(17, 149), font(0, 21)
Get (18, 142)-(25, 149), font(0, 22)
Get (26, 142)-(33, 149), font(0, 23)
Get (34, 142)-(41, 149), font(0, 36)
Get (42, 142)-(49, 149), font(0, 24)
Get (50, 142)-(57, 149), font(0, 25)
Get (58, 142)-(65, 149), font(0, 26)
Get (66, 142)-(73, 149), font(0, 27)
Get (74, 142)-(81, 149), font(0, 28)
Get (2, 151)-(9, 158), font(0, 29)
Get (10, 151)-(17, 158), font(0, 30)
Get (18, 151)-(25, 158), font(0, 31)
Get (26, 151)-(33, 158), font(0, 32)
Get (34, 151)-(41, 158), font(0, 33)
Get (42, 151)-(49, 158), font(0, 34)
Get (50, 151)-(57, 158), font(0, 35)
Get (58, 151)-(65, 158), font(0, 37)
Get (66, 151)-(73, 158), font(0, 38)
Get (74, 151)-(81, 158), font(0, 39)
Get (2, 160)-(9, 167), font(0, 40)
Get (10, 160)-(17, 167), font(0, 41)
Get (18, 160)-(25, 167), font(0, 42)
Get (26, 160)-(33, 167), font(0, 43)
Get (34, 160)-(41, 167), font(0, 44)
Get (42, 160)-(49, 167), font(0, 45)
Get (50, 160)-(57, 167), font(0, 46)
Get (58, 160)-(65, 167), font(0, 47)
Get (66, 160)-(73, 167), font(0, 48)
Get (74, 160)-(81, 167), font(0, 49)
Get (2, 169)-(9, 176), font(0, 50)
Get (10, 169)-(17, 176), font(0, 51)
Get (19, 169)-(26, 176), font(0, 52)

Get (20, 20)-(37, 37), death(0, 0) 'pac death graphics getting
Get (1, 39)-(18, 56), death(0, 1)
Get (58, 39)-(75, 56), death(0, 2)
Get (39, 1)-(56, 18), death(0, 3)
Get (77, 39)-(93, 56), death(0, 4)
Get (95, 39)-(111, 56), death(0, 5)
Get (113, 39)-(129, 56), death(0, 6)
Get (131, 39)-(147, 56), death(0, 7)

Get (153, 1)-(170, 18), death(0, 8) 'common death graphics getting
Get (172, 0)-(190, 18), death(0, 9)
Get (153, 20)-(170, 37), death(0, 10)
Get (172, 19)-(192, 38), death(0, 11)
Get (153, 39)-(170, 56), death(0, 12)
Get (172, 39)-(193, 56), death(0, 13)

Get (104, 134)-(118, 151), death(0, 14) 'phantom and bug death graphics getting
Get (104, 135)-(118, 151), death(0, 15)
Get (104, 136)-(118, 151), death(0, 16)
Get (104, 137)-(118, 151), death(0, 17)
Get (104, 138)-(118, 151), death(0, 18)
Get (104, 139)-(118, 151), death(0, 19)
Get (104, 140)-(118, 151), death(0, 20)

Get (1, 1)-(18, 18), pac(0, 0) 'good pac graphics getting
Get (20, 1)-(37, 18), pac(0, 1)
Get (39, 1)-(56, 18), pac(0, 2)
Get (58, 1)-(75, 18), pac(0, 3)
Get (1, 20)-(18, 37), pac(0, 4)
Get (20, 20)-(37, 37), pac(0, 5)
Get (39, 20)-(56, 37), pac(0, 6)
Get (58, 20)-(75, 37), pac(0, 7)
Get (1, 39)-(18, 56), pac(0, 8)
Get (20, 39)-(37, 56), pac(0, 9)
Get (39, 39)-(56, 56), pac(0, 10)
Get (58, 39)-(75, 56), pac(0, 11)

Get (120, 58)-(137, 75), pac(0, 12) 'bad pac graphics getting
Get (139, 58)-(156, 75), pac(0, 13)
Get (158, 58)-(175, 75), pac(0, 14)
Get (177, 58)-(194, 75), pac(0, 15)
Get (120, 77)-(137, 94), pac(0, 16)
Get (139, 77)-(156, 94), pac(0, 17)
Get (158, 77)-(175, 94), pac(0, 18)
Get (177, 77)-(194, 94), pac(0, 19)
Get (120, 96)-(137, 113), pac(0, 20)
Get (139, 96)-(156, 113), pac(0, 21)
Get (158, 96)-(175, 113), pac(0, 22)
Get (177, 96)-(194, 113), pac(0, 23)

Get (77, 1)-(94, 18), phantom(0, 0) 'bad phantom graphics getting
Get (96, 1)-(113, 18), phantom(0, 1)
Get (115, 1)-(132, 18), phantom(0, 2)
Get (134, 1)-(151, 18), phantom(0, 3)
Get (77, 20)-(94, 37), phantom(0, 4)
Get (96, 20)-(113, 37), phantom(0, 5)
Get (115, 20)-(132, 37), phantom(0, 6)
Get (134, 20)-(151, 37), phantom(0, 7)

Get (120, 115)-(137, 132), phantom(0, 8) 'good phantom graphics getting
Get (139, 115)-(156, 132), phantom(0, 9)
Get (158, 115)-(175, 132), phantom(0, 10)
Get (177, 115)-(194, 132), phantom(0, 11)
Get (120, 134)-(137, 151), phantom(0, 12)
Get (139, 134)-(156, 151), phantom(0, 13)
Get (158, 134)-(175, 151), phantom(0, 14)
Get (177, 134)-(194, 151), phantom(0, 15)

Get (120, 153)-(137, 168), bug(0, 0) 'bug graphics getting
Get (139, 153)-(154, 170), bug(0, 1)
Get (158, 153)-(175, 168), bug(0, 2)
Get (177, 153)-(192, 170), bug(0, 3)

'palette initialization

Palette 13, 8
Palette 15, 8
Palette 11, 7
Palette 3, 0
Palette 6, 2
Palette 9, 8

'menu initialization

menu:

Key(8) Off: Key(11) Off: Key(12) Off: Key(13) Off: Key(14) Off

Close '#2

file$ = "default.txt"
ddd = 0: points = -1
View: Cls
View Screen(50, 0)-(275, 199) 'defines scroll window
BlankScreen

ViewText 92, 40, "MADMIX GAME V1.2"
ViewText 92, 64, "1...START GAME  "
ViewText 92, 80, "2...LOAD CUSTOM "
ViewText 92, 96, "3...HALL OF FAME"
ViewText 92, 112, "4...CREDITS     "
ViewText 92, 128, "5...EXIT        "
ViewText 84, 156, "QBASIC VERSION BY"
ViewText 84, 165, "ENRIQUE HUERTA"

Palette 11, 7: Palette 0, 0 '''

Do: Loop Until InKey$ = "" 'clears keyboard buffer

Timer On
On Timer(5) GoSub activatedemo 'five seconds to demo

Do While (Choice = 0 And startdemo = 0)
    PCopy 0, 1
Loop

Timer Off

Select Case chosen
    Case 1
    Case 2
        file$ = FileBrowser$("FILE NAME:³", 40)
        If file$ = "" Then GoTo menu
    Case 3
        BlankScreen
        CheckRecord
        LoadRecords
        GoTo menu
    Case 4
        View: Cls
        ViewWavyText 100, "PROGRAMMER: ENRIQUE HUERTA MEZQUITA, CONTACT ME AT ENRIQUEMAIL@MIXMAIL.COM, "
        GoTo menu
    Case 5
        GoTo escape
End Select

'Game Initialization

Open file$ For Input As #2
Input #2, maxlev

View: Cls: Paint (0, 0), 3
View Screen(50, 0)-(275, 199) 'defines scroll window

lives = 3: points = 0: name$ = "": levnum = 0

If startdemo = 0 Then Key(8) On 'activates F8 = exit key

On Key(8) GoSub returntomenu 'intercept keys
On Key(11) GoSub arriba
On Key(12) GoSub izquierda
On Key(13) GoSub derecha
On Key(14) GoSub abajo

loadlevel:

Erase kickass

If levnum > (maxlev - 1) Then levnum = 0: Close #2: Open file$ For Input As #2: Input #2, maxlev

'prisons = 0
xprison = 0
foodleft = 0

LoadMap 'map matrix reading

openorclose = map(xprison, yprison)
lives = lives + addlife
Abefore = A: Bbefore = B

'FOR kind = 0 TO prisons
'opendoor(kind) = INT(RND * 40)
'NEXT kind

realpoints = points: BlankScreen: ViewPoints

'prints stage name
TIMERbefore = Timer 'count the elapsed time
Key(11) Off: Key(12) Off: Key(13) Off: Key(14) Off ': KEY(1) OFF: KEY(2) OFF
ViewText 90 + (128 - Len(stagename$) * 8) / 2, 100, stagename$
ViewText 90 + (128 - Len(stagetext$) * 8) / 2, 120, stagetext$
Palette 11, 0: PCopy 0, 1
Do 'minimum elapsed time
    If InKey$ <> "" And startdemo Then startdemo = 0: GoTo menu
Loop Until Timer > TIMERbefore + 1.5

restart:

If lives = -1 Then
    lives = 0: realpoints = points: BlankScreen: ViewPoints: GameOver: BlankScreen: PCopy 0, 1: Palette 11, 7: Palette 0, 0
    If (chosen - 2) Then CheckRecord: BlankScreen: LoadRecords
    GoTo menu
End If

factor = 4 'phantoms loop
flip = 1 'phantoms want to kill pac. if it is -1 phantoms will escape
accuracy = 3 'phantom intelligence accuracy
character = 0 'good/medium/bad character
timeleft = 0 'time left to mutate

newgame = 1 'if newgame is true we have to press any key because of Ready sub
pacisalive = 1 'if pacisalive is equal to one then phantoms can eat pac. if pacisalive is grower then pac can eat phantoms. if pacisalive is equal to zero then pac is dead
backcount = 0 'changes graphics making the death animation effect
opendoor = 0 'time counter to open and close phantom prison door
count = 5 'changes graphics making the animation effect

dopath = 0 'pac is not forced
tryadda = adda: tryaddb = addb 'their values say to us the direction we want to go
A = Abefore: B = Bbefore 'pac coordinates and pac coordinates buffer are the same value
realpoints = points 'points refresh

'FOR kind = 0 TO prisons
map(xprison, yprison) = openorclose 'prison door is restored as at the beginning
'NEXT kind

For i = 0 To (phantoms + bugs):
    ghosta(i) = aghost: ghostb(i) = bghost 'all phantoms start over the same location
    RandomMove 'phantom starts moving randomly
Next i

Do 'here starts the main loop

    TIMERbefore = Timer 'count the time elapsed between two frames

    If startdemo = 0 Then Key(11) Stop: Key(12) Stop: Key(13) Stop: Key(14) Stop ': KEY(1) STOP: KEY(2) STOP

    Cls 1
        
    'FOR kind = 0 TO prisons
    If xprison Then
        opendoor = opendoor + 1
        If opendoor > 75 Then
            opendoor = 0
            map(xprison, yprison) = nextone(map(xprison, yprison) - 9)
            'prison door can be put in the middle
            Select Case map(xprison, yprison)
                Case 32: map(0, yprison) = nextone(map(0, yprison) - 9)
                Case 1: map(33, yprison) = nextone(map(33, yprison) - 9)
            End Select
        End If
    End If
    'NEXT kind

    For i = 0 To (phantoms + bugs)
        Select Case ghosta(i)
            Case Is < -72: ghosta(i) = ghosta(i) + 512
            Case Is > 440: ghosta(i) = ghosta(i) - 512
        End Select
        Select Case (56 + ghosta(i) - A)
            Case Is > 256: rewind(i) = -512
            Case Is < -256: rewind(i) = 512
            Case Else: rewind(i) = 0
        End Select
        Select Case (56 + kickghosta(i) - A)
            Case Is > 256: kickrewind(i) = -512
            Case Is < -256: kickrewind(i) = 512
            Case Else: kickrewind(i) = 0
        End Select

        dist = ((A - 56 - ghosta(i) - rewind(i)) ^ 2 + (B - 56 - ghostb(i)) ^ 2)
        If dist < 196 And (i <= phantoms Or factor - 4) And dooropening = 0 Then pacisalive = 1 - flip
                
        If pacisalive > 1 Then
            pacisalive = 1: kickass(i) = 13
            kickghosta(i) = ghosta(i): kickghostb(i) = ghostb(i)
            ghosta(i) = aghost: ghostb(i) = bghost
            RandomMove
            points = points + 60
        Else
            If (Int(ghosta(i) / 16) = (ghosta(i) / 16) And Int(ghostb(i) / 16) = (ghostb(i) / 16)) And newgame = 0 Then AI
        End If
        ghosta(i) = ghosta(i) + addgha(i) * ChooseFactor: ghostb(i) = ghostb(i) + addghb(i) * ChooseFactor
    Next i
                                
    Select Case timeleft
        Case 1: factor = 4: flip = 1: accuracy = 3: character = 0: timeleft = 0
            For i = 0 To phantoms:
                ghosta(i) = ghosta(i) - addgha(i) * (ghosta(i) / 4 - Int(ghosta(i) / 4)) * 4
                ghostb(i) = ghostb(i) - addghb(i) * (ghostb(i) / 4 - Int(ghostb(i) / 4)) * 4
                addgha(i) = -addgha(i): addghb(i) = -addghb(i)
            Next i
        Case 50: character = 1: timeleft = timeleft - 1
        Case Is > 0: timeleft = timeleft - 1
    End Select

    If dopath Then dopath = dopath - 1: tryadda = doadda: tryaddb = doaddb
                            
    If pacisalive Then
        Abefore = A: Bbefore = B
        If (Int((A + 8) / 16) = ((A + 8) / 16) And Int((B + 8) / 16) = ((B + 8) / 16)) Or (tryadda = -adda And adda <> 0) Or (tryaddb = -addb And addb <> 0) Then
            If Find = 2 Then adda = tryadda: addb = tryaddb
        End If
        A = A + adda: B = B + addb
        Wall
        'this is the previous code. it is faster but L door cannot be put in the middle
        'SELECT CASE dooropening
        'CASE -6: map(xopening, yopening) = -109: map(xopening + 1, yopening) = -10: dooropening = dooropening + 1
        'CASE -3: map(xopening, yopening) = -5: map(xopening + 1, yopening) = 98: dooropening = dooropening + 1
        'CASE IS < 0: dooropening = dooropening + 1
        'CASE 6: map(xopening, yopening) = -109: map(xopening + 1, yopening) = -10: dooropening = dooropening - 1
        'CASE 3: map(xopening, yopening) = 99: map(xopening + 1, yopening) = -6: dooropening = dooropening - 1
        'CASE IS > 0: dooropening = dooropening - 1
        'END SELECT
        Select Case dooropening 'Map numbers identifiers for the door: -5, 98 = Left Door ÄÙ ; -109, -10 = Middle Door \/; 99, -6 = Right Door ÀÄ
            Case -6: dooropening = dooropening + 1
                Select Case xopening
                    Case -1: map(31, yopening) = -109: map(32, yopening) = -10: map(0, yopening) = -10
                    Case 0: map(32, yopening) = -109: map(0, yopening) = -109: map(1, yopening) = -10: map(33, yopening) = -10
                    Case 1: map(33, yopening) = -109: map(1, yopening) = -109: map(2, yopening) = -10
                    Case Else: map(xopening, yopening) = -109: map(xopening + 1, yopening) = -10
                End Select
            Case -3: dooropening = dooropening + 1
                Select Case xopening
                    Case -1: map(31, yopening) = -5: map(32, yopening) = 98: map(0, yopening) = 98
                    Case 0: map(32, yopening) = -5: map(33, yopening) = 98: map(1, yopening) = 98: map(xopening, yopening) = -5
                    Case 1: map(33, yopening) = -5: map(2, yopening) = 98: map(xopening, yopening) = -5
                    Case Else: map(xopening + 1, yopening) = 98: map(xopening, yopening) = -5
                End Select
            Case Is < 0: dooropening = dooropening + 1
            Case 6: map(xopening, yopening) = -109: dooropening = dooropening - 1
                Select Case xopening
                    Case 31: map(32, yopening) = -10: map(0, yopening) = -10
                    Case 32: map(0, yopening) = -109: map(1, yopening) = -10: map(33, yopening) = -10
                    Case 33: map(1, yopening) = -109: map(2, yopening) = -10
                    Case Else: map(xopening + 1, yopening) = -10
                End Select
            Case 3: map(xopening, yopening) = 99: dooropening = dooropening - 1
                Select Case xopening
                    Case 31: map(32, yopening) = -6: map(0, yopening) = -6
                    Case 32: map(0, yopening) = 99: map(1, yopening) = -6: map(33, yopening) = -6
                    Case 33: map(1, yopening) = 99: map(2, yopening) = -6
                    Case Else: map(xopening + 1, yopening) = -6
                End Select
            Case Is > 0: dooropening = dooropening - 1
        End Select
        HaveLunch
        MoveScreen
        'may be it is better to use mouth(count, INT((adda + 4) / 8) + INT((addb + 4) / 8) + 2 * ABS(addb / 4), character) to optimize
        Put (152, 92), pac(0, mouth(count, (adda + 4) / 4, (addb + 4) / 4, character)), Or
    Else
        MoveScreen
        Put (152, 92), death(0, pacdeath(backcount)), Or
        backcount = backcount + 1: If backcount > 25 Then lives = lives - 1: GoTo restart
    End If

    For i = 0 To (phantoms + bugs)
        If (ghosta(i) - A + rewind(i)) > -144 And (ghosta(i) - A + rewind(i)) < 32 And (ghostb(i) - B) > -144 And (ghostb(i) - B) < 35 Then
            If i > phantoms Then
                Put (ghosta(i) + 208 - A + rewind(i), ghostb(i) + 148 - B), bug(0, ass(count, addgha(i) + 1, addghb(i) + 1)), Or
            Else
                Put (ghosta(i) + 208 - A + rewind(i), ghostb(i) + 148 - B), phantom(0, sheet(count, addgha(i) + 1, addghb(i) + 1, character)), Or
            End If
        End If
        If kickass(i) Then
            If (kickghosta(i) - A + kickrewind(i)) > -144 And (kickghosta(i) - A + kickrewind(i)) < 32 And (kickghostb(i) - B) > -144 And (kickghostb(i) - B) < 35 Then
                Put (kickghosta(i) + 208 - A + kickrewind(i), kickghostb(i) + 148 - B), death(0, phantomdeath(kickass(i))), Or
            End If
            kickass(i) = kickass(i) - 1
            'SOUND 100, .1
        End If
    Next i

Select Case A: Case Is < -16: A = A + 512: Case Is > 496: A = A - 512: End Select
        
    count = count + 1: If count > 7 Then count = 0

    Line (81, 21)-(242, 182), 3, B: Paint (67, 17), 3

    ViewPoints

    'demo data compression will be -40 = left, 40 = right, -04 = up, 04 = down
    If startdemo Then
        tryadda = Fix(compressed(ddd) / 10)
        tryaddb = (1 - Abs(Fix(compressed(ddd) / 40))) * compressed(ddd)
        If ddd Mod 2 Then ViewText 190, 170, "DEMO"
        ddd = ddd + 1: If ddd > 299 Then ddd = 0: levnum = levnum + 1: If levnum <> 6 Then GoSub nextstagedemo: GoTo loadlevel Else GoTo finishdemo
    End If

    If newgame Then
        Palette 0, 2: newgame = 0
        If startdemo = 0 Then Ready
    Else
        PCopy 0, 1
    End If

    If foodleft = 0 Then levnum = levnum + 1: GoTo loadlevel

    Do: Loop Until Timer > TIMERbefore 'minimum time elapsed between two frames will be 0.01 seconds

    If startdemo = 0 Then Key(11) On: Key(12) On: Key(13) On: Key(14) On ': KEY(1) ON: KEY(2) ON
        
Loop While (InKey$ = "" Or startdemo = 0) 'if demo is running we will exit pressing any key

finishdemo:
Close #1
'DO: LOOP UNTIL INKEY$ = ""             'clears keyboard buffer
startdemo = 0: GoTo menu
arriba:
tryaddb = -4: tryadda = 0
Return
izquierda:
tryadda = -4: tryaddb = 0
Return
derecha:
tryadda = 4: tryaddb = 0
Return
abajo:
tryaddb = 4: tryadda = 0
Return
escape:
null$ = Alert("HAVE A NICE DAY")
Screen 0: Width 80: Cls
Print "FOR MORE FUN VISIT MY OWN PAGE HTTP://WWW11.BRINKSTER.COM/FREESOURCE"
Close: End
returntomenu:
If startdemo Then Return Else Return menu
activatedemo:
Open "demo.txt" For Input As #1
GoSub nextstagedemo
startdemo = 1
chosen = 1
Return
nextstagedemo:
For kind = 0 To 299
    Input #1, compressed(kind)
Next kind
Return
errortrapping:
Close
Select Case Err
    Case 53:
        null$ = Alert$("ERROR 53:FILE NOT FOUND")
        Resume menu
    Case 64:
        null$ = Alert$("ERROR 64:BAD FILENAME")
        Resume menu
    Case 75:
        null$ = Alert$("ERROR 75:PATH/FILE ACCESS ERROR")
        Resume menu
    Case 76:
        null$ = Alert$("ERROR 76:PATH NOT FOUND")
        Resume menu
        'CASE 70:
        'null$ = Alert$("ERROR 70:PERMISSION DENIED")
        'RESUME menu
        'CASE 71:
        'null$ = Alert$("ERROR 71:DISK NOT READY")
        'RESUME menu
    Case Else:
        null$ = Alert$("SEVERAL ERROR" + Str$(Err) + ":CANNOT CONTINUE")
        Screen 0: Width 80: Cls
        End
End Select

Sub AI
    'converts screen coordinates to matrix coordinates
    ghostx = (ghosta(i) + 80) / 16
    ghosty = (ghostb(i) + 80) / 16

    'if bug is visible he will put points
    If map(ghostx, ghosty) = -7 And i > phantoms And (ghosta(i) - A + rewind(i) > -144) And (ghosta(i) - A + rewind(i)) < 32 And (ghostb(i) - B) > -144 And (ghostb(i) - B) < 35 Then
        map(ghostx, ghosty) = 4: foodleft = foodleft + 1
    End If

    'if this is equal to zero then phantom behaves randomly ([1/50] probit)
    'IF INT(RND * 50) = 0 AND map(ghostx, ghosty) < 9 THEN RandomMove: EXIT SUB

    'intelligence accuracy increases when phantom is nearby to pac
    If dist < 64 * 64 Or character > 0 Then probit = Int(Rnd * accuracy) Else probit = 0

    Select Case Abs(addghb(i))
        'phantom is moving horizontally
        Case 0
            If map(ghostx + addgha(i), ghosty) < 10 Then updown = updown + 1
            If map(ghostx, ghosty - 1) < 10 Then updown = updown + 2
            If map(ghostx, ghosty + 1) < 10 Then updown = updown + 4
            Select Case updown
                Case 0 'no exits
                    addgha(i) = -addgha(i)
                Case 2 'exit above
                    addgha(i) = 0: addghb(i) = -1
                Case 4 'exit below
                    addgha(i) = 0: addghb(i) = 1
                Case 3 'exits above, in front
                    If probit = 0 Then
                        probit = Int(Rnd * 2)
                        addgha(i) = addgha(i) * probit: addghb(i) = probit - 1
                    Else
                        If ghosty * flip > (Int(B / 16) + 2) * flip Then addgha(i) = 0: addghb(i) = -1
                    End If
                Case 5 'exits below, in front
                    If probit = 0 Then
                        probit = Int(Rnd * 2)
                        addgha(i) = addgha(i) * probit: addghb(i) = 1 - probit
                    Else
                        If ghosty * flip < (Int(B / 16) + 2) * flip Then addgha(i) = 0: addghb(i) = 1
                    End If
                Case 6 'exits above, below
                    addgha(i) = 0
                    If probit = 0 Then
                        probit = Int(Rnd * 2)
                        addghb(i) = probit * 2 - 1
                    Else
                        If ghosty * flip > (Int(B / 16) + 2) * flip Then addghb(i) = -1 Else addghb(i) = 1
                    End If
                Case 7 'exits above, below, in front
                    If probit = 0 Then
                        probit = Int(Rnd * 3) - 1
                        addghb(i) = probit: addgha(i) = addgha(i) * (1 - Abs(addghb(i)))
                    Else
                        If ghosty * flip > (Int(B / 16) + 2) * flip Then addgha(i) = 0: addghb(i) = -1
                        If ghosty * flip < (Int(B / 16) + 2) * flip Then addgha(i) = 0: addghb(i) = 1
                    End If
            End Select
            'phantom is moving vertically
        Case 1
            If map(ghostx, ghosty + addghb(i)) < 10 Then leftright = leftright + 1
            If map(ghostx - 1, ghosty) < 10 Then leftright = leftright + 2
            If map(ghostx + 1, ghosty) < 10 Then leftright = leftright + 4
            Select Case leftright
                Case 0 'no exits
                    addghb(i) = -addghb(i)
                Case 2 'exit on the left
                    addghb(i) = 0: addgha(i) = -1
                Case 4 'exit on the right
                    addghb(i) = 0: addgha(i) = 1
                Case 3 'exits on the left, in front
                    If probit = 0 Then
                        probit = Int(Rnd * 2)
                        addghb(i) = addghb(i) * probit: addgha(i) = probit - 1
                    Else
                        If ghostx * flip + rewind(i) > (Int(A / 16) + 2) * flip Then addghb(i) = 0: addgha(i) = -1
                    End If
                Case 5 'exits on the right, in front
                    If probit = 0 Then
                        probit = Int(Rnd * 2)
                        addghb(i) = addghb(i) * probit: addgha(i) = 1 - probit
                    Else
                        If ghostx * flip + rewind(i) < (Int(A / 16) + 2) * flip Then addghb(i) = 0: addgha(i) = 1
                    End If
                Case 6 'exits on the left, on the right
                    addghb(i) = 0
                    If probit = 0 Then
                        probit = Int(Rnd * 2)
                        addgha(i) = probit * 2 - 1
                    Else
                        If ghostx * flip + rewind(i) > (Int(A / 16) + 2) * flip Then addgha(i) = -1 Else addgha(i) = 1
                    End If
                Case 7 'exits on the left, on the right, in front
                    If probit = 0 Then
                        probit = Int(Rnd * 3) - 1
                        addgha(i) = probit: addghb(i) = addghb(i) * (1 - Abs(addgha(i)))
                    Else
                        If ghostx * flip + rewind(i) > (Int(A / 16) + 2) * flip Then addghb(i) = 0: addgha(i) = -1
                        If ghostx * flip + rewind(i) < (Int(A / 16) + 2) * flip Then addghb(i) = 0: addgha(i) = 1
                    End If
            End Select
    End Select
End Sub

Function Alert$ (txt$)
    PCopy 1, 0
    txtlen = Len(txt$)
    If txtlen > 24 Then midwidth = 12 Else midwidth = txtlen / 2
    ViewWindow 19 - midwidth, 11, 21 + midwidth, 15 + Int(txtlen / 25)
    For f = 0 To Int(txtlen / 24)
        ViewText 156 - midwidth * 8, 104 + f * 9, Mid$(txt$, f * 24 + 1, 24)
    Next f
    PCopy 0, 1
    While push$ = "": push$ = InKey$: Wend
    Alert$ = push$
End Function

Sub BlankScreen
    Cls
    Paint (67, 17), 3
    Line (81, 21)-(242, 182), 7, B
    Paint (87, 37), 7
End Sub

Sub CheckRecord
    Open "records.txt" For Append As #1: Close #1
    Open "records.txt" For Input As #1
    While Not EOF(1)
        Input #1, hallpoints(insert), hallnames$(insert)
        insert = insert + 1
    Wend
    Close #1
    For insert = 4 To 0 Step -1
        If hallpoints(insert) <= points Then
            hallpoints(insert + 1) = hallpoints(insert): hallnames$(insert + 1) = hallnames$(insert)
        Else
            If insert < 4 Then name$ = FileBrowser("YOUR NAME:³", 10)
            hallpoints(insert + 1) = points: hallnames$(insert + 1) = name$ + String$(10 - Len(name$), 46)
            Exit For
        End If
        If insert = 0 Then
            name$ = FileBrowser("YOUR NAME:³", 10)
            hallpoints(0) = points: hallnames$(0) = name$ + String$(10 - Len(name$), 46)
        End If
    Next insert
    Open "records.txt" For Output As #1
    For insert = 0 To 4
        If hallnames$(insert) = "" Then hallnames$(insert) = String$(10, 46)
        Print #1, hallpoints(insert), hallnames$(insert)
    Next insert
    Close #1
End Sub

Function Choice
    LookForKey$ = InKey$
    Select Case Val(LookForKey$)
        Case 1 To 5: Choice = 1: startdemo = 0: chosen = Val(LookForKey$)
        Case Else: Choice = 0
    End Select
End Function

Function ChooseFactor
    If i > phantoms Then ChooseFactor = 2 Else ChooseFactor = factor
End Function

Function FileBrowser$ (txt$, txtmax)
    ViewWindow 7, 10, 32, 14
    ViewText 64, 96, txt$
    Do: Loop Until InKey$ = "" 'clears keyboard buffer
    While LookForKey$ <> Chr$(13) And LookForKey$ <> Chr$(27)
        PCopy 0, 1
        Do: LookForKey$ = UCase$(Input$(1)): Loop While (Len(txtwrote$) = 0 And Asc(LookForKey$) = 8)
        Select Case Asc(LookForKey$)
            Case 8:
                txtwrote$ = Left$(txtwrote$, Len(txtwrote$) - 1)
                ViewText 143, 96, Right$(txtwrote$, 12) + Right$(txt$, 1) + Chr$(32)
            Case 13:
                FileBrowser$ = txtwrote$
            Case 27:
                FileBrowser$ = ""
            Case Is <> 13:
                Select Case Len(txtwrote$)
                    Case Is >= txtmax
                    Case Is < 12:
                        txtwrote$ = txtwrote$ + LookForKey$
                        ViewText 143, 96, Right$(txtwrote$, Len(txtwrote$)) + Right$(txt$, 1) + Chr$(32)
                    Case Is < txtmax:
                        txtwrote$ = txtwrote$ + LookForKey$
                        ViewText 143, 96, Right$(txtwrote$, 12) + Right$(txt$, 1) + Chr$(32)
                End Select
        End Select
    Wend
End Function

Function Find
    For side = 0 To 2 Step 2
        Select Case map(Int((A + tryadda + corners((tryadda + 4) / 4, (tryaddb + 4) / 4, 0 + side)) / 16), Int((B + tryaddb + corners((tryadda + 4) / 4, (tryaddb + 4) / 4, 1 + side)) / 16))
            Case 99, 98
                FI = FI + 1
            Case Is < 11
                FI = FI + 1
        End Select
    Next side
    Find = FI
End Function

Sub GameOver
    Dim TIMERbefore As Single
    TIMERbefore = Timer 'count the elapsed time
    Key(11) Off: Key(12) Off: Key(13) Off: Key(14) Off ': KEY(1) OFF: KEY(2) OFF
    ViewText 118, 100, "GAME OVER"
    PCopy 0, 1
    Do: Loop Until Timer > TIMERbefore + 1.5 'minimum elapsed time
End Sub

Sub HaveLunch
    Select Case map(Int((A + dinner((adda + 4) / 4, (addb + 4) / 4, 0)) / 16), Int((B + dinner((adda + 4) / 4, (addb + 4) / 4, 1)) / 16))
        Case 3 'red face
            If (factor - 2) Then
                map(Int((A + dinner((adda + 4) / 4, (addb + 4) / 4, 0)) / 16), Int((B + dinner((adda + 4) / 4, (addb + 4) / 4, 1)) / 16)) = 0
                flip = -1: factor = 2: accuracy = 6: character = 2
                timeleft = badpactime
                For i = 0 To phantoms:
                    addgha(i) = -addgha(i): addghb(i) = -addghb(i)
                Next i
            End If
        Case 4 'food
            map(Int((A + dinner((adda + 4) / 4, (addb + 4) / 4, 0)) / 16), Int((B + dinner((adda + 4) / 4, (addb + 4) / 4, 1)) / 16)) = -7
            points = points + 8: foodleft = foodleft - 1
        Case 5 'right arrow
            If (adda + 4) Then
                map(Int((A + dinner((adda + 4) / 4, (addb + 4) / 4, 0)) / 16), Int((B + dinner((adda + 4) / 4, (addb + 4) / 4, 1)) / 16)) = 0
                points = points + 8: foodleft = foodleft - 1
                dopath = 4: doadda = 4: doaddb = 0
            Else A = Abefore: B = Bbefore
            End If
        Case 6 'left arrow
            If (adda - 4) Then
                map(Int((A + dinner((adda + 4) / 4, (addb + 4) / 4, 0)) / 16), Int((B + dinner((adda + 4) / 4, (addb + 4) / 4, 1)) / 16)) = 0
                points = points + 8: foodleft = foodleft - 1
                dopath = 4: doadda = -4: doaddb = 0
            Else A = Abefore: B = Bbefore
            End If
        Case 7 'down arrow
            If (addb + 4) Then
                map(Int((A + dinner((adda + 4) / 4, (addb + 4) / 4, 0)) / 16), Int((B + dinner((adda + 4) / 4, (addb + 4) / 4, 1)) / 16)) = 0
                points = points + 8: foodleft = foodleft - 1
                dopath = 4: doadda = 0: doaddb = 4
            Else A = Abefore: B = Bbefore
            End If
        Case 8 'up arrow
            If (addb - 4) Then
                map(Int((A + dinner((adda + 4) / 4, (addb + 4) / 4, 0)) / 16), Int((B + dinner((adda + 4) / 4, (addb + 4) / 4, 1)) / 16)) = 0
                points = points + 8: foodleft = foodleft - 1
                dopath = 4: doadda = 0: doaddb = -4
            Else A = Abefore: B = Bbefore
            End If
        Case Else: Exit Sub
    End Select
    'SOUND 600, .5: SOUND 400, .5
End Sub

Sub LoadMap
    Input #2, stagename$, stagetext$
    Input #2, addlife, phantoms, bugs, badpactime
    For ydatabase = 0 To 29
        For xdatabase = 0 To 33
            Input #2, map(xdatabase, ydatabase)
            Select Case map(xdatabase, ydatabase)
                'L door
                Case 98, -6
                Case -5, 99
                    'phantoms start over point
                Case -8: aghost = xdatabase * 16 - 80: bghost = ydatabase * 16 - 80
                    map(xdatabase, ydatabase) = 4: foodleft = foodleft + 1
                    'pac variables initialization
                Case Is < 0: A = xdatabase * 16 - 24: B = ydatabase * 16 - 24
                    adda = pathsa(Abs(map(xdatabase, ydatabase)) - 1) * 4: addb = pathsb(Abs(map(xdatabase, ydatabase)) - 1) * 4
                    'phantom variables initialization
                Case 2: aghost = xdatabase * 16 - 80: bghost = ydatabase * 16 - 80
                    'food counter
                Case 4, 5, 6, 7, 8: foodleft = foodleft + 1
                    'phantom prison door
                Case 10: If xdatabase > 0 And xdatabase < 33 Then xprison = xdatabase: yprison = ydatabase ': prisons = prisons + 1
            End Select
        Next xdatabase
    Next ydatabase
    'CLOSE #2
    phantoms = phantoms - 1
End Sub

Sub LoadPcx (txt$)
    Dim H As TH
    Dim dat As String * 1
    Open txt$ For Binary As #1
    Get #1, 1, H
    C = 1
    Y = 0: X = 0
    While C <= 64000
        Get #1, , dat
        If Asc(dat) > 192 And Asc(dat) <= 255 Then
            LPS = Asc(dat) - 192
            Get #1, , dat
            value = Asc(dat)
            While LPS > 0
                PSet (X, Y), ega(value - 241)
                If X = 320 Then X = 1: Y = Y + 1 Else X = X + 1
                C = C + 1
                LPS = LPS - 1
            Wend
        Else
            value = Asc(dat)
            PSet (X, Y), value
            If X = 320 Then X = 1: Y = Y + 1 Else X = X + 1
            C = C + 1
        End If
    Wend
    Close #1
End Sub

Sub LoadRecords
    ViewText 105, 40, "HALL OF FAME"
    Open "records.txt" For Input As #1
    While Not EOF(1)
        Input #1, viewhallpoints, viewhallnames$
        ViewText 86, 64 + insert, viewhallnames$ + String$(8 - Len(Str$(viewhallpoints)), 46) + Right$(Str$(viewhallpoints), Len(Str$(viewhallpoints)) - 1)
        insert = insert + 16
    Wend
    Close #1
    ViewText 90, 164, "PRESS ANY KEY..."
    PCopy 0, 1
    While InKey$ = "": Wend
End Sub

Sub MoveScreen
    'this version let you put so doors as you want. it is large but fast
    For xmap = Int(A / 16) - 3 To 4 + 3 + Int(A / 16)
        Select Case xmap
            Case Is > 32: remind = -32
            Case Is < 1: remind = 32
            Case Else: remind = 0
        End Select
        'rows 1 to 11
        For ymap = Int(B / 16) - 3 To 4 + 3 + Int(B / 16)
            Select Case map(xmap + remind, ymap)
                'prints the doors
                Case -109
                    If ymap > Int(B / 16) - 3 Then Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 8)
                    Put (xmap * 16 - A + 128, ymap * 16 - B + 70), door(0, 10), PSet
                Case -10
                    If ymap > Int(B / 16) - 3 Then Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 9)
                    Put (xmap * 16 - A + 128, ymap * 16 - B + 70), door(0, 11), PSet
                Case -5
                    If ymap > Int(B / 16) - 3 Then Put (xmap * 16 - A + 136, (ymap - 1) * 16 - B + 70 + 2), door(0, 0)
                    Put (xmap * 16 - A + 136, ymap * 16 - B + 70), door(0, 2), PSet
                Case 98
                    If ymap > Int(B / 16) - 3 Then Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 1)
                    Put (xmap * 16 - A + 128, ymap * 16 - B + 70), door(0, 3), PSet
                Case 99
                    If ymap > Int(B / 16) - 3 Then Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 4)
                    Put (xmap * 16 - A + 128, ymap * 16 - B + 70), door(0, 6), PSet
                Case -6
                    If ymap > Int(B / 16) - 3 Then Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 5)
                    Put (xmap * 16 - A + 128, ymap * 16 - B + 70), door(0, 7), PSet
                    'prints the rest of the objects
                Case Is > 2
                    Put (xmap * 16 - A + 130, ymap * 16 - B + 70), tiles(0, map(xmap + remind, ymap))
            End Select
        Next ymap
        'last row
        Select Case map(xmap + remind, ymap)
            'prints the upper door graphics
            Case -109
                Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 8)
            Case -10
                Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 9)
            Case -5
                Put (xmap * 16 - A + 136, (ymap - 1) * 16 - B + 70 + 2), door(0, 0)
            Case 98
                Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 1)
            Case 99
                Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 4)
            Case -6
                Put (xmap * 16 - A + 128, (ymap - 1) * 16 - B + 70 + 2), door(0, 5)
        End Select
    Next xmap
End Sub

Sub RandomMove
    ghostx = (ghosta(i) + 80) / 16
    ghosty = (ghostb(i) + 80) / 16
    If map(ghostx - 1, ghosty) < 10 Then moving = moving + 1
    If map(ghostx + 1, ghosty) < 10 Then moving = moving + 2
    If map(ghostx, ghosty - 1) < 10 Then moving = moving + 4
    If map(ghostx, ghosty + 1) < 10 Then moving = moving + 8
    Select Case moving
        Case 1
            addgha(i) = -1: addghb(i) = 0
        Case 2
            addgha(i) = 1: addghb(i) = 0
        Case 4
            addghb(i) = -1: addgha(i) = 0
        Case 8
            addghb(i) = 1: addgha(i) = 0
        Case 3
            which = Int(Rnd * 2) 'two random paths to choose
            addgha(i) = pathsb(which + 1): addghb(i) = 0
        Case 5
            which = Int(Rnd * 2) 'two random paths to choose
            addgha(i) = pathsa(which): addghb(i) = pathsb(which)
        Case 9
            which = Int(Rnd * 2) 'two random paths to choose
            addgha(i) = pathsa(which): addghb(i) = -pathsb(which)
        Case 6
            which = Int(Rnd * 2) 'two random paths to choose
            addgha(i) = -pathsa(which): addghb(i) = pathsb(which)
        Case 10
            which = Int(Rnd * 2) 'two random paths to choose
            addgha(i) = -pathsa(which): addghb(i) = -pathsb(which)
        Case 12
            which = Int(Rnd * 2) 'two random paths to choose
            addgha(i) = 0: addghb(i) = pathsb(which + 1)
        Case 7
            which = Int(Rnd * 3) 'three random paths to choose
            addgha(i) = pathsb(which): addghb(i) = pathsa(which)
        Case 13
            which = Int(Rnd * 3) 'three random paths to choose
            addgha(i) = pathsa(which): addghb(i) = pathsb(which)
        Case 11
            which = Int(Rnd * 3) 'three random paths to choose
            addgha(i) = pathsb(which): addghb(i) = -pathsa(which)
        Case 14
            which = Int(Rnd * 3) 'three random paths to choose
            addgha(i) = -pathsa(which): addghb(i) = pathsb(which)
        Case 15
            which = Int(Rnd * 4) 'four random paths to choose
            addgha(i) = pathsa(which): addghb(i) = pathsb(which)
        Case Else
            addgha(i) = 0: addghb(i) = 0
    End Select
End Sub

Sub Ready
    Key(11) Off: Key(12) Off: Key(13) Off: Key(14) Off ': KEY(1) OFF: KEY(2) OFF
    ViewText 114, 110, Space$(10)
    ViewText 114, 118, "  READY?  "
    ViewText 114, 126, Space$(10)
    PCopy 0, 1
    Do: Loop Until InKey$ = "" 'clears keyboard buffer
    While InKey$ = "": Wend
End Sub

Sub ViewPoints
    If realpoints < points Then realpoints = realpoints + 1
    lengthpoints = Len(Str$(Int(realpoints)))
    For stepbystep = 2 To lengthpoints
        Put (228 + stepbystep * 8 - lengthpoints * 8, 188), font(0, Val(Mid$(Str$(Int(realpoints)), stepbystep, 1))), PSet
    Next stepbystep
    ViewText 80, 188, "&*" + Right$(Str$(lives), Len(Str$(lives)) - 1)
End Sub

Sub ViewText (X, Y, txt$)
    For stepbystep = 1 To Len(txt$)
        Put (X + stepbystep * 8, Y), font(0, chrcodes(Asc(Mid$(txt$, stepbystep, 1)))), PSet
    Next stepbystep
End Sub

Sub ViewWavyText (Y, txt$)
    View Screen(0, Y - 35)-(319, Y + 35)
    For stepbystep = 1 To Len(txt$)
        C(stepbystep) = 169 + stepbystep * 6
    Next stepbystep
    While InKey$ = ""
        Cls
        For stepbystep = 1 To Len(txt$)
            If C(stepbystep) <= 169 Then PSet (xx(C(stepbystep)), yy(C(stepbystep)) + Y), 0: Draw "TA-" + Str$(angle(C(stepbystep))) + font$(chrcodes(Asc(Mid$(txt$, stepbystep, 1))))
            C(stepbystep) = C(stepbystep) - 1: If C(stepbystep) < 0 Then C(stepbystep) = Len(txt$) * 6
        Next stepbystep
        PCopy 0, 1
        _Limit 30
    Wend
End Sub

Sub ViewWindow (fromx, fromy, tox, toy)
    For Y = fromy To toy
        For X = fromx To tox
            If X = fromx And Y = fromy Then Put (X * 8, Y * 8), boxes(0, 2), PSet: GoTo nextfor
            If X = tox And Y = fromy Then Put (X * 8, Y * 8), boxes(0, 3), PSet: GoTo nextfor
            If X = fromx And Y = toy Then Put (X * 8, Y * 8), boxes(0, 0), PSet: GoTo nextfor
            If X = tox And Y = toy Then Put (X * 8, Y * 8), boxes(0, 1), PSet: GoTo nextfor
            If X = fromx Then Put (X * 8, Y * 8), boxes(0, 4), PSet: GoTo nextfor
            If X = tox Then Put (X * 8, Y * 8), boxes(0, 5), PSet: GoTo nextfor
            If Y = fromy Then Put (X * 8, Y * 8), boxes(0, 6), PSet: GoTo nextfor
            If Y = toy Then Put (X * 8, Y * 8), boxes(0, 7), PSet: GoTo nextfor
            Put (X * 8, Y * 8), boxes(0, 8), PSet
            nextfor:
        Next X
    Next Y
End Sub

Sub Wall
    'FOR side = 0 TO 0 STEP 2
    Select Case map(Int((A + corners((adda + 4) / 4, (addb + 4) / 4, 0 + side)) / 16), Int((B + corners((adda + 4) / 4, (addb + 4) / 4, 1 + side)) / 16))
        Case -5, -6
            If dooropening = 0 Then
                dopath = 11: doadda = adda: doaddb = 0: dooropening = 8 * ((adda + 4) / 4 - 1)
                xopening = Int((A + corners((adda + 4) / 4, (addb + 4) / 4, 0 + side)) / 16) + (adda - 4) / 8
                yopening = Int((B + corners((adda + 4) / 4, (addb + 4) / 4, 1 + side)) / 16)
            End If
        Case Is > 8
            A = Abefore: B = Bbefore
    End Select
    'NEXT side
End Sub

