'Fictional CPU writen in BASIC because why not...
'Don't ask, i was bored...
$Resize:Smooth
_Title "FakeCPU"
Screen 11 'on legacy qbasic DOS it's CGA high res (640*200*2) on qb64 it's a window of the same properties
_AllowFullScreen _SquarePixels , _Smooth
'Some Features
' 64Kb RAM
' integrated io port
' 256 Entries Program Stack
' 256 Entries General Purpose Stack

Dim ram(0 To 65535) As _Unsigned Integer
Dim io As _Unsigned Integer
Dim PStack(0 To 255) As _Unsigned Integer
Dim Stack(0 To 255) As _Unsigned _Byte

'Some Registers 4x8bits, 4x16bits
Dim A As _Unsigned _Byte
Dim X As _Unsigned _Byte
Dim Y As _Unsigned _Byte
Dim Z As _Unsigned _Byte
Dim IA As _Unsigned Integer
Dim IX As _Unsigned Integer
Dim IY As _Unsigned Integer
Dim IZ As _Unsigned Integer

irq_vector = 65280
brk_vector = 65024
rst_vector = 0

'For Debuging Purpose...
' sstep = 0 RUN FULL; sstep = 1 single step; sstep = 2 show cpu info ; sstep= 3 run slower ; sstep= 4 slower with info
sstep = 2

GoSub cold_restart

'Prof of concept Hello World program for our CPU to execute
ram(0) = 4 '             ' lda $00
ram(1) = 0 '             ' -> high byte
ram(2) = 5 '             ' ldx $80
ram(3) = 128 '           ' -> low byte
ram(4) = 8 '             ' taxia -> a and x to IA as string pointer
ram(5) = 7 '             ' ldz $00
ram(6) = 0 '             ' -> z will be our counter
ram(7) = 2 '             '  out $02
ram(8) = 2 '             ' -> IO port 2 is char out
ram(9) = 79 '            ' inia -> increment string pointer
ram(10) = 27 '           ' inz -> increment our counter
ram(11) = 44 '           ' cpz $0C
ram(12) = 13 '           ' -> compare z to $0C (13 in decimal, that is the number of character in our string)
ram(13) = 72 '           ' bne $0007
ram(14) = 0 '            ' -> not equal we loop to $0007
ram(15) = 7 '            ' -> otherwise we are done
ram(16) = 80 '           ' cle -> clear the equal flag
ram(17) = 68 '           ' jmp $0100
ram(18) = 1 '            ' -> jump somewhere after the string
ram(19) = 0 '            ' -> so we can let the CPU cycle over all the nop instruction in RAM before repeating our program
ram(128) = Asc("h") '    ' This is our string char 1
ram(129) = Asc("e") '    ' This is our string char 2
ram(130) = Asc("l") '    ' This is our string char 3
ram(131) = Asc("l") '    ' This is our string char 4
ram(132) = Asc("o") '    ' This is our string char 5
ram(133) = Asc(" ") '    ' This is our string char 6
ram(134) = Asc("w") '    ' This is our string char 7
ram(135) = Asc("o") '    ' This is our string char 8
ram(136) = Asc("r") '    ' This is our string char 9
ram(137) = Asc("l") '    ' This is our string char 10
ram(138) = Asc("d") '    ' This is our string char 11
ram(139) = Asc("!") '    ' This is our string char 12
ram(140) = Asc(Chr$(13)) ' This is our string char 13 (carriage return)
ram(141) = Asc("i") '    ' This is only reached when irq happend
ram(65020) = 89 '        ' set interupt
ram(65021) = 68 '        ' jmp $0000  <= return from interupt here and jump back to $0000 to avoid brk_vector execution
ram(65022) = 0 '         '
ram(65023) = 0 '         '
ram(65024) = 3 '         ' HLT  (this is our brk_vector, it activate with F2 key, in this case we use it to HALT the cpu & end the emulation)
ram(65280) = 2 '         ' IO 2 is char out (if an interupt occurs output i, we end here when interrupt is set)
ram(65281) = 2 '         '
ram(65282) = 79 '        ' increment ia
ram(65284) = 90 '        ' rti

'This is our CPU main loop

While PC <= 65535
    On Key(1) GoSub warm_restart
    On Key(2) GoSub brk
    Key(1) On
    Key(2) On
    If intq = 1 Then intq = 0: GoSub irq

    opcode = ram(PC)
    ' NOP, IN ia, OUT ia, HALT
    If opcode = 0 Then GoSub nop
    If opcode = 1 Then GoSub in
    If opcode = 2 Then GoSub ou
    If opcode = 3 Then GoSub halt
    ' LOAD immediate 8 bits
    If opcode = 4 Then GoSub lda_i
    If opcode = 5 Then GoSub ldx_i
    If opcode = 6 Then GoSub ldy_i
    If opcode = 7 Then GoSub ldz_i
    ' 8bits pair <=> 16bits
    If opcode = 8 Then GoSub taxia
    If opcode = 9 Then GoSub tyzix
    If opcode = 10 Then GoSub taxiy
    If opcode = 11 Then GoSub tyziz
    If opcode = 12 Then GoSub iaxat
    If opcode = 13 Then GoSub xizyt
    If opcode = 14 Then GoSub yixat
    If opcode = 15 Then GoSub zizyt
    ' Store 8 bits, addr = IA
    If opcode = 16 Then GoSub sta
    If opcode = 17 Then GoSub stx
    If opcode = 18 Then GoSub sty
    If opcode = 19 Then GoSub stz
    ' Store 16 bits, addr = IA
    If opcode = 20 Then GoSub stix
    If opcode = 21 Then GoSub stiy
    If opcode = 22 Then GoSub stiz
    ' Store 16 bits IA, addr = IZ
    If opcode = 23 Then GoSub stia
    ' increment 8bits
    If opcode = 24 Then GoSub ina
    If opcode = 25 Then GoSub inx
    If opcode = 26 Then GoSub iny
    If opcode = 27 Then GoSub inz
    ' decrement 8bits
    If opcode = 28 Then GoSub dca
    If opcode = 29 Then GoSub dcx
    If opcode = 30 Then GoSub dcy
    If opcode = 31 Then GoSub dcz
    ' add 8 bits add sub other reg with A
    If opcode = 32 Then GoSub adx
    If opcode = 33 Then GoSub sbx
    If opcode = 34 Then GoSub ady
    If opcode = 35 Then GoSub sby
    If opcode = 36 Then GoSub adz
    If opcode = 37 Then GoSub sbz
    ' mul and div
    If opcode = 38 Then GoSub axmia
    If opcode = 40 Then GoSub iada
    ' compare imediate
    If opcode = 41 Then GoSub cpa
    If opcode = 42 Then GoSub cpx
    If opcode = 43 Then GoSub cpy
    If opcode = 44 Then GoSub cpz
    ' compare absolute via ia
    If opcode = 45 Then GoSub cpaia
    If opcode = 46 Then GoSub cpxia
    If opcode = 47 Then GoSub cpyia
    If opcode = 48 Then GoSub cpzia
    ' compare immediate indexed via ia,a
    If opcode = 49 Then GoSub cpiaa
    ' or immediate
    If opcode = 50 Then GoSub ora
    If opcode = 51 Then GoSub oria
    ' and immediate
    If opcode = 52 Then GoSub ana
    If opcode = 53 Then GoSub ania
    '    ' or reg pair
    If opcode = 54 Then GoSub orax
    If opcode = 55 Then GoSub oryz
    If opcode = 56 Then GoSub oriaix
    '    ' and reg pair
    If opcode = 57 Then GoSub anax
    If opcode = 58 Then GoSub anyz
    If opcode = 59 Then GoSub aniaix
    ' Stack push an pull
    If opcode = 60 Then GoSub pha
    If opcode = 61 Then GoSub phx
    If opcode = 62 Then GoSub phy
    If opcode = 63 Then GoSub phz
    If opcode = 64 Then GoSub pla
    If opcode = 65 Then GoSub plx
    If opcode = 66 Then GoSub ply
    If opcode = 67 Then GoSub plz
    'branching
    If opcode = 68 Then GoSub jmp
    If opcode = 69 Then GoSub jsr
    If opcode = 70 Then GoSub rts
    If opcode = 71 Then GoSub beq
    If opcode = 72 Then GoSub bne
    If opcode = 73 Then GoSub brz
    If opcode = 74 Then GoSub bnz
    If opcode = 75 Then GoSub brn
    If opcode = 76 Then GoSub bnn
    If opcode = 77 Then GoSub brk
    If opcode = 78 Then GoSub irq
    ' Increment IA
    If opcode = 79 Then GoSub inia
    ' Clear and Set Flags
    If opcode = 80 Then GoSub cle
    If opcode = 81 Then GoSub see
    If opcode = 82 Then GoSub clz
    If opcode = 83 Then GoSub sez
    If opcode = 84 Then GoSub cln
    If opcode = 85 Then GoSub sen
    If opcode = 86 Then GoSub clb
    If opcode = 87 Then GoSub seb
    If opcode = 88 Then GoSub cli
    If opcode = 89 Then GoSub sei
    ' Probably more ...
    If opcode = 90 Then GoSub rti

    ' loop the PC on overflow
    If PC >= 65535 Then PC = 0
    ' are we debuging?
    If sstep = 1 Then
        row = CsrLin ' Save current print cursor row.
        col = Pos(0) ' Save current print cursor column
        Locate 1, 1
        Print "PC= "; Hex$(PC); " A= "; Hex$(A); " X= "; Hex$(X); " Y= "; Hex$(Y); " Z= "; Hex$(Z)
        Print "IA= "; Hex$(IA); " IX= "; Hex$(IX); " IY= "; Hex$(IY); " IZ= "; Hex$(IZ); " PSP="; Hex$(PSP); " SP="; Hex$(SP); " PStack="; Hex$(PStack(PSP))
        Print " FLAGS C="; CARRY; " Z="; ZERO; "E="; EQUAL; "I="; intq; "B="; BRK; "N="; NEG
        K$ = "": While K$ = "": K$ = InKey$: Wend
        Locate row, col
    End If
    If sstep = 2 Then
        row = CsrLin ' Save current print cursor row.
        col = Pos(0) ' Save current print cursor column.
        Locate 1, 1
        Print "PC= "; Hex$(PC); " A= "; Hex$(A); " X= "; Hex$(X); " Y= "; Hex$(Y); " Z= "; Hex$(Z)
        Print "IA= "; Hex$(IA); " IX= "; Hex$(IX); " IY= "; Hex$(IY); " IZ= "; Hex$(IZ); " PSP="; Hex$(PSP); " SP="; Hex$(SP); " PStack="; Hex$(PStack(PSP))
        Print " FLAGS C="; CARRY; " Z="; ZERO; "E="; EQUAL; "I="; intq; "B="; BRK; "N="; NEG
        Locate row, col
    End If
    ' or running slower?
    If sstep = 3 Then
        For i = 0 To 5000: Next i
    End If
    If sstep = 4 Then
        row = CsrLin ' Save current print cursor row.
        col = Pos(0) ' Save current print cursor column.
        Locate 1, 1
        Print "PC= "; Hex$(PC); " A= "; Hex$(A); " X= "; Hex$(X); " Y= "; Hex$(Y); " Z= "; Hex$(Z)
        Print "IA= "; Hex$(IA); " IX= "; Hex$(IX); " IY= "; Hex$(IY); " IZ= "; Hex$(IZ); " PSP="; Hex$(PSP); " SP="; Hex$(SP); " PStack="; Hex$(PStack(PSP))
        Print " FLAGS C="; CARRY; " Z="; ZERO; "E="; EQUAL; "I="; intq; "B="; BRK; "N="; NEG
        For i = 0 To 5000: Next i
        Locate row, col
    End If
Wend
End

'This is our CPU instruction Set

nop:
PC = PC + 1
Return

in:
io = ram(PC + 1)
If io = 1 Then
    K$ = "": While K$ = "" And K$ <> Chr$(13): K$ = InKey$: Wend
    ram(IA) = Asc(K$)
    Print K$;
End If
If io = 2 Then
    ram(IA) = 0 'Unimplemented
End If
PC = PC + 2
io = 0
Return

ou:
io = ram(PC + 1)
If io = 1 Then
End If
If io = 2 Then
    s = ram(IA): Print Chr$(s);
End If
PC = PC + 2
io = 0
Return

halt:
End

lda_i:
A = ram(PC + 1)
PC = PC + 2
Return

ldx_i:
X = ram(PC + 1)
PC = PC + 2
Return

ldy_i:
Y = ram(PC + 1)
PC = PC + 2
Return

ldz_i:
Z = ram(PC + 1)
PC = PC + 2
Return

taxia:
IA = A * 256 + X
PC = PC + 1
Return

tyzix:
IX = Y * 256 + Z
PC = PC + 1
Return

taxiy:
IY = A * 256 + X
PC = PC + 1
Return

tyziz:
IZ = Y * 256 + Z
PC = PC + 1
Return

iaxat:
X = IA Mod 256
A = IA / 256
PC = PC + 1
Return

xizyt:
Z = IX Mod 256
Y = IX / 256
PC = PC + 1
Return

yixat:
X = IY Mod 256
A = IY / 256
PC = PC + 1
Return

zizyt:
Y = IZ Mod 256
Z = IZ / 256
PC = PC + 1
Return

sta:
ram(IA) = A
PC = PC + 1
Return

stx:
ram(IA) = X
PC = PC + 1
Return

sty:
ram(IA) = Y
PC = PC + 1
Return

stz:
ram(IA) = Z
PC = PC + 1
Return

stia:
ram(IZ) = IA / 256
ram(IZ + 1) = IA Mod 256
PC = PC + 1
Return

stix:
ram(IA) = IX / 256
ram(IA + 1) = IX Mod 256
PC = PC + 1
Return

stiy:
ram(IA) = IY / 256
ram(IA + 1) = IY Mod 256
PC = PC + 1
Return

stiz:
ram(IA) = IZ / 256
ram(IA + 1) = IZ Mod 256
PC = PC + 1
Return

ina:
A = A + 1
If A >= 255 Then A = A - 255: CARRY = 1
PC = PC + 1
Return

inx:
X = X + 1
If X >= 255 Then X = X - 255: CARRY = 1
PC = PC + 1
Return

iny:
Y = Y + 1
If Y >= 255 Then Y = Y - 255: CARRY = 1
PC = PC + 1
Return

inz:
Z = Z + 1
If Z >= 255 Then Z = Z - 255: CARRY = 1
PC = PC + 1
Return

dca:
A = A - 1
If A <= 0 Then A = A + 255: NEG = 1
PC = PC + 1
Return

dcx:
X = X - 1
If X <= 0 Then X = X + 255: NEG = 1
PC = PC + 1
Return

dcy:
Y = Y - 1
If Y <= 0 Then Y = Y + 255: NEG = 1
PC = PC + 1
Return

dcz:
Z = Z - 1
If Z <= 0 Then Z = Z + 255: NEG = 1
PC = PC + 1
Return

cpa:
op1 = ram(PC + 1)
If op1 = A Then EQUAL = 1
If op1 <> A Then EQUAL = 0
PC = PC + 2
Return

cpx:
op1 = ram(PC + 1)
If op1 = X Then EQUAL = 1
If op1 <> X Then EQUAL = 0
PC = PC + 2
Return

cpy:
op1 = ram(PC + 1)
If op1 = Y Then EQUAL = 1
If op1 <> Y Then EQUAL = 0
PC = PC + 2
Return

cpz:
op1 = ram(PC + 1)
If op1 = Z Then EQUAL = 1
If op1 <> Z Then EQUAL = 0
PC = PC + 2
Return

inia:
IA = IA + 1
If IA >= 65535 Then IA = 0
PC = PC + 1
Return

bne:
op1 = ram(PC + 1)
op2 = ram(PC + 2)
IZ = op1 * 256 + op2
If EQUAL = 0 Then
    PC = IZ
End If
If EQUAL = 1 Then PC = PC + 3
Return

jmp:
op1 = ram(PC + 1)
op2 = ram(PC + 2)
PC = op1 * 256 + op2
Return

adx:
X = X + A
If X >= 255 Then X = X - 255: CARRY = 1
PC = PC + 1
Return

sbx:
X = X - A
If X <= -1 Then X = X + 255: NEG = 1
PC = PC + 1
Return

ady:
Y = Y + A
If Y >= 255 Then Y = Y - 255: CARRY = 1
PC = PC + 1
Return

sby:
Y = Y - A
If Y <= -1 Then Y = Y + 255: NEG = 1
PC = PC + 1
Return

adz:
Z = Z + A
If Z >= 255 Then Z = Z - 255: CARRY = 1
PC = PC + 1
Return

sbz:
Z = Z - A
If Z <= -1 Then Z = Z + 255: NEG = 1
PC = PC + 1
Return

'mul A by x result in IA
axmia:
IA = A * X
PC = PC + 1
Return

'div IA by A result in IX
iada:
IX = IA / A
PC = PC + 1
Return

cpaia:
If ram(IA) = A Then EQUAL = 1
If ram(IA) <> A Then EQUAL = 0
PC = PC + 1
Return

cpxia:
If ram(IA) = X Then EQUAL = 1
If ram(IA) <> X Then EQUAL = 0
PC = PC + 1
Return

cpyia:
If ram(IA) = Y Then EQUAL = 1
If ram(IA) <> Y Then EQUAL = 0
PC = PC + 1
Return

cpzia:
If ram(IA) = Z Then EQUAL = 1
If ram(IA) <> Z Then EQUAL = 0
PC = PC + 1
Return

cpiaa:
op1 = ram(PC + 1)
If ram(IA + A) = op1 Then EQUAL = 1
If ram(IA + A) <> op1 Then EQUAL = 0
PC = PC + 2
Return

pha:
Stack(SP) = A
SP = SP + 1
PC = PC + 1
Return

phx:
Stack(SP) = X
SP = SP + 1
PC = PC + 1
Return

phy:
Stack(SP) = Y
SP = SP + 1
PC = PC + 1
Return

phz:
Stack(SP) = Z
SP = SP + 1
PC = PC + 1
Return

pla:
A = Stack(SP)
SP = SP - 1
PC = PC + 1
Return

plx:
X = Stack(SP)
SP = SP - 1
PC = PC + 1
Return

ply:
Y = Stack(SP)
SP = SP - 1
PC = PC + 1
Return

plz:
Z = Stack(SP)
SP = SP - 1
PC = PC + 1
Return

jsr:
op1 = ram(PC + 1)
op2 = ram(PC + 2)
addr = op1 * 256 + op2
PC = PC + 3
PStack(PSP) = PC
PSP = PSP + 1
PC = addr
Return

rts:
PC = PStack(PSP)
PStack(PSP) = 0
PSP = PSP - 1
Return

beq:
op1 = ram(PC + 1)
op2 = ram(PC + 2)
IZ = op1 * 256 + op2
If EQUAL = 1 Then
    PC = IZ
End If
If EQUAL = 0 Then PC = PC + 3
Return

brz:
op1 = ram(PC + 1)
op2 = ram(PC + 2)
IZ = op1 * 256 + op2
If ZERO = 0 Then
    PC = IZ
End If
If ZERO = 1 Then PC = PC + 3
Return

bnz:
op1 = ram(PC + 1)
op2 = ram(PC + 2)
IZ = op1 * 256 + op2
If ZERO = 1 Then
    PC = IZ
End If
If ZERO = 0 Then PC = PC + 3
Return

brn:
op1 = ram(PC + 1)
op2 = ram(PC + 2)
IZ = op1 * 256 + op2
If NEG = 0 Then
    PC = IZ
End If
If NEG = 1 Then PC = PC + 3
Return

bnn:
op1 = ram(PC + 1)
op2 = ram(PC + 2)
IZ = op1 * 256 + op2
If NEG = 1 Then
    PC = IZ
End If
If NEG = 0 Then PC = PC + 3
Return

brk:
If BRK = 1 Then PC = PC + 1
PStack(PSP) = PC
PSP = PSP + 1
PC = brk_vector
Return

irq:
PStack(PSP) = PC
PSP = PSP + 1
PC = irq_vector
Return

'This Function initialize the RAM by Zeroing it.
clr_ram:
For C = 0 To 65535
    ram(C) = 0
Next C
Return

clr_Pstack:
For C = 0 To 255
    PStack(C) = 0
Next C
Return

clr_stack:
For C = 0 To 255
    Stack(C) = 0
Next C
Return

cle:
EQUAL = 0
PC = PC + 1
Return

see:
EQUAL = 1
PC = PC + 1
Return

cli:
intq = 0
PC = PC + 1
Return

sei:
intq = 1
PC = PC + 1
Return

clz:
ZERO = 0
PC = PC + 1
Return

sez:
ZERO = 1
PC = PC + 1
Return

cln:
NEG = 0
PC = PC + 1
Return

sen:
NEG = 1
PC = PC + 1
Return

clb:
BRK = 0
PC = PC + 1

seb:
BRK = 1
PC = PC + 1
Return

ora:
result = A Or ram(PC + 1)
A = result
PC = PC + 2
Return

ana:
result = A And ram(PC + 1)
A = result
PC = PC + 2
Return

oria:
addr = ram(PC + 1) * 256 + ram(PC + 2)
result = IA Or addr
IA = result
PC = PC + 3
Return

ania:
addr = ram(PC + 1) * 256 + ram(PC + 2)
result = IA And addr
IA = result
PC = PC + 3
Return

orax:
result = A Or X
A = result
PC = PC + 1
Return

oryz:
result = Y Or Z
A = result
PC = PC + 1
Return

oriaix:
result = IA Or IX
IA = result
PC = PC + 1
Return

anax:
result = A And X
A = result
PC = PC + 1
Return

anyz:
result = Y And Z
A = result
PC = PC + 1
Return

aniaix:
result = IA And IX
IA = result
Return

rti:
GoSub cli
GoSub rts
Return

'This clear the registers, and flags
clr_regf:
'Registers
' Accumulators  8bits, 16bits
A = 0
IA = 0
' 8 bits
X = 0
Y = 0
Z = 0
' 16 bits
IX = 0
IY = 0
IZ = 0
'Specials (Program counter, Program Stack Pointer, Stack Pointer)
PC = rst_vector
PSP = 0
SP = 0
'FLAGS
BRK = 0
NEG = 0
ZERO = 0
CARRY = 0
EQUAL = 0
intq = 0
col = 1
Return

'This is a cold start or hard reset (clear the ram, registers, Program Stack and Stack)
cold_restart:
Cls
If sstep = 0 Then row = 1
If sstep = 1 Then row = 4
If sstep = 2 Then row = 4
If sstep = 3 Then row = 1
If sstep = 4 Then row = 4
'LOCATE row, col
GoSub clr_regf
GoSub clr_Pstack
GoSub clr_stack
GoSub clr_ram
Return

'This is a warm start or soft reset (only clean registers and flags, Program Stack but not Stack)
warm_restart:
Cls
If sstep = 0 Then row = 1
If sstep = 1 Then row = 4
If sstep = 2 Then row = 4
If sstep = 3 Then row = 1
If sstep = 4 Then row = 4
'LOCATE row, col
GoSub clr_regf
GoSub clr_Pstack
Return

