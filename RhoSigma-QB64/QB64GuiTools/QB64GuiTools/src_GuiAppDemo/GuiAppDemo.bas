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
'| === GuiAppDemo.bas ===                                            |
'|                                                                   |
'| == A complex example for a GuiTools Framework based Application.  |
'| == Read the comments alongside the code and feel free to change   |
'| == things to see and learn how the GUI is working.                |
'| == Also take a look into the various files in the "classes" and   |
'| == "support" folders, which are included by this program.         |
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

SetupScreen 1024, 768, 0
appCR$ = "The GuiTools Framework v0.15, Done by RhoSigma, Roland Heyder"
_TITLE appExeName$ + " - [" + appPCName$ + "] - " + appCR$

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
CONST guiReservedPens% = 1 'reserved for "Color Gauge" (see Demo Page5)
'-----
btxt$ = "Other Button ON" 'initial text for OnOffButton object
disa$ = "true" 'initial disabled state for FrameSwitch button object
immq$ = NewTag$("CHECKED", "false") 'initial tag for EndingChkBox1 checkbox object
abou$ = NewTag$("CHECKED", "true") 'initial tag for EndingChkBox2 checkbox object

'~~~ My GUI Setup
'--------------------------------------
'--- Now we create some GUI objects ---
'--------------------------------------
'--- Note that none of the objects will appear immediately on screen, the
'--- complete GUI will be drawn after the first call of GetGUIMsg$(), when
'--- the GUI event handler will handle the "GUIREFRESH" events. Hence
'--- the GUI will appear as soon as we enter our main loop below.
'-----
'--- Splitting up the lines and using the line continue char _ will make
'--- adding/removing of tags much easier here, as entire lines can be
'--- selected for delete and/or copy&paste operations. Also the object
'--- defines are better readable.
'-----
'--- For object groups, which will share some properties, it's also a
'--- good idea to predefine that properties. It saves some writing and
'--- the common properties are easier to change. With this practice it
'--- becomes also obvious, that the order of tags doesn't matter.
'-----
MouseCommonProps$ =_
        NewTag$("TOP", "25") +_
        NewTag$("WIDTH", "175") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("IMAGEFILE", "Burning.jpg")
MouseXPos$ = TextC$("INIT", MouseCommonProps$ +_
        NewTag$("LEFT", "25") +_
        NewTag$("LABEL", "Mouse X Position"))
MouseYPos$ = TextC$("INIT", MouseCommonProps$ +_
        NewTag$("LEFT", "225") +_
        NewTag$("LABEL", "Mouse Y Position"))
MouseLeft$ = TextC$("INIT", MouseCommonProps$ +_
        NewTag$("LEFT", "425") +_
        NewTag$("LABEL", "Left Button State"))
MouseMiddle$ = TextC$("INIT", MouseCommonProps$ +_
        NewTag$("LEFT", "625") +_
        NewTag$("LABEL", "Middle Button State"))
MouseRight$ = TextC$("INIT", MouseCommonProps$ +_
        NewTag$("LEFT", "825") +_
        NewTag$("LABEL", "Right Button State"))
LastMessage$ = TextC$("INIT",_
        NewTag$("LEFT", "25") +_
        NewTag$("TOP", "75") +_
        NewTag$("WIDTH", "975") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABEL", "These were the most recent input events returned by GetGUIMsg$() ...") +_
        NewTag$("LABELPLACE", "below"))
Ruler1$ = RulerC$("INIT",_
        NewTag$("LEFT", "15") +_
        NewTag$("TOP", "132") +_
        NewTag$("LENGTH", "994") +_
        NewTag$("FORM", "ridge") +_
        NewTag$("ALIGN", "horizontal"))
'--- framed area ---
Frame1$ = FrameC$("INIT",_
        NewTag$("LEFT", "25") +_
        NewTag$("TOP", "160") +_
        NewTag$("WIDTH", "525") +_
        NewTag$("HEIGHT", "250") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Frame 1 (raised)") +_
        NewTag$("TEXTPLACE", "topleft"))
Frame2$ = FrameC$("INIT",_
        NewTag$("LEFT", "50") +_
        NewTag$("TOP", "185") +_
        NewTag$("WIDTH", "475") +_
        NewTag$("HEIGHT", "200") +_
        NewTag$("FORM", "solid") +_
        NewTag$("RECESSED", "true") +_
        NewTag$("TEXT", "Frame 2 (recessed)") +_
        NewTag$("TEXTPLACE", "bottomcenter"))
OnOffButton$ = ButtonC$("INIT",_
        NewTag$("LEFT", "80") +_
        NewTag$("TOP", "225") +_
        NewTag$("WIDTH", "185") +_
        NewTag$("HEIGHT", "50") +_
        NewTag$("SHORTCUT", MakeShortcut$("b", 0, 0, 0)) +_
        NewTag$("TEXT", btxt$) +_
        NewTag$("IMAGEFILE", "GreenBack.jpg"))
OnOffState$ = TextC$("INIT",_
        NewTag$("LEFT", "285") +_
        NewTag$("TOP", "230") +_
        NewTag$("WIDTH", "215") +_
        NewTag$("HEIGHT", "40") +_
        NewTag$("FORM", "ridge") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABEL", "Button State") +_
        NewTag$("LABELHIGH", "true"))
FrameSwitch$ = ButtonC$("INIT",_
        NewTag$("LEFT", "80") +_
        NewTag$("TOP", "300") +_
        NewTag$("WIDTH", "185") +_
        NewTag$("HEIGHT", "50") +_
        NewTag$("SHORTCUT", MakeShortcut$("f", 0, 0, 0)) +_
        NewTag$("TEXT", "Erase Frame 2") +_
        NewTag$("IMAGEFILE", "GreenBack.jpg") +_
        NewTag$("DISABLED", disa$))
FrameSwitchState$ = TextC$("INIT",_
        NewTag$("LEFT", "285") +_
        NewTag$("TOP", "305") +_
        NewTag$("WIDTH", "215") +_
        NewTag$("HEIGHT", "40") +_
        NewTag$("FORM", "ridge") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABEL", "Button State") +_
        NewTag$("LABELHIGH", "true"))
'--- upper pager ---
GreenCheckSym$ = SymbolC$("INIT",_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("LEFT", "7") +_
        NewTag$("TOP", "7") +_
        NewTag$("WIDTH", "50") +_
        NewTag$("HEIGHT", "17") +_
        NewTag$("WHICH", "Checkmark"))
RedCrossSym$ = SymbolC$("INIT",_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("LEFT", "7") +_
        NewTag$("TOP", "7") +_
        NewTag$("WIDTH", "50") +_
        NewTag$("HEIGHT", "17") +_
        NewTag$("WHICH", "Cross"))
PageCommonProps$ =_
        NewTag$("TOP", "440") +_
        NewTag$("WIDTH", "100") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("IMAGEFILE", "Cloud.jpg") +_
        NewTag$("WALLPEN", "11") +_
        NewTag$("WALLLEFT", "10") +_
        NewTag$("WALLRIGHT", "1013") +_
        NewTag$("WALLBOTTOM", "767") +_
        NewTag$("WALLAREA", "true")
Page2$ = PagerC$("INIT", PageCommonProps$ +_
        SymbolTag$(RedCrossSym$) +_
        NewTag$("LEFT", "260") +_
        NewTag$("WALLIMAGE", "Stone.jpg") +_
        NewTag$("SHORTCUT", MakeShortcut$("F2", 0, 1, 0)) +_
        NewTag$("TEXT", "Page 2"))
Page3$ = PagerC$("INIT", PageCommonProps$ +_
        SymbolTag$(RedCrossSym$) +_
        NewTag$("LEFT", "362") +_
        NewTag$("WALLIMAGE", "SomeGray.jpg") +_
        NewTag$("SHORTCUT", MakeShortcut$("F3", 0, 1, 0)) +_
        NewTag$("TEXT", "Page 3"))
Page4$ = PagerC$("INIT", PageCommonProps$ +_
        SymbolTag$(RedCrossSym$) +_
        NewTag$("LEFT", "464") +_
        NewTag$("WALLIMAGE", "Structure.jpg") +_
        NewTag$("SHORTCUT", MakeShortcut$("F4", 0, 1, 0)) +_
        NewTag$("TEXT", "Page 4"))
Page5$ = PagerC$("INIT", PageCommonProps$ +_
        SymbolTag$(RedCrossSym$) +_
        NewTag$("LEFT", "566") +_
        NewTag$("WALLIMAGE", "WarpBlue.jpg") +_
        NewTag$("SHORTCUT", MakeShortcut$("F5", 0, 1, 0)) +_
        NewTag$("TEXT", "Page 5"))
Page6$ = PagerC$("INIT", PageCommonProps$ +_
        SymbolTag$(RedCrossSym$) +_
        NewTag$("LEFT", "668") +_
        NewTag$("WALLIMAGE", "Plasma.jpg") +_
        NewTag$("SHORTCUT", MakeShortcut$("F6", 0, 1, 0)) +_
        NewTag$("TEXT", "Page 6"))
Page7$ = PagerC$("INIT", PageCommonProps$ +_
        SymbolTag$(RedCrossSym$) +_
        NewTag$("LEFT", "770") +_
        NewTag$("WALLIMAGE", "RootsLight.jpg") +_
        NewTag$("SHORTCUT", MakeShortcut$("F7", 0, 1, 0)) +_
        NewTag$("TEXT", "Page 7"))
Page1$ = PagerC$("INIT", PageCommonProps$ +_
        SymbolTag$(GreenCheckSym$) +_
        NewTag$("LEFT", "158") +_
        NewTag$("WALLIMAGE", "ColorPlastic.jpg") +_
        NewTag$("SHORTCUT", MakeShortcut$("F1", 0, 1, 0)) +_
        NewTag$("TEXT", "Page 1"))
'--- Page 1 ---
KillTestRuler$ = RulerC$("INIT",_
        PagerTag$(Page1$) +_
        NewTag$("LEFT", "262") +_
        NewTag$("TOP", "500") +_
        NewTag$("LENGTH", "500") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Pager Kill Test"))
KillButtonCommonProps$ =_
        PagerTag$(Page1$) +_
        NewTag$("TOP", "525") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50")
KillTestButton1$ = ButtonC$("INIT", KillButtonCommonProps$ +_
        NewTag$("LEFT", "190") +_
        NewTag$("SHORTCUT", MakeShortcut$("1", 0, 0, 1)) +_
        NewTag$("TEXT", "Kill Page 1") +_
        NewTag$("DISABLED", "true"))
KillTestButton2$ = ButtonC$("INIT", KillButtonCommonProps$ +_
        NewTag$("LEFT", "410") +_
        NewTag$("SHORTCUT", MakeShortcut$("3", 0, 0, 1)) +_
        NewTag$("TEXT", "Kill Page 3") +_
        NewTag$("DISABLED", "true"))
KillTestButton3$ = ButtonC$("INIT", KillButtonCommonProps$ +_
        NewTag$("LEFT", "630") +_
        NewTag$("SHORTCUT", MakeShortcut$("7", 0, 0, 1)) +_
        NewTag$("TEXT", "Kill Page 2,4,5,6 & 7"))
'--- Page 2 ---
ImageRuler$ = RulerC$("INIT",_
        PagerTag$(Page2$) +_
        NewTag$("LEFT", "262") +_
        NewTag$("TOP", "500") +_
        NewTag$("LENGTH", "500") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Some standalone Image Objects"))
ImageCommonProps$ =_
        PagerTag$(Page2$) +_
        NewTag$("TOP", "530") +_
        NewTag$("HEIGHT", "206") +_
        NewTag$("FORM", "ridge")
Page2Img1$ = ImageC$("INIT", ImageCommonProps$ +_
        NewTag$("IMAGEFILE", "BeachGirl.jpg") +_
        NewTag$("LEFT", "325") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("WIDTH", "-275")) 'note the negative WIDTH, it will flip the image
Page2Img2$ = ImageC$("INIT", ImageCommonProps$ +_
        NewTag$("IMAGEFILE", "Fish.jpg") +_
        NewTag$("LEFT", "375") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("WIDTH", "275"))
Page2Img3$ = ImageC$("INIT", ImageCommonProps$ +_
        NewTag$("IMAGEFILE", "TheKnot.jpg") +_
        NewTag$("LEFT", "700") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("WIDTH", "275"))
'--- Page 3 ---
EndingRuler$ = RulerC$("INIT",_
        PagerTag$(Page3$) +_
        NewTag$("LEFT", "162") +_
        NewTag$("TOP", "500") +_
        NewTag$("LENGTH", "700") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Interactive object creation at runtime"))
EndingButtonCommonProps$ =_
        PagerTag$(Page3$) +_
        NewTag$("TOP", "525") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50")
EndingButton1$ = ButtonC$("INIT", EndingButtonCommonProps$ +_
        NewTag$("LEFT", "190") +_
        NewTag$("SHORTCUT", MakeShortcut$("c", 0, 0, 0)) +_
        NewTag$("TEXT", "Create Quit Button"))
EndingButton2$ = ButtonC$("INIT", EndingButtonCommonProps$ +_
        NewTag$("LEFT", "410") +_
        NewTag$("SHORTCUT", MakeShortcut$("e", 0, 0, 0)) +_
        NewTag$("TEXT", "Erase Quit Button") +_
        NewTag$("DISABLED", "true"))
EndingButton3$ = ButtonC$("INIT", EndingButtonCommonProps$ +_
        NewTag$("LEFT", "630") +_
        NewTag$("SHORTCUT", MakeShortcut$("d", 0, 0, 0)) +_
        NewTag$("TEXT", "Dump Object Array") +_
        NewTag$("DISABLED", "true"))
EndCycList$ = ListC$("INIT", "")
dummy$ = ListC$("STORE", EndCycList$ + NewTag$("DATA", "QUIT PROGRAM"))
dummy$ = ListC$("STORE", EndCycList$ + NewTag$("DATA", "!! EXIT !!"))
dummy$ = ListC$("STORE", EndCycList$ + NewTag$("DATA", "I'm done."))
EndingCycler$ = CycleC$("INIT",_
        PagerTag$(Page3$) +_
        ListTag$(EndCycList$) +_
        NewTag$("LEFT", "825") +_
        NewTag$("TOP", "699") +_
        NewTag$("WIDTH", "175") +_
        NewTag$("HEIGHT", "41") +_
        NewTag$("LABEL", "Quit Button Text") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("SHORTCUT", MakeShortcut$("t", 0, 0, 0)) +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "UglyGray.jpg"))
gradient& = _NEWIMAGE(400, 25, 32)
_DEST gradient&
FOR x% = 0 TO 395
    HSBtoRGB CLNG((395 - x%) * (21845 / 395)) + 21845, 45875, 52428, re&, gr&, bl&
    LINE (x% + 2, 2)-(x% + 2, 22), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
NEXT x%
EndingGauge$ = ProgressC$("INIT",_
        PagerTag$(Page3$) +_
        NewTag$("LEFT", "600") +_
        NewTag$("TOP", "650") +_
        NewTag$("WIDTH", "400") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("LEVEL", "100") +_
        NewTag$("LABEL", "Relative Quit Button Area Size") +_
        NewTag$("LABELPLACE", "above") +_
        NewTag$("LABELHIGH", "true") +_
        NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))))
EndingChkBox1$ = CheckboxC$("INIT", immq$ +_
        PagerTag$(Page3$) +_
        NewTag$("LEFT", "359") +_
        NewTag$("TOP", "595") +_
        NewTag$("DISABLED", "true") +_
        NewTag$("LABEL", "Immediate Quit") +_
        NewTag$("LABELPLACE", "left") +_
        NewTag$("SHORTCUT", MakeShortcut$("i", 0, 0, 0)) +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "MarbleWhite.jpg"))
EndingChkBox2$ = CheckboxC$("INIT", abou$ +_
        PagerTag$(Page3$) +_
        NewTag$("LEFT", "579") +_
        NewTag$("TOP", "595") +_
        NewTag$("DISABLED", "true") +_
        NewTag$("LABEL", "Show About Message") +_
        NewTag$("LABELPLACE", "left") +_
        NewTag$("SHORTCUT", MakeShortcut$("a", 0, 0, 0)) +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "MarbleWhite.jpg"))
EndingChkBox3$ = CheckboxC$("INIT",_
        PagerTag$(Page3$) +_
        NewTag$("LEFT", "123") +_
        NewTag$("TOP", "641") +_
        NewTag$("WIDTH", "44") +_
        NewTag$("HEIGHT", "44") +_
        NewTag$("LABEL", "Enable 'Keep Aspect Ratio' Slider Model") +_
        NewTag$("LABELHIGH", "true") +_
        NewTag$("LABELPLACE", "right") +_
        NewTag$("SHORTCUT", MakeShortcut$("k", 0, 0, 0)) +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "UglyBlue.jpg"))
EndingSlider1$ = SliderC$("INIT",_
        PagerTag$(Page3$) +_
        NewTag$("LEFT", "175") +_
        NewTag$("TOP", "699") +_
        NewTag$("WIDTH", "635") +_
        NewTag$("HEIGHT", "41") +_
        NewTag$("MINIMUM", "112") +_
        NewTag$("MAXIMUM", "250") +_
        NewTag$("LEVEL", "250") +_
        NewTag$("LABEL", "Quit Button Width") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "Sky.jpg"))
EndingSlider2$ = SliderC$("INIT",_
        PagerTag$(Page3$) +_
        NewTag$("LEFT", "70") +_
        NewTag$("TOP", "490") +_
        NewTag$("WIDTH", "41") +_
        NewTag$("HEIGHT", "250") +_
        NewTag$("MINIMUM", "78") +_
        NewTag$("MAXIMUM", "175") +_
        NewTag$("LEVEL", "175") +_
        NewTag$("LABEL", "Quit Button Height") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "Sky.jpg"))
EndingIcSlider1to2$ = ModelC$("INIT",_
        NewTag$("WHICH", "Ratio") +_
        NewTag$("INTONLY", "true") +_
        NewTag$("DISABLED", "true") +_
        NewTag$("RATIO", "1.428571428571428") +_
        RatioMulTag$(EndingSlider1$) +_
        NewTag$("MULTAG", "LEVEL") +_
        RatioDivTag$(EndingSlider2$) +_
        NewTag$("DIVTAG", "LEVEL"))
'--- Page 4 ---
IcRuler$ = RulerC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "112") +_
        NewTag$("TOP", "500") +_
        NewTag$("LENGTH", "800") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Model Class interconnection Marathon"))
IcSlider1$ = SliderC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "60") +_
        NewTag$("TOP", "541") +_
        NewTag$("WIDTH", "500") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("MINIMUM", "0") +_
        NewTag$("MAXIMUM", "300") +_
        NewTag$("LEVEL", "10") +_
        NewTag$("NOSHOW", "true") +_
        NewTag$("LABEL", "Model Slider x1") +_
        NewTag$("LABELPLACE", "below"))
IcText1$ = TextC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "585") +_
        NewTag$("TOP", "541") +_
        NewTag$("WIDTH", "60") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABEL", "'Forwarded' Level Display for Slider x1") +_
        NewTag$("LABELPLACE", "right"))
IcSliderText1$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(IcSlider1$) +_
        NewTag$("PRITAG", "LEVEL") +_
        FwdSecTag$(IcText1$) +_
        NewTag$("SECTAG", "TEXT"))
IcSlider2$ = SliderC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "60") +_
        NewTag$("TOP", "620") +_
        NewTag$("WIDTH", "500") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("MINIMUM", "0") +_
        NewTag$("MAXIMUM", "300") +_
        NewTag$("LEVEL", "20") +_
        NewTag$("NOSHOW", "true") +_
        NewTag$("LABEL", "Model Slider x2") +_
        NewTag$("LABELPLACE", "below"))
IcText2$ = TextC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "585") +_
        NewTag$("TOP", "620") +_
        NewTag$("WIDTH", "60") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABEL", "'Forwarded' Level Display for Slider x2") +_
        NewTag$("LABELPLACE", "right"))
IcSliderText2$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(IcSlider2$) +_
        NewTag$("PRITAG", "LEVEL") +_
        FwdSecTag$(IcText2$) +_
        NewTag$("SECTAG", "TEXT"))
IcSlider3$ = SliderC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "60") +_
        NewTag$("TOP", "699") +_
        NewTag$("WIDTH", "500") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("MINIMUM", "0") +_
        NewTag$("MAXIMUM", "300") +_
        NewTag$("LEVEL", "30") +_
        NewTag$("NOSHOW", "true") +_
        NewTag$("LABEL", "Model Slider x3") +_
        NewTag$("LABELPLACE", "below"))
IcText3$ = TextC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "585") +_
        NewTag$("TOP", "699") +_
        NewTag$("WIDTH", "60") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABEL", "'Forwarded' Level Display for Slider x3") +_
        NewTag$("LABELPLACE", "right"))
IcSliderText3$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(IcSlider3$) +_
        NewTag$("PRITAG", "LEVEL") +_
        FwdSecTag$(IcText3$) +_
        NewTag$("SECTAG", "TEXT"))
IcSlider2to1$ = ModelC$("INIT",_
        NewTag$("WHICH", "Ratio") +_
        NewTag$("INTONLY", "true") +_
        NewTag$("RATIO", "2") +_
        RatioMulTag$(IcSlider2$) +_
        NewTag$("MULTAG", "LEVEL") +_
        RatioDivTag$(IcSlider1$) +_
        NewTag$("DIVTAG", "LEVEL"))
IcSlider2to3$ = ModelC$("INIT",_
        NewTag$("WHICH", "Ratio") +_
        NewTag$("INTONLY", "true") +_
        NewTag$("RATIO", "1.5") +_
        RatioMulTag$(IcSlider3$) +_
        NewTag$("MULTAG", "LEVEL") +_
        RatioDivTag$(IcSlider2$) +_
        NewTag$("DIVTAG", "LEVEL"))
IcChkBox1$ = CheckboxC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "520") +_
        NewTag$("TOP", "580") +_
        NewTag$("CHECKED", "true") +_
        NewTag$("SHORTCUT", MakeShortcut$("1", 0, 0, 0)) +_
        NewTag$("LABEL", "Enable 'Ratio' Slider x1 x2 Interconnection") +_
        NewTag$("LABELHIGH", "true") +_
        NewTag$("LABELPLACE", "right"))
IcChkBox2$ = CheckboxC$("INIT",_
        PagerTag$(Page4$) +_
        NewTag$("LEFT", "520") +_
        NewTag$("TOP", "659") +_
        NewTag$("CHECKED", "true") +_
        NewTag$("SHORTCUT", MakeShortcut$("2", 0, 0, 0)) +_
        NewTag$("LABEL", "Enable 'Ratio' Slider x2 x3 Interconnection") +_
        NewTag$("LABELHIGH", "true") +_
        NewTag$("LABELPLACE", "right"))
'--- Page 5 ---
PalRuler$ = RulerC$("INIT",_
        PagerTag$(Page5$) +_
        NewTag$("LEFT", "112") +_
        NewTag$("TOP", "500") +_
        NewTag$("LENGTH", "800") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Colorwheel with HSB <-> RGB Model Interconnection"))
PalWheel$ = ColorwheelC$("INIT",_
        PagerTag$(Page5$) +_
        NewTag$("LEFT", "50") +_
        NewTag$("TOP", "525") +_
        NewTag$("HUE", "0") +_
        NewTag$("SATURATION", "0") +_
        NewTag$("WIDTH", "215") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "MarshGreen.jpg"))
PalFrame$ = FrameC$("INIT",_
        PagerTag$(Page5$) +_
        NewTag$("LEFT", "311") +_
        NewTag$("TOP", "525") +_
        NewTag$("WIDTH", "246") +_
        NewTag$("HEIGHT", "215") +_
        NewTag$("FORM", "ridge") +_
        NewTag$("RECESSED", "true") +_
        NewTag$("TEXT", "Color Gauge") +_
        NewTag$("TEXTPLACE", "bottomcenter"))
PalSymbol$ = SymbolC$("INIT",_
        PagerTag$(Page5$) +_
        NewTag$("LEFT", "346") +_
        NewTag$("TOP", "545") +_
        NewTag$("WIDTH", "175") +_
        NewTag$("HEIGHT", "175") +_
        NewTag$("TOOLTIP", "The mixed color") +_
        NewTag$("WHICH", "Star") +_
        NewTag$("KEEPASPECT", "true") +_
        NewTag$("STANDALONE", "true") +_
        NewTag$("SHINEPEN", "255"))
PalSliderCommonProps$ =_
        PagerTag$(Page5$) +_
        NewTag$("TOP", "525") +_
        NewTag$("WIDTH", "41") +_
        NewTag$("HEIGHT", "215") +_
        NewTag$("MINIMUM", "0") +_
        NewTag$("LABELHIGH", "true") +_
        NewTag$("LABELPLACE", "below")
'make a Hue gradient image for the respective slider
gradient& = _NEWIMAGE(41, 215, 32)
_DEST gradient&
FOR y% = 0 TO 210
    HSBtoRGB CLNG((210 - y%) * (65535 / 210)), 65535, 65535, re&, gr&, bl&
    LINE (2, y% + 2)-(38, y% + 2), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
NEXT y%
PalHSBSliderH$ = SliderC$("INIT", PalSliderCommonProps$ +_
        NewTag$("LEFT", "603") +_
        NewTag$("MAXIMUM", "359") +_
        NewTag$("LABEL", "H") +_
        NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))))
'make a Saturation gradient image for the respective slider
gradient& = _NEWIMAGE(41, 215, 32)
_DEST gradient&
FOR x% = 0 TO 36
    FOR y% = 0 TO 210
        HSBtoRGB CLNG(x% * (65535 / 36)), CLNG((210 - y%) * (65535 / 210)), 65535, re&, gr&, bl&
        PSET (x% + 2, y% + 2), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
    NEXT y%
NEXT x%
PalHSBSliderS$ = SliderC$("INIT", PalSliderCommonProps$ +_
        NewTag$("LEFT", "664") +_
        NewTag$("MAXIMUM", "100") +_
        NewTag$("LABEL", "S") +_
        NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))))
'make a Brightness gradient image for the respective slider
gradient& = _NEWIMAGE(41, 215, 32)
_DEST gradient&
FOR y% = 0 TO 210
    HSBtoRGB 0, 0, CLNG((210 - y%) * (65535 / 210)), re&, gr&, bl&
    LINE (2, y% + 2)-(38, y% + 2), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
NEXT y%
PalHSBSliderB$ = SliderC$("INIT", PalSliderCommonProps$ +_
        NewTag$("LEFT", "725") +_
        NewTag$("MAXIMUM", "100") +_
        NewTag$("LEVEL", "100") +_
        NewTag$("LABEL", "B") +_
        NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))))
'make a Red gradient image for the respective slider
gradient& = _NEWIMAGE(41, 215, 32)
_DEST gradient&
FOR y% = 0 TO 210
    HSBtoRGB 0, 65535, CLNG((210 - y%) * (65535 / 210)), re&, gr&, bl&
    LINE (2, y% + 2)-(38, y% + 2), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
NEXT y%
PalRGBSliderR$ = SliderC$("INIT", PalSliderCommonProps$ +_
        NewTag$("LEFT", "811") +_
        NewTag$("MAXIMUM", "255") +_
        NewTag$("LEVEL", "255") +_
        NewTag$("LABEL", "R") +_
        NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))))
'make a Green gradient image for the respective slider
gradient& = _NEWIMAGE(41, 215, 32)
_DEST gradient&
FOR y% = 0 TO 210
    HSBtoRGB 21845, 65535, CLNG((210 - y%) * (65535 / 210)), re&, gr&, bl&
    LINE (2, y% + 2)-(38, y% + 2), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
NEXT y%
PalRGBSliderG$ = SliderC$("INIT", PalSliderCommonProps$ +_
        NewTag$("LEFT", "872") +_
        NewTag$("MAXIMUM", "255") +_
        NewTag$("LEVEL", "255") +_
        NewTag$("LABEL", "G") +_
        NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))))
'make a Blue gradient image for the respective slider
gradient& = _NEWIMAGE(41, 215, 32)
_DEST gradient&
FOR y% = 0 TO 210
    HSBtoRGB 43690, 65535, CLNG((210 - y%) * (65535 / 210)), re&, gr&, bl&
    LINE (2, y% + 2)-(38, y% + 2), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
NEXT y%
PalRGBSliderB$ = SliderC$("INIT", PalSliderCommonProps$ +_
        NewTag$("LEFT", "933") +_
        NewTag$("MAXIMUM", "255") +_
        NewTag$("LEVEL", "255") +_
        NewTag$("LABEL", "B") +_
        NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))))
PalIcHue$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(PalWheel$) +_
        NewTag$("PRITAG", "HUE") +_
        FwdSecTag$(PalHSBSliderH$) +_
        NewTag$("SECTAG", "LEVEL"))
PalIcSat$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(PalWheel$) +_
        NewTag$("PRITAG", "SATURATION") +_
        FwdSecTag$(PalHSBSliderS$) +_
        NewTag$("SECTAG", "LEVEL"))
PalIcHsbRgb$ = ModelC$("INIT",_
        NewTag$("WHICH", "HsbRgb") +_
        HsbHueTag$(PalHSBSliderH$) +_
        NewTag$("HUETAG", "LEVEL") +_
        HsbSatTag$(PalHSBSliderS$) +_
        NewTag$("SATTAG", "LEVEL") +_
        HsbBriTag$(PalHSBSliderB$) +_
        NewTag$("BRITAG", "LEVEL") +_
        RgbRedTag$(PalRGBSliderR$) +_
        NewTag$("REDTAG", "LEVEL") +_
        RgbGreTag$(PalRGBSliderG$) +_
        NewTag$("GRETAG", "LEVEL") +_
        RgbBluTag$(PalRGBSliderB$) +_
        NewTag$("BLUTAG", "LEVEL"))
'--- Page 6 ---
ScrRuler$ = RulerC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "112") +_
        NewTag$("TOP", "500") +_
        NewTag$("LENGTH", "800") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Scroller demonstration"))
ScrRuler1$ = RulerC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "512") +_
        NewTag$("TOP", "520") +_
        NewTag$("LENGTH", "235") +_
        NewTag$("FORM", "solid") +_
        NewTag$("ALIGN", "vertical"))
ScrFrame3$ = FrameC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "544") +_
        NewTag$("TOP", "555") +_
        NewTag$("WIDTH", "427") +_
        NewTag$("HEIGHT", "172") +_
        NewTag$("FORM", "ridge"))
ScrStringCommonProps$ =_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "30") +_
        NewTag$("WIDTH", "62") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("ALLOWED", "0123456789") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABELPLACE", "right") +_
        NewTag$("IMAGEFILE", "MarbleBrown.jpg") +_
        NewTag$("AREA", "true")
ScrString1$ = StringC$("INIT", ScrStringCommonProps$ +_
        NewTag$("TOP", "574") +_
        NewTag$("MAXIMUM", "5") +_
        NewTag$("TEXT", "15") +_
        NewTag$("SHORTCUT", MakeShortcut$("1", 0, 0, 0)) +_
        NewTag$("LABEL", "First visible text line/column (1st = 0)"))
ScrString2$ = StringC$("INIT", ScrStringCommonProps$ +_
        NewTag$("TOP", "620") +_
        NewTag$("MAXIMUM", "3") +_
        NewTag$("TEXT", "20") +_
        NewTag$("SHORTCUT", MakeShortcut$("v", 0, 0, 0)) +_
        NewTag$("LABEL", "Number visible lines/columns (scroll area)"))
ScrString3$ = StringC$("INIT", ScrStringCommonProps$ +_
        NewTag$("TOP", "666") +_
        NewTag$("MAXIMUM", "5") +_
        NewTag$("TEXT", "100") +_
        NewTag$("SHORTCUT", MakeShortcut$("t", 0, 0, 0)) +_
        NewTag$("LABEL", "Total number of lines/columns (text buffer)"))
ScrScroller1$ = ScrollerC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "30") +_
        NewTag$("TOP", "720") +_
        NewTag$("WIDTH", "420") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("VISIBLENUM", "20") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "Leaves.jpg"))
ScrScroller2$ = ScrollerC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "450") +_
        NewTag$("TOP", "555") +_
        NewTag$("WIDTH", "30") +_
        NewTag$("HEIGHT", "165") +_
        NewTag$("VISIBLENUM", "20") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "Leaves.jpg"))
ScrText$ = TextC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "70") +_
        NewTag$("TOP", "525") +_
        NewTag$("WIDTH", "370") +_
        NewTag$("HEIGHT", "26") +_
        NewTag$("FORM", "ridge") +_
        NewTag$("TEXT", "Play with the vital scroller values") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "WarpBlue.jpg"))
ScrButton$ = ButtonC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "584") +_
        NewTag$("TOP", "525") +_
        NewTag$("WIDTH", "370") +_
        NewTag$("HEIGHT", "26") +_
        NewTag$("SHORTCUT", MakeShortcut$("s", 0, 0, 0)) +_
        NewTag$("TEXT", "Select another background image") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "WarpBlue.jpg"))
ScrImgScrollerH$ = ScrollerC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "544") +_
        NewTag$("TOP", "727") +_
        NewTag$("WIDTH", "427") +_
        NewTag$("HEIGHT", "23") +_
        NewTag$("TOPNUM", "109") +_
        NewTag$("TOTALNUM", "1024") +_
        NewTag$("VISIBLENUM", "419") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "MarshGreen.jpg"))
ScrImgScrollerV$ = ScrollerC$("INIT",_
        PagerTag$(Page6$) +_
        NewTag$("LEFT", "971") +_
        NewTag$("TOP", "555") +_
        NewTag$("WIDTH", "23") +_
        NewTag$("HEIGHT", "172") +_
        NewTag$("TOPNUM", "497") +_
        NewTag$("TOTALNUM", "768") +_
        NewTag$("VISIBLENUM", "164") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "MarshGreen.jpg"))
ScrT1S1$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(ScrString1$) +_
        NewTag$("PRITAG", "TEXT") +_
        FwdSecTag$(ScrScroller1$) +_
        NewTag$("SECTAG", "TOPNUM"))
ScrT1S2$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(ScrString1$) +_
        NewTag$("PRITAG", "TEXT") +_
        FwdSecTag$(ScrScroller2$) +_
        NewTag$("SECTAG", "TOPNUM"))
ScrT2S1$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(ScrString2$) +_
        NewTag$("PRITAG", "TEXT") +_
        FwdSecTag$(ScrScroller1$) +_
        NewTag$("SECTAG", "VISIBLENUM"))
ScrT2S2$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(ScrString2$) +_
        NewTag$("PRITAG", "TEXT") +_
        FwdSecTag$(ScrScroller2$) +_
        NewTag$("SECTAG", "VISIBLENUM"))
ScrT3S1$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(ScrString3$) +_
        NewTag$("PRITAG", "TEXT") +_
        FwdSecTag$(ScrScroller1$) +_
        NewTag$("SECTAG", "TOTALNUM"))
ScrT3S2$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(ScrString3$) +_
        NewTag$("PRITAG", "TEXT") +_
        FwdSecTag$(ScrScroller2$) +_
        NewTag$("SECTAG", "TOTALNUM"))
'--- Page 7 ---
MultiRuler$ = RulerC$("INIT",_
        PagerTag$(Page7$) +_
        NewTag$("LEFT", "112") +_
        NewTag$("TOP", "500") +_
        NewTag$("LENGTH", "800") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Multiple Choice (Listview & Radiobuttons)"))
MultiFlagsCommonProps$ =_
        NewTag$("LEFT", "0") + NewTag$("TOP", "0") +_
        NewTag$("WIDTH", LTRIM$(STR$(CINT(24 / 3 * 4)))) +_
        NewTag$("HEIGHT", LTRIM$(STR$(24))) +_
        NewTag$("KEEPASPECT", "true")
MultiAU$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "au20px.gif"))
MultiBR$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "br20px.gif"))
MultiCA$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "ca20px.gif"))
MultiDE$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "de20px.gif"))
MultiDK$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "dk20px.gif"))
MultiET$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "et20px.gif"))
MultiFR$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "fr20px.gif"))
MultiHT$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "ht20px.gif"))
MultiIT$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "it20px.gif"))
MultiJM$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "jm20px.gif"))
MultiKE$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "ke20px.gif"))
MultiKR$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "kr20px.gif"))
MultiLI$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "li20px.gif"))
MultiMN$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "mn20px.gif"))
MultiNA$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "na20px.gif"))
MultiOM$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "om20px.gif"))
MultiPA$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "pa20px.gif"))
MultiQA$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "qa20px.gif"))
MultiRU$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "ru20px.gif"))
MultiTZ$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "tz20px.gif"))
MultiUK$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "uk20px.gif"))
MultiUS$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "us20px.gif"))
MultiVE$ = ImageC$("INIT", MultiFlagsCommonProps$ + NewTag$("IMAGEFILE", "ve20px.gif"))
MultiLVListIMG$ = ListC$("INIT", NewTag$("SORT", "alphabet"))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Australia") + ImageTag$(MultiAU$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Brazil") + ImageTag$(MultiBR$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Canada") + ImageTag$(MultiCA$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Germany") + ImageTag$(MultiDE$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Denmark") + ImageTag$(MultiDK$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Ethiopia") + ImageTag$(MultiET$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "France") + ImageTag$(MultiFR$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Haiti") + ImageTag$(MultiHT$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Italy") + ImageTag$(MultiIT$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Jamaica") + ImageTag$(MultiJM$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Kenya") + ImageTag$(MultiKE$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "South Korea") + ImageTag$(MultiKR$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Liechtenstein") + ImageTag$(MultiLI$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Mongolia") + ImageTag$(MultiMN$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Namibia") + ImageTag$(MultiNA$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Oman") + ImageTag$(MultiOM$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Panama") + ImageTag$(MultiPA$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Qatar") + ImageTag$(MultiQA$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Russia") + ImageTag$(MultiRU$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Tanzania") + ImageTag$(MultiTZ$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "United Kingdom") + ImageTag$(MultiUK$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "United States") + ImageTag$(MultiUS$))
dummy$ = ListC$("STORE", MultiLVListIMG$ + NewTag$("DATA", "Venezuela") + ImageTag$(MultiVE$))
MultiLVwithIMG$ = ListviewC$("INIT",_
        PagerTag$(Page7$) +_
        ListTag$(MultiLVListIMG$) +_
        NewTag$("LEFT", "40") +_
        NewTag$("TOP", "540") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "166") +_
        NewTag$("SPACING", "8") +_
        NewTag$("ACTUAL", "7") +_
        NewTag$("SHORTCUT", MakeShortcut$("F1", 0, 0, 0)) +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LABEL", "A fancy List"))
MultiTextLVI$ = TextC$("INIT",_
        PagerTag$(Page7$) +_
        NewTag$("LEFT", "40") +_
        NewTag$("TOP", "715") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "35") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("IMAGEFILE", "Sand.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("FORM", "simple"))
MultiLVListPLAIN$ = ListC$("INIT", "")
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "January"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "February"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "March"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "April"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "May"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "June"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "July"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "August"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "September"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "October"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "November"))
dummy$ = ListC$("STORE", MultiLVListPLAIN$ + NewTag$("DATA", "December"))
MultiLVPlain$ = ListviewC$("INIT",_
        PagerTag$(Page7$) +_
        ListTag$(MultiLVListPLAIN$) +_
        NewTag$("LEFT", "281") +_
        NewTag$("TOP", "540") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "166") +_
        NewTag$("SPACING", "2") +_
        NewTag$("ACTUAL", "4") +_
        NewTag$("SHORTCUT", MakeShortcut$("F2", 0, 0, 0)) +_
        NewTag$("LABEL", "A plain List"))
MultiTextLVP$ = TextC$("INIT",_
        PagerTag$(Page7$) +_
        NewTag$("LEFT", "281") +_
        NewTag$("TOP", "715") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "35") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("IMAGEFILE", "Sand.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("FORM", "simple"))
MultiRADListF$ = ListC$("INIT", "")
dummy$ = ListC$("STORE", MultiRADListF$ + NewTag$("DATA", "Short Option"))
dummy$ = ListC$("STORE", MultiRADListF$ + NewTag$("DATA", "Longest Option"))
dummy$ = ListC$("STORE", MultiRADListF$ + NewTag$("DATA", "Longer Option"))
MultiRadio1$ = RadioC$("INIT",_
        PagerTag$(Page7$) +_
        ListTag$(MultiRADListF$) +_
        NewTag$("LEFT", "552") +_
        NewTag$("TOP", "570") +_
        NewTag$("SPACING", "23") +_
        NewTag$("SHORTCUT", MakeShortcut$("F3", 0, 0, 0)) +_
        NewTag$("WIDTH", "30") +_
        NewTag$("ACTUAL", "2") +_
        NewTag$("LABEL", "Radiobuttons") +_
        NewTag$("RECESSED", "true") +_
        NewTag$("FORM", "ridge"))
MultiTextRAD$ = TextC$("INIT",_
        PagerTag$(Page7$) +_
        NewTag$("LEFT", "523") +_
        NewTag$("TOP", "715") +_
        NewTag$("WIDTH", "176") +_
        NewTag$("HEIGHT", "35") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("IMAGEFILE", "Sand.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("FORM", "simple"))
MultiRADListBGF$ = ListC$("INIT", "")
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "Backgrounds are available"))
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "Different Frame types"))
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "Use other Button sizes"))
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "and different spacing"))
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "Text could also be placed"))
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "left from Buttons"))
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "Automatic box calculation"))
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "for Frames & Background"))
dummy$ = ListC$("STORE", MultiRADListBGF$ + NewTag$("DATA", "or omit those completely"))
MultiRadio2$ = RadioC$("INIT",_
        PagerTag$(Page7$) +_
        ListTag$(MultiRADListBGF$) +_
        NewTag$("LEFT", "759") +_
        NewTag$("TOP", "558") +_
        NewTag$("SPACING", "4") +_
        NewTag$("SHORTCUT", MakeShortcut$("F4", 0, 0, 0)) +_
        NewTag$("WIDTH", "18") +_
        NewTag$("ACTUAL", "7") +_
        NewTag$("IMAGEFILE", "Marble.jpg") +_
        NewTag$("AREA", "true") +_
        NewTag$("LABEL", "More Radiobuttons") +_
        NewTag$("RECESSED", "true") +_
        NewTag$("FORM", "simple"))
'--- Sub Pager on Page 1 ---
SubPageCommonProps$ =_
        PagerTag$(Page1$) +_
        NewTag$("TOP", "600") +_
        NewTag$("WIDTH", "166") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("WALLLEFT", "15") +_
        NewTag$("WALLRIGHT", "1008") +_
        NewTag$("WALLBOTTOM", "762") +_
        NewTag$("WALLAREA", "true")
SubPage2$ = PagerC$("INIT", SubPageCommonProps$ +_
        NewTag$("LEFT", "340") +_
        NewTag$("SHORTCUT", MakeShortcut$("F2", 1, 0, 0)) +_
        NewTag$("WALLPEN", "15") +_
        NewTag$("TEXT", "SubPage 2"))
SubPage3$ = PagerC$("INIT", SubPageCommonProps$ +_
        NewTag$("LEFT", "522") +_
        NewTag$("SHORTCUT", MakeShortcut$("F3", 1, 0, 0)) +_
        NewTag$("WALLIMAGE", "Platon.jpg") +_
        NewTag$("WALLPEN", "2") +_
        NewTag$("TEXT", "SubPage 3"))
SubPage4$ = PagerC$("INIT", SubPageCommonProps$ +_
        NewTag$("LEFT", "704") +_
        NewTag$("SHORTCUT", MakeShortcut$("F4", 1, 0, 0)) +_
        NewTag$("WALLIMAGE", "WoodLight.jpg") +_
        NewTag$("WALLPEN", "2") +_
        NewTag$("TEXT", "SubPage 4"))
SubPage1$ = PagerC$("INIT", SubPageCommonProps$ +_
        NewTag$("LEFT", "158") +_
        NewTag$("SHORTCUT", MakeShortcut$("F1", 1, 0, 0)) +_
        NewTag$("TEXT", "SubPage 1"))
'--- SubPage 1 ---
SubFrame1$ = FrameC$("INIT",_
        PagerTag$(SubPage1$) +_
        NewTag$("LEFT", "25") +_
        NewTag$("TOP", "644") +_
        NewTag$("WIDTH", "975") +_
        NewTag$("HEIGHT", "108") +_
        NewTag$("FORM", "ridge") +_
        NewTag$("TEXT", "Special Controls") +_
        NewTag$("TEXTPLACE", "topleft"))
TextCommonProps$ =_
        PagerTag$(SubPage1$) +_
        NewTag$("LEFT", "40") +_
        NewTag$("HEIGHT", "18")
TextLine1$ = TextC$("INIT", TextCommonProps$ +_
        NewTag$("TOP", "664") +_
        NewTag$("WIDTH", "800") +_
        NewTag$("TEXT", "Many interactive objects have also keyboard shortcuts assigned:"))
TextLine2$ = TextC$("INIT", TextCommonProps$ +_
        NewTag$("TOP", "689") +_
        NewTag$("WIDTH", "800") +_
        NewTag$("TEXT", "Shortcuts (if any) are shown in the object's tooltip when hovering an object for a second."))
TextLine3$ = TextC$("INIT", TextCommonProps$ +_
        NewTag$("TOP", "714") +_
        NewTag$("WIDTH", "955") +_
        NewTag$("TEXT", "Check Sliders, Scrollers, Colorwheels, Listviews, Radiobuttons also with mousewheel. Try also with Shift/Ctrl pressed."))
Sub1Button$ = ButtonC$("INIT",_
        PagerTag$(SubPage1$) +_
        NewTag$("LEFT", "843") +_
        NewTag$("TOP", "651") +_
        NewTag$("WIDTH", "150") +_
        NewTag$("HEIGHT", "30") +_
        NewTag$("SHORTCUT", MakeShortcut$("D", 0, 0, 0)) +_
        NewTag$("TEXT", "Disable SubPage 1") +_
        NewTag$("IMAGEFILE", "WarpBlue.jpg"))
'--- SubPage 2 ---
WallColorRuler$ = RulerC$("INIT",_
        PagerTag$(SubPage2$) +_
        NewTag$("LEFT", "262") +_
        NewTag$("TOP", "660") +_
        NewTag$("LENGTH", "500") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Wall Color Test"))
ColorButtonCommonProps$ =_
        PagerTag$(SubPage2$) +_
        NewTag$("TOP", "685") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50")
ColorTestButton1$ = ButtonC$("INIT", ColorButtonCommonProps$ +_
        NewTag$("LEFT", "190") +_
        NewTag$("SHORTCUT", MakeShortcut$("5", 0, 0, 0)) +_
        NewTag$("TEXT", "Color 15") +_
        NewTag$("DISABLED", "true"))
ColorTestButton2$ = ButtonC$("INIT", ColorButtonCommonProps$ +_
        NewTag$("LEFT", "410") +_
        NewTag$("SHORTCUT", MakeShortcut$("1", 0, 0, 0)) +_
        NewTag$("TEXT", "Color 11"))
ColorTestButton3$ = ButtonC$("INIT", ColorButtonCommonProps$ +_
        NewTag$("LEFT", "630") +_
        NewTag$("SHORTCUT", MakeShortcut$("3", 0, 0, 0)) +_
        NewTag$("TEXT", "Color 23"))
'--- SubPage 3 ---
RemoteRuler$ = RulerC$("INIT",_
        PagerTag$(SubPage3$) +_
        NewTag$("LEFT", "262") +_
        NewTag$("TOP", "660") +_
        NewTag$("LENGTH", "500") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Pager Remote Control"))
RemoteButtonCommonProps$ =_
        PagerTag$(SubPage3$) +_
        NewTag$("TOP", "685") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50")
RemoteButton1$ = ButtonC$("INIT", RemoteButtonCommonProps$ +_
        NewTag$("LEFT", "190") +_
        NewTag$("SHORTCUT", MakeShortcut$("1", 0, 0, 0)) +_
        NewTag$("TEXT", "ReEnable SubPage 1") +_
        NewTag$("DISABLED", "true"))
RemoteButton2$ = ButtonC$("INIT", RemoteButtonCommonProps$ +_
        NewTag$("LEFT", "410") +_
        NewTag$("SHORTCUT", MakeShortcut$("2", 0, 0, 0)) +_
        NewTag$("TEXT", "Back to SubPage 2"))
RemoteButton3$ = ButtonC$("INIT", RemoteButtonCommonProps$ +_
        NewTag$("LEFT", "630") +_
        NewTag$("SHORTCUT", MakeShortcut$("4", 0, 0, 0)) +_
        NewTag$("TEXT", "Goto SubPage 4"))
'--- SubPage 4 ---
MessageRuler$ = RulerC$("INIT",_
        PagerTag$(SubPage4$) +_
        NewTag$("LEFT", "262") +_
        NewTag$("TOP", "660") +_
        NewTag$("LENGTH", "500") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Show Message Boxes"))
MessageButtonCommonProps$ =_
        PagerTag$(SubPage4$) +_
        NewTag$("TOP", "685") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50")
MessageButton1$ = ButtonC$("INIT", MessageButtonCommonProps$ +_
        NewTag$("LEFT", "190") +_
        NewTag$("SHORTCUT", MakeShortcut$("1", 0, 0, 0)) +_
        NewTag$("TEXT", "Simple 1-Button"))
MessageButton2$ = ButtonC$("INIT", MessageButtonCommonProps$ +_
        NewTag$("LEFT", "410") +_
        NewTag$("SHORTCUT", MakeShortcut$("2", 0, 0, 0)) +_
        NewTag$("TEXT", "Multiline 2-Button"))
MessageButton3$ = ButtonC$("INIT", MessageButtonCommonProps$ +_
        NewTag$("LEFT", "630") +_
        NewTag$("SHORTCUT", MakeShortcut$("m", 0, 0, 0)) +_
        NewTag$("TEXT", "Multiline Multibutton"))
'--- define background image ---
BackImage$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Blossom.jpg") +_
        NewTag$("BACKFILL", "true") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "0") +_
        NewTag$("TOP", "0"))
'~~~~~

'-----------------------
'--- Runtime Globals ---
'-----------------------
'--- Here we can define the remaining global variables, which are not
'--- needed for object initialization, but during runtime.
'-----
done% = 0 'our main loop continuation boolean
subClicks% = 1 'try to find out, what this is used for :)
IF _FILEEXISTS("qb64.exe") THEN
    'FileSelect$() initial drawer (if compiled to QB64 folder)
    fsStartDir$ = "QB64GuiTools\images"
ELSE
    'FileSelect$() initial drawer (if compiled to source folder)
    fsStartDir$ = "..\images"
END IF

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
    '-----------------------------------------------------------------
    'Here comes the almighty call, it's a very complex operation going
    'on here. First the keyboard and mouse inputs are collected and run
    'through a first wrapping stage, which will wrap keypresses, mouse
    'movements and mouse button clicks into its respective event tags.
    'Then each object is asked in hierachical order (root>parent>child),
    'if it is affected by these events. If so, then the object will do
    'required actions (state changes, maybe redraw its imagery) and will
    'give back a "status report" to the input handler, which now enters
    'a second wrapping stage to create the resulting event tags. Finally
    'the entire message (all event tags) is returned. Obviously this task
    'gets more complex and time consuming, as more objects will be added
    'to the GUI. To keep the overhead as low as possible, every invoked
    'routine will do its best to figure out if and what must be done and
    'what not, eg. Rulers/Frames and some others cannot handle any input,
    'so they are excluded from the input/update process, same is true for
    'currently disabled or invisible objects. Also a redraw is required
    'only, if any state change in the object will happen, which would
    'affect the currently displayed imagery. The implementation of this
    'entire process did took most of the development time, but I'm sure
    'it was worth it, as this almost automatic GUI operation is a key
    'feature of a good GUI system. As programmer I don't want to do the
    'whole work of drawing the GUI, updating objects etc., I don't want
    'to constantly monitor mouse positions and mouse button states to
    'find out, if any of my objects got focus or was clicked. I just want
    'to init eg. a Button and then get notified, if it got clicked. So
    'all this is covered by the just following call...
    '-----------------------------------------------------------------
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
    '
    '-----------------------------------------------------------------
    'These outputs are not required for the GUI operations, it's just for
    'this demo, so you can see what's going on in the received messages
    'while running the loop.
    dummy$ = GenC$("SET", MouseXPos$ + NewTag$("TEXT", GetTag$(mess$, "MOUSEX")))
    dummy$ = GenC$("SET", MouseYPos$ + NewTag$("TEXT", GetTag$(mess$, "MOUSEY")))
    dummy$ = GenC$("SET", MouseLeft$ + NewTag$("TEXT", GetTag$(mess$, "MOUSELB")))
    dummy$ = GenC$("SET", MouseMiddle$ + NewTag$("TEXT", GetTag$(mess$, "MOUSEMB")))
    dummy$ = GenC$("SET", MouseRight$ + NewTag$("TEXT", GetTag$(mess$, "MOUSERB")))
    RemTags mess$, "MOUSEX,MOUSEY,MOUSELB,MOUSERB,MOUSEMB"
    IF mess$ <> "" THEN dummy$ = GenC$("SET", LastMessage$ + NewTag$("TEXT", mess$))
    '-----------------------------------------------------------------
    'Some more outputs just for your enjoyment, it will display the flags
    'of some buttons, so you can see, how things change, when a button is
    'on focus, selected or disabled.
    result$ = GenC$("GET", OnOffButton$ + NewTag$("TAGNAMES", "DISABLED,FOCUS,SELECTED"))
    dummy$ = GenC$("SET", OnOffState$ + NewTag$("TEXT", result$ + " "))
    result$ = GenC$("GET", FrameSwitch$ + NewTag$("TAGNAMES", "DISABLED,FOCUS,SELECTED"))
    dummy$ = GenC$("SET", FrameSwitchState$ + NewTag$("TEXT", result$ + " "))
    IF QuitButton$ <> "" AND NOT ThisObject%(EndingButton1$, mess$, "GADGETUP") THEN
        result$ = GenC$("GET", QuitButton$ + NewTag$("TAGNAMES", "DISABLED,FOCUS,SELECTED"))
        dummy$ = GenC$("SET", QuitState$ + NewTag$("TEXT", result$ + " "))
    END IF
WEND
'~~~~~

'--- Who did it? ---
IF BoolTagTrue%(abou$, "CHECKED") THEN
    dummy$ = MessageBox$("", "About",_
                         "The GuiTools Framework v0.15|" +_
                         "Done by RhoSigma, Roland Heyder|~" +_
                         "Thanx for your interest in my work.",_
                         "{SYM RhoSigma * 10 * 2}It's been a pleasure!")
END IF

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
ChangePagerStatesPage1:
subClicks% = (subClicks% OR 16) 'avoid any further updates
dummy$ = GenC$("SET", KillTestButton1$ + NewTag$("DISABLED", "false"))
dummy$ = GenC$("SET", Page2$ + SymbolTag$(GreenCheckSym$))
dummy$ = GenC$("SET", Page3$ + SymbolTag$(GreenCheckSym$))
dummy$ = GenC$("SET", Page4$ + SymbolTag$(GreenCheckSym$))
dummy$ = GenC$("SET", Page5$ + SymbolTag$(GreenCheckSym$))
dummy$ = GenC$("SET", Page6$ + SymbolTag$(GreenCheckSym$))
dummy$ = GenC$("SET", Page7$ + SymbolTag$(GreenCheckSym$))
dummy$ = GenC$("KILL", RedCrossSym$) 'no longer needed
RETURN
'----------
RefreshSizeGaugePage3:
widt% = VAL(GetTagData$(GenC$("GET", EndingSlider1$ + NewTag$("TAGNAMES", "LEVEL")), "LEVEL", "250"))
heig% = VAL(GetTagData$(GenC$("GET", EndingSlider2$ + NewTag$("TAGNAMES", "LEVEL")), "LEVEL", "175"))
perc% = 100 / (250 * 175) * (widt% * heig%)
dummy$ = GenC$("SET", EndingGauge$ + NewTag$("LEVEL", LTRIM$(STR$(perc%))))
RETURN
'----------
RefreshColorGaugePage5:
pRed% = VAL(GetTagData$(GenC$("GET", PalRGBSliderR$ + NewTag$("TAGNAMES", "LEVEL")), "LEVEL", "0"))
pGre% = VAL(GetTagData$(GenC$("GET", PalRGBSliderG$ + NewTag$("TAGNAMES", "LEVEL")), "LEVEL", "0"))
pBlu% = VAL(GetTagData$(GenC$("GET", PalRGBSliderB$ + NewTag$("TAGNAMES", "LEVEL")), "LEVEL", "0"))
_PALETTECOLOR 255, _RGB32(pRed%, pGre%, pBlu%)
RETURN
'----------
RefreshScrollImagePage6:
IF BoolTagTrue%(GenC$("GET", Page6$ + NewTag$("TAGNAMES", "ACTIVE")), "ACTIVE") THEN
    IF guiViews$(0) = "" THEN
        COLOR guiTextPen%, guiBackPen%
        _PRINTSTRING (620, 615), "+---------------------------------+"
        _PRINTSTRING (620, 631), "| No background image selected !! |"
        _PRINTSTRING (620, 647), "+---------------------------------+"
        dummy$ = GenC$("SET", ScrImgScrollerH$ + NewTag$("TOTALNUM", "0"))
        dummy$ = GenC$("SET", ScrImgScrollerV$ + NewTag$("TOTALNUM", "0"))
    ELSE
        imag& = VAL(GetTagData$(GenC$("GET", ObjectTag$(guiViews$(0), "BGIMG") + NewTag$("TAGNAMES", "RHANDLE")), "RHANDLE", "-1"))
        dummy$ = GenC$("SET", ScrImgScrollerH$ + NewTag$("TOTALNUM", LTRIM$(STR$(_WIDTH(imag&)))))
        dummy$ = GenC$("SET", ScrImgScrollerV$ + NewTag$("TOTALNUM", LTRIM$(STR$(_HEIGHT(imag&)))))
        htop% = VAL(GetTagData$(GenC$("GET", ScrImgScrollerH$ + NewTag$("TAGNAMES", "TOPNUM")), "TOPNUM", "0"))
        vtop% = VAL(GetTagData$(GenC$("GET", ScrImgScrollerV$ + NewTag$("TAGNAMES", "TOPNUM")), "TOPNUM", "0"))
        _PUTIMAGE (548, 559), imag&, _DEST, (htop%, vtop%)-(419 + htop% - 1, 164 + vtop% - 1)
    END IF
END IF
RETURN
'----------
RefreshSelectionDisplaysPage7:
lv1$ = GetTagData$(GenC$("GET", MultiLVwithIMG$ + NewTag$("TAGNAMES", "DATA")), "DATA", "")
lv2$ = GetTagData$(GenC$("GET", MultiLVPlain$ + NewTag$("TAGNAMES", "DATA")), "DATA", "")
ra1$ = GetTagData$(GenC$("GET", MultiRadio1$ + NewTag$("TAGNAMES", "DATA")), "DATA", "")
dummy$ = GenC$("SET", MultiTextLVI$ + NewTag$("TEXT", lv1$))
dummy$ = GenC$("SET", MultiTextLVP$ + NewTag$("TEXT", lv2$))
dummy$ = GenC$("SET", MultiTextRAD$ + NewTag$("TEXT", ra1$))
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
'appIcon& = _LOADIMAGE("QB64GuiTools\images\icons\RhoSigma32px.png", 32)
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

'$INCLUDE: 'inline\Info16Img.bm'
'$INCLUDE: 'inline\Info32Img.bm'
'$INCLUDE: 'inline\Problem16Img.bm'
'$INCLUDE: 'inline\Problem32Img.bm'
'$INCLUDE: 'inline\Error16Img.bm'
'$INCLUDE: 'inline\Error32Img.bm'

