' '''''''''' '''''''''' '''''''''' '''''''''' ''''''''''

' JavaScript: STARTSKIP
'\\std::string subExecute (std::string TheScriptIn, std::string TheModeIn, std::string ScopeSwitchIn);
'\\std::string numberCrunch (std::string TheStringIn);
'\\std::string sxriptEval (std::string TheStringIn);
'\\std::string evalStep (std::string TheStringIn);
' JavaScript: ENDSKIP

' '''''''''' '''''''''' '''''''''' '''''''''' ''''''''''

DECLARE FUNCTION CountElements (TheStringIn AS STRING, TheSeparatorIn AS STRING)
DECLARE FUNCTION FindMatching (TheStringIn AS STRING, TheSymbolIn AS STRING, TheStartPosIn AS INTEGER)
DECLARE FUNCTION FindMostEmbedded (TheStringIn AS STRING)
DECLARE FUNCTION GetSeparatorPos (TheStringIn AS STRING, TheSeparatorTypeIn AS STRING, TheSeparatorNumIn AS INTEGER, TheStartPosIn AS INTEGER)
DECLARE FUNCTION ManageWhiteSpace$ (TheStringIn AS STRING)
DECLARE FUNCTION RemoveWrapping$ (TheStringIn AS STRING, TheWrapIn AS STRING)
DECLARE FUNCTION ReplaceWord$ (TheStringIn AS STRING, TheWordIn AS STRING, TheReplacementIn AS STRING, CurlyDepthIn As INTEGER)
DECLARE FUNCTION ReplaceRaw$ (TheStringIn AS STRING, TheWordIn AS STRING, TheReplacementIn AS STRING)
DECLARE FUNCTION ScanForName (TheStringIn AS STRING, TheCritPosIn AS INTEGER, TheSwitchIn AS STRING)
DECLARE FUNCTION ScanForOperator (TheStringIn AS STRING, TheSymbolIn AS STRING)
DECLARE FUNCTION TypeCheck$ (TheStringIn AS STRING)
DECLARE FUNCTION ManageOperators$ (TheStringIn AS STRING)
DECLARE FUNCTION PlotASCII$ (TheFuncIn AS STRING, LowLimitIn AS DOUBLE, HighLimitIn AS DOUBLE, StepSizeIn AS DOUBLE, WindowWidthIn AS INTEGER, WindowHeightIn AS INTEGER, DetailSwitchIn AS INTEGER)
DECLARE FUNCTION PlotScatter$ (TheListIn AS STRING, WindowWidthIn AS INTEGER, WindowHeightIn AS INTEGER, DetailSwitchIn AS INTEGER)
DECLARE FUNCTION HistASCII$ (TheListIn AS STRING, DetailSwitchIn AS INTEGER)
DECLARE FUNCTION ReturnElement$ (TheStringIn AS STRING, TheArgNumberIn AS INTEGER, TheSeparatorIn AS STRING)
DECLARE FUNCTION VectorASMD$ (Vector1In AS STRING, Vector2In AS STRING, TheOperatorIn AS STRING)
DECLARE FUNCTION StructureEval$ (TheVectorIn AS STRING, TheLeftBrackIn AS STRING, TheRightBrackIn AS STRING)
DECLARE FUNCTION StructureApplyFunc$ (TheVectorIn AS STRING, TheFunctionIn AS STRING, TheBracketsIn AS STRING)
DECLARE FUNCTION FormatForTerminal$ (TheStringIn AS STRING)
DECLARE FUNCTION EvalStep$ (TheStringIn AS STRING)
DECLARE FUNCTION InternalEval$ (TheStringIn AS STRING)
DECLARE FUNCTION FunctionCrunch$ (ScannedNameIn AS STRING, MidFragmentIn AS STRING)
DECLARE FUNCTION SxriptEval$ (TheStringIn AS STRING)
DECLARE FUNCTION NumberCrunch$ (TheStringIn AS STRING)
DECLARE FUNCTION SubExecute$ (TheScriptIn AS STRING, TheModeIn AS STRING, ScopeSwitchIn AS STRING)

' '''''''''' '''''''''' '''''''''' '''''''''' ''''''''''

' Initialize globals and startup variables.
'DIM kglob AS INTEGER
'DIM jglob AS INTEGER
DIM SHARED BrackList AS STRING
DIM SHARED OpList AS STRING
DIM SHARED EscapeChar AS STRING

' Define array for Sxript logo.
DIM SHARED SxriptLogoText(30) AS STRING
DIM SHARED SxriptLogoSize AS INTEGER

' Define structure for function and variable storage.
DIM SHARED FunctionListSize AS INTEGER
DIM SHARED VariableListSize AS INTEGER
DIM SHARED ScopeLevel AS INTEGER
DIM SHARED FunctionList(131, 2) AS STRING
DIM SHARED VariableList(131, 2) AS STRING
DIM SHARED FunctionListScope(131, 2, 24) AS STRING
DIM SHARED VariableListScope(131, 2, 24) AS STRING

'kglob = 0
'jglob = 0

' '''''''''' '''''''''' '''''''''' '''''''''' ''''''''''

' CPP: STARTSKIP

DIM kglob AS INTEGER
DIM jglob AS INTEGER
kglob = 0
jglob = 0

'\\var document;
'\\var FunctionList = new Array(101);
'\\var VariableList = new Array(101);
'\\var FunctionListScope = new Array(101);
'\\var VariableListScope = new Array(101);

'\\(function () {
'\\    "use strict";
'\\for (kglob = 1; kglob <= 101; kglob += 1) {
'\\    FunctionList[kglob] = new Array(2);
'\\}
'\\for (kglob = 1; kglob <= 101; kglob += 1) {
'\\    VariableList[kglob] = new Array(2);
'\\}
'\\for (kglob = 1; kglob <= 101; kglob += 1) {
'\\    FunctionListScope[kglob] = new Array(2);
'\\}
'\\for (kglob = 1; kglob <= 101; kglob += 1) {
'\\    VariableListScope[kglob] = new Array(2);
'\\}
'\\for (kglob = 1; kglob <= 101; kglob += 1) {
'\\    for (jglob = 1; jglob <= 2; jglob += 1) {
'\\        FunctionListScope[kglob][jglob] = new Array(24);
'\\    }
'\\}
'\\for (kglob = 1; kglob <= 101; kglob += 1) {
'\\    for (jglob = 1; jglob <= 2; jglob += 1) {
'\\        VariableListScope[kglob][jglob] = new Array(24);
'\\    }
'\\}
' CPP: ENDSKIP

' CPP: STARTSKIP
SxriptLogoSize = 0
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "                  .      "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "    +@@@@,        @@     "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "   @@@@@@@'       @@@:   "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "  @@@@@@@@@      +@@@@@: "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "  #    @@@@#     @@@@@@  "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "       ,@@@@    .++@@@+  "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "        @@@@#   @    @   "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "        ;@@@@  ,@        "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "         @@@@# @         "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "         #@@@@'@         "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "          @@@@@,         "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "      '###@@@@@#######   "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "      @@@@@@@@@@@@@@@.   "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "     .@@@@@@@@@@@@@@@    "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "      ``....@@@@#        "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "           ,@@@@@        "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "           @`@@@@#       "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "          `@ @@@@@       "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "          @;  @@@@'      "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "          @   @@@@@      "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "    @;   #+   `@@@@'     "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "   ,@@@' @     @@@@@     "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "   @@@@@@@     .@@@@; +  "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "   @@@@@@       @@@@@@+  "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "    +@@@@       .@@@@#   "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "      @@.        #@@@    "
SxriptLogoSize = SxriptLogoSize + 1
SxriptLogoText(SxriptLogoSize) = "       `          `+     "

BrackList = "`',()<>[]{}"
OpList = "!^*/%+-=&|~?"
EscapeChar = "\"

FunctionListSize = 0
VariableListSize = 0
ScopeLevel = 1

' JavaScript: STARTSKIP
DIM kt AS INTEGER
DIM at AS STRING
DIM bt AS STRING
at = "<"
FOR kt = 1 TO SxriptLogoSize
    bt = SxriptLogoText(kt)
    bt = ReplaceRaw$(bt, "`", CHR$(26))
    bt = ReplaceRaw$(bt, CHR$(26), EscapeChar + "`")
    bt = ReplaceRaw$(bt, "'", CHR$(26))
    bt = ReplaceRaw$(bt, CHR$(26), EscapeChar + "'")
    bt = "`" + bt + "'"
    at = at + bt
    IF (kt < SxriptLogoSize) THEN
        at = at + ","
    END IF
NEXT
at = at + ">"
at = SxriptEval$("let(sxlogo,apply($({[x]\n})," + at + "))")
' JavaScript: ENDSKIP

'\\}());
' CPP: ENDSKIP

' '''''''''' '''''''''' '''''''''' '''''''''' ''''''''''
