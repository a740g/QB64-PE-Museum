'$INCLUDE: 'QB64GuiTools\dev_framework\classes\GuiClasses.bi'
'$INCLUDE: 'QB64GuiTools\dev_framework\support\TagSupport.bi'

'$INCLUDE: 'QB64GuiTools\dev_framework\support\BufferSupport.bi'

'*****************************************************
'$INCLUDE: 'QB64GuiTools\dev_framework\GuiAppFrame.bi'
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
'| === MakeDATA.bas ===                                              |
'|                                                                   |
'| == Create a DATA block out of the given file, so you can embed it |
'| == in your program and write it back when needed.                 |
'|                                                                   |
'| == The DATAs are written into a .bm file together with a ready to |
'| == use write back FUNCTION. You just $INCLUDE this .bm file into  |
'| == your program and call the write back FUNCTION somewhere.       |
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
TempLog RhoSigmaImgName$, "": TempLog PlasmaImgName$, ""
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

SetupScreen 480, 273, 0
appCR$ = "Convert File to DATAs v1.1, Done by RhoSigma, Roland Heyder"
_TITLE appExeName$ + " - " + appCR$

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
use% = -1 'initial "Use LZW Packing" checkbox state
'-----
pfnChars$ = "" 'allowed chars for path/file names
FOR i% = 32 TO 255
    SELECT CASE i%
        CASE 34, 42, 47, 60, 62, 63, 124
            'not allowed
        CASE ELSE
            pfnChars$ = pfnChars$ + CHR$(i%)
    END SELECT
NEXT i%
'-----

'~~~ My GUI Setup
'-----------------------------
'--- Init GUI objects here ---
'-----------------------------
BackImage$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Plasma.jpg") +_
        NewTag$("BACKFILL", "yes") +_
        NewTag$("AREA", "on") +_
        NewTag$("LEFT", "0") +_
        NewTag$("TOP", "0"))
InputRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "10") +_
        NewTag$("TOP", "15") +_
        NewTag$("LENGTH", "460") +_
        NewTag$("TEXT", "Inputs"))
GetFileSym$ = SymbolC$("INIT",_
        NewTag$("LEFT", "7") +_
        NewTag$("TOP", "7") +_
        NewTag$("WIDTH", "17") +_
        NewTag$("HEIGHT", "17") +_
        NewTag$("WHICH", "MediaDisk"))
InputSource$ = StringC$("INIT",_
        NewTag$("LEFT", "75") +_
        NewTag$("TOP", "30") +_
        NewTag$("WIDTH", "356") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("MAXIMUM", "259") +_
        NewTag$("ALLOWED", pfnChars$) +_
        NewTag$("LABEL", "Source:") +_
        NewTag$("LABELPLACE", "left") +_
        NewTag$("IMAGEFILE", "Aluminium.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("TOOLTIP", "Name of the file to convert into DATAs.|You can type and edit it here or click|the disk symbol for easy selection."))
GetSource$ = ButtonC$("INIT",_
        SymbolTag$(GetFileSym$) +_
        NewTag$("LEFT", "434") +_
        NewTag$("TOP", "30") +_
        NewTag$("WIDTH", "31") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("IMAGEFILE", "Crap.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("TOOLTIP", "File Load Dialog"))
InputTarget$ = StringC$("INIT",_
        NewTag$("LEFT", "75") +_
        NewTag$("TOP", "70") +_
        NewTag$("WIDTH", "356") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("MAXIMUM", "259") +_
        NewTag$("ALLOWED", pfnChars$) +_
        NewTag$("LABEL", "Target:") +_
        NewTag$("LABELPLACE", "left") +_
        NewTag$("IMAGEFILE", "Aluminium.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("DISABLED", "yes") +_
        NewTag$("TOOLTIP", "Name of the file to save the DATAs to.|You can type and edit it here or click|the disk symbol for easy selection."))
GetTarget$ = ButtonC$("INIT",_
        SymbolTag$(GetFileSym$) +_
        NewTag$("LEFT", "434") +_
        NewTag$("TOP", "70") +_
        NewTag$("WIDTH", "31") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("IMAGEFILE", "Crap.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("DISABLED", "yes") +_
        NewTag$("TOOLTIP", "File Save Dialog"))
InputRatio$ = SliderC$("INIT",_
        NewTag$("LEFT", "116") +_
        NewTag$("TOP", "110") +_
        NewTag$("WIDTH", "315") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("MINIMUM", "1") +_
        NewTag$("MAXIMUM", "50") +_
        NewTag$("LEVEL", "20") +_
        NewTag$("LABEL", "Least Ratio:") +_
        NewTag$("LABELPLACE", "left") +_
        NewTag$("IMAGEFILE", "PaperGray.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("DISABLED", LTRIM$(STR$(NOT use%))) +_
        NewTag$("TOOLTIP", "If packing gives less ratio than this, then|convert it unpacked and rather save the|time required for unpacking at writeback."))
UseLzw$ = CheckboxC$("INIT",_
        NewTag$("LEFT", "434") +_
        NewTag$("TOP", "110") +_
        NewTag$("WIDTH", "31") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("CHECKED", LTRIM$(STR$(use%))) +_
        NewTag$("IMAGEFILE", "MarbleBrown.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("TOOLTIP", "Use LZW Packing"))
OutputRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "10") +_
        NewTag$("TOP", "156") +_
        NewTag$("LENGTH", "460") +_
        NewTag$("TEXT", "Outputs"))
OutputState$ = TextC$("INIT",_
        NewTag$("LEFT", "15") +_
        NewTag$("TOP", "171") +_
        NewTag$("WIDTH", "100") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("TEXT", "get inputs") +_
        NewTag$("FORM", "simple") +_
        NewTag$("IMAGEFILE", "Aluminium.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("TOOLTIP", "Shows the current program state."))
OutputProgress$ = ProgressC$("INIT",_
        NewTag$("LEFT", "120") +_
        NewTag$("TOP", "171") +_
        NewTag$("WIDTH", "345") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("IMAGEFILE", "WallRough.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("TOOLTIP", "Shows packing/converting progress."))
BottomRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "10") +_
        NewTag$("TOP", "217") +_
        NewTag$("LENGTH", "460"))
Start$ = ButtonC$("INIT",_
        NewTag$("LEFT", "45") +_
        NewTag$("TOP", "232") +_
        NewTag$("WIDTH", "100") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("TEXT", "Start") +_
        NewTag$("IMAGEFILE", "Crap.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("DISABLED", "yes") +_
        NewTag$("TOOLTIP", "Start converting into DATAs."))
Reset$ = ButtonC$("INIT",_
        NewTag$("LEFT", "190") +_
        NewTag$("TOP", "232") +_
        NewTag$("WIDTH", "100") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("TEXT", "Reset") +_
        NewTag$("IMAGEFILE", "Crap.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("DISABLED", "yes") +_
        NewTag$("TOOLTIP", "Clear all file input fields."))
Cancel$ = ButtonC$("INIT",_
        NewTag$("LEFT", "335") +_
        NewTag$("TOP", "232") +_
        NewTag$("WIDTH", "100") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("TEXT", "Cancel") +_
        NewTag$("IMAGEFILE", "Crap.jpg") +_
        NewTag$("AREA", "on") +_
        NewTag$("TOOLTIP", "Cancel, quit program."))
'~~~~~

'-----------------------
'--- Runtime Globals ---
'-----------------------
'--- Here we can define the remaining global variables, which are not
'--- needed for object initialization, but during runtime.
'-----
done% = 0 'our main loop continuation boolean
'-----
DIM SHARED lzwProgress$ 'progress indicator object for LzwPack$()

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
'---------------------------------------------------------------------
'Convert the selected file into DATAs, the return value indicates
'whether to auto-reset the file input fields after the call or not.
'---------------------------------------------------------------------
FUNCTION ConvertFile%
SHARED srcPath$, src$, tarPath$, tar$, tarName$, rat%, use%
SHARED OutputState$, OutputProgress$
ConvertFile% = 0
'--- strip invalid chars for labels ---
tmp$ = tarName$: tarName$ = ""
FOR i% = 1 TO LEN(tmp$)
    a% = ASC(tmp$, i%)
    SELECT CASE a%
        CASE 48 TO 57, 65 TO 90, 97 TO 122 'keep only 0-9, Aa-Zz
            tarName$ = tarName$ + CHR$(a%)
    END SELECT
NEXT i%
MID$(tarName$, 1, 1) = UCASE$(MID$(tarName$, 1, 1)) 'capitalize 1st letter
'--- check files ---
IF (srcPath$ + src$) = (tarPath$ + tar$) THEN
    res$ = MessageBox$("Error16px.png", "Error !!",_
           "Source and Target files are the same!", "{IMG Error16px.png 39}I'll check")
    EXIT FUNCTION
END IF
IF _FILEEXISTS(tarPath$ + tar$) THEN
    res$ = MessageBox$("Problem16px.png", "Attention !!",_
           "Target file already exists,|do you want to overwrite?",_
           "{SYM Checkmark * * * *}Yes||{SYM Cross * * * *}No")
    IF res$ = "No" OR res$ = "" THEN EXIT FUNCTION
END IF
sff% = SafeOpenFile%("I", srcPath$ + src$)
IF sff% THEN CLOSE sff%: ELSE res$ = MessageBox$("Error16px.png", "Error !!",_
                                   "Can't open/access source file!", "{IMG Error16px.png 39}I'll check")
tff% = SafeOpenFile%("O", tarPath$ + tar$)
IF tff% THEN CLOSE tff%: ELSE res$ = MessageBox$("Error16px.png", "Error !!",_
                                   "Can't open/access target file!", "{IMG Error16px.png 39}I'll check")
IF sff% = 0 OR tff% = 0 THEN EXIT FUNCTION
'--- init converter ---
IF use% THEN 'packing requested?
    OPEN "B", #1, srcPath$ + src$
    filedata$ = SPACE$(LOF(1))
    GET #1, , filedata$
    CLOSE #1
    res$ = GenC$("SET", OutputState$ + NewTag$("TEXT", "packing"))
    lzwProgress$ = OutputProgress$ 'set progress indicator for LzwPack$()
    rawdata$ = LzwPack$(filedata$, rat%)
    IF rawdata$ <> "" THEN
        tmpLzw$ = appTempDir$ + GetUniqueID$
        TempLog tmpLzw$, "MODULE: MakeDATA CONTENTS: Temporary compressed file data."
        OPEN "O", #1, tmpLzw$: CLOSE #1
        OPEN "B", #1, tmpLzw$: PUT #1, , rawdata$: CLOSE #1
        packed% = -1
        OPEN "B", #1, tmpLzw$
    ELSE
        packed% = 0
        OPEN "B", #1, srcPath$ + src$
    END IF
ELSE
    packed% = 0
    OPEN "B", #1, srcPath$ + src$
END IF
res$ = GenC$("SET", OutputState$ + NewTag$("TEXT", "converting"))
fl& = LOF(1)
cntL& = INT(fl& / 32)
cntB& = (fl& - (cntL& * 32))

'--- .bm include file ---
OPEN "O", #2, tarPath$ + tar$
PRINT #2, "'============================================================"
PRINT #2, "'=== This file was created with MakeDATA.bas by RhoSigma, ==="
PRINT #2, "'=== you must $INCLUDE this at the end of your program.   ==="
IF packed% THEN
    PRINT #2, "'=== ---------------------------------------------------- ==="
    PRINT #2, "'=== If your program is NOT a GuiTools based application, ==="
    PRINT #2, "'=== then it must also $INCLUDE: 'lzwpacker.bm' available ==="
    PRINT #2, "'=== from the Libraries Collection here:                  ==="
    PRINT #2, "'=== http://qb64phoenix.com/forum/forumdisplay.php?fid=23 ==="
END IF
PRINT #2, "'============================================================"
PRINT #2, ""
'--- writeback function ---
PRINT #2, "'"; STRING$(LEN(tarName$) + 18, "-")
PRINT #2, "'--- Write"; tarName$; "Data$ ---"
PRINT #2, "'"; STRING$(LEN(tarName$) + 18, "-")
PRINT #2, "' This function will write the DATAs you've created with MakeDATA.bas"
PRINT #2, "' back to disk and so it rebuilds the original file."
PRINT #2, "'"
PRINT #2, "' After the writeback call, only use the returned realFile$ to access the"
PRINT #2, "' written file. It's your given path, but with an maybe altered filename"
PRINT #2, "' (number added) in order to avoid the overwriting of an already existing"
PRINT #2, "' file with the same name in the given location."
PRINT #2, "'----------"
PRINT #2, "' SYNTAX:"
PRINT #2, "'   realFile$ = Write"; tarName$; "Data$ (wantFile$)"
PRINT #2, "'----------"
PRINT #2, "' INPUTS:"
PRINT #2, "'   --- wantFile$ ---"
PRINT #2, "'    The filename you would like to write the DATAs to, can contain"
PRINT #2, "'    a full or relative path."
PRINT #2, "'----------"
PRINT #2, "' RESULT:"
PRINT #2, "'   --- realFile$ ---"
PRINT #2, "'    - On success this is the path and filename finally used after all"
PRINT #2, "'      applied checks, use only this returned filename to access the"
PRINT #2, "'      written file."
PRINT #2, "'    - On failure this function will panic with the appropriate runtime"
PRINT #2, "'      error code which you may trap and handle as needed with your own"
PRINT #2, "'      ON ERROR GOTO... handler."
PRINT #2, "'---------------------------------------------------------------------"
PRINT #2, "FUNCTION Write"; tarName$; "Data$ (file$)"
PRINT #2, "'--- option _explicit requirements ---"
PRINT #2, "DIM po%, body$, ext$, num%, numL&, numB&, rawdata$, stroffs&, i&, dat&, ff%";
IF packed% THEN PRINT #2, ", filedata$": ELSE PRINT #2, ""
PRINT #2, "'--- separate filename body & extension ---"
PRINT #2, "FOR po% = LEN(file$) TO 1 STEP -1"
PRINT #2, "    IF MID$(file$, po%, 1) = "; CHR$(34); "."; CHR$(34); " THEN"
PRINT #2, "        body$ = LEFT$(file$, po% - 1)"
PRINT #2, "        ext$ = MID$(file$, po%)"
PRINT #2, "        EXIT FOR"
PRINT #2, "    ELSEIF MID$(file$, po%, 1) = "; CHR$(34); "\"; CHR$(34); " OR MID$(file$, po%, 1) = "; CHR$(34); "/"; CHR$(34); " OR po% = 1 THEN"
PRINT #2, "        body$ = file$"
PRINT #2, "        ext$ = "; CHR$(34); CHR$(34)
PRINT #2, "        EXIT FOR"
PRINT #2, "    END IF"
PRINT #2, "NEXT po%"
PRINT #2, "'--- avoid overwriting of existing files ---"
PRINT #2, "num% = 1"
PRINT #2, "WHILE _FILEEXISTS(file$)"
PRINT #2, "    file$ = body$ + "; CHR$(34); "("; CHR$(34); " + LTRIM$(STR$(num%)) + "; CHR$(34); ")"; CHR$(34); " + ext$"
PRINT #2, "    num% = num% + 1"
PRINT #2, "WEND"
PRINT #2, "'--- write DATAs ---"
PRINT #2, "RESTORE "; tarName$
PRINT #2, "READ numL&, numB&"
PRINT #2, "rawdata$ = SPACE$((numL& * 4) + numB&)"
PRINT #2, "stroffs& = 1"
PRINT #2, "FOR i& = 1 TO numL&"
PRINT #2, "    READ dat&"
PRINT #2, "    MID$(rawdata$, stroffs&, 4) = MKL$(dat&)"
PRINT #2, "    stroffs& = stroffs& + 4"
PRINT #2, "NEXT i&"
PRINT #2, "IF numB& > 0 THEN"
PRINT #2, "    FOR i& = 1 TO numB&"
PRINT #2, "        READ dat&"
PRINT #2, "        MID$(rawdata$, stroffs&, 1) = CHR$(dat&)"
PRINT #2, "        stroffs& = stroffs& + 1"
PRINT #2, "    NEXT i&"
PRINT #2, "END IF"
PRINT #2, "ff% = FREEFILE"
PRINT #2, "OPEN file$ FOR OUTPUT AS ff%"
IF packed% THEN
    PRINT #2, "CLOSE ff%"
    PRINT #2, "filedata$ = LzwUnpack$(rawdata$)"
    PRINT #2, "OPEN file$ FOR BINARY AS ff%"
    PRINT #2, "PUT #ff%, , filedata$"
ELSE
    PRINT #2, "PRINT #ff%, rawdata$;"
END IF
PRINT #2, "CLOSE ff%"
PRINT #2, "'--- set result ---"
PRINT #2, "Write"; tarName$; "Data$ = file$"
PRINT #2, "EXIT FUNCTION"
PRINT #2, ""
PRINT #2, "'--- DATAs representing the contents of file "; src$
PRINT #2, "'---------------------------------------------------------------------"
PRINT #2, tarName$; ":"
'--- read LONGs ---
PRINT #2, "DATA "; LTRIM$(STR$(cntL& * 8)); ","; LTRIM$(STR$(cntB&))
_DISPLAY: stim# = TIMER(0.001)
tmpI$ = SPACE$(32)
FOR z& = 1 TO cntL&
    GET #1, , tmpI$: offI% = 1
    tmpO$ = "DATA " + STRING$(87, ","): offO% = 6
    DO
        tmpL& = CVL(MID$(tmpI$, offI%, 4)): offI% = offI% + 4
        MID$(tmpO$, offO%, 10) = "&H" + RIGHT$("00000000" + HEX$(tmpL&), 8)
        offO% = offO% + 11
    LOOP UNTIL offO% > 92
    PRINT #2, tmpO$
    etim# = TIMER(0.001) - stim#
    IF etim# < 0 THEN etim# = etim# + 86400 'midnight fix
    IF etim# >= 0.04 THEN
        res$ = GenC$("SET", OutputProgress$ + NewTag$("LEVEL", LTRIM$(STR$(CINT(100 / cntL& * z&)))))
        _DISPLAY: stim# = TIMER(0.001)
    END IF
NEXT z&
res$ = GenC$("SET", OutputProgress$ + NewTag$("LEVEL", "100"))
_AUTODISPLAY
'--- read remaining BYTEs ---
IF cntB& > 0 THEN
    PRINT #2, "DATA ";
    FOR x% = 1 TO cntB&
        GET #1, , tmpB%%
        PRINT #2, "&H" + RIGHT$("00" + HEX$(tmpB%%), 2);
        IF x% <> 16 THEN
            IF x% <> cntB& THEN PRINT #2, ",";
        ELSE
            IF x% <> cntB& THEN
                PRINT #2, ""
                PRINT #2, "DATA ";
            END IF
        END IF
    NEXT x%
    PRINT #2, ""
END IF
PRINT #2, "END FUNCTION"
PRINT #2, ""
'--- ending ---
CLOSE #2
CLOSE #1
'--- finish message ---
ConvertFile% = -1
IF packed% THEN
    KILL tmpLzw$
    tmp$ = IndexFormat$("The original data were packed with a ratio of 0{##.##}%,|", STR$(100 - (100 / LEN(filedata$) * LEN(rawdata$))), "|") +_
           "Original:" + STR$(LEN(filedata$)) + " Bytes, Packed:" + STR$(LEN(rawdata$)) + " Bytes.|~"
ELSEIF use% THEN
    ConvertFile% = 0
    tmp$ = "The original data could not be packed with your desired|" +_
           "least ratio, you may try again with a lesser ratio or|" +_
           "keep the converted DATAs as is (unpacked).|~"
ELSE
    tmp$ = "As requested, the data were converted without packing.|~"
END IF
ok$ = MessageBox$("Info16px.png", "Information !!", tmp$ +_
     IndexFormat$("Have a look into the created file (0{&})|", tar$, CHR$(0)) +_
                  "to learn how to write the DATAs back into a file.",_
                  "{SYM Checkmark * * * *}")
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
'$INCLUDE: 'QB64GuiTools\dev_framework\GuiAppPalette.bm'
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
'note it's QB64-GL only then, QB64-SDL will throw an error on $EXEICON
'$EXEICON:'QB64GuiTools\images\icons\Default.ico'
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
IF appFont& > 0 THEN _FREEFONT appFont&: appFont& = 0
'--- free the screen and invalidate its handle ---
SCREEN 0
IF appScreen& < -1 THEN _FREEIMAGE appScreen&: appScreen& = -1
END SUB
'~~~~~

'*****************************************************
'$INCLUDE: 'QB64GuiTools\dev_framework\GuiAppFrame.bm'
'*****************************************************

'$INCLUDE: 'QB64GuiTools\dev_framework\support\BufferSupport.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\support\ConvertSupport.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\support\ImageSupport.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\support\PackSupport.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\support\PolygonSupport.bm'

'$INCLUDE: 'QB64GuiTools\dev_framework\support\TagSupport.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\GuiClasses.bm'

'$INCLUDE: 'QB64GuiTools\dev_framework\classes\GenericClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ModelClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ListClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ImageClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\SymbolClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\RulerClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\FrameClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\StringClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\TextClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ProgressClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\PagerClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ButtonClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\CheckboxClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\CycleClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\RadioClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ListviewClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\SliderClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ScrollerClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ColorwheelClass.bm'

'$INCLUDE: 'inline\RhoSigmaImg.bm'
'$INCLUDE: 'inline\PlasmaImg.bm'

'$INCLUDE: 'inline\Info16Img.bm'
'$INCLUDE: 'inline\Info32Img.bm'
'$INCLUDE: 'inline\Problem16Img.bm'
'$INCLUDE: 'inline\Problem32Img.bm'
'$INCLUDE: 'inline\Error16Img.bm'
'$INCLUDE: 'inline\Error32Img.bm'

