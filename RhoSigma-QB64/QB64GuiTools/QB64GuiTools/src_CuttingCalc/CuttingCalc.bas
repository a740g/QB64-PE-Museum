'$INCLUDE: '..\dev_framework\classes\GuiClasses.bi'
'$INCLUDE: '..\dev_framework\support\TagSupport.bi'

'$INCLUDE: '..\dev_framework\support\BufferSupport.bi'

'*****************************************************
'$INCLUDE: '..\dev_framework\GuiAppFrame.bi'
'*****************************************************

'+---------------+---------------------------------------------------+
'| ###### ###### |     .--. .         .-.                            |
'| ##  ## ##   # |     |   )|        (   ) o                         |
'| ##  ##  ##    |     |--' |--. .-.  `-.  .  .-...--.--. .-.        |
'| ######   ##   |     |  \ |  |(   )(   ) | (   ||  |  |(   )       |
'| ##      ##    |     '   `'  `-`-'  `-'-' `-`-`|'  '  `-`-'`-      |
'| ##     ##   # |                            ._.'                   |
'| ##     ###### | Sources & Documents placed under the MIT License. |
'+---------------+---------------------------------------------------+
'|                                                                   |
'| === CuttingCalc.bas ===                                           |
'|                                                                   |
'| == A small neat App to calculate values for machine tool practice,|
'| == mainly milling, such as Spindle Speed and Feed Rate.           |
'| == Features two languages as well as metric and imperial units.   |
'|                                                                   |
'| == I need this very often for my Job in the automotive division.  |
'| == Of course there are plenty of software and online solutions for|
'| == this already, but now with my GuiTools Framework I could do my |
'| == very own little calculator.                                    |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

'~~~ My Init/Exit Handlers
UserInitHandler:
'=====================================================================
'==================== START OF USER INIT HANDLER =====================
'=====================================================================
'As this handler is called from the init code in file "GuiAppFrame.bi"
'as a GOSUB routine, you must end or exit it with a single RETURN !!
'        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'        !!! DON'T DELETE THIS HANDLER, EVEN IF LEFT EMPTY !!!
'        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'Here you should place the write back calls of any embedded data files.
'Not required but best to use is appTempDir$ + "original name" as filename.
'Going this way has an advantage for image files, here you'd only need to
'specify the literal image name (ie. without path) for any ImageC objects
'or MessageBox/Dialog header icon images, as appTempDir$ is part of the
'internal image search tree (ImageClass). For all other uses (where a full
'filename and path is required, eg. _LOADIMAGE), you simply use the result
'of the write back call. That said, it seems also to be a good idea to
'DIM SHARED the result variables in order to make them available in all
'SUBs and FUNCTIONs. It's also considered good style to TempLog() the
'written files in order for a correct cleanup in error/crash cases.
'=====================================================================
DIM SHARED RhoSigmaImgName$ 'my own icon used in SetupScreen()
RhoSigmaImgName$ = WriteRhoSigmaImgArray$(appTempDir$ + "RhoSigma32px.png", -1)
PlasmaImgName$ = WritePlasmaImgArray$(appTempDir$ + "Plasma.jpg", -1)
DeFlagImgName$ = WriteDeFlagImgArray$(appTempDir$ + "de20px.gif", -1)
UkFlagImgName$ = WriteUkFlagImgArray$(appTempDir$ + "uk20px.gif", -1)
ExitImgName$ = WriteExitImgArray$(appTempDir$ + "Exit32px.png", -1)
HelpImgName$ = WriteHelpImgArray$(appTempDir$ + "Help32px.png", -1)
CopyImgName$ = WriteCopyImgArray$(appTempDir$ + "Copy32px.png", -1)
TempLog RhoSigmaImgName$, "": TempLog PlasmaImgName$, ""
TempLog DeFlagImgName$, "": TempLog UkFlagImgName$, ""
TempLog ExitImgName$, "": TempLog HelpImgName$, "": TempLog CopyImgName$, ""
'--- the next 3 blocks should always be kept ---
DIM SHARED Info16Img$, Info32Img$ 'for Info MsgBoxes
Info16Img$ = WriteInfo16ImgData$(appTempDir$ + "Info16px.png")
Info32Img$ = WriteInfo32ImgData$(appTempDir$ + "Info32px.png")
TempLog Info16Img$, "": TempLog Info32Img$, ""
DIM SHARED Problem16Img$, Problem32Img$ 'for warning/problem MsgBoxes
Problem16Img$ = WriteProblem16ImgData$(appTempDir$ + "Problem16px.png")
Problem32Img$ = WriteProblem32ImgData$(appTempDir$ + "Problem32px.png")
TempLog Problem16Img$, "": TempLog Problem32Img$, ""
DIM SHARED Error16Img$, Error32Img$ 'for error MsgBoxes
Error16Img$ = WriteError16ImgData$(appTempDir$ + "Error16px.png")
Error32Img$ = WriteError32ImgData$(appTempDir$ + "Error32px.png")
TempLog Error16Img$, "": TempLog Error32Img$, ""
RETURN
'=====================================================================
'===================== END OF USER INIT HANDLER ======================
'=====================================================================

UserExitHandler:
'=====================================================================
'==================== START OF USER EXIT HANDLER =====================
'=====================================================================
'As this handler is called by the cleanup code in file "GuiAppFrame.bi"
'as a GOSUB routine, you must end or exit it with a single RETURN !!
'        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'        !!! DON'T DELETE THIS HANDLER, EVEN IF LEFT EMPTY !!!
'        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'Here you should delete the files written back via the Init handler, even
'if the files were added to the Temp logging system for automatic cleanup.
'Keep in mind, that the current directory (CHDIR) may have changed during
'your program's runtime. That's another reason why I recommended the use
'of appTempDir$ for the file writeback, it's a known absolut path.
'=====================================================================
KILL Error32Img$: KILL Error16Img$
KILL Problem32Img$: KILL Problem16Img$
KILL Info32Img$: KILL Info16Img$
RETURN
'=====================================================================
'===================== END OF USER EXIT HANDLER ======================
'=====================================================================
'~~~~~

'~~~ My Error Handler
UserErrorHandler:
'=====================================================================
'=================== START OF USER ERROR HANDLER =====================
'=====================================================================
'    !!! DON'T DEFINE YOUR OWN HANDLERS VIA "ON ERROR GOTO ..." !!!
'    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'Add more CASEs to the SELECT CASE statement below to handle specific
'errors. Some cases are prepared, just uncomment and fill it. All other
'errors can be considered syntax or logic programming errors, which
'should be solved through bugfixing. Don't change the CASE ELSE branch,
'it handles the remaining error numbers without an own CASE statement.
'     /---!!!---\
'Every active CASE must set a resume type (uehResType%) to one of the
'defined CONSTs (see below this text), DON'T use a RESUME instruction
'directly to resume from any CASE. This handler does for safety reasons
'not support "RESUME label" (except emergencyExit:) because of its dirty
'implementation in QB64 (may cause stack overflows if used over and over).
'If it turns out you can't resolve an error you started handling, then
'always set the resume type to uehEXIT% in order for a correct program
'cleanup procedure.
'     \---!!!---/
'If you want to turn off the error trapping during development, so that
'QB64 will report any errors in the usual Continue?-Yes/No-MessageBox,
'then simply set the CONST ErrorHandlerSwitch$ below to "OFF", which will
'switch off this user handler, but not the internal error handler in the
'file "GuiAppFrame.bi", which is for program flow control only. If you
'really need all error trapping off, then set the CONST to "DISABLED",
'but be aware that it may even affect some GuiTools internal behavior.
'=====================================================================
CONST ErrorHandlerSwitch$ = "ON" 'ON, OFF or DISABLED
CONST uehRETRY% = 1, uehNEXT% = 2, uehEXIT% = 3
'-----
appLastErr% = ERR
IF appLastErr% = 1000 THEN RESUME emergencyExit 'immediate exit request

IF appErrCnt% >= appErrMax% THEN
    dummy$ = MessageBox$("Error16px.png", appExeName$,_
                         "Error handler reports too many|" +_
                         "recursive Errors !!|~" +_
                         "Program will cleanup and terminate|" +_
                         "via internal emergency exit.",_
                         "{IMG Error16px.png 39}Ok, got it...")
    RESUME emergencyExit
END IF

appErrCnt% = appErrCnt% + 1
appErrorArr%(appErrCnt%, 0) = appLastErr%
appErrorArr%(appErrCnt%, 1) = _ERRORLINE
QB64ErrorOff
SELECT CASE appLastErr%
    'CASE 24 'device timeout
    '    uehResType% = uehEXIT%
    'CASE 25 'device fault
    '    uehResType% = uehEXIT%
    'CASE 27 'printer out of paper
    '    uehResType% = uehEXIT%
    'CASE 53 'file not found
    '    uehResType% = uehEXIT%
    'CASE 57 'device i/o error
    '    uehResType% = uehEXIT%
    'CASE 58 'file already exists
    '    uehResType% = uehEXIT%
    'CASE 61 'disk full
    '    uehResType% = uehEXIT%
    'CASE 68 'device unavailable
    '    uehResType% = uehEXIT%
    'CASE 69 'communication buffer overflow
    '    uehResType% = uehEXIT%
    'CASE 70 'permission denied
    '    uehResType% = uehEXIT%
    'CASE 71 'disk not ready
    '    uehResType% = uehEXIT%
    'CASE 72 'disk media error
    '    uehResType% = uehEXIT%
    'CASE 74 'rename across disks
    '    uehResType% = uehEXIT%
    'CASE 75 'path/file access error
    '    uehResType% = uehEXIT%
    'CASE 76 'path not found
    '    uehResType% = uehEXIT%
    CASE ELSE
        uehText$ = "Unhandled Runtime Error" + STR$(appErrorArr%(appErrCnt%, 0))
        uehText$ = uehText$ + " occurred|in source file line" + STR$(appErrorArr%(appErrCnt%, 1))
        uehText$ = uehText$ + " !!|~Program will cleanup and terminate|via internal emergency exit."
        dummy$ = MessageBox$("Error16px.png", appExeName$, uehText$,_
                             "{IMG Error16px.png 39}Ok, got it...")
        uehResType% = uehEXIT%
END SELECT
QB64ErrorOn
IF uehResType% = uehEXIT% THEN 'resume type EXIT
    appErrCnt% = 0
    RESUME emergencyExit
END IF
appErrCnt% = appErrCnt% - 1
IF _EXIT THEN RESUME emergencyExit 'last chance for a clean abort if caught in endless ERROR/RESUME retry loop (don't delete this line)
IF uehResType% = uehNEXT% THEN RESUME NEXT 'resume type NEXT
RESUME 'resume type RETRY
'=====================================================================
'==================== END OF USER ERROR HANDLER ======================
'=====================================================================
'~~~~~

UserMain:
'=====================================================================
'==================== START OF USER MAIN ROUTINE =====================
'=====================================================================
'This is your main program. Because it is called by the init code in
'file "GuiAppFrame.bi" as a GOSUB routine, it must end with a RETURN !!
'   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'   !!! NEVER USE "$CHECKING:OFF" OR "CLEAR" WITHIN YOUR CODE !!!
'   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'For your info, the active current directory (CHDIR) at this point is
'where the EXE file of your program is located (ie. appHomePath$).
'=====================================================================

SetupScreen 416, 375, 0
_TITLE VersionCuttingCalc$

'------------------------------
'--- Early required Globals ---
'------------------------------
'--- Here would be a good place to define early required global
'--- variables, ie. those already needed for object initialization.
'-----
'--- Sometimes you may need one or more private pens, which are not used
'--- for image remapping, so you can change its RGB values without making
'--- any remapped images looking ugly. The pens are reserved at the end
'--- of the palette (eg. 1 reserved = pen 255, 2 reserved = pens 254-255)
CONST guiReservedPens% = 0 'no reserved pens
'-----
langIdx% = 1 'actual language index according to CycleListLanguage$ below
systIdx% = 1 'actual unit system index according to CycleListSystem$ below
numFmt$ = "0{#####.###}" 'initial number format (3 fractional digits for metric)
extFac% = 1000 'initial velocity extension factor (metric)

'--- define some initial default values for the input fields ---
d$ = "10.000": z$ = "2"
fz$ = "0.150": fn$ = "0.300": vc$ = "120.000"
n$ = "3820": vf$ = "1146"

'~~~ My GUI Setup
'-----------------------------
'--- Init GUI objects here ---
'-----------------------------

'--- init window background image ---
ImageWallpaper$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Plasma.jpg") +_
        NewTag$("BACKFILL", "true") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "0") +_
        NewTag$("TOP", "0"))
'--- init top ruler ---
TopRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "12") +_
        NewTag$("TOP", "53") +_
        NewTag$("LENGTH", "392"))
'--- init attention string image ---
StringImageAttn$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Problem32px.png") +_
        NewTag$("CLEARCOLOR", "39") +_
        NewTag$("LEFT", "80") +_
        NewTag$("TOP", "4") +_
        NewTag$("WIDTH", "22") +_
        NewTag$("HEIGHT", "22"))
'--- init bottom ruler ---
BottomRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "12") +_
        NewTag$("TOP", "322") +_
        NewTag$("LENGTH", "392"))
'--- init quit button image ---
ButtonImageQuit$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Exit32px.png") +_
        NewTag$("CLEARCOLOR", "39") +_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "24") +_
        NewTag$("HEIGHT", "24"))
'--- init help button image ---
ButtonImageHelp$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Help32px.png") +_
        NewTag$("CLEARCOLOR", "39") +_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "24") +_
        NewTag$("HEIGHT", "24"))
'--- init help button ---
ButtonHelp$ = ButtonC$("INIT",_
        ImageTag$(ButtonImageHelp$) +_
        NewTag$("LEFT", "191") +_
        NewTag$("TOP", "334") +_
        NewTag$("WIDTH", "34") +_
        NewTag$("HEIGHT", "34"))
'--- init copy button image ---
ButtonImageCopy$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Copy32px.png") +_
        NewTag$("CLEARCOLOR", "39") +_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "24") +_
        NewTag$("HEIGHT", "24"))

'--- init language translations list using custom user tags ---
ListLanguages$ = ListC$("INIT", "")
'--- cycler options ---
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "CYC_OPT_Metric") +_
        NewTag$("L_Deutsch", "Metrisch") +_
        NewTag$("L_English", "Metric"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "CYC_OPT_Imperial") +_
        NewTag$("L_Deutsch", "Imperial") +_
        NewTag$("L_English", "Imperial"))
'--- string field labels ---
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "STR_LBL_Diameter") +_
        NewTag$("L_Deutsch", "Werkzeugdurchmesser D  =") +_
        NewTag$("L_English", "Tool Diameter D  ="))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "STR_LBL_Teeth") +_
        NewTag$("L_Deutsch", "ZÑhneanzahl Z  =") +_
        NewTag$("L_English", "Number of Teeth T  ="))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "STR_LBL_PerTooth") +_
        NewTag$("L_Deutsch", "Zahnvorschub Fz =") +_
        NewTag$("L_English", "Feed per Tooth Ft ="))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "STR_LBL_PerRev") +_
        NewTag$("L_Deutsch", "Vorschub pro Umdrehung Fn =") +_
        NewTag$("L_English", "Feed per Revolution Fn ="))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "STR_LBL_CutSpeed") +_
        NewTag$("L_Deutsch", "Schnittgeschwindigkeit Vc =") +_
        NewTag$("L_English", "Cutting Speed Vc ="))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "STR_LBL_Speed") +_
        NewTag$("L_Deutsch", "Spindeldrehzahl N  =") +_
        NewTag$("L_English", "Spindle Speed N  ="))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "STR_LBL_Feed") +_
        NewTag$("L_Deutsch", "Vorschub Vf =") +_
        NewTag$("L_English", "Feed Rate Vf ="))
'--- button texts ---
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "BUT_TXT_Quit") +_
        NewTag$("L_Deutsch", "Beenden") +_
        NewTag$("L_English", "Quit"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "BUT_TXT_Copy") +_
        NewTag$("L_Deutsch", "NC-Kopie") +_
        NewTag$("L_English", "NC-Copy"))
'--- help texts ---
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "HLP_TIT_Help") +_
        NewTag$("L_Deutsch", "Hilfe") +_
        NewTag$("L_English", "Help"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "HLP_TXT_Help") +_
        NewTag$("L_Deutsch", "Funktion sollte offensichtlich sein:|" +_
                             "- Felder mit (!) sind generell erforderlich,|" +_
                             "  damit Åberhaupt gerechnet werden kann.|" +_
                             "- Eingaben in der wei·en Gruppe fÅhren zur|" +_
                             "  Neuberechnung der Gelben und umgekehrt.|" +_
                             "- Die Berechnungen erfolgen bereits bei der|" +_
                             "  Eingabe, kein extra <Enter> erforderlich.|~" +_
                             "Bedienung:|" +_
                             "- Beliebiges Eingabefeld mit Maus anwÑhlen|" +_
                             "  oder einfach <Enter> drÅcken (wÑhlt 1.Feld).|" +_
                             "- Mit Pfeiltasten hoch/runter oder TAB-Taste|" +_
                             "  durch die Felder navigieren.|" +_
                             "- Das aktive Feld unterstÅtzt die typischen|" +_
                             "  Funktionen zum editieren des Inhalts.|" +_
                             "- NC-Kopie anklicken, um Drehzahl u. Vorschub|" +_
                             "  zu kopieren, kann dann als Sxxx Fxxx in ein|" +_
                             "  NC-Programm eingefÅgt werden.") +_
        NewTag$("L_English", "Function should be obvious:|" +_
                             "- Fields marked with (!) are mandatory to be|" +_
                             "  able to calculate anything at all.|" +_
                             "- Inputs in the white group trigger recalulation|" +_
                             "  of the yellow one and vise versa.|" +_
                             "- Immediate recalculations while input, no|" +_
                             "  extra <Enter> press required.|~" +_
                             "Usage:|" +_
                             "- Select any field with mouse or simply press|" +_
                             "  <Enter> (will select 1st field).|" +_
                             "- Use arrow keys up/down or TAB-Key to navigate|" +_
                             "  through available fields.|" +_
                             "- The selected field does support the typical|" +_
                             "  functions to edit its contents.|" +_
                             "- Click NC-Copy to copy Spindle Speed and Feed|" +_
                             "  Rate, can be pasted into any NC-Program as|" +_
                             "  usual Sxxx Fxxx values."))
'--- metric/imperial units ---
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "MET_UNI_Length") +_
        NewTag$("L_Deutsch", "mm") +_
        NewTag$("L_English", "mm"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "IMP_UNI_Length") +_
        NewTag$("L_Deutsch", "Zoll") +_
        NewTag$("L_English", "Inch"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "MET_UNI_Fn") +_
        NewTag$("L_Deutsch", "mm/U") +_
        NewTag$("L_English", "mm/Rev"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "IMP_UNI_Fn") +_
        NewTag$("L_Deutsch", "Zoll/U") +_
        NewTag$("L_English", "Inch/Rev"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "MET_UNI_Vc") +_
        NewTag$("L_Deutsch", "m/min") +_
        NewTag$("L_English", "m/min"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "IMP_UNI_Vc") +_
        NewTag$("L_Deutsch", "Fu·/min") +_
        NewTag$("L_English", "SFM")) 'surface feet per minute
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "MET_UNI_Rpm") +_
        NewTag$("L_Deutsch", "U/min") +_
        NewTag$("L_English", "RPM")) 'revolutions per minute
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "IMP_UNI_Rpm") +_
        NewTag$("L_Deutsch", "U/min") +_
        NewTag$("L_English", "RPM")) 'same as metric, but duplicated to avoid a special case handling
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "MET_UNI_Vf") +_
        NewTag$("L_Deutsch", "mm/min") +_
        NewTag$("L_English", "mm/min"))
r$ = ListC$("STORE", ListLanguages$ +_
        NewTag$("DATA", "IMP_UNI_Vf") +_
        NewTag$("L_Deutsch", "Zoll/min") +_
        NewTag$("L_English", "Inch/min"))

'--- Init language cycler (chooser) list, also add respective ---
'--- flag image file specification using a custom user tag.   ---
CycleListLanguage$ = ListC$("INIT", "")
r$ = ListC$("STORE", CycleListLanguage$ +_
        NewTag$("DATA", "deutsch") +_
        NewTag$("CYC_IMG_Flag", "de20px.gif"))
r$ = ListC$("STORE", CycleListLanguage$ +_
        NewTag$("DATA", "english") +_
        NewTag$("CYC_IMG_Flag", "uk20px.gif"))

'--- The remaining stuff is done in a subroutine, as it's needed ---
'--- whenever the language or unit system is changed.            ---
GOSUB GUIInit
GOTO afterGUIInit 'continue after this stuff

GUIInit:
'--- first clean out old objects, if any ---
r$ = GenC$("KILL", ButtonCopy$): r$ = GenC$("KILL", ButtonQuit$)
r$ = GenC$("KILL", StringFeed$): r$ = GenC$("KILL", StringSpeed$)
r$ = GenC$("KILL", StringCutSpeed$): r$ = GenC$("KILL", StringPerRev$)
r$ = GenC$("KILL", StringPerTooth$): r$ = GenC$("KILL", StringTeeth$)
r$ = GenC$("KILL", StringDiameter$)
r$ = GenC$("KILL", CycleSystem$): r$ = GenC$("KILL", CycleListSystem$)
r$ = GenC$("KILL", CycleLanguage$): r$ = GenC$("KILL", CycleImageLanguage$)

'--- get actual language tag name ---
reco$ = GenC$("READ", CycleListLanguage$ + NewTag$("ACTUAL", LTRIM$(STR$(langIdx%))))
lang$ = "L_" + GetTagData$(reco$, "DATA", "")

'--- init language cycler flag image according to chosen language ---
CycleImageLanguage$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", GetTagData$(ListC$("SEARCH", CycleListLanguage$ +_
                             NewTag$("DATA", LCASE$(MID$(lang$, 3)))), "CYC_IMG_Flag", "")) +_
        NewTag$("LEFT", "161") +_
        NewTag$("TOP", "5"))
'--- Init language cycler (chooser), TEXTMOVEX is used to ---
'--- make some more space for the embedded flag image.    ---
CycleLanguage$ = CycleC$("INIT",_
        ListTag$(CycleListLanguage$) +_
        NewTag$("ACTUAL", LTRIM$(STR$(langIdx%))) +_
        ImageTag$(CycleImageLanguage$) +_
        NewTag$("TEXTMOVEX", "-12") +_
        NewTag$("LEFT", "16") +_
        NewTag$("TOP", "10") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "30"))

'--- init unit system cycler (chooser) list ---
CycleListSystem$ = ListC$("INIT", "")
r$ = ListC$("STORE", CycleListSystem$ +_
        NewTag$("DATA", GetTagData$(ListC$("SEARCH", ListLanguages$ +_
                        NewTag$("DATA", "CYC_OPT_Metric")), lang$, "")))
r$ = ListC$("STORE", CycleListSystem$ +_
        NewTag$("DATA", GetTagData$(ListC$("SEARCH", ListLanguages$ +_
                        NewTag$("DATA", "CYC_OPT_Imperial")), lang$, "")))
'--- init unit system cycler (chooser) ---
CycleSystem$ = CycleC$("INIT",_
        ListTag$(CycleListSystem$) +_
        NewTag$("ACTUAL", LTRIM$(STR$(systIdx%))) +_
        NewTag$("LEFT", "233") +_
        NewTag$("TOP", "10") +_
        NewTag$("WIDTH", "166") +_
        NewTag$("HEIGHT", "30"))

'--- get actual unit system prefix ---
odat$ = GenC$("GET", CycleSystem$ + NewTag$("TAGNAMES", "DATA"))
sysp$ = UCASE$(LEFT$(GetTagData$(odat$, "DATA", ""), 3))

'--- Init value input/display fields, note the special label handling, ---
'--- it's placed left, but moved to the right. Easy way to combine the ---
'--- descriptive label on the left side of the object and the unit on  ---
'--- the right, leaving SPACE$(n) for the object itself. Disadvantage  ---
'--- of this trick is the required filling with CHR$(255) (NBSP) to    ---
'--- keep the same (moved) startpositon designated by LABELMOVEX.      ---
StringCommon$ =_
        NewTag$("MAXIMUM", "8") +_
        NewTag$("LEFT", "233") +_
        NewTag$("WIDTH", "100") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("LABELMOVEX", "176") +_
        NewTag$("LABELPLACE", "left")
'--- tool diameter --
txt$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", "STR_LBL_Diameter")), lang$, "")
uni$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", sysp$ + "_UNI_Length")), lang$, "")
lab$ = txt$ + SPACE$(14) + uni$ + STRING$(8 - LEN(uni$), CHR$(255))
StringDiameter$ = StringC$("INIT", StringCommon$ +_
        ImageTag$(StringImageAttn$) +_
        NewTag$("ALLOWED", ".0123456789") +_
        NewTag$("TOP", "67") +_
        NewTag$("TEXT", d$) +_
        NewTag$("LABEL", lab$) +_
        NewTag$("SHORTCUT", MakeShortcut$("Return", 0, 0, 0)))
'--- number of teeth ---
txt$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", "STR_LBL_Teeth")), lang$, "")
uni$ = ""
lab$ = txt$ + SPACE$(14) + uni$ + STRING$(8 - LEN(uni$), CHR$(255))
StringTeeth$ = StringC$("INIT", StringCommon$ +_
        ImageTag$(StringImageAttn$) +_
        NewTag$("ALLOWED", "0123456789") +_
        NewTag$("TOP", "102") +_
        NewTag$("TEXT", z$) +_
        NewTag$("LABEL", lab$))
'--- feed per tooth ---
txt$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", "STR_LBL_PerTooth")), lang$, "")
uni$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", sysp$ + "_UNI_Length")), lang$, "")
lab$ = txt$ + SPACE$(14) + uni$ + STRING$(8 - LEN(uni$), CHR$(255))
StringPerTooth$ = StringC$("INIT", StringCommon$ +_
        NewTag$("ALLOWED", ".0123456789") +_
        NewTag$("TOP", "137") +_
        NewTag$("TEXT", fz$) +_
        NewTag$("LABEL", lab$))
'--- feed per revolution ---
txt$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", "STR_LBL_PerRev")), lang$, "")
uni$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", sysp$ + "_UNI_Fn")), lang$, "")
lab$ = txt$ + SPACE$(14) + uni$ + STRING$(8 - LEN(uni$), CHR$(255))
StringPerRev$ = StringC$("INIT", StringCommon$ +_
        NewTag$("ALLOWED", ".0123456789") +_
        NewTag$("TOP", "172") +_
        NewTag$("TEXT", fn$) +_
        NewTag$("LABEL", lab$))
'--- cutting speed ---
txt$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", "STR_LBL_CutSpeed")), lang$, "")
uni$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", sysp$ + "_UNI_Vc")), lang$, "")
lab$ = txt$ + SPACE$(14) + uni$ + STRING$(8 - LEN(uni$), CHR$(255))
StringCutSpeed$ = StringC$("INIT", StringCommon$ +_
        NewTag$("ALLOWED", ".0123456789") +_
        NewTag$("TOP", "207") +_
        NewTag$("TEXT", vc$) +_
        NewTag$("LABEL", lab$))
'--- spindle speed ---
txt$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", "STR_LBL_Speed")), lang$, "")
uni$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", sysp$ + "_UNI_Rpm")), lang$, "")
lab$ = txt$ + SPACE$(14) + uni$ + STRING$(8 - LEN(uni$), CHR$(255))
StringSpeed$ = StringC$("INIT", StringCommon$ +_
        NewTag$("ALLOWED", "0123456789") +_
        NewTag$("TOP", "242") +_
        NewTag$("LABELHIGH", "true") +_
        NewTag$("TEXT", n$) +_
        NewTag$("LABEL", lab$))
'--- feed rate ---
txt$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", "STR_LBL_Feed")), lang$, "")
uni$ = GetTagData$(ListC$("SEARCH", ListLanguages$ + NewTag$("DATA", sysp$ + "_UNI_Vf")), lang$, "")
lab$ = txt$ + SPACE$(14) + uni$ + STRING$(8 - LEN(uni$), CHR$(255))
StringFeed$ = StringC$("INIT", StringCommon$ +_
        NewTag$("ALLOWED", "0123456789") +_
        NewTag$("TOP", "277") +_
        NewTag$("LABELHIGH", "true") +_
        NewTag$("TEXT", vf$) +_
        NewTag$("LABEL", lab$))

'--- init quit button ---
ButtonQuit$ = ButtonC$("INIT",_
        ImageTag$(ButtonImageQuit$) +_
        NewTag$("LEFT", "21") +_
        NewTag$("TOP", "334") +_
        NewTag$("WIDTH", "150") +_
        NewTag$("HEIGHT", "34") +_
        NewTag$("TEXT", GetTagData$(ListC$("SEARCH", ListLanguages$ +_
                        NewTag$("DATA", "BUT_TXT_Quit")), lang$, "")))
'--- init copy button ---
ButtonCopy$ = ButtonC$("INIT",_
        ImageTag$(ButtonImageCopy$) +_
        NewTag$("LEFT", "245") +_
        NewTag$("TOP", "334") +_
        NewTag$("WIDTH", "150") +_
        NewTag$("HEIGHT", "34") +_
        NewTag$("TEXT", GetTagData$(ListC$("SEARCH", ListLanguages$ +_
                        NewTag$("DATA", "BUT_TXT_Copy")), lang$, "")))
RETURN
afterGUIInit:
'~~~~~

'-----------------------
'--- Runtime Globals ---
'-----------------------
'--- Here we can define the remaining global variables, which are not
'--- needed for object initialization, but during runtime.
'-----
done% = 0 'our main loop continuation boolean

'~~~ My Main Loop
'---------------------------------
'--- Now let's operate the GUI ---
'---------------------------------
'--- This is simply done by placing a GetGUIMsg$() call within our main
'--- loop and then take actions according to the received messages.
'-----
_MOUSESHOW
WHILE NOT done%
    _LIMIT 50
    mess$ = GetGUIMsg$
    '--------------- START OF EVENT HANDLER ---------------
    'Here comes a generic event handler, which can be used in this form
    'in any GuiTools based programs. Just fill the required event type
    'files with your magic. The event types telling you, what all has
    'happened since last GetGUIMsg$() call, some events will also deliver
    'additional informations. Also every message has tags containing the
    'current mouse position and mousebutton states. (see KnownTags.txt)
    'Look into the handler include files for detailed descriptions of the
    'respective event types.
    '$INCLUDE: 'handlers\guirefresh.bm'
    '$INCLUDE: 'handlers\userbreak.bm'
    '$INCLUDE: 'handlers\keypress.bm'
    '$INCLUDE: 'handlers\mouselbdown.bm'
    '$INCLUDE: 'handlers\mouselbup.bm'
    '$INCLUDE: 'handlers\mouserbdown.bm'
    '$INCLUDE: 'handlers\mouserbup.bm'
    '$INCLUDE: 'handlers\mousembdown.bm'
    '$INCLUDE: 'handlers\mousembup.bm'
    '$INCLUDE: 'handlers\mousescroll.bm'
    '$INCLUDE: 'handlers\mousemove.bm'
    '-----
    'The next five event types are not simply true or false (boolean),
    'but its value reflects the index of the respective object responsible
    'for the event. Note that the values of MOUSEOVER and the GADGETxxx
    'tags must not necessarily match. As it is possible to select objects
    'via keyboard shortcuts, it may happen that the mousepointer is over
    'one object, while another object is selected via shortcut.
    '-----
    '$INCLUDE: 'handlers\mousein.bm'
    '$INCLUDE: 'handlers\mouseout.bm'
    '$INCLUDE: 'handlers\mouseover.bm'
    '$INCLUDE: 'handlers\gadgetdown.bm'
    '$INCLUDE: 'handlers\gadgetup.bm'
    '---------------- END OF EVENT HANDLER ----------------
WEND
'~~~~~

'---------------------
'--- Final Cleanup ---
'---------------------
CloseScreen
RETURN 'return to the GuiTools Framework init/cleanup procedure
'=====================================================================
'===================== END OF USER MAIN ROUTINE ======================
'=====================================================================

'=====================================================================
'============== START OF USER GOSUB/SUB/FUNCTION AREA ================
'=====================================================================
'~~~ My GOSUB routines
'=====================================================================
'One possible usage here could be to outsource any recurring code
'sequences from the various event handlers into subroutines and let the
'handlers then just call these subroutines, instead of placing the same
'code over and over in every handler. This way the code would be much
'easier maintainable and it would also help to keep the filesize of the
'compiled EXEs down, as the code appears only one time instead of many
'times in several places.
'=====================================================================
RecurringCode: 'just a sample
'do something
RETURN
'~~~~~
'---------------------------------------------------------------------
'~~~ My SUBs/FUNCs
'=====================================================================
'This is a simple help function for debugging. If any method call seems
'not to give you the expected results, then you can enclose the call with
'this function. If the method call will return any errors or warnings,
'then these will be shown to you in a MessageBox. If no errors/warnings
'are returned, then it will simply put through the method call's result.
'  USAGE:  result$ = ShowErr$(AnyClassC$("ANYMETHOD", methodTags$))
'You should remove this function again, after all bugs are fixed and your
'method calls do work properly without errors/warnings, or at least set
'the CONST ShowErrSwitch$ right below to "OFF".
'=====================================================================
CONST ShowErrSwitch$ = "ON" 'ON or OFF
'-----
FUNCTION ShowErr$ (tagString$)
    ShowErr$ = tagString$
    IF UCASE$(ShowErrSwitch$) = "ON" THEN
        IF ValidateTags%(tagString$, "ERROR", -1) THEN
        dummy$ = MessageBox$("Error16px.png", "Error Tag",_
                             GetTagData$(tagString$, "ERROR", "empty"),_
                             "{IMG Error16px.png 39}Ok, got it...")
        ELSEIF ValidateTags%(tagString$, "WARNING", -1) THEN
        dummy$ = MessageBox$("Problem16px.png", "Warning Tag",_
                             GetTagData$(tagString$, "WARNING", "empty"),_
                             "{IMG Problem16px.png 39}Ok, got it...")
        END IF
    END IF
END FUNCTION
'--- Function to define/return the program's version string.
'-----
FUNCTION VersionCuttingCalc$
    VersionCuttingCalc$ = MID$("$VER: CuttingCalc 1.2 (14-Oct-2017) by RhoSigma :END$", 7, 41)
END FUNCTION
'~~~~~
'=====================================================================
'=============== END OF USER GOSUB/SUB/FUNCTION AREA =================
'=====================================================================

'~~~ My Screen Setup/Cleanup
'-------------------
'--- SetupScreen ---
'-------------------
' Will create a 256 colors SCREEN (active program window) of the given
' width/height and setup a standard palette, font and icon. Call this
' subroutine once at the entry point of your main program (UserMain:)
' to create/open your program window.
' Don't change this to another screen mode, as you will probably face a
' lot of errors then. The whole Framework is exclusively built around
' a 256 colors palette based screen.
' There are ready to use lines to load a custom font and/or icon, which
' you may uncomment and adjust for your needs, but everything else should
' remain unchanged.
'----------
' SYNTAX:
'   SetupScreen wid%, hei%, mid%
'----------
' INPUTS:
'   --- wid%, hei% ---
'    The desired SCREEN width and height respectively given in pixels.
'   --- mid% ---
'    This flag defines whether to middle the window on the desktop (-1)
'    or to move it to the last known (if any) window position (0).
'---------------------------------------------------------------------
SUB SetupScreen (wid%, hei%, mid%)
    '--- create the screen ---
    appScreen& = _NEWIMAGE(wid%, hei%, 256)
    IF appScreen& >= -1 THEN ERROR 1000 'can't create main screen
    IF appGLVComp% THEN _SCREENSHOW
    SCREEN appScreen&
    '--- setup screen palette ---
    '$INCLUDE: '..\dev_framework\GuiAppPalette.bm'
    ApplyPrefs "Global.Colors", ""
    '--- set default font ---
    'uncomment and adjust the _LOADFONT line below to load/use a custom font,
    'otherwise QB64's inbuilt default _FONT 16 is used
    'appFont& = _LOADFONT("C:\Windows\Fonts\timesbd.ttf", 16)
    IF appFont& > 0 THEN _FONT appFont&: ELSE _FONT 16
    '--- set default icon ---
    'uncomment and adjust the _LOADIMAGE line below to load a specific icon,
    'otherwise the GuiTools Framework's default icon is used as embedded via
    'the GuiAppIcon.h/.bm files located in the dev_framework folder
    appIcon& = _LOADIMAGE(RhoSigmaImgName$, 32)
    IF appIcon& < -1 THEN _ICON appIcon&
    'if you rather use $EXEICON then comment out the IF appIcon& ... line above
    'and uncomment and adjust the $EXEICON line below as you need instead, but
    'note it's QB64 v1.1+ then, older versions will throw an error on $EXEICON
    '$EXEICON:'..\images\icons\Default.ico'
    '--- make screen visible ---
    _DELAY 0.025
    IF mid% THEN
        desktop& = _SCREENIMAGE
        _SCREENMOVE (_WIDTH(desktop&) - wid%) / 2 - 4, (_HEIGHT(desktop&) - hei%) / 2 - 20
        _FREEIMAGE desktop&
    ELSE
        LastPosUpdate 0 'load last known win pos
    END IF
    _DELAY 0.025: _SCREENSHOW
    IF appGLVComp% THEN _DELAY 0.05: UntitledToTop
END SUB

'-------------------
'--- CloseScreen ---
'-------------------
' Will hide the SCREEN (active program window) and free all resources
' created by its counterpart SetupScreen(). Call this subroutine once
' at the end of your main program (UserMain:), hence right before the
' RETURN instruction.
'----------
' SYNTAX:
'   CloseScreen
'---------------------------------------------------------------------
SUB CloseScreen
    '--- make screen invisible ---
    _SCREENHIDE
    '--- free the icon (if any) and invalidate its handle ---
    IF appIcon& < -1 THEN _FREEIMAGE appIcon&: appIcon& = -1
    '--- free the font (if any) and invalidate its handle ---
    _FONT 16
    IF appFont& > 0 AND guiPGVCount% = 0 THEN _FREEFONT appFont&: appFont& = 0
    '--- free the screen and invalidate its handle ---
    SCREEN 0
    IF appScreen& < -1 THEN _FREEIMAGE appScreen&: appScreen& = -1
END SUB
'~~~~~

'*****************************************************
'$INCLUDE: '..\dev_framework\GuiAppFrame.bm'
'*****************************************************

'$INCLUDE: '..\dev_framework\support\BufferSupport.bm'
'$INCLUDE: '..\dev_framework\support\ConvertSupport.bm'
'$INCLUDE: '..\dev_framework\support\ImageSupport.bm'
'$INCLUDE: '..\dev_framework\support\PackSupport.bm'
'$INCLUDE: '..\dev_framework\support\PolygonSupport.bm'

'$INCLUDE: '..\dev_framework\support\TagSupport.bm'
'$INCLUDE: '..\dev_framework\classes\GuiClasses.bm'

'$INCLUDE: '..\dev_framework\classes\GenericClass.bm'
'$INCLUDE: '..\dev_framework\classes\ModelClass.bm'
'$INCLUDE: '..\dev_framework\classes\ListClass.bm'
'$INCLUDE: '..\dev_framework\classes\ImageClass.bm'
'$INCLUDE: '..\dev_framework\classes\SymbolClass.bm'
'$INCLUDE: '..\dev_framework\classes\RulerClass.bm'
'$INCLUDE: '..\dev_framework\classes\FrameClass.bm'
'$INCLUDE: '..\dev_framework\classes\StringClass.bm'
'$INCLUDE: '..\dev_framework\classes\TextClass.bm'
'$INCLUDE: '..\dev_framework\classes\ProgressClass.bm'
'$INCLUDE: '..\dev_framework\classes\PagerClass.bm'
'$INCLUDE: '..\dev_framework\classes\ButtonClass.bm'
'$INCLUDE: '..\dev_framework\classes\CheckboxClass.bm'
'$INCLUDE: '..\dev_framework\classes\CycleClass.bm'
'$INCLUDE: '..\dev_framework\classes\RadioClass.bm'
'$INCLUDE: '..\dev_framework\classes\ListviewClass.bm'
'$INCLUDE: '..\dev_framework\classes\SliderClass.bm'
'$INCLUDE: '..\dev_framework\classes\ScrollerClass.bm'
'$INCLUDE: '..\dev_framework\classes\ColorwheelClass.bm'

'$INCLUDE: 'inline\RhoSigmaImg.bm'
'$INCLUDE: 'inline\PlasmaImg.bm'
'$INCLUDE: 'inline\DeFlagImg.bm'
'$INCLUDE: 'inline\UkFlagImg.bm'
'$INCLUDE: 'inline\ExitImg.bm'
'$INCLUDE: 'inline\HelpImg.bm'
'$INCLUDE: 'inline\CopyImg.bm'

'$INCLUDE: 'inline\Info16Img.bm'
'$INCLUDE: 'inline\Info32Img.bm'
'$INCLUDE: 'inline\Problem16Img.bm'
'$INCLUDE: 'inline\Problem32Img.bm'
'$INCLUDE: 'inline\Error16Img.bm'
'$INCLUDE: 'inline\Error32Img.bm'

