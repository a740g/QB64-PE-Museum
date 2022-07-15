'QB45BIN.BAS - written by qarnos
'Used by permission: http://www.qb64.net/forum/index.php?topic=1771.msg16215#msg16215
'Command line interface adapted by FellippeHeitor

Rem $DYNAMIC

DefInt A-Z
'----------------------------------------------------------------------------
' Used for sorting alphabetically.
'----------------------------------------------------------------------------
Dim Shared QBBinProcedureIndex As String

'----------------------------------------------------------------------------
' Internal constants used by parse rule decoder
'----------------------------------------------------------------------------
Const TagType.Recursive = 1
Const TagType.TokenData = 2
Const TagType.StackABS = 3
Const TagType.StackREL = 4

'----------------------------------------------------------------------------
' Constants returned by the Meta field of QBBinReadLine. I will probably
' use the high 16-bits for flags, so best to mask them out for now.
'----------------------------------------------------------------------------
Const QBBinMeta.SUB = 1
Const QBBinMeta.FUNCTION = 2

'----------------------------------------------------------------------------
' Not yet used since it only supports QB45 atm.
'----------------------------------------------------------------------------
Const QBBinFileMode.QB45 = 1

'----------------------------------------------------------------------------
' Option variable declarations
'----------------------------------------------------------------------------
Dim Shared QBBinOption.OmitIncludedLines As Integer
Dim Shared QBBinOption.SortProceduresAZ As Integer

'----------------------------------------------------------------------------
' Option variable initialisation
'----------------------------------------------------------------------------
QBBinOption.OmitIncludedLines = -1
QBBinOption.SortProceduresAZ = -1

'----------------------------------------------------------------------------
' Errors only half-implemented so far.
'----------------------------------------------------------------------------
Const QBErrBadFormat = 255
Const QBErrBadToken = 254
Const QBErrInsane = 253

'----------------------------------------------------------------------------
' You may use QBBinEOF, for now, to determine when EOF has been reached.
' QBBinDefType contains the current DEFxxx setting for each letter of the
' alphabet (1 = INT, 2 = LNG, 3 = SNG, 4 = DBL, 5 = STR).
'----------------------------------------------------------------------------
Dim Shared QBBinDefType(1 To 26) As Integer
Dim Shared QBBinLineReady As Integer ' get rid of this
Dim Shared QBBinProgramLine As String ' and this
Dim Shared QBBinFile As Integer
Dim Shared QBBinEOF As Integer

'----------------------------------------------------------------------------
' A hash table is used for symbols defined in the parse rules. There aren't
' many of them, so a small table will do.
'----------------------------------------------------------------------------
Const SymbolHashBuckets = 43
Dim Shared SymbolHashTable(0 To SymbolHashBuckets - 1) As String
Dim Shared SymbolHashEntries As Integer

'----------------------------------------------------------------------------
' Not worth commenting on... oops.
'----------------------------------------------------------------------------
Dim Shared TypeSpecifiers(0 To 5, 1 To 3) As String
Dim Shared ParseRules(0) As String

'----------------------------------------------------------------------------
' We don't need a very big stack. I haven't seen it go beyond 8 or 9 entries
' so 255 is plenty. Also, STACK(0) is a special entry. IF SP = 0 then there
' is nothing on the stack.
'----------------------------------------------------------------------------
Dim Shared STACK(0 To 255) As String
Dim Shared SP As Integer

'----------------------------------------------------------------------------
' Define global symbol table, code space and instruction pointer
'----------------------------------------------------------------------------
Dim Shared SYMTBL(0) As Integer
Dim Shared CODE(0) As Integer
Dim Shared IP As Long

'----------------------------------------------------------------------------
' PCODE always contains the ID of the current token (the low 10 bits of the
'       input word.
'
' HPARAM contains the high 6 bits of the input word and is used by some
'        tokens. IE: Identifiers use it for the type suffix and integers
'        smaller than 10 are encoded this way.
'
' TOKEN is a string containing the binary data for the current token (PCODE
'       and HPARAM in the first word, the rest of the data follows). All the
'       FetchXXX functions work on this variable
'----------------------------------------------------------------------------
Dim Shared PCODE As Integer
Dim Shared HPARAM As Integer
Dim Shared TOKEN As String

'----------------------------------------------------------------------------
' LastProcType is just a hack to keep track of the current SUB or FUNCTION
' status since END SUB and END FUNCTION share the same token.
'----------------------------------------------------------------------------
Dim Shared LastProcType As String ' Current procedure type
Dim Shared QBTxtFile As Integer

'----------------------------------------------------------------------------
' These variables contain the current prodecure name and type the parser
' is decoding.
'
' QBBinProcedureType = MAIN | SUB | FUNCTON | DEF
'----------------------------------------------------------------------------
Dim Shared QBBinProcedureName As String
Dim Shared QBBinProcedureType As String


'----------------------------------------------------------------------------
' Variables used to store common token codes referenced in the code. Faster
' than doing GetHashedSymbol("tokenname") every time, and flexible since the
' QB40 token codes are different from QB45.
'----------------------------------------------------------------------------
Dim Shared QBBinTok.SUBDEF As Integer
Dim Shared QBBinTok.FUNCDEF As Integer
Dim Shared QBBinTok.DEFTYPE As Integer

Dim Shared OutputContents$

$Console:Only
_Dest _Console

'----------------------------------------------------------------------------
' Initialisation will eventually be automatic in QBBinOpenFile
'----------------------------------------------------------------------------
Restore TSPECS
For i = 0 To 17: Read TypeSpecifiers(i \ 3, i Mod 3 + 1): Next i

'----------------------------------------------------------------------------
' Get file names, etc.
'----------------------------------------------------------------------------
'ON ERROR GOTO ErrorHandler

GetInputFileName:

If _CommandCount = 0 Then
    Print "QB45BIN"
    Print
    Print "Conversion utility from QuickBASIC 4.5 binary to plain text."
    Print "by qarnos"
    Print
    Print "    Syntax: QB45BIN <source.bas> [-o output.bas]"
    Print
    Print "If no output is specified, a backup file is saved and the original"
    Print "file is overwritten."
    Print
    System 1
End If

If _FileExists(Command$(1)) = 0 Then
    If InStr(InputFile$, ".") = 0 Then InputFile$ = InputFile$ + ".BAS"

    Print "File not found: "; Command$(1)
    System 1
Else
    InputFile$ = Command$(1)
End If

If LCase$(Command$(2)) = "-o" Then
    If Len(Command$(3)) Then
        OutputFile$ = Command$(3)
    End If
End If

If OutputFile$ = "" Then
    If InStr(InputFile$, "\") > 0 Or InStr(InputFile$, "/") > 0 Then
        For i = Len(InputFile$) To 1 Step -1
            If Mid$(InputFile$, i, 1) = "/" Or Mid$(InputFile$, i, 1) = "\" Then
                path$ = Left$(InputFile$, i)
                InputFile$ = Mid$(InputFile$, i + 1)
                Exit For
            End If
        Next
    End If
    OutputFile$ = path$ + InputFile$ + ".converted.bas"
End If

Print UCase$(InputFile$)

Print
Print "Loading parse rules... ";
LoadParseRules
Print "Done!": Print

QBBinOpenFile path$ + InputFile$

'---------------------------------------------------------------------------
' The main loop is pretty straight-forward these days.
'---------------------------------------------------------------------------
StartProcessing! = Timer
Do While Not QBBinEOF

    ProgramLine$ = QBBinReadLine$(Meta&)

    '-----------------------------------------------------------------------
    ' Just an example of meta-data usage. Pretty limited at the moment,
    ' but could be helpful to QB64 IDE when building SUB/FUNCTION list.
    '-----------------------------------------------------------------------
    'IF Meta& = QBBinMeta.SUB THEN PRINT "----- SUBROUTINE -----"
    'IF Meta& = QBBinMeta.FUNCTION THEN PRINT "----- FUNCTION -----"

    '-----------------------------------------------------------------------
    ' AOutput has become a pretty-print function. All program lines are now
    ' retrieved by calling QBBinReadLine.
    '-----------------------------------------------------------------------
    AOutput ProgramLine$

    'Quit after a number of seconds - likely an invalid file causing an endless loop
    Const TIMEOUT = 30
    If StartProcessing! > Timer Then StartProcessing! = StartProcessing! - 86400
    If Timer - StartProcessing! > TIMEOUT Then Print "Conversion failed.": System 1

Loop

'If we've made it this far, output the resulting file:
QBTxtFile = FreeFile
Open OutputFile$ For Binary As #QBTxtFile
Put #QBTxtFile, 1, OutputContents$
Close #QBTxtFile

Reset

Print "Finished!"

System 0

TSPECS:
Data ANY,,
Data INTEGER,INT,%
Data LONG,LNG,&
Data SINGLE,SNG,!
Data DOUBLE,DBL,#
Data STRING,STR,$


QB45TOKENS:
'
' Most of the tokens for QB45 are defined here, along with the length of the
' token (or '*' for variable length) and some parse rules.
'
' The first column determined the PCODE (the low 10 bits of the token)
' which the rule responds to. This is followed by the length of the token
' *data*, which may be omitted if the token has no data, or an asterisk to
' indicate a variable length token. Variable length tokens are always
' followed by a word indicating the length of the token.
'
' The final column is the parse rule itself. A token may have multiple
' parse rules. Multiple parse rules may be specified on a seperate line
' (without a PCODE or LENGTH field), or seperated by a pipe ('|') symbol.
'
' There is one important difference between the two methods. Some rules
' define a symbol which can be used to reference the rule, such as:
'
'   declmod::=SHARED
'
' If a pipe symbol is used, the next rule will inherit the "declmod" (or
' whatever symbol), unless it exlicitly defines it's own. Rules defined
' on seperate lines use the default symbol which, initially, is nothing, but
' may be overridden using the ".default" directive. This is only really used
' in the second half of the rule list, where almost every token is an
' expression ('expr').
'
' Rules are matched on a first-come first-served basis. The first rule which
' can be successfully applied (see below) is accepted.
'
' The rules can have {tags} embedded in them. There are basically two types
' of tags - stack and data/format tags. I will discuss them briefly here:
'
' STACK tags can take these basic forms:
'
'  {1}
'  {*:1}
'  {rulename:1}
'  {$+1}
'  {$-1}
'  {rulename:$+1}
'
' The first type will be substituded for the text located 1 item from the
' top of the parse stack. If the stack isn't that deep, it will be replaced
' with the null string.
'
' The second type is just like the first, except the rule will be rejected
' if the stack item doesn't exist.
'
' The third type will only accept a rule if the stack item at the specified
' offset is of the correct rule type. So {declmod:1} will reject the rule
' if the stack entry at offset 1 is not a "declemod". There is also a special
' rule name, "self", which always refers to the current rule.
'
' The final three forms, use the '$' symbol. This symbol refers to a
' "relative" stack offset - an offset from the deepest stack item referenced
' in a normal tag. This is really a bit of a hack, due to me trying to avoid
' writing a full LALR(1) parser! This feature is rarely used.
'
' DATA/FORMAT tags
'
' Data and format tags being with a '#', such as {#id:2}. These tags are used
' either to interpret data from the token or to generate a dynamic parse
' rule (another hack).
'
' In the case of data tokens, the number refers to the offset into the token
' data on which the tag is to work.
'
' Format tokens usually have two '#' symbols, such as {##id(decl)}. The
' extra '#' causes the parser to re-scan the tag for other tags once it
' has been subsituted, allowing these tags to generate stack tags which can
' then be parsed.
'
' See the function GetTaggedItem for a list of tag names which can be used.
'
'
'


Rem     Token   Length  Rule(s)
Rem     -------+-------+-------

Data 0x000,"newline::=.{#newline}{#tabh}"
Data 0x001,2,"newline::=.{#newline}{#tabi}"
Data 0x002,2,"newline::=.{#newline-include}"
Data 0x003,4,"newline::=.{#newline-include}{#indent:2} "
Data 0x004,4,".{#newline}{#thaddr:0}{#label:2}"
Data 0x005,6,".{#newline}{#thaddr:0}{#label:2} {#indent:4}"
Data 0x006,": "
Data 0x007,2,":{#tabi}"

'----------------------------------------------------------------------------
' 0x008 = End of procedure/module code (watch list follows)
' 0x009 = End of watch list
'----------------------------------------------------------------------------
Data 0x008,"."
Data 0x009,

Data 0x00a,*,"{#raw:2}"
Data 0x00b,2,"expr::={#id+}"
Data 0x00c,2,"consts::={const:1} {#id+} = {0}"
Data "consts::={consts:1}, {#id+} = {0}"
Data "{#id+} = {0}"
Data 0x00d,2,"decls::={decls:1}, {#id+:0} {astype:0}"
Data "decls::={decls:0}, {#id+:0}"
Data "decls::={decl:1} {#id+:0} {astype:0}"
Data "decls::={decl:0} {#id+:0}"
Data "{#id+:0} {astype:0}"
Data "{#id+:0}"
Data 0x00e,4,"expr::={##id(expr)}"
Data 0x00f,4,"{##id(expr)} = {$+0}"
Data 0x010,4,"decls::={##id(decl)}"
Data 0x011,2,"expr::={0}.{#id}"
Data 0x012,2,"{0}.{#id} = {1}"

' 0x015 = AS USERTYPE
' 0x016 = AS BUILTINTYPE?
Data 0x015,4,"astype::={#tabi:2}AS {#type:0}"
Data 0x016,4,"astype::={#tabi:2}AS {#type:0}"

' 0x017 - used for unkown type assignments?
Data 0x017,0,""

Data 0x018,""

'----------------------------------------------------------------------------
' 0x019 = user-type field declaration.
'----------------------------------------------------------------------------
Data 0x019,2,"{#id}"
Data 0x01a,"declmod::=SHARED"
Data 0x01b,6,"deftype::={#thaddr:0}{#DEFxxx}"
Data 0x01c,"{self:1}, {0}|REDIM {declmod:1} {0}|REDIM {0}"
Data 0x01d,2,"END TYPE"
Data 0x01e,2,"decl::=SHARED"
Data 0x01f,2,"decl::=STATIC"
Data 0x020,4,"TYPE {#id:2}"
Data 0x021,*,"$STATIC{#raw}"
Data 0x022,*,"$DYNAMIC{#raw}"
Data 0x023,"const::=CONST"

'----------------------------------------------------------------------------
' 0x024 = IDE breakpoint
'----------------------------------------------------------------------------
Data 0x024,

Data 0x025,"BYVAL {0}"
Data 0x026,*,"{deffn:1} = {0}"
Data 0x027,"COM({0})"
Data 0x028,2,"ON {0} GOSUB {#id}"
Data 0x029,"KEY({0})"
Data 0x02a,"{0} OFF"
Data 0x02b,"{0} ON"
Data 0x02c,"{0} STOP"
Data 0x02d,"PEN"
Data 0x02e,"PLAY"
Data 0x02f,"PLAY({0})"
Data 0x030,"SIGNAL({0})"
Data 0x031,"STRIG({0})"
Data 0x032,"TIMER"
Data 0x033,"TIMER({0})"

'----------------------------------------------------------------------------
' Labels used in $INCLUDEd lines
'----------------------------------------------------------------------------
Data 0x034,4,"newline::={#thaddr:0}{#label:2} "
Data 0x035,6,"newline::={#thaddr:0}{#label:2} {#indent:4}"

Data 0x037,4,"CALL {#id:2}{##call()}"
Data 0x038,4,"{#id:2}{##call}"
Data 0x039,4,"CALLS {#id:2}{##call()}"
Data 0x03a,"CASE ELSE"
Data 0x03b,"case::={case:1}, {0}|CASE {0}"
Data 0x03c,"case::={case:2}, {1} TO {0}|CASE {1} TO {0}"
Data 0x03d,"case::={case:1}, IS = {0}|CASE IS = {0}"
Data 0x03e,"case::={case:1}, IS < {0}|CASE IS < {0}"
Data 0x03f,"case::={case:1}, IS > {0}|CASE IS > {0}"
Data 0x040,"case::={case:1}, IS <= {0}|CASE IS <= {0}"
Data 0x041,"case::={case:1}, IS >= {0}|CASE IS >= {0}"
Data 0x042,"case::={case:1}, IS <> {0}|CASE IS <> {0}"

Data 0x043,"ON"
Data 0x044,*,"DECLARE {#procdecl()}"
Data 0x045,*,"deffn::={#procdecl:2}"
Data 0x046,"DO"
Data 0x047,"DO UNTIL {0}"
Data 0x048,2,"DO WHILE {0}"
Data 0x049,2,"{newline:0}ELSE | ELSE "

' 0x04a = implicit GOTO linenumber used in 0x04c ELSE
Data 0x04a,2,"{#id}"
Data 0x04c," ELSE "

Data 0x04d,2,"ELSEIF {0} THEN"
Data 0x04e,"END"
Data 0x04f,*,"END DEF"
Data 0x050,"END IF"
Data 0x051,"END {#proctype}"
Data 0x052,"END SELECT"
Data 0x053,2,"EXIT DO"
Data 0x054,2,"EXIT FOR"
Data 0x055,2,"EXIT {#proctype}"
Data 0x056,4,"FOR {2} = {1} TO {0}"
Data 0x057,4,"FOR {3} = {2} TO {1} STEP {0}"
Data 0x058,*,"funcdef::={#procdecl}"
Data 0x059,2,"GOSUB {#id}"
'       0x05a   2,      "GOSUB {#id}"
Data 0x05b,2,"GOTO {#id}"
'       0x05c   2,      "GOTO {#id}"
Data 0x05d,2,"IF {0} THEN "
Data 0x05e,2,"IF {0} THEN {#id}"
'       0x05f,  2,      "IF {0} THEN "
Data 0x060,2,"IF {0} GOTO {#id}"
Data 0x061,2,"IF {0} THEN"
Data 0x062,2,"LOOP"
Data 0x063,2,"LOOP UNTIL {0}"
Data 0x064,2,"LOOP WHILE {0}"
Data 0x065,4,"NEXT"
Data 0x066,4,"{self:1}, {0}|NEXT {0}"
Data 0x067,2,"ON ERROR GOTO {#id}"
Data 0x068,*,"ON {0} GOSUB {#id-list}"
Data 0x069,*,"ON {0} GOTO {#id-list}"
Data 0x06a,"RESTORE"
Data 0x06b,2,"RESTORE {#id}"
Data 0x06c,"RESUME"
Data 0x06d,2,"RESUME {#id}"
Data 0x06e,"RESUME NEXT"
Data 0x06f,"RETURN"
Data 0x070,2,"RETURN {#id}"
Data 0x071,"RUN {0}"
Data 0x072,2,"RUN {#id}"
Data 0x073,"RUN"
Data 0x074,2,"SELECT CASE {0}"
Data 0x075,2,"STOP"
Data 0x076,*,"subdef::={#procdecl}"
Data 0x077,"WAIT {1}, {0}"
Data 0x078,"WAIT {2}, {1}, {0}"
Data 0x079,2,"WEND"
Data 0x07a,2,"WHILE {0}"

'----------------------------------------------------------------------------
' 0x07b used in IDE watch mode. Probably 0x07c, too.
'----------------------------------------------------------------------------
Data 0x07b,
Data 0x07c,

Data 0x07d,"prnmod::={prnmod:1} {0},|PRINT {0},"

'----------------------------------------------------------------------------
' 3 dummy tokens used in LINE statements
'----------------------------------------------------------------------------
Data 0x07e,"{0}"
Data 0x07f,"{0}"
Data 0x080,"{0}"

'----------------------------------------------------------------------------
' graphics co-ordinates
'----------------------------------------------------------------------------
Data 0x081,"1st-coord::=({1}, {0})"
Data 0x082,"1st-coord::=STEP({1}, {0})"
Data 0x083,"{1st-coord:2}-({1}, {0})|({1}, {0})"
Data 0x084,"{1st-coord:2}-STEP({1}, {0})|-STEP({1}, {0})"

Data 0x085,"FIELD {0}"
Data 0x086,", {1} AS {0}"
Data 0x087,"finput::=INPUT {0},"
Data 0x088,"{input:1} {inputs:0}"
Data 0x089,*,"input::=INPUT {##input-args}"
Data 0x08a,"#{0}"

'----------------------------------------------------------------------------
' These two consume data, but I have no idea what they do. I haven't seen
' one in the wild.
'----------------------------------------------------------------------------
Data 0x08c,2,""
'       0x08d,  4,      ""

'----------------------------------------------------------------------------
' Most of the PRINT stuff is here. The rules are pretty finicky. These
' sequences also apply to LPRINT and WRITE.
'----------------------------------------------------------------------------
Data 0x08f,"prnsmc::={self|prncma|prnsrl:1} SPC({0});"
Data "prnsmc::=SPC({0});"
Data 0x090,"prnsmc::={self|prncma|prnsrl:1} TAB({0});"
Data "prnsmc::=TAB({0});"

Data 0x091,"prncma::={self|prnsmc|prnsrl:0} ,|,"

Data 0x092,"prnsmc::={self:0}|{prncma|prnsrl:0} ;|;"

Data 0x093,"{prnmod:2} {prnuse:1} {prnsrl|prnsmc|prncma:0}"
Data "{prnmod:1} {prnsrl|prnsmc|prncma:0}"
Data "{prnmod:1} {prnuse:0}"
Data "{prnmod:1}"
Data "PRINT {prnuse:1} {prnsrl|prnsmc|prncma:0}"
Data "PRINT {prnsrl|prnsmc|prncma:0}"
Data "PRINT {prnuse:0}"
Data "PRINT"

Data 0x094,"prnsrl::={prncma|prnsmc|self:1} {expr:0},|{expr:0},"
Data 0x095,"prnsrl::={prncma|prnsmc|self:1} {expr:0};|{expr:0};"

Data 0x096,"{prnmod:3} {prnuse:2} {prnsmc|prncma|prnsrl:1} {expr:0}"
Data "{prnmod:2} {prnsmc|prncma|prnsrl:1} {expr:0}"
Data "{prnmod:1} {prnsmc|prncma|prnsrl|expr:0}"
Data "PRINT {prnuse:2} {prnsmc|prncma|prnsrl:1} {expr:0}"
Data "PRINT {prnsmc|prncma|prnsrl:1} {expr:0}"
Data "PRINT {prnsmc|prncma|prnsrl|expr:0}"


Data 0x097,*,"{#tabi:0}'{#raw:2}"
'       0x098           nothing?
Data 0x099,*,"$INCLUDE: '{#raw:0}"
Data 0x09a,"BEEP"
Data 0x09b,"BLOAD {0}"
Data 0x09c,"BLOAD {1}, {0}"
Data 0x09d,"BSAVE {2}, {1}, {0}"
Data 0x09e,"CHDIR {0}"
Data 0x09f,"CIRCLE {##circle-args}"
Data 0x0a0,"CIRCLE {##circle-args}"
Data 0x0a1,2,"CLEAR{##varargs}"
Data 0x0a2,2,"CLOSE{##varargs}"
Data 0x0a3,"CLS {expr:0}|CLS "
Data 0x0a4,2,"COLOR{##varargs}"

Data 0x0a5,4,"decl::=COMMON {declmod:0}{#blockname:2}"
Data "decl::=COMMON{#blockname:2}"

Data 0x0a6,*,"DATA{#cstr:2}"
Data 0x0a7,"DATE$ = {0}"
Data 0x0a8,"DEF SEG"
Data 0x0a9,"DEF SEG = {0}"

Data 0x0aa,"DRAW {0}"
Data 0x0ab,"ENVIRON {0}"
Data 0x0ac,2,"ERASE{##varargs}"
Data 0x0ad,"ERROR {0}"
Data 0x0ae,"FILES"
Data 0x0af,"FILES {0}"

Data 0x0b0,"GET {0}"
Data 0x0b1,"GET {1}, {0}"
Data 0x0b2,2,"GET {1}, , {0}"
Data 0x0b3,2,"GET {2}, {1}, {0}"
Data 0x0b4,"GET {1}, {0}"
Data 0x0b5,2,"PUT {1}, {0}, {#action-verb}"


Data 0x0b6,"inputs::={inputs:1}, {0}|{0}"
Data 0x0b7,"IOCTL {1}, {0}"
Data 0x0b8,2,"KEY {#keymode}"
Data 0x0b9,"KEY {1}, {0}"
Data 0x0ba,"KILL {0}"
Data 0x0bb,2,"LINE {##line-args}"
Data 0x0bc,2,"LINE {##line-args}"
Data 0x0bd,2,"LINE {##line-args}"
Data 0x0be,2,"LINE {##line-args}"
Data 0x0bf,"LET "

Data 0x0c0,2,"input::=LINE {finput:1} {0}"
Data "input::=LINE INPUT {##input-args} {0}"

Data 0x0c1,2,"LOCATE{##varargs}"
Data 0x0c2,2,"LOCK {##lock-args}"
Data 0x0c3,"prnmod::=LPRINT"
Data 0x0c4,"LSET {0} = {1}"
Data 0x0c5,"MID$({0}, {2}) = {1}"
Data 0x0c6,"MID$({0}, {3}, {2}) = {1}"
Data 0x0c7,"MKDIR {0}"
Data 0x0c8,"NAME {1} AS {0}"

Data 0x0c9,2,"OPEN {1} {#open-args} AS {0}"
Data 0x0ca,2,"OPEN {2} {#open-args} AS {1} LEN = {0}"
Data 0x0cb,"OPEN {2}, {1}, {0}"
Data 0x0cc,"OPEN {3}, {2}, {1}, {0}"
Data 0x0cd,"OPTION BASE 0"
Data 0x0ce,"OPTION BASE 1"
Data 0x0cf,"OUT {1}, {0}"



Data 0x0d0,"PAINT {2}{nularg:1}{nularg:0}"
Data "PAINT {2}, {nularg:1}, {0}"
Data "PAINT {2}, {1}{nularg:0}"
Data "PAINT {2}, {1}, {0}"
Data 0x0d1,"PAINT {3}, {2}, {1}, {0}"
Data 0x0d2,"PALETTE"
Data 0x0d3,"PALETTE {1}, {0}"
Data 0x0d4,"PALETTE {0}"
Data 0x0d5,"PCOPY {1}, {0}"
Data 0x0d6,"PLAY {0}"

Data 0x0d7,"POKE {1}, {0}"
Data 0x0d8,"PRESET {0}"
Data 0x0d9,"PRESET {0}, {1}"
Data 0x0da,"PSET {0}"
Data 0x0db,"PSET {1}, {0}"
Data 0x0dd,"PUT {1}, {0}"
Data 0x0de,2,"PUT {1}, , {0}"
Data 0x0df,2,"PUT {2}, {1}, {0}"

Data 0x0e0,"RANDOMIZE"
Data 0x0e1,"RANDOMIZE {0}"
Data 0x0e2,"{self:1}, {0}|READ {0}"
Data 0x0e3,*,"REM{#raw}"
Data 0x0e4,"RESET"
Data 0x0e5,"RMDIR {0}"
Data 0x0e6,"RSET {0} = {1}"

Data 0x0e7,2,"SCREEN{##varargs}"
Data 0x0e8,"SEEK {1}, {0}"
Data 0x0e9,"SHELL"
Data 0x0ea,"SHELL {0}"
Data 0x0eb,"SLEEP"
Data 0x0ec,"SOUND {1}, {0}"
Data 0x0ed,2,"SWAP {1}, {0}"
Data 0x0ee,"SYSTEM"
Data 0x0ef,"TIME$ = {0}"
Data 0x0f0,"TROFF"
Data 0x0f1,"TRON"
Data 0x0f2,2,"UNLOCK {##lock-args}"
Data 0x0f3,"VIEW ({5}, {4})-({3}, {2}){nularg:1}{nularg:0}"
Data "VIEW ({5}, {4})-({3}, {2}), {nularg:1}, {0}"
Data "VIEW ({5}, {4})-({3}, {2}), {1}{nularg:0}"
Data "VIEW ({5}, {4})-({3}, {2})"
Data 0x0f4,"VIEW"

Data 0x0f5,"VIEW PRINT"
Data 0x0f6,"VIEW PRINT {1} TO {0}"

Data 0x0f7,"VIEW SCREEN ({5}, {4})-({3}, {2}){nularg:1}{nularg:0}"
Data "VIEW SCREEN ({5}, {4})-({3}, {2}), {nularg:1}, {0}"
Data "VIEW SCREEN ({5}, {4})-({3}, {2}), {1}{nularg:0}"
Data "VIEW SCREEN ({5}, {4})-({3}, {2})"
Data 0x0f8,"WIDTH {1}{nularg:0}|WIDTH {1}, {0}"
Data 0x0f9,"WIDTH LPRINT {0}"
Data 0x0fa,"WIDTH {1}, {0}"
Data 0x0fb,"WINDOW ({3}, {2})-({1}, {0})"
Data 0x0fc,"WINDOW"
Data 0x0fd,"WINDOW SCREEN ({3}, {2})-({1}, {0})"
Data 0x0fe,"prnmod::=WRITE"
Data 0x0ff,"prnuse::=USING {0};"

Data .default expr

Data 0x100,"{1} + {0}"
Data 0x101,"{1} AND {0}"
Data 0x102,"{1} / {0}"
Data 0x103,"{1} = {0}"
Data 0x104,"{1} EQV {0}"
Data 0x105,"ABS({0})"
Data 0x106,"ASC({0})"
Data 0x107,"ATN({0})"
Data 0x108,"C{#type-abbr}({0})"
Data 0x109,"CHR$({0})"
Data 0x10a,"COMMAND$"
Data 0x10b,"COS({0})"
Data 0x10c,"CSRLIN"
Data 0x10d,"CVD({0})"
Data 0x10e,"CVDMBD({0})"
Data 0x10f,"CVI({0})"
Data 0x110,"CVL({0})"
Data 0x111,"CVS({0})"
Data 0x112,"CVSMBF({0})"
Data 0x113,"DATE$"
Data 0x114,"ENVIRON$({0})"
Data 0x115,"EOF({0})"
Data 0x116,"ERDEV"
Data 0x117,"ERDEV$"
Data 0x118,"ERL"
Data 0x119,"ERR"
Data 0x11a,"EXP({0})"
Data 0x11b,"FILEATTR({1}, {0})"
Data 0x11c,"FIX({0})"
Data 0x11d,"FRE({0})"
Data 0x11e,"FREEFILE"
Data 0x11f,"HEX$({0})"
Data 0x120,"INKEY$"
Data 0x121,"INP({0})"
Data 0x122,"INPUT$({0})"
Data 0x123,"INPUT$({1}, {0})"
Data 0x124,"INSTR({1}, {0})"
Data 0x125,"INSTR({2}, {1}, {0})"
Data 0x126,"INT({0})"
Data 0x127,"IOCTL$({0})"
Data 0x128,"LBOUND({0})"
Data 0x129,"LBOUND({1}, {0})"
Data 0x12a,"LCASE$({0})"
Data 0x12b,"LTRIM$({0})"
Data 0x12c,"LEFT$({1}, {0})"
Data 0x12d,2,"LEN({0})"
Data 0x12e,"LOC({0})"
Data 0x12f,"LOF({0})"
Data 0x130,"LOG({0})"
Data 0x131,"LPOS({0})"
Data 0x132,"MID$({1}, {0})"
Data 0x133,"MID$({2}, {1}, {0})"
Data 0x134,"MKD$({0})"
Data 0x135,"MKDMBF$({0})"
Data 0x136,"MKI$({0})"
Data 0x137,"MKL$({0})"
Data 0x138,"MKS$({0})"
Data 0x139,"MKSMBF({0})"
Data 0x13a,"OCT$({0})"
Data 0x13b,"PEEK({0})"
Data 0x13c,"PEN"
Data 0x13d,"PLAY"
Data 0x13e,"PMAP({1}, {0})"
Data 0x13f,"POINT({0})"
Data 0x140,"POINT({1}, {0})"
Data 0x141,"POS({0})"
Data 0x142,"RIGHT$({1}, {0})"
Data 0x143,"RND"
Data 0x144,"RND({0})"
Data 0x145,"RTRIM$({0})"
Data 0x146,"SADD({0})"
Data 0x147,"SCREEN({1}, {0})"
Data 0x148,"SCREEN({2}, {1}, {0})"
Data 0x149,"SEEK({0})"
Data 0x14a,"SETMEM({0})"
Data 0x14b,"SGN({0})"
Data 0x14c,"SHELL({0})"
Data 0x14d,"SIN({0})"
Data 0x14e,"SPACE$({0})"
Data 0x14f,"SQR({0})"
Data 0x150,"STICK({0})"
Data 0x151,"STR$({0})"
Data 0x152,"STRIG({0})"
Data 0x153,"STRING$({1}, {0})"
Data 0x154,"TAN({0})"
Data 0x155,"TIME$"
Data 0x156,"TIMER"
Data 0x157,"UBOUND({0})"
Data 0x158,"UBOUND({1}, {0})"
Data 0x159,"UCASE$({0})"
Data 0x15a,"VAL({0})"
Data 0x15b,"VARPTR({0})"
Data 0x15c,2,"VARPTR$({0})"
Data 0x15d,"VARSEG({0})"
Data 0x15e,"{1} >= {0}"
Data 0x15f,"{1} > {0}"
Data 0x160,"{1} \ {0}"
Data 0x161,"{1} IMP {0}"
Data 0x162,"{1} <= {0}"
Data 0x163,"{1} < {0}"
Data 0x164,"{#hprm}"
Data 0x165,2,"{#int}"
Data 0x166,4,"{#lng}"
Data 0x167,2,"{#int&h}"
Data 0x168,4,"{#lng&h}"
Data 0x169,2,"{#int&o}"
Data 0x16a,4,"{#lng&o}"
Data 0x16b,4,"{#sng}"
Data 0x16c,8,"{#dbl}"
Data 0x16d,*,"{#qstr}"
Data 0x16e,"({0})"
Data 0x16f,"{1} MOD {0}"
Data 0x170,"{1} * {0}"
Data 0x171,"{1} <> {0}"
Data 0x172,"{#nul}"
Data 0x173,"nularg::={#nul}"
Data 0x174,"NOT {0}"
Data 0x175,"{1} OR {0}"
Data 0x176,"{1} ^ {0}"
Data 0x177,"{1} - {0}"
Data 0x178,"-{0}"
Data 0x179,"{1} XOR {0}"

Data .default

Data 0x17a,"UEVENT"
Data 0x17b,"SLEEP {0}"
Data 0x17c,6,"astype::={#tabi:4}AS STRING * {#int:2}"
Data 0x17d,2,"decl::=DIM {declmod:0}|DIM"

Data .

Rem $STATIC
'
' This subroutine is called whenever a program line has been decoded.
'
Sub AOutput (ProgramLine As String)

    Static OutputLines

    OutputLines = OutputLines + 1

    If Len(OutputContents$) Then
        OutputContents$ = OutputContents$ + Chr$(10) + ProgramLine
    Else
        OutputContents$ = ProgramLine
    End If

End Sub

Sub DbgOutput (DbgTxt As String)

    Exit Sub

    Print #5, DbgTxt

End Sub

Function DbgPlainText$ (Txt2$)

    Txt$ = Txt2$

    Do
        Marker = InStr(Txt$, MKL$(0))
        If Marker = 0 Then Exit Do

        TagTxtLen = CVI(Mid$(Txt$, Marker + 4, 2))
        TagParam = CVI(Mid$(Txt$, Marker + 6, 2))
        TagTxt$ = Mid$(Txt$, Marker + 8, TagTxtLen)

        TagParam$ = ITOA(TagParam)
        If TagParam > 0 Then TagParam$ = "+" + TagParam$
        TagParam$ = "$" + TagParam$
        If TagTxt$ <> "" Then TagParam$ = TagTxt$ + ":" + TagParam$


        Txt$ = Left$(Txt$, Marker - 1) + "{" + TagParam$ + "}" + Mid$(Txt$, Marker + 8 + TagTxtLen)

    Loop


    Do
        Marker = InStr(Txt$, Chr$(&HD))
        If Marker = 0 Then Exit Do

        If CVI(Mid$(Txt$, Marker, 2)) = &HD Then
            Txt$ = Left$(Txt$, Marker - 1) + "®newline¯" + Mid$(Txt$, Marker + 2)
        ElseIf CVI(Mid$(Txt$, Marker, 2)) = &H10D Then
            Txt$ = Left$(Txt$, Marker - 1) + "®indent¯" + Mid$(Txt$, Marker + 4)
        Else
            Txt$ = Left$(Txt$, Marker - 1) + "®rle¯" + Mid$(Txt$, Marker + 3)
        End If

    Loop

    DbgPlainText$ = Txt$

End Function

'
' Iterates through the various rules for a token contained in the ParseRules
' array and stops when one of them works.
'
Sub DefaultParseRule

    Dim ParseRule As String

    If PCODE < LBound(ParseRules) Or PCODE > UBound(ParseRules) Then Exit Sub
    ParseRule = ParseRules(PCODE)

    If ParseRule = "" Then Exit Sub

    DbgOutput ""
    DbgOutput "PCODE = 0x" + Hex$(PCODE)
    DbgOutput "HPARAM = 0x" + Hex$(HPARAM)
    DbgOutput ""
    'DumpStack

    For RuleBegin = 3 To Len(ParseRule) Step 4

        RuleLn = CVI(Mid$(ParseRule, RuleBegin + 0, 2))
        RuleID = CVI(Mid$(ParseRule, RuleBegin + 2, 2))

        RuleTxt$ = Mid$(ParseRule, RuleBegin + 4, RuleLn)

        If ExecuteParseRule(RuleID, RuleTxt$) Then Exit For

        RuleBegin = RuleBegin + RuleLn

    Next RuleBegin

End Sub

'
' Returns the string of the first rule in a compound|parse|rule, and removes
' it from the input string.
'
' If the rule does not have a rule id (ident::=), DefaultRuleID is assigned.
'
Function DelimitParseRule$ (ParseRule As String, DefaultRuleID As String)

    Dim FirstRule As String

    '----------------------------------------------------------------------------
    ' Locate the first instance of the rule delimiter "|" that does not occur
    ' inside a rule {tag}
    '----------------------------------------------------------------------------
    RuleOffset = 1
    RuleEnd = Len(ParseRule) + 1

    Do

        BraceOffset = InStr(RuleOffset, ParseRule, "{")
        If BraceOffset = 0 Then BraceOffset = RuleEnd

        PipeOffset = InStr(RuleOffset, ParseRule, "|")

        RuleOffset = InStr(BraceOffset, ParseRule, "}")
        If RuleOffset = 0 Then RuleOffset = RuleEnd

    Loop Until PipeOffset < BraceOffset

    If PipeOffset = 0 Then PipeOffset = RuleEnd


    '----------------------------------------------------------------------------
    ' Extract the first rule and return if there is nothing left.
    '----------------------------------------------------------------------------
    FirstRule = Left$(ParseRule, PipeOffset - 1)
    ParseRule = Mid$(ParseRule, PipeOffset + 1)


    '----------------------------------------------------------------------------
    ' If the first rule has a symbol on the left-hand side and the next rule
    ' does not, the next rule inherits the symbol.
    '----------------------------------------------------------------------------
    RuleLHS$ = GetParseRuleLHS(FirstRule)

    If RuleLHS$ = "" And DefaultRuleID <> "" Then
        RuleLHS$ = DefaultRuleID
        FirstRule = DefaultRuleID + "::=" + FirstRule
    End If

    DelimitParseRule = FirstRule
    If ParseRule = "" Then Exit Function

    If RuleLHS$ <> "" And GetParseRuleLHS(ParseRule) = "" Then
        ParseRule = RuleLHS$ + "::=" + ParseRule
    End If

End Function

'
' For debugging only
'
Sub DumpStack

    Print #5, "The stack has"; SP; "entries"

    For i = 1 To SP
        ID = CVI(Left$(STACK(i), 2))
        Txt$ = Mid$(STACK(i), 3)


        Do
            Marker = InStr(Txt$, Chr$(&HD))
            If Marker = 0 Then Exit Do

            If CVI(Mid$(Txt$, Marker, 2)) = &HD Then
                Txt$ = Left$(Txt$, Marker - 1) + "®newline¯" + Mid$(Txt$, Marker + 2)
            ElseIf CVI(Mid$(Txt$, Marker, 2)) = &H10D Then
                Txt$ = Left$(Txt$, Marker - 1) + "®indent¯" + Mid$(Txt$, Marker + 4)
            Else
                Txt$ = Left$(Txt$, Marker - 1) + "®rle¯" + Mid$(Txt$, Marker + 3)
            End If

        Loop

        Print #5, ITOA$(i); ": 0x"; Hex$(ID),

        TRIM = 76 - Pos(0) - Len(Txt$)
        If TRIM < 0 Then Print #5, Left$(Txt$, Len(Txt$) + TRIM); " ..." Else Print #5, Txt$
        '80-60-19=1



    Next i
End Sub

Function ExecuteParseRule% (RuleID As Integer, ParseRule As String)

    Dim RuleTxt As String
    Dim TagTxt As String
    Dim OutTxt As String

    RuleOffset = 1

    '
    ' NOTE: Since the stack is flushed immediately upon seeing a leading period,
    ' rules should not have non-flushing alternatives.
    '
    If Left$(ParseRule, 1) = "." Then
        FlushStack
        RuleOffset = 2
    End If

    InitialSP = SP
    FinalSP = SP
    RuleTxt = ParseRule

    DbgOutput "Trying rule: " + Quote(ParseRule)

    Do

        DbgOutput "Rule: " + ParseRule
        DbgOutput "Output: " + OutTxt

        TagBegin = InStr(RuleOffset, RuleTxt, "{")
        If TagBegin = 0 Then TagBegin = Len(RuleTxt) + 1

        TagEnd = InStr(TagBegin, RuleTxt, "}") + 1

        OutTxt = OutTxt + Mid$(RuleTxt, RuleOffset, TagBegin - RuleOffset)

        If TagEnd <= TagBegin Then Exit Do

        TagTxt = Mid$(RuleTxt, TagBegin + 1, TagEnd - TagBegin - 2)

        Select Case TokenizeTag(TagTxt, TagParam)

            '------------------------------------------------------------------------
            ' If a relative stack tag is used, we will need to wait until all the
            ' absolute tags have been processed before we can calculate the tag
            ' offset, so we insert a marker into OutTxt.
            '------------------------------------------------------------------------
            Case TagType.StackREL
                OutTxt = OutTxt + MKL$(0) + MKI$(Len(TagTxt)) + MKI$(TagParam) + TagTxt
                RuleOffset = TagEnd


            Case TagType.StackABS

                If Not ValidateStackTag(RuleID, TagTxt, TagParam) Then
                    ExecuteParseRule = 0
                    DbgOutput "Rule REJECTED!"
                    Exit Function
                Else
                    If OffsetSP < SP Then OutTxt = OutTxt + Mid$(STACK(SP - TagParam), 3)
                    If SP - TagParam - 1 < FinalSP Then FinalSP = SP - TagParam - 1
                End If

                RuleOffset = TagEnd


            Case TagType.Recursive
                RuleTxt = Left$(RuleTxt, TagBegin - 1) + GetTaggedItem(TagTxt, TagParam) + Mid$(RuleTxt, TagEnd)
                RuleOffset = TagBegin


            Case TagType.TokenData
                OutTxt = OutTxt + GetTaggedItem(TagTxt, TagParam)
                RuleOffset = TagEnd


        End Select




    Loop While RuleOffset <= Len(RuleTxt)

    DbgOutput "Rule: " + ParseRule
    DbgOutput "Output: " + OutTxt

    SP = FinalSP

    Do
        Marker = InStr(OutTxt, MKL$(0))
        If Marker = 0 Then Exit Do

        TagTxtLen = CVI(Mid$(OutTxt, Marker + 4, 2))
        TagParam = CVI(Mid$(OutTxt, Marker + 6, 2))
        TagTxt = Mid$(OutTxt, Marker + 8, TagTxtLen)

        If Not (ValidateStackTag(RuleID, TagTxt, TagParam)) Then
            SP = InitialSP
            ExecuteParseRule = 0
            DbgOutput "Rule REJECTED!"
            Exit Function
        End If

        OutTxt = Left$(OutTxt, Marker - 1) + Mid$(STACK(SP - TagParam), 3) + Mid$(OutTxt, Marker + 8 + TagTxtLen)
        If SP - TagParam - 1 < FinalSP Then FinalSP = SP - TagParam - 1
    Loop

    For SP = InitialSP To FinalSP + 1 Step -1: STACK(SP) = "": Next SP
    SP = FinalSP

    PUSH RuleID, OutTxt
    ExecuteParseRule = -1

    DbgOutput "Rule ACCEPTED!"

    'PCODE = RuleID

End Function

Function ExtractProgramLine% (ProgramLine As String)

End Function

'
' Generates a /blockname/ as used in COMMON statements, using the ID at
' CODE(DP)
'
Function FetchBlockName$ (DP As Integer)

    ID = FetchINT(DP)
    If ID <> -1 Then x$ = " /" + GetID(ID) + "/" Else x$ = ""

End Function

'
' Reads a null-terminate string. These are only found in DATA statements
' and the null always seems to be at the end of the string anyway, but we
' will process it properly to be sure.
'
Function FetchCSTR$ (DP As Integer)

    CSTR$ = FetchRAW(DP)

    null = InStr(CSTR$, Chr$(0))

    If null Then CSTR$ = Left$(CSTR$, null - 1)

    FetchCSTR$ = CSTR$

End Function

'
' Fetches an identifier from the current TOKEN data by performing a symbol
' table lookup on the word at the specified offset.
'
Function FetchID$ (Offset As Integer)

    FetchID$ = ""

    If Offset < 0 Or Offset > Len(TOKEN) - 4 Then Exit Function

    FetchID$ = GetID(CVI(Mid$(TOKEN, Offset + 3, 2)))

End Function

Function FetchIDList$ (DP As Integer)


    TkLen = Len(TOKEN)
    If DP < 0 Or DP > TkLen - 2 Then Exit Function

    For i = DP + 3 To TkLen - 1 Step 2

        ID$ = GetID(CVI(Mid$(TOKEN, i, 2)))

        If IdList$ <> "" Then IdList$ = IdList$ + ", "
        IdList$ = IdList$ + ID$

    Next i

    FetchIDList = IdList$

End Function

'
' Returns the integer at the specified zero-based offset from the start
' of the token data.
'
Function FetchINT% (Offset As Integer)

    FetchINT = -1

    If Offset < 0 Or Offset > Len(TOKEN) - 4 Then Exit Function

    FetchINT = CVI(Mid$(TOKEN, Offset + 3, 2))

End Function

'
' Returns the integer at the specified zero-based offset from the start
' of the token data as a LONG value.
'
Function FetchINTASLONG& (Offset As Integer)

    FetchINTASLONG = -1

    If Offset < 0 Or Offset > Len(TOKEN) - 4 Then Exit Function

    FetchINTASLONG = CVI(Mid$(TOKEN, Offset + 3, 2)) And &HFFFF&

End Function

'
' Reads a literal 64-bit float from the p-code and returns its string
' representation. Using the "{dbl}" tag in the SHIFT procedure is a more
' convienient method to extract literals.
'
' The IP is passed by reference, and will be incremented to the code
' following the literal. There is no radix option for floating point values.
'
Function FetchLiteralDBL$ (DP)

    If DP > UBound(CODE) Then
        FetchLiteralDBL$ = "0#"
        Exit Function
    End If

    Value# = CVD(Mid$(TOKEN, DP + 3, 8))
    Txt$ = LTrim$(Str$(Value#))


    ' If the single and double precision representations are equal, we will
    ' insert a # to indicate double precision.

    If Value# = CSng(Value#) Then Txt$ = Txt$ + "#"

    FetchLiteralDBL$ = Txt$

End Function

'
' Reads a literal 16-bit integer from the code and returns its string
' representation. Using the "{int}" tag in ExecuteParseRule is a more
' convienient method to extract literals.
'
' The Radix parameter may be 8, 10 or 16 to produce
' the desired number format, or use the "{int&o}" and "{int&h}" tags.
'
Function FetchLiteralINT$ (Offset As Integer, Radix As Integer)

    Dim Value As Integer

    If Offset < 0 Or Offset > Len(TOKEN) - 4 Then
        FetchLiteralINT$ = "0"
        Exit Function
    End If

    Value = CVI(Mid$(TOKEN, Offset + 3, 2))

    Select Case Radix

        Case 8: Txt$ = "&O" + Oct$(Value)
        Case 10: Txt$ = ITOA$(Value)
        Case 16: Txt$ = "&H" + Hex$(Value)

        Case Else: Txt$ = "[bad radix]"

    End Select

    FetchLiteralINT$ = Txt$

End Function

'
' Reads a literal 32-bit integer from the code and returns its string
' representation. Using the "{lng}" tag in ExecuteParseRule is a more
' convienient method to extract literals.
'
' The Radix parameter may be 8, 10 or 16 to produce the desired number
' format, or use the "{lng&o}" and "{lng&h}" tags.
'
Function FetchLiteralLNG$ (Offset As Integer, Radix As Integer)

    Dim Value As Long

    If Offset < 0 Or Offset > Len(TOKEN) - 6 Then
        FetchLiteralLNG$ = "0"
        Exit Function
    End If

    Value = CVL(Mid$(TOKEN, Offset + 3, 4))

    Select Case Radix

        Case 8: Txt$ = "&O" + Oct$(Value)
        Case 10: Txt$ = LTOA$(Value)
        Case 16: Txt$ = "&H" + Hex$(Value)

        Case Else: Txt$ = "[bad radix]"

    End Select

    If Value < 65536 Then Txt$ = Txt$ + "&"

    FetchLiteralLNG$ = Txt$

End Function

'
' Reads a literal 32-bit float from the p-code and returns its string
' representation. Using the "{sng}" tag in the SHIFT procedure is a more
' convienient method to extract literals.
'
' The IP is passed by reference, and will be incremented to the code
' following the literal. There is no radix option for floating point values.
'
Function FetchLiteralSNG$ (DP)

    If OffsetIP > UBound(CODE) Then
        FetchLiteralSNG$ = "0"
        Exit Function
    End If

    Value! = CVS(Mid$(TOKEN, DP + 3, 4))

    Txt$ = LTrim$(Str$(Value!))

    FetchLiteralSNG$ = Txt$

End Function

Function FetchLNG& (Offset As Integer)

    FetchLNG = -1

    If Offset < 0 Or Offset > Len(TOKEN) - 6 Then Exit Function

    FetchLNG = CVL(Mid$(TOKEN, Offset + 3, 4))

End Function

Function FetchRAW$ (Offset As Integer)

    If Offset < 0 Or Offset > Len(TOKEN) - 2 Then Exit Function

    FetchRAW$ = Mid$(TOKEN, 3 + Offset)

End Function

Function FindRuleDelimiter% (ParseRule As String)

    RuleOffset = 1
    RuleEnd = Len(ParseRule) + 1

    Do While RuleOffset < RuleEnd

        BraceOffset = InStr(RuleOffset, ParseRule, "{")
        PipeOffset = InStr(RuleOffset, ParseRule, "|")

        If BraceOffset = 0 Or PipeOffset <= BraceOffset Then Exit Do

        RuleOffset = InStr(BraceOffset + 1, ParseRule, "}")
        If RuleOffset = 1 Then Exit Do

    Loop

    FindRuleDelimiter = PipeOffset

End Function

'
' Flushes all stack entries to STACK(0), ready for final processing into
' a program line.
'
Sub FlushStack

    For i = 1 To SP
        STACK(0) = STACK(0) + Mid$(STACK(i), 3)
        STACK(i) = ""
    Next i

    SP = 0

End Sub

'
' Returns an integer identifier for a parse rule symbol
'
Function GetHashedSymbol (ParseRuleSymbol As String)
    Dim LookupSymbol As String

    SymbolID$ = LTrim$(RTrim$(ParseRuleSymbol))

    '----------------------------------------------------------------------------
    ' Parse rule symbols my be literal integers
    '----------------------------------------------------------------------------
    If StringToINT(SymbolID$, SymbolID%) Then
        GetHashedSymbol% = SymbolID%
        Exit Function
    End If

    Hash = HashPJW(SymbolID$)

    LookupSymbol = "[" + SymbolID$ + "]"

    SymbolOffset = InStr(SymbolHashTable(Hash), LookupSymbol)

    If SymbolOffset = 0 Then

        SymbolID% = SymbolHashEntries
        SymbolID% = SymbolID% + UBound(ParseRules) + 1
        SymbolID$ = Right$(SymbolHashTable(Hash), 2)
        If SymbolID$ <> "" Then SymbolID% = CVI(SymbolID$) + 1

        SymbolID$ = MKI$(SymbolID%)

        SymbolHashTable(Hash) = SymbolHashTable(Hash) + LookupSymbol + SymbolID$

        SymbolHashEntries = SymbolHashEntries + 1

    Else

        SymbolOffset = SymbolOffset + Len(LookupSymbol)

        SymbolID$ = Mid$(SymbolHashTable(Hash), SymbolOffset, 2)
        SymbolID% = CVI(SymbolID$)

    End If

    GetHashedSymbol% = SymbolID% '+ UBOUND(ParseRules) + 1


End Function

'
' Reads an identifier from the symbol table data stored in the SYMTBL
' array.
'
Function GetID$ (SymTblOffset As Integer)

    '----------------------------------------------------------------------------
    ' Convert offset to LONG to we can read above 32767
    '----------------------------------------------------------------------------
    SymTblOfs& = SymTblOffset And &HFFFF&

    '----------------------------------------------------------------------------
    ' offset FFFF is used as a shortcut for "0" in statements such as
    ' ON ERROR GOTO 0
    '----------------------------------------------------------------------------
    If SymTblOfs& = &HFFFF& Then
        GetID$ = "0"
        Exit Function
    End If


    '----------------------------------------------------------------------------
    ' Make sure we can at least read the first 4 bytes
    '----------------------------------------------------------------------------
    If SymTblOfs& \ 2 > UBound(SYMTBL) - 2 Then
        GetID$ = "®QB45BIN:SymbolTableError¯"
        Exit Function
    End If

    Def Seg = VarSeg(SYMTBL(1))
    Offset = VarPtr(SYMTBL(1))

    Symbol& = (Offset And &HFFFF&) + SymTblOfs&

    SymbolFlags = Peek(Symbol& + 2)

    If SymbolFlags And 2 Then

        ' Short line numbers are stored as integers.

        NumericID& = Peek(Symbol& + 4) Or Peek(Symbol& + 5) * &H100&
        GetID$ = LTrim$(Str$(NumericID&))
    Else

        ' Identifier is a text string - extract it. Note the string may be
        ' a line number.

        Length = Peek(Symbol& + 3)

        If SymTblOfs& \ 2 > UBound(SYMTBL) - (Length + 1) \ 2 Then
            GetID$ = "SymbolTableError"
            Exit Function
        End If

        ID$ = String$(Length, Chr$(0))
        For i = 1 To Length
            Mid$(ID$, i, 1) = Chr$(Peek(Symbol& + 3 + i))
        Next i

        GetID$ = ID$
    End If


End Function

'
' Removes the parse rule id::= from a string and returns its numeric ID.
'
Function GetParseRuleID% (ParseRule As String, TokenID As Integer)

    '----------------------------------------------------------------------------
    ' The default rule ID is always the PCODE
    '----------------------------------------------------------------------------

    For i = 1 To Len(ParseRule)

        If InStr("{}|", Mid$(ParseRule, i, 1)) Then Exit For

        If Mid$(ParseRule, i, 3) = "::=" Then
            GetParseRuleID = SetHashedSymbol(Left$(ParseRule, i - 1), TokenID)
            ParseRule = Mid$(ParseRule, i + 3)
            Exit Function
        End If

    Next i

    GetParseRuleID = -1

End Function

Function GetParseRuleLHS$ (ParseRule As String)

    For i = 1 To Len(ParseRule)

        If InStr("{}|", Mid$(ParseRule, i, 1)) Then Exit For

        If Mid$(ParseRule, i, 3) = "::=" Then
            GetParseRuleLHS = Left$(ParseRule, i - 1)
            Exit Function
        End If

    Next i

End Function

Function GetTaggedItem$ (TagTxt As String, DP As Integer)
 
    Dim SubstTxt As String

    Select Case LCase$(TagTxt)
     
        Case "blockname": SubstTxt = FetchBlockName(DP)
        Case "circle-args": SubstTxt = SubstTagCIRCLE
        Case "input-args": SubstTxt = SubstTagINPUT
        Case "line-args": SubstTxt = SubstTagLINE
        Case "lock-args": SubstTxt = SubstTagLOCK

        Case "open-args": SubstTxt = SubstTagOPEN
        Case "action-verb": SubstTxt = SubstTagVERB
        Case "keymode": SubstTxt = SubstTagKEY
        Case "type-abbr": SubstTxt = GetTypeAbbr(HPARAM)

        Case "call": SubstTxt = ParseCALL(0)
        Case "call()": SubstTxt = ParseCALL(-1)

        Case "defxxx": SubstTxt = SubstTagDEFxxx(QBBinDefType())
        Case "newline": SubstTxt = MKI$(&H10D)

        Case "newline-include": SubstTxt = MKI$(&H20D)

        Case "tabh": SubstTxt = MKI$(&HD) + MKI$(HPARAM)
        Case "tabi": SubstTxt = MKI$(&HD) + MKI$(FetchINT(DP))
        Case "indent": SubstTxt = Space$(FetchINT(DP) And &HFFFF&)
        Case "type": SubstTxt = GetTypeName$(FetchINT(DP))
        Case "id": SubstTxt = GetID(FetchINT(DP))
        Case "id+": SubstTxt = GetID(FetchINT(DP)) + GetTypeSuffix(HPARAM)
        Case "id-list": SubstTxt = FetchIDList(DP)
        Case "id(decl)": SubstTxt = ParseArrayDecl
        Case "id(expr)": SubstTxt = ParseArrayExpr

        Case "hprm": SubstTxt = ITOA$(HPARAM)
        Case "int": SubstTxt = FetchLiteralINT(DP, 10)
        Case "int&h": SubstTxt = FetchLiteralINT(DP, 16)
        Case "int&o": SubstTxt = FetchLiteralINT(DP, 8)
        Case "label": SubstTxt = FetchID(DP): If IsLineNumber(SubstTxt) Then SubstTxt = SubstTxt + " " Else SubstTxt = SubstTxt + ":"

        Case "lng": SubstTxt = FetchLiteralLNG(DP, 10)
        Case "lng&h": SubstTxt = FetchLiteralLNG(DP, 16)
        Case "lng&o": SubstTxt = FetchLiteralLNG(DP, 8)
        Case "nul": SubstTxt = ""
        Case "sng": SubstTxt = FetchLiteralSNG(DP)
        Case "dbl": SubstTxt = FetchLiteralDBL(DP)
        Case "qstr": SubstTxt = Quote(FetchRAW(DP))
        Case "cstr": SubstTxt = FetchCSTR(DP)
        Case "raw": SubstTxt = FetchRAW(DP)
        Case "varargs": SubstTxt = ParseVarArgs
        Case "optargs":
        Case "procdecl": SubstTxt = ParseProcDecl$(DP, 0)
        Case "procdecl()": SubstTxt = ParseProcDecl$(DP, -1)
        Case "proctype": SubstTxt = QBBinProcedureType

        Case "thaddr": SanityCheck DP

        Case Else:
            SubstTxt = "®QB45BIN:bad tag¯"
    End Select

    GetTaggedItem$ = SubstTxt

End Function

Function GetTotalLines%

    Dim TotalLines As Long
    Dim IncludeLines As Long

    TotalLines = 0
    IncludeLines = 0

    FTell& = Loc(QBBinFile) + 1

    Get #QBBinFile, 27, SymTblLen%
    ModuleLOC& = Loc(QBBinFile) + (SymTblLen% And &HFFFF&) + 1

    Seek #QBBinFile, ModuleLOC&

    Do
        Get #QBBinFile, , ModuleLen%
        Seek #QBBinFile, Loc(QBBinFile) + (ModuleLen% And &HFFFF&) + 9

        Get #QBBinFile, , NumTotLines%
        Get #QBBinFile, , NumIncLines%

        TotalLines = TotalLines + (NumTotLines% And &HFFFF&)
        IncludeLines = IncludeLines + (NumIncLines% And &HFFFF&)


        Seek #QBBinFile, Loc(QBBinFile) + 5
        Byte$ = Chr$(0)
        Get #QBBinFile, , Byte$

        If EOF(QBBinFile) Then Exit Do

        ProcedureCOUNT = ProcedureCOUNT + 1

        Get #QBBinFile, , NameLen%
        Seek #QBBinFile, Loc(QBBinFile) + (NameLen% And &HFFFF&) + 4

    Loop

    ReDim ProcedureNAME(1 To ProcedureCOUNT + 1) As String
    ReDim ProcedureLOC(1 To ProcedureCOUNT + 1) As Long

    Seek #QBBinFile, ModuleLOC&

    For i = 1 To ProcedureCOUNT

        Get #QBBinFile, , ModuleLen%

        ProcedureLOC(i) = Loc(QBBinFile) + (ModuleLen% And &HFFFF&) + 17
        Seek #QBBinFile, ProcedureLOC(i) + 1

        Get #QBBinFile, , ProcedureNameLEN%
        ProcedureNAME(i) = String$(ProcedureNameLEN%, 0)
        Get #QBBinFile, , ProcedureNAME(i)
        ProcedureNAME(i) = UCase$(ProcedureNAME(i))

        '------------------------------------------------------------------------
        ' Incremental bubble sort of procedure names
        '------------------------------------------------------------------------
        If QBBinOption.SortProceduresAZ Then
            For j = i - 1 To 1 Step -1
                If ProcedureNAME(j + 1) > ProcedureNAME(j) Then Exit For
                Swap ProcedureNAME(j + 1), ProcedureNAME(j)
                Swap ProcedureLOC(j + 1), ProcedureLOC(j)
            Next j
        End If

        Seek #QBBinFile, Loc(QBBinFile) + 4
    Next i

    For i = 1 To ProcedureCOUNT
        'PRINT ProcedureNAME(i)
        QBBinProcedureIndex = QBBinProcedureIndex + MKL$(ProcedureLOC(i))
    Next i

    Erase ProcedureNAME, ProcedureLOC

    Seek #QBBinFile, FTell&

    If QBBinOption.OmitIncludedLines Then
        GetTotalLines = TotalLines - IncludedLines
    Else
        GetTotalLines = TotalLines
    End If

End Function

'
' Returns the abbreviated name for a built-in type (ie: LNG or DBL).
'
Function GetTypeAbbr$ (TypeID As Integer)

    GetTypeAbbr$ = TypeSpecifiers(LIMIT(TypeID, 0, 5), 2)

End Function

Function GetTypeName$ (TypeID As Integer)

    LTypeID& = TypeID And &HFFFF&

    If LTypeID& > 5 Then
        GetTypeName$ = GetID$(TypeID) ' User-define type
    Else
        GetTypeName$ = TypeSpecifiers(LTypeID&, 1)
    End If

End Function

Function GetTypeSuffix$ (TypeID As Integer)

    GetTypeSuffix$ = TypeSpecifiers(LIMIT(TypeID, 0, 5), 3)

End Function

'
' Implementation of PJW hash, written to avoid 32-bit overflow.
'
Function HashPJW% (Identifier As String)

    Dim h As Long, g As Long, k As Long


    For i = 1 To Len(Identifier)

        k = Asc(Mid$(Identifier, i, 1))

        h = h + (k \ 16)

        g = (h And &HF000000) \ 2 ^ 20

        h = (h And &HFFFFFF) * 16 + (k And 15)

        If g Then h = h Xor (g \ 2 ^ 20)

    Next i

    HashPJW% = h Mod SymbolHashBuckets

End Function

Function IsLineNumber (ID As String)

    Ch$ = Left$(ID, 1)
    If Ch$ = "" Then Exit Function
    If Asc(Ch$) >= 48 And Asc(Ch$) < 57 Then IsLineNumber = -1

End Function

Function ITOA$ (Value As Integer)

    ITOA$ = LTrim$(RTrim$(Str$(Value)))

End Function

Function LIMIT (x, xMin, xMax)

    If x < xMin Then
        LIMIT = xMin

    ElseIf x > xMax Then
        LIMIT = xMax

    Else
        LIMIT = x
    End If

End Function

Function LoadMainModule

    '----------------------------------------------------------------------------
    ' Read module size and convert to long to lose sign bit. Note that modules
    ' should always be a multiple of two in size since all the tokens are 16
    ' bits.
    '----------------------------------------------------------------------------
    If EOF(QBBinFile) Then Exit Function

    Get #QBBinFile, , szModule%
    szModule& = (szModule% And &HFFFF&)
    szModule% = (szModule& + 1) \ 2

    ReDim CODE(1 To szModule%) As Integer
    ReadToArrayINT QBBinFile, CODE(), szModule&

    '----------------------------------------------------------------------------
    ' There is always 16 bytes of data after a code block
    '----------------------------------------------------------------------------
    Dim Footer As String * 16
    Get #QBBinFile, , Footer

    If EOF(QBBinFile) Then
        QBBinCloseFile
        Exit Function
    End If

    LoadMainModule = -1
    IP = LBound(CODE)

End Function

Function LoadNextProcedure


    If QBBinProcedureIndex = "" Then
        QBBinCloseFile
        Exit Function
    End If

    
    
    ProcedureLOC& = CVL(Left$(QBBinProcedureIndex, 4))
    QBBinProcedureIndex = Mid$(QBBinProcedureIndex, 5)
    Seek #QBBinFile, ProcedureLOC&

    Dim Junk As String



    Junk = Chr$(0)
    Get #QBBinFile, , Junk

    If EOF(QBBinFile) Then
        QBBinCloseFile
        Exit Function
    End If
    
    Get #QBBinFile, , ProcNameLen%

    QBBinProcedureName = String$(ProcNameLen% And &HFFFF&, 0)
    Get #QBBinFile, , QBBinProcedureName
    Junk = String$(3, 0)
    Get #QBBinFile, , Junk

    Get #QBBinFile, , ProcCodeLen%

    ReadToArrayINT QBBinFile, CODE(), ProcCodeLen% And &HFFFF&

    Dim Footer As String * 16
    Get #QBBinFile, , Footer

    LoadNextProcedure = -1
    IP = LBound(CODE)

End Function

Sub LoadParseRules

    Dim ParseRule As String

    TokenLBound = &H7FFF
    TokenUBound = 0
    TokenLength = 0

    '----------------------------------------------------------------------------
    ' Clear the symbol hash table
    '----------------------------------------------------------------------------
    For i = 0 To SymbolHashBuckets - 1: SymbolHashTable(i) = "": Next i
    SymbolHashEntries = 0

    '----------------------------------------------------------------------------
    ' PASS 1: Enumerate all tokens
    '----------------------------------------------------------------------------
    RestoreParseRules

    Do While ReadParseRule(TokenPCODE, TokenLength, ParseRule)

        TokenLBound = MIN(TokenPCODE, TokenLBound)
        TokenUBound = MAX(TokenPCODE, TokenLBound)

    Loop

    ReDim ParseRules(TokenLBound To TokenUBound) As String


    '----------------------------------------------------------------------------
    ' PASS 2: Generate token strings
    '----------------------------------------------------------------------------
    RestoreParseRules

    Do While ReadParseRule(TokenPCODE, TokenLength, ParseRule)

        '------------------------------------------------------------------------
        ' If this is the first rule for this PCODE, then we'll write the
        ' length of the token data as the first word.
        '------------------------------------------------------------------------
        If ParseRules(TokenPCODE) = "" Then
            ParseRules(TokenPCODE) = MKI$(TokenLength)
        End If

        RuleID = GetParseRuleID(ParseRule, TokenPCODE)
        If RuleID = -1 Then RuleID = TokenPCODE

        ParseRule = MKI$(Len(ParseRule)) + MKI$(RuleID) + ParseRule
        ParseRules(TokenPCODE) = ParseRules(TokenPCODE) + ParseRule

    Loop

    QBBinTok.SUBDEF = GetHashedSymbol("subdef")
    QBBinTok.FUNCDEF = GetHashedSymbol("funcdef")
    QBBinTok.DEFTYPE = GetHashedSymbol("deftype")

End Sub

'
' Returns the token id of the next unprocessed token without modifying IP.
' Neccessary for REDIM, which causes an array expression to behave like
' an array declaration, for reasons best known to the QB45 dev team.
'
Function LookAhead


    If IP < LBound(CODE) Or IP > UBound(CODE) Then
        LookAhead = -1
    Else
        LookAhead = CODE(IP) And &H3FF
    End If

End Function

Function LTOA$ (Value As Long)

    LTOA$ = LTrim$(RTrim$(Str$(Value)))

End Function

Function MAX% (x As Integer, Y As Integer)

    If x > Y Then MAX = x Else MAX = Y

End Function

Function MIN% (x As Integer, Y As Integer)

    If x < Y Then MIN = x Else MIN = Y

End Function

Function ParseArrayDecl$

    Static RuleIDLoaded As Integer
    Static RuleAsTypeID As Integer
    Static RuleDeclID As Integer
    Static RuleDeclsID As Integer

    If Not RuleIDLoaded Then
        RuleAsTypeID = GetHashedSymbol("astype")
        RuleDeclID = GetHashedSymbol("decl")
        RuleDeclsID = GetHashedSymbol("decls")
    End If


    nElmts = FetchINT(0)
    ID$ = FetchID(2) + GetTypeSuffix(HPARAM)

    If StackPeek(0) = RuleAsTypeID Then
        ArgC = 1
        AsType$ = "{0}"
    End If

    While nElmts > 0

        nElmts = nElmts - 1

        Indices$ = STAG(ArgC) + Indices$
        ArgC = ArgC + 1

        If nElmts And 1 Then
            If StackPeek(ArgC) <> &H18 Then Indices$ = " TO " + Indices$
        Else
            If nElmts Then Indices$ = ", " + Indices$
        End If

    Wend

    If Indices$ <> "" Then Indices$ = "(" + Indices$ + ")"

    If StackPeek(ArgC) = RuleDeclsID Then
        ParseArrayDecl$ = STAG(ArgC) + ", " + ID$ + Indices$ + AsType$
    ElseIf StackPeek(ArgC) = RuleDeclID Then
        ParseArrayDecl$ = STAG(ArgC) + " " + ID$ + Indices$ + AsType$
    Else
        ParseArrayDecl$ = ID$ + Indices$ + AsType$
    End If

End Function

'
' Generates a parse rule for an array expression.
'
Function ParseArrayExpr$

    If LookAhead = 28 Then
        ParseArrayExpr = ParseArrayDecl
        Exit Function
    End If

    'IF PCODE = 15 THEN ArgC = 1

    nElmts = FetchINT(0)
    ID$ = FetchID(2) + GetTypeSuffix(HPARAM)

    If Not nElmts And &H8000 Then

        For i = nElmts - 1 To 0 Step -1

            If i Then
                Indices$ = ", " + STAG(ArgC) + Indices$
            Else
                Indices$ = STAG(ArgC) + Indices$
            End If

            ArgC = ArgC + 1

        Next i

        Indices$ = "(" + Indices$ + ")"

    End If

    ParseArrayExpr = ID$ + Indices$

End Function

'
' Generates parse rule fragment for a procedure call
'
Function ParseCALL$ (Parenthesis As Integer)

    ArgC = FetchINT(0)

    For ArgI = 0 To ArgC - 1

        If ArgI Then
            ArgV$ = STAG(ArgI) + ", " + ArgV$
        Else
            ArgV$ = STAG(ArgI) + ArgV$
        End If

    Next ArgI

    If ArgC > 0 Then
        If Parenthesis Then ArgV$ = "(" + ArgV$ + ")" Else ArgV$ = " " + ArgV$
    End If

    ParseCALL$ = ArgV$

End Function

'
' This helper function parses a SUB or FUNCTION declaration, or a
' SUB/FUNCTION/DEF FN definition.
'
Function ParseProcDecl$ (DP As Integer, Parenthesis As Integer)

    Dim Flags As Long
    Dim ArgC As Long

    Const fCDECL = &H8000
    Const fALIAS = &H400

    ID$ = GetID(FetchINT(DP + 0))
    Flags = FetchINTASLONG(DP + 2)
    ArgC = FetchINTASLONG(DP + 4)

    LenALIAS = Flags \ &H400 And &H1F

    If Flags And &H80 Then TS$ = GetTypeSuffix(Flags And 7)
    Arguments$ = ""

    ProcType = (Flags And &H300) \ 256

    Select Case ProcType
        Case 1: ID$ = "SUB " + ID$ + TS$: QBBinProcedureType = "SUB"
        Case 2: ID$ = "FUNCTION " + ID$ + TS$: QBBinProcedureType = "FUNCTION"
        Case 3: ID$ = "DEF " + ID$ + TS$: QBBinProcedureType = "DEF"
    End Select


    '
    ' Process arguments list
    '
    For ArgI = 1 To ArgC

        ArgName$ = GetID(FetchINT(DP + ArgI * 6 + 0))
        ArgFlags = FetchINT(DP + ArgI * 6 + 2)
        ArgType = FetchINT(DP + ArgI * 6 + 4)

        '------------------------------------------------------------------------
        ' Process special argument flags. Not all of these can be combined,
        ' but we'll just assume the file contains a valid combination.
        '------------------------------------------------------------------------
        If ArgFlags And &H200 Then ArgName$ = ArgName$ + GetTypeSuffix(ArgType)
        If ArgFlags And &H400 Then ArgName$ = ArgName$ + "()"
        If ArgFlags And &H800 Then ArgName$ = "SEG " + ArgName$
        If ArgFlags And &H1000 Then ArgName$ = "BYVAL " + ArgName$
        If ArgFlags And &H2000 Then ArgName$ = ArgName$ + " AS " + GetTypeName(ArgType)

        If ArgI = 1 Then
            Arguments$ = ArgName$
        Else
            Arguments$ = Arguments$ + ", " + ArgName$
        End If

    Next ArgI

    If Parenthesis Or Arguments$ <> "" Then Arguments$ = " (" + Arguments$ + ")"


    '
    ' Process CDECL and ALIAS modifiers
    '
    If Flags And fCDECL Then ID$ = ID$ + " CDECL"

    AliasName$ = Left$(FetchRAW(DP + ArgI * 6), LenALIAS)
    If LenALIAS Then ID$ = ID$ + " ALIAS " + AliasName$

    ParseProcDecl$ = ID$ + Arguments$

End Function

'
'
'
Function ParseVarArgs$

    ArgC = FetchINT(0)

    Static NULARG

    If NULARG = 0 Then NULARG = GetHashedSymbol("nularg")

    For ArgI = 0 To ArgC - 1

        If StackPeek(ArgI) <> NULARG Then ArgV$ = ", " + ArgV$

        ArgV$ = STAG(ArgI) + ArgV$

    Next ArgI


    '----------------------------------------------------------------------------
    ' Trim trailing commas
    '----------------------------------------------------------------------------
    For i = Len(ArgV$) To 1 Step -1
        Ch$ = Mid$(ArgV$, i, 1)
        If Ch$ <> " " And Ch$ <> "," Then Exit For
    Next i

    ArgV$ = Left$(ArgV$, i)

    If ArgV$ <> "" Then ArgV$ = " " + ArgV$

    ParseVarArgs$ = ArgV$

End Function

Function POP$

    If SP = LBound(STACK) Then Exit Function

    POP$ = Mid$(STACK(SP), 3)
    SP = SP - 1

End Function

'
' The following special codes may be embedded in a string:
'
' 0xccnn0D      - RLE encoding (used by QB45 comments)
' 0xnnnn000D    - Indentation marker
' 0x101D        - NEWLINE marker 1
' 0x201D        - NEWLINE marker 2
'
Sub PostProcess

    Dim OutText As String
    Dim OutTxt As String
    Dim Marker As Long
    Dim LineColumn As Long
    Dim OffsetFromNewline As Long
    Dim TextBegin As Long

    TextBegin = 1

    Do
        '------------------------------------------------------------------------
        ' Look for special symbol marker
        '------------------------------------------------------------------------
        Marker = InStr(TextBegin, STACK(0), Chr$(&HD))
        If Marker = 0 Then Marker = Len(STACK(0)) + 1

        '------------------------------------------------------------------------
        ' Copy leading text to output string
        '------------------------------------------------------------------------
        OutTxt = OutTxt + Mid$(STACK(0), TextBegin, Marker - TextBegin)
        If Marker > Len(STACK(0)) Then
            TextBegin = Marker
            Exit Do
        End If

        OffsetFromNewline = OffsetFromNewline + Marker - TextBegin

        Select Case Mid$(STACK(0), Marker + 1, 1)
       
            Case Chr$(0):
                '----------------------------------------------------------------
                ' Indentation
                '----------------------------------------------------------------
                RunLn& = CVI(Mid$(STACK(0), Marker + 2)) And &HFFFF&
                RunLn& = RunLn& - CLng(OffsetFromNewline)

                If (RunLn& < 0) Then RunLn& = 1

                OffsetFromNewline = OffsetFromNewline + RunLn&
                OutTxt = OutTxt + Space$(RunLn&)
                TextBegin = Marker + 4
        
            Case Chr$(1):
                '----------------------------------------------------------------
                ' Newline
                '----------------------------------------------------------------
                If FlushToOutput Then Exit Do
                DiscardLine = 0
                FlushToOutput = -1
                OffsetFromNewline = 0
                TextBegin = Marker + 2

            Case Chr$(2):
                '----------------------------------------------------------------
                ' Newline - $INCLUDEd file
                '----------------------------------------------------------------
                DiscardLine = QBBinOption.OmitIncludedLines
                          
                FlushToOutput = -1
                OffsetFromNewline = 0
                TextBegin = Marker + 2

            Case Else:
                '----------------------------------------------------------------
                ' RLE encoded comment
                '----------------------------------------------------------------
                RunLn& = Asc(Mid$(STACK(0), Marker + 1))
                RunCh$ = Mid$(STACK(0), Marker + 2)

                OutTxt = OutTxt + String$(RunLn&, RunCh$)

                OffsetFromNewline = OffsetFromNewline + RunLn&
                TextBegin = Marker + 3
   
        End Select

    Loop

    If FlushToOutput Then
        If OutTxt <> Space$(Len(OutTxt)) Then OutTxt = RTrim$(OutTxt)
        QBBinProgramLine = OutTxt
        QBBinLineReady = Not DiscardLine
    
        OutTxt = ""
    End If

    STACK(0) = OutTxt + Mid$(STACK(0), Marker)

End Sub

Sub ProcessProcDefType

    ' Procedure DEFTYPE defaults to SINGLE

    Dim ProcDefType(1 To 26) As Integer
    Dim OutTxt As String

    For i = 1 To 26: ProcDefType(i) = 3: Next i

    Do While LookAhead = 0
        If Not ReadToken Then Exit Sub

        If LookAhead <> QBBinTok.DEFTYPE Then
            IP = IP - 1
            Exit Do
        End If

        If Not ReadToken Then Exit Do

        UnwantedReturnValue$ = SubstTagDEFxxx(ProcDefType())
    
    Loop

    'FOR i = 1 TO 26: PRINT GetTypeSuffix(ProcDefType(i)); : NEXT i: PRINT

    'PRINT QBBinProcedureName

    For i = 1 To 5
   
        'IF i = 3 THEN i = i + 1

        AnythingOutput = 0
        InitialLetter = 0
        OutTxt = ""

        For j = 1 To 27


            BITSET = 0

            If j < 27 Then
                BITSET = ProcDefType(j) = i
                BITSET = BITSET And QBBinDefType(j) <> i
            End If

            If BITSET And InitialLetter = 0 Then

                InitialLetter = j + 64

            ElseIf InitialLetter And Not BITSET Then

                If AnythingOutput Then OutTxt = OutTxt + ", "

                OutTxt = OutTxt + Chr$(InitialLetter)

                Range = j + 64 - InitialLetter
                If Range > 1 Then OutTxt = OutTxt + "-" + Chr$(j + 63)

                AnythingOutput = -1
                InitialLetter = 0
            End If
        Next j

        If AnythingOutput Then
            PUSH 0, MKI$(&H10D)
            PUSH QBBinTok.DEFTYPE, "DEF" + GetTypeAbbr(i) + " " + OutTxt
            FlushStack
        End If
    
    Next i

    For i = 1 To 26: QBBinDefType(i) = ProcDefType(i): Next i

End Sub

Function ProcessToken

    ProcessToken = 0
    If Not ReadToken Then Exit Function

    If PCODE = 8 Then Exit Function

    ProcessToken = -1
    DefaultParseRule

End Function

Sub PUSH (ID As Integer, Txt As String)

    If SP = UBound(STACK) Then Exit Sub

    SP = SP + 1
    STACK(SP) = MKI$(ID) + Txt

End Sub

Sub QBBinCloseFile

    Close #QBBinFile
    QBBinFile = 0
    QBBinEOF = -1

End Sub

DefSng A-Z
Function QBBinGetFileType

End Function

DefInt A-Z
'
Function QBBinGetProcName$

End Function

Sub QBBinOpenFile (FileName As String)

    QBBinFile = FreeFile
    QBBinEOF = 0

    Open FileName For Binary As #QBBinFile

    Get #QBBinFile, , Magic%
    Get #QBBinFile, , Version%

    '----------------------------------------------------------------------------
    ' Only QB45 is currently supported
    '----------------------------------------------------------------------------
    If (Magic% <> &HFC) Or (Version% <> 1) Then
        Reset
        Print "ERROR: The file you provided does not have a valid QB45 header."
        System 1
    End If

    ' Don't delete this - alpha sorter needs it!
    x = GetTotalLines

    '----------------------------------------------------------------------------
    ' Read symbol table size and convert to long to lose sign bit
    '----------------------------------------------------------------------------
    Get #QBBinFile, 27, szSymTbl%
    szSymTbl& = szSymTbl% And &HFFFF&

    '----------------------------------------------------------------------------
    ' Load symbol table to memory and return file number
    '----------------------------------------------------------------------------
    ReDim SYMTBL(1 To (szSymTbl& + 1) \ 2) As Integer
    ReadToArrayINT QBBinFile, SYMTBL(), szSymTbl&

    If Not LoadMainModule Then Exit Sub

    '----------------------------------------------------------------------------
    ' If main module is empty, look for non-empty procedure
    '----------------------------------------------------------------------------
    While CODE(IP) = 8
        If Not LoadNextProcedure Then Exit Sub
    Wend

End Sub

Function QBBinReadLine$ (Meta As Long)


    Static NewProc

    Meta = 0

    PostProcess

    If QBBinLineReady Then
        QBBinReadLine = QBBinProgramLine
        QBBinLineReady = 0
        QBBinProgramLine = ""
        Exit Function
    End If

    If QBBinEOF Then Exit Function

    Do
        If NoMoreTokens Then
            QBBinCloseFile
            Exit Function
        End If

        If Not ReadToken Then Exit Function
        DefaultParseRule

        '------------------------------------------------------------------------
        ' Trap some special tokens
        '------------------------------------------------------------------------
        Select Case PCODE
                                                                       
            '------------------------------------------------------------------------
            ' Token 0x008 appears at the end of the code (before the watch list)
            '------------------------------------------------------------------------
            Case 8:
                If Not LoadNextProcedure Then
                    NoMoreTokens = -1
                Else
                    PUSH 0, MKI$(&H10D) ' Force blank line before SUB/FUNCTION
                    ProcessProcDefType
                    NewProc = -1

            
                    'ProcessProcDefType

                End If

                'END SELECT

                'SELECT CASE StackPeek(0)
       
            Case QBBinTok.SUBDEF: Meta = QBBinMeta.SUB
            Case QBBinTok.FUNCDEF: Meta = QBBinMeta.FUNCTION

        End Select

        PostProcess

    Loop While Not QBBinLineReady

    QBBinReadLine = QBBinProgramLine
    QBBinLineReady = 0
    QBBinProgramLine = ""

End Function

Sub QBBinSetOption (OptionName As String, OptionValue As Integer)
End Sub

Function Quote$ (Txt As String)

    Quote$ = Chr$(34) + Txt + Chr$(34)

End Function

Function ReadKey$
    Do: Loop While InKey$ <> ""
    Do: Key$ = InKey$: Loop While Key$ = ""

    ReadKey = UCase$(Key$)

End Function

Function ReadParseRule (TokenID As Integer, OpLen As Integer, ParseRule As String)

    '------------------------------------------------------------------------
    ' Ugh... static. I'm being lazy.
    '------------------------------------------------------------------------
    Static RuleItem As String
    Static DefaultRuleID As String

    '------------------------------------------------------------------------
    ' If RuleItem isn't empty, extract the next rule.
    '------------------------------------------------------------------------
    If RuleItem <> "" Then
        ParseRule = DelimitParseRule(RuleItem, DefaultRuleID)
        ReadParseRule = -1
        Exit Function
    End If

    ReadParseRule = 0

    Read RuleItem

    '------------------------------------------------------------------------
    ' Loop until we have something which isn't the .default directive
    '------------------------------------------------------------------------
    While Mid$(RuleItem, 1, 8) = ".default"

        DefaultRuleID = LTrim$(RTrim$(Mid$(RuleItem, 9)))
        Read RuleItem

    Wend

    '------------------------------------------------------------------------
    ' The rule list is terminated by a period.
    '------------------------------------------------------------------------
    If RuleItem = "." Then
        RuleItem = ""
        DefaultRuleID = ""
        Exit Function
    End If

    '------------------------------------------------------------------------
    ' If RuleItem is a number, then assume it is the start of a new token.
    ' Otherwise, we assume it is an additional rule of the previous token.
    '------------------------------------------------------------------------
    If (StringToINT(RuleItem, TokenID)) Then

        Read RuleItem

        '--------------------------------------------------------------------
        ' If the token length is not omitted, then we need to read again
        ' to fetch the token parse rule. Also, an asterisk may be used to
        ' represent a variable length token, so we need to check for that.
        '--------------------------------------------------------------------
        If StringToINT(RuleItem, OpLen) Then
            Read RuleItem

        ElseIf RuleItem$ = "*" Then
            OpLen = -1
            Read RuleItem

        Else
            OpLen = 0
        End If

    End If


    '------------------------------------------------------------------------
    ' Extract rule and return
    '------------------------------------------------------------------------
    ParseRule = DelimitParseRule(RuleItem, DefaultRuleID)
    ReadParseRule = -1

End Function

Sub ReadToArrayINT (FileNumber As Integer, Array() As Integer, ByteCount As Long)

    Const BlockReadSize = 1024 ' must be a multiple of 2

    If BlockReadSize And 1 Then Print "BlockReadSize error.": System 1 'ERROR 255

    Dim i As Long
    Dim BytesToRead As Long

    '----------------------------------------------------------------------------
    ' REDIM the array if necessary, but keep the lower bound in place
    '----------------------------------------------------------------------------
    If (UBound(Array) - LBound(Array)) * 2 < ByteCount Then
        ReDim Array(LBound(Array) To LBound(Array) + (ByteCount + 1) \ 2) As Integer
    End If

    For i = 0 To ByteCount - 1 Step BlockReadSize

        BytesToRead = ByteCount - i

        If BytesToRead > BlockReadSize Then BytesToRead = BlockReadSize

        Buffer$ = String$(BytesToRead, 0)
        Get FileNumber, , Buffer$

        '------------------------------------------------------------------------
        ' Copy data from string to integer array (even number of bytes only)
        '------------------------------------------------------------------------
        For j = 1 To BytesToRead - 1 Step 2
            Index = LBound(Array) + i \ 2 + j \ 2
            Array(Index) = CVI(Mid$(Buffer$, j, 2))
        Next j

        '------------------------------------------------------------------------
        ' The final block may have had an odd number of bytes
        '------------------------------------------------------------------------
        If BytesToRead And 1 Then
            Index = LBound(Array) + i \ 2 + j \ 2
            Array(Index) = Asc(Right$(Buffer$, 1))
        End If

    Next i


End Sub

'
' Reads a token into the globals PCODE and HPARAM. IP is updated to point
' To the next token, and DP points to the start of the token data.
'
Function ReadToken

    Dim TokLen As Long

    ReadToken = 0

    If IP < LBound(CODE) Or IP > UBound(CODE) Then Exit Function

    '----------------------------------------------------------------------------
    ' Fetch basic token information
    '----------------------------------------------------------------------------
    TOKEN = MKI$(CODE(IP))
    PCODE = CODE(IP) And &H3FF
    HPARAM = (CODE(IP) And &HFC00&) \ 1024
    ReadToken = -1


    '----------------------------------------------------------------------------
    ' If the token is outside the known token range, we have a problem.
    '----------------------------------------------------------------------------
    If PCODE < LBound(ParseRules) Or PCODE > UBound(ParseRules) Then
        IP = IP + 1
        'PRINT "Bad token found.": SYSTEM 1 'ERROR QBErrBadToken
        PCODE = 0: HPARAM = 0: TOKEN = MKI$(0)
        Exit Function
    End If

    '----------------------------------------------------------------------------
    ' If the token has no information in the parse rules, then we clearly don't
    ' understand what it does, so increment IP and return. We will try to
    ' soldier on and parse the rest of the file
    '----------------------------------------------------------------------------
    If ParseRules(PCODE) = "" Then
        AOutput "REM ®QB45BIN¯ Unkown token - " + Hex$(PCODE)
        IP = IP + 1
        Exit Function
    End If

    '----------------------------------------------------------------------------
    ' Fetch the token data length from the parse rules to determine if the token
    ' is fixed or variable length
    '----------------------------------------------------------------------------
    If PCODE >= LBound(ParseRules) And PCODE <= UBound(ParseRules) Then
        If Len(ParseRules(PCODE)) > 2 Then
            TokLen = CVI(Left$(ParseRules(PCODE), 2)) And &HFFFF&
        End If
    End If

    '----------------------------------------------------------------------------
    ' If the token is variable length it will be followed by the size word, so
    ' read it now.
    '----------------------------------------------------------------------------
    If TokLen = &HFFFF& Then
        IP = IP + 1
        TokLen = CODE(IP) And &HFFFF&
    End If

    '----------------------------------------------------------------------------
    ' Read the token data into the TOKEN string. Note that due to a bug in QB64,
    ' we can not use IP as the control variable.
    '----------------------------------------------------------------------------
    For DP = IP + 1 To IP + (TokLen + 1) \ 2
        TOKEN = TOKEN + MKI$(CODE(DP))
    Next DP
    IP = DP

    TOKEN = Left$(TOKEN, TokLen + 2)

End Function

Sub RestoreParseRules

    '
    ' This is so I can change parse rules later if I add QB40 support.
    '
    Restore QB45TOKENS

End Sub

Sub SanityCheck (DP As Integer)

    Dim ThAddr As Long

    ThAddr = FetchINTASLONG(DP)

    If ThAddr = &HFFFF& Then Exit Sub

    ThAddr = ThAddr \ 2 - 1

    If ThAddr >= LBound(CODE) And ThAddr <= UBound(CODE) - 1 Then

        If (CODE(LBound(CODE) + ThAddr) And &H1FF) = PCODE Then Exit Sub

    End If

    'ERROR QBBinErrInsane
End Sub

Function SetHashedSymbol% (ParseRuleSymbol As String, SymbolID As Integer)
    Dim LookupSymbol As String

    SymbolName$ = LTrim$(RTrim$(ParseRuleSymbol))

    '----------------------------------------------------------------------------
    ' Parse rule symbols my be literal integers
    '----------------------------------------------------------------------------
    If StringToINT(SymbolName$, SymbolID%) Then Exit Function

    Hash = HashPJW(SymbolName$)

    LookupSymbol = "[" + SymbolName$ + "]"

    SymbolOffset = InStr(SymbolHashTable(Hash), LookupSymbol)

    If SymbolOffset = 0 Then

        SymbolHashTable(Hash) = SymbolHashTable(Hash) + LookupSymbol + MKI$(SymbolID)

        SetHashedSymbol = SymbolID

    Else

        SymbolOffset = SymbolOffset + Len(LookupSymbol)

        ID$ = Mid$(SymbolHashTable(Hash), SymbolOffset, 2)
        SetHashedSymbol = CVI(ID$)

    End If

    'GetHashedSymbol% = SymbolID% + UBOUND(ParseRules) + 1



End Function

'
' Peeks at the ID of a stack item
'
Function StackPeek (OffsetSP)

    StackPeek = -1

    If OffsetSP < 0 Or OffsetSP >= SP Then Exit Function

    StackPeek = CVI(Left$(STACK(SP - OffsetSP), 2))

End Function

'
' STAG is a shortcut function for creating numeric stack tags dynamically
' such as {1}.
'
Function STAG$ (n)

    STAG$ = "{" + LTrim$(RTrim$(Str$(n))) + "}"

End Function

'
' Parses a STRING into an INTEGER, returning 0 if the string contained
' any invalid characters (not including leading and trailing whitespace).
' Only positive integers are recognised (no negative numbers!).
'
' The actual numeric value is returned in OutVal
'
Function StringToINT (Txt As String, OutVal As Integer)

    x$ = UCase$(LTrim$(RTrim$(Txt)))

    SignCharacter$ = Left$(x$, 1)
    SignMultiplier = 1

    If (SignCharacter$ = "+" Or SignCharacter$ = "-") Then
        SignMultiplier = 45 - Asc(SignCharacter$)
        x$ = Mid$(x$, 2)
    End If

    FoundBadDigit = Len(x$) = 0

    Select Case Left$(x$, 2)
        Case "&H", "0X": nBase = 16: FirstDigitPos = 3
        Case "&O": nBase = 8: FirstDigitPos = 3
        Case Else: nBase = 10: FirstDigitPos = 1
    End Select

    If nBase Then

        For i = FirstDigitPos To Len(x$)
            Digit = Asc(Mid$(x$, i, 1)) - 48
            If Digit > 16 Then Digit = Digit - 7
            If Digit < 0 Or Digit >= nBase Then FoundBadDigit = -1

            If Not FoundBadDigit Then
                Value = Value * nBase
                Value = Value + Digit
            End If

        Next i
    End If

    StringToINT = Not FoundBadDigit
    If Not FoundBadDigit Then OutVal = Value * SignMultiplier

End Function

Function SubstTagCIRCLE$

    Dim ParseRule As String

    ParseRule = "{?}, {?}, {?}, {?}, {?}, {?}"

    ArgC = 0
    ArgI = 0

    '
    ' The last 3 arguments are optional.
    '
    For i = 0 To 2

        If StackPeek(ArgC) = &H7E + i Then

            If ArgI = 0 Then ArgI = 28 - i * 5

            Mid$(ParseRule, 27 - i * 5, 1) = Chr$(ArgC + 48)
            ArgC = ArgC + 1

        End If

    Next i

    ' PCODE 0x09f means no colour argument
    If PCODE <> &H9F Then
        If ArgI = 0 Then ArgI = 13
        Mid$(ParseRule, 12, 1) = Chr$(ArgC + 48)
        ArgC = ArgC + 1
    End If

    ' The last 3 arguments are required
    If ArgI = 0 Then ArgI = 8
    Mid$(ParseRule, 7, 1) = Chr$(ArgC + 48): ArgC = ArgC + 1
    Mid$(ParseRule, 2, 1) = Chr$(ArgC + 48): ArgC = ArgC + 1

    ' Remove unused arguments

    ParseRule = Left$(ParseRule, ArgI)

    Do
        ArgI = InStr(ParseRule, "?")
        If ArgI <= 1 Then Exit Do
        ParseRule = Left$(ParseRule, ArgI - 2) + Mid$(ParseRule, ArgI + 2)
    Loop

    SubstTagCIRCLE = ParseRule

End Function

'
' 0x01B : DEF(INT|LNG|SNG|DBL|STR) letterrange
'
' The DEFxxx token is followed by 6 bytes of data. The first two bytes give
' the absolute offset in the p-code to the correspdoning bytes of the next
' DEFxxx statement (!), or 0xFFFF if there are no more DEFxxx statements.
'
' Naturally, we can ignore these two bytes.
'
' The next 4 bytes form a 32-bit integer. The low 3 bits give the data-type
' for the DEFxxx. The upper 26 bits represent each letter or the alphabet,
' with A occupying the highest bit, and Z the lowest.
'
Function SubstTagDEFxxx$ (DefTypeArray() As Integer)

    Dim AlphaMask As Long
    Dim OutTxt As String

    AlphaMask = FetchLNG(2)
    DefType = LIMIT(AlphaMask And 7, 0, 5)
    OutTxt = "DEF" + GetTypeAbbr(DefType) + " "

    ' Shift the mask right once to avoid overflow problems.
    AlphaMask = AlphaMask \ 2
    InitialLetter = 0
    AnythingOutput = 0

    ' We will loop one extra time to avoid code redendancy after the loop to
    ' clean up the Z. To ensure everything works out, we just need to make
    ' sure the bit after the Z is clear. We also need to clear the high 2 bits
    ' every time to avoid overflow ploblems.

    For i = 0 To 26

        ' Get the next bit and shift the mask
        BITSET = (AlphaMask And &H40000000) <> 0
        AlphaMask = AlphaMask And &H3FFFFFE0
        AlphaMask = AlphaMask * 2

        '------------------------------------------------------------------------
        ' Update current DEFtype state
        '------------------------------------------------------------------------
        If i < 26 And BITSET Then DefTypeArray(i + 1) = DefType

        If BITSET And InitialLetter = 0 Then

            InitialLetter = i + 65

        ElseIf InitialLetter And Not BITSET Then

            If AnythingOutput Then OutTxt = OutTxt + ", "

            OutTxt = OutTxt + Chr$(InitialLetter)

            Range = i + 65 - InitialLetter
            If Range > 1 Then OutTxt = OutTxt + "-" + Chr$(i + 64)

            AnythingOutput = -1
            InitialLetter = 0
        End If

    Next i

    SubstTagDEFxxx$ = OutTxt

End Function

Function SubstTagINPUT$

    Const fPrompt = &H4
    Const fSemiColon = &H2
    Const fComma = &H1

    Flags = Asc(Mid$(TOKEN, 3, 1))

    If Flags And fSemiColon Then OutTxt$ = "; "

    If Flags And fPrompt Then
        Tail = 59 - (((Flags And fComma) = 1) And 15)
        OutTxt$ = OutTxt$ + "{$+0}" + Chr$(Tail)
    End If

    SubstTagINPUT = OutTxt$

End Function

Function SubstTagKEY$

    Select Case CVI(Mid$(TOKEN, 3, 2))
        Case 1: SubstTagKEY$ = "ON"
        Case 2: SubstTagKEY$ = "LIST"
        Case Else: SubstTagKEY$ = "OFF"
    End Select

End Function

Function SubstTagLINE$

    LineForm = PCODE - &HBB

    Select Case FetchINT(0) And 3

        Case 1: BF$ = "B"
        Case 2: BF$ = "BF"
        Case Else: BF$ = ""

    End Select

    ' 0x0bb : LINE x-x, ,[b[f]]
    ' 0x0bc : LINE x-x,n,[b[f]]
    ' 0x0bd : LINE x-x,n,[b[f]],n
    ' 0x0be : LINE x-x, ,[b[f]],n


    If BF$ <> "" Then

        Select Case LineForm

            Case 0: Rule$ = "{0}, , " + BF$
            Case 1: Rule$ = "{1}, {0}, " + BF$
            Case 2: Rule$ = "{2}, {1}, " + BF$ + ", {0}"
            Case 3: Rule$ = "{1}, , " + BF$ + ", {0}"

        End Select

    Else

        Select Case LineForm

            Case 0: Rule$ = "{0}"
            Case 1: Rule$ = "{1}, {0}"
            Case 2: Rule$ = "{2}, {1}, , {0}"
            Case 3: Rule$ = "{1}, , , {0}"

        End Select

    End If

    SubstTagLINE = Rule$

End Function

Function SubstTagLOCK$

    Dim Flags As Long

    Flags = FetchINTASLONG(0) And &HFFFF&

    If (Flags And 2) = 0 Then
        SubstTagLOCK$ = "{0}"
    Else
    
        ' check high 2 bits
        Select Case Flags \ &H4000
            Case 0: SubstTagLOCK$ = "{2}, {1} TO {0}"
            Case 1: SubstTagLOCK$ = "{2}, TO {0}"
            Case 2: SubstTagLOCK$ = "{1}, {0}"
        End Select

    End If

End Function

Function SubstTagOPEN$

    Dim ModeFlags As Long
    Dim ForMode As String
    Dim AccessMode As String
    Dim LockMode As String
    Dim OutTxt As String

    ModeFlags = FetchINT(0) And &HFFFF&

    Select Case ModeFlags And &H3F
        Case &H1: ForMode = "FOR INPUT"
        Case &H2: ForMode = "FOR OUTPUT"
        Case &H4: ForMode = "FOR RANDOM"
        Case &H8: ForMode = "FOR APPEND"
        Case &H20: ForMode = "FOR BINARY"
    End Select

    Select Case ModeFlags \ 256 And 3
        Case 1: AccessMode = "ACCESS READ"
        Case 2: AccessMode = "ACCESS WRITE"
        Case 3: AccessMode = "ACCESS READ WRITE"
    End Select

    Select Case ModeFlags \ &H1000 And &H7
        Case 1: LockMode = "LOCK READ WRITE"
        Case 2: LockMode = "LOCK WRITE"
        Case 3: LockMode = "LOCK READ"
        Case 4: LockMode = "SHARED"
    End Select

    OutTxt = ForMode
    If (OutTxt <> "" And AccessMode <> "") Then OutTxt = OutTxt + " "
    OutTxt = OutTxt + AccessMode
    If (OutTxt <> "" And LockMode <> "") Then OutTxt = OutTxt + " "
    OutTxt = OutTxt + LockMode

    SubstTagOPEN = OutTxt

End Function

Function SubstTagVERB$

    Verbs$ = "0OR|1AND|2PRESET|3PSET|4XOR|"

    VerbBegin = InStr(Verbs$, Chr$(48 + LIMIT(FetchINT(0), 0, 4))) + 1
    VerbEnd = InStr(VerbBegin, Verbs$, "|")

    SubstTagVERB$ = Mid$(Verbs$, VerbBegin, VerbEnd - VerbBegin)

End Function

'
' Splits a {ruletag} into it's constituent components.
'
Function TokenizeTag (TagTxt As String, TagParam As Integer)

    Dim ParamTxt As String

    Delimiter = InStr(TagTxt, ":")

    ParamTxt = LTrim$(Mid$(TagTxt, Delimiter + 1))

    If Left$(ParamTxt, 1) = "$" Then

        TokenizeTag = TagType.StackREL

        If Not StringToINT(Mid$(ParamTxt, 2), TagParam) Then
            Delimiter = Len(TagTxt) + 1
            TagParam = 0
        End If

    Else

        TokenizeTag = TagType.StackABS

        If Not StringToINT(Mid$(ParamTxt, 1), TagParam) Then
            Delimiter = Len(TagTxt) + 1
            TagParam = 0
        End If

    End If

    If Delimiter Then Delimiter = Delimiter - 1

    TagTxt = LTrim$(RTrim$(Left$(TagTxt, Delimiter)))

    If Left$(TagTxt, 2) = "##" Then

        TokenizeTag = TagType.Recursive
        TagTxt = Mid$(TagTxt, 3)

    ElseIf Left$(TagTxt, 1) = "#" Then

        TokenizeTag = TagType.TokenData
        TagTxt = Mid$(TagTxt, 2)

    End If


End Function

Function ValidateStackTag (RuleID As Integer, TagTxt As String, OffsetSP As Integer)


    Dim RuleSymbol As String

    '------------------------------------------------------------------------
    ' If the specified stack offset is invalid, only the null tag will do.
    '------------------------------------------------------------------------
    If (OffsetSP < 0 Or OffsetSP >= SP) Then
        ValidateStackTag = (TagTxt = "")
        Exit Function
    End If

    TagLen = Len(TagTxt)
    TagOffset = 1

    Do While TagOffset <= TagLen
     
        Delimiter = InStr(TagOffset, TagTxt, "|")
        If Delimiter = 0 Then Delimiter = TagLen + 1

        RuleSymbol = Mid$(TagTxt, TagOffset, Delimiter - TagOffset)
        RuleSymbol = LTrim$(RTrim$(RuleSymbol))

        If Not StringToINT(RuleSymbol, RuleSymbolID) Then
            RuleSymbolID = GetHashedSymbol(RuleSymbol)
        End If

        If RuleSymbol = "*" Then Exit Do
        If RuleSymbol = "self" Then RuleSymbolID = RuleID

        If StackPeek(OffsetSP) = RuleSymbolID Then Exit Do

        TagOffset = Delimiter + 1

    Loop

    ValidateStackTag = Not (TagLen And TagOffset > TagLen)

    If TagLen And TagOffset > TagLen Then
        ValidateStackTag = 0
    Else
        ValidateStackTag = -1
    End If


End Function

