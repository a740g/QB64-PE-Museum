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
'| === LogicTrainerBig.bas ===                                       |
'|                                                                   |
'| == This is a Super-Mastermind clone. Find 5 out of 8 colors, you  |
'| == have a maximum of 12 tries to achieve the goal.                |
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
NiceGrayImgName$ = WriteNiceGrayImgArray$(appTempDir$ + "NiceGray.jpg", -1)
MarbleImgName$ = WriteMarbleImgArray$(appTempDir$ + "Marble.jpg", -1)
WoodLightImgName$ = WriteWoodLightImgArray$(appTempDir$ + "WoodLight.jpg", -1)
TempLog RhoSigmaImgName$, "": TempLog NiceGrayImgName$, ""
TempLog MarbleImgName$, "": TempLog WoodLightImgName$, ""
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

SetupScreen 600, 756, 0
appCR$ = "A Super-Mastermind clone v1.0, Done by RhoSigma, Roland Heyder"
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
CONST guiReservedPens% = 8 'reserved game colors
'-----
_PALETTECOLOR 248, _RGB32(170, 34, 0): _PALETTECOLOR 249, _RGB32(238, 187, 0)
_PALETTECOLOR 250, _RGB32(0, 136, 0): _PALETTECOLOR 251, _RGB32(0, 119, 187)
_PALETTECOLOR 252, _RGB32(238, 136, 136): _PALETTECOLOR 253, _RGB32(153, 0, 255)
_PALETTECOLOR 254, _RGB32(221, 85, 0): _PALETTECOLOR 255, _RGB32(153, 85, 0)

'~~~ My GUI Setup
'-----------------------------
'--- Init GUI objects here ---
'-----------------------------
BackImage$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "NiceGray.jpg") +_
        NewTag$("BACKFILL", "true") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "0") +_
        NewTag$("TOP", "0"))
GuessFrame$ = FrameC$("INIT",_
        NewTag$("FORM", "ridge") +_
        NewTag$("LEFT", "14") +_
        NewTag$("TOP", "14") +_
        NewTag$("WIDTH", "280") +_
        NewTag$("HEIGHT", "644") +_
        NewTag$("TEXT", "Guess"))
ResultFrame$ = FrameC$("INIT",_
        NewTag$("FORM", "ridge") +_
        NewTag$("LEFT", "306") +_
        NewTag$("TOP", "14") +_
        NewTag$("WIDTH", "280") +_
        NewTag$("HEIGHT", "644") +_
        NewTag$("TEXT", "Result"))
CodeFrame$ = FrameC$("INIT",_
        NewTag$("FORM", "ridge") +_
        NewTag$("LEFT", "306") +_
        NewTag$("TOP", "670") +_
        NewTag$("WIDTH", "280") +_
        NewTag$("HEIGHT", "72") +_
        NewTag$("TEXT", "Code"))
CheckButton$ = ButtonC$("INIT",_
        NewTag$("IMAGEFILE", "WoodLight.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "14") +_
        NewTag$("TOP", "670") +_
        NewTag$("WIDTH", "280") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("DISABLED", "true") +_
        NewTag$("TOOLTIP", "You may still change colors,|click here when you're ready.") +_
        NewTag$("TEXT", "Check it"))
NewButton$ = ButtonC$("INIT",_
        NewTag$("IMAGEFILE", "WoodLight.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "14") +_
        NewTag$("TOP", "712") +_
        NewTag$("WIDTH", "280") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("TEXT", "New Game"))
'----------
WhiteSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "24") +_
        NewTag$("BORDERPEN", "39"))
BlackSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "37") +_
        NewTag$("BORDERPEN", "39"))
RedSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "248") +_
        NewTag$("BORDERPEN", "39"))
YellowSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "249") +_
        NewTag$("BORDERPEN", "39"))
GreenSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "250") +_
        NewTag$("BORDERPEN", "39"))
BlueSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "251") +_
        NewTag$("BORDERPEN", "39"))
PinkSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "252") +_
        NewTag$("BORDERPEN", "39"))
LilacSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "253") +_
        NewTag$("BORDERPEN", "39"))
OrangeSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "254") +_
        NewTag$("BORDERPEN", "39"))
BrownSymbol$ = SymbolC$("INIT",_
        NewTag$("LEFT", "5") +_
        NewTag$("TOP", "5") +_
        NewTag$("WIDTH", "25") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("WHICH", "Pentagon") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("SHINEPEN", "255") +_
        NewTag$("BORDERPEN", "39"))
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
cleanUp:
obj$ = PopStr$
WHILE obj$ <> ""
    res$ = GenC$("KILL", obj$)
    obj$ = PopStr$
WEND
RETURN
'-----
initGuess:
IF Col1$ <> "" THEN PushStr Col1$
Col1$ = ButtonC$("INIT",_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "32") +_
        NewTag$("TOP", STR$(32 + (try% * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
IF Col2$ <> "" THEN PushStr Col2$
Col2$ = ButtonC$("INIT",_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "84") +_
        NewTag$("TOP", STR$(32 + (try% * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
IF Col3$ <> "" THEN PushStr Col3$
Col3$ = ButtonC$("INIT",_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "136") +_
        NewTag$("TOP", STR$(32 + (try% * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
IF Col4$ <> "" THEN PushStr Col4$
Col4$ = ButtonC$("INIT",_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "188") +_
        NewTag$("TOP", STR$(32 + (try% * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
IF Col5$ <> "" THEN PushStr Col5$
Col5$ = ButtonC$("INIT",_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "240") +_
        NewTag$("TOP", STR$(32 + (try% * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
RETURN
'-----
initColorChooser:
InitHoverLayer 0, 26, 24 + ((try% + 1) * 52), 436, 72
C1$ = ButtonC$("INIT",_
        SymbolTag$(RedSymbol$) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "44") +_
        NewTag$("TOP", STR$(42 + ((try% + 1) * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
C2$ = ButtonC$("INIT",_
        SymbolTag$(YellowSymbol$) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "96") +_
        NewTag$("TOP", STR$(42 + ((try% + 1) * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
C3$ = ButtonC$("INIT",_
        SymbolTag$(GreenSymbol$) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "148") +_
        NewTag$("TOP", STR$(42 + ((try% + 1) * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
C4$ = ButtonC$("INIT",_
        SymbolTag$(BlueSymbol$) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "200") +_
        NewTag$("TOP", STR$(42 + ((try% + 1) * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
C5$ = ButtonC$("INIT",_
        SymbolTag$(PinkSymbol$) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "252") +_
        NewTag$("TOP", STR$(42 + ((try% + 1) * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
C6$ = ButtonC$("INIT",_
        SymbolTag$(LilacSymbol$) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "304") +_
        NewTag$("TOP", STR$(42 + ((try% + 1) * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
C7$ = ButtonC$("INIT",_
        SymbolTag$(OrangeSymbol$) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "356") +_
        NewTag$("TOP", STR$(42 + ((try% + 1) * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
C8$ = ButtonC$("INIT",_
        SymbolTag$(BrownSymbol$) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "408") +_
        NewTag$("TOP", STR$(42 + ((try% + 1) * 52))) +_
        NewTag$("WIDTH", "36") +_
        NewTag$("HEIGHT", "36"))
chac% = -1 'chooser active (Esc will now abort chooser)
RETURN
'-----
killColorChooser:
chac% = 0 'chooser inactive (Esc is ignored)
res$ = GenC$("KILL", C8$): C8$ = ""
res$ = GenC$("KILL", C7$): C7$ = ""
res$ = GenC$("KILL", C6$): C6$ = ""
res$ = GenC$("KILL", C5$): C5$ = ""
res$ = GenC$("KILL", C4$): C4$ = ""
res$ = GenC$("KILL", C3$): C3$ = ""
res$ = GenC$("KILL", C2$): C2$ = ""
res$ = GenC$("KILL", C1$): C1$ = ""
IF chk% = 31 THEN res$ = GenC$("SET", CheckButton$ + NewTag$("DISABLED", "false"))
RETURN
'-----
showCode:
res$ = GenC$("KILL", text$): text$ = ""
FOR c% = 1 TO 5
    SELECT CASE ASC(code$, c%)
        CASE 248: symb$ = RedSymbol$
        CASE 249: symb$ = YellowSymbol$
        CASE 250: symb$ = GreenSymbol$
        CASE 251: symb$ = BlueSymbol$
        CASE 252: symb$ = PinkSymbol$
        CASE 253: symb$ = LilacSymbol$
        CASE 254: symb$ = OrangeSymbol$
        CASE 255: symb$ = BrownSymbol$
    END SELECT
    PushStr ButtonC$("INIT",_
            SymbolTag$(symb$) +_
            NewTag$("IMAGEFILE", "Marble.jpg") +_
            NewTag$("AREA", "true") +_
            NewTag$("LEFT", STR$(324 + ((c% - 1) * 52))) +_
            NewTag$("TOP", "688") +_
            NewTag$("WIDTH", "36") +_
            NewTag$("HEIGHT", "36"))
NEXT c%
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
FUNCTION VersionLogicTrainerBig$
    VersionLogicTrainerBig$ = MID$("$VER: LogicTrainerBig 1.0 (16-Sep-2019) by RhoSigma :END$", 7, 45)
END FUNCTION
'-----
FUNCTION RangeRand% (low%, high%)
    RangeRand% = INT(RND(1) * (high% - low% + 1)) + low%
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
    appFont& = _LOADFONT("C:\Windows\Fonts\courbd.ttf", 24)
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
'$INCLUDE: 'inline\NiceGrayImg.bm'
'$INCLUDE: 'inline\MarbleImg.bm'
'$INCLUDE: 'inline\WoodLightImg.bm'

'$INCLUDE: 'inline\Info16Img.bm'
'$INCLUDE: 'inline\Info32Img.bm'
'$INCLUDE: 'inline\Problem16Img.bm'
'$INCLUDE: 'inline\Problem32Img.bm'
'$INCLUDE: 'inline\Error16Img.bm'
'$INCLUDE: 'inline\Error32Img.bm'

