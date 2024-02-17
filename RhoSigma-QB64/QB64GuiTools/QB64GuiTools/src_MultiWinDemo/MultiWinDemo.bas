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
'| === MultiWinDemo.bas ===                                          |
'|                                                                   |
'| == Just a short demo to showcase the new multiple forms/windows   |
'| == abilities of GuiTools.                                         |
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

SetupScreen 460, 345, 0
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
CONST guiReservedPens% = 0 'no reserved pens
'-----

'~~~ My GUI Setup
'-----------------------------
'--- Init GUI objects here ---
'-----------------------------
' In a multiple windows application we first need to define the additional
' GuiViews beside the main window. The use of the main program window is
' always implied and the window is created as usual by the SetupScreen()
' call above. Without any further GuiView specification all created GUI
' objects will display in the main window as usual, so there are no technical
' changes, if you just work with a single window. In a multiple windows
' application the main window can be designated either as GuiView #0, or
' by simply omitting any specific GuiView designation.
'--- create some GuiViews ---
v1& = CreateGuiView&("GuiView #1", 460, 345)
v2& = CreateGuiView&("GuiView #2", 460, 345)
'--- now let's set a background for all windows ---
' Note that all object backgrounds specified here in the object init calls
' are just defaults, which are used only, if there are no user preferences
' found for a particular object class. You can easily change settings by
' using the GuiTools Preferences Editor (src_GTPrefsEditor).
' Designating an object for a specific GuiView is as easy as adding the
' new GUIVIEW tag to the init call, we can do this manually with a NewTag$()
' call or we simply use the wrapper function ViewTag$() for that purpose.
' As said above we simply omit the view tag for objects in the main window.
MainBackImage$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Rainbow.jpg") +_
        NewTag$("BACKFILL", "true") +_
        NewTag$("LEFT", "0") +_
        NewTag$("TOP", "0"))
V1BackImage$ = ImageC$("INIT",_
        ViewTag$(v1&) +_
        NewTag$("IMAGEFILE", "Fish.jpg") +_
        NewTag$("BACKFILL", "true") +_
        NewTag$("LEFT", "0") +_
        NewTag$("TOP", "0"))
V2BackImage$ = ImageC$("INIT",_
        ViewTag$(v2&) +_
        NewTag$("IMAGEFILE", "BumpMap.jpg") +_
        NewTag$("BACKFILL", "true") +_
        NewTag$("AREA", "true") +_
        NewTag$("LEFT", "0") +_
        NewTag$("TOP", "0"))
'--- following objects in main window, hence no ViewTag$() ---
'--- the code for these buttons is in handlers\gadgetup.bm ---
MainV1OpenButton$ = ButtonC$("INIT",_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "20") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50") +_
        NewTag$("TEXT", "Open GuiView #1") +_
        NewTag$("IMAGEFILE", "Crap.jpg"))
MainV1CloseButton$ = ButtonC$("INIT",_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "90") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50") +_
        NewTag$("TEXT", "Close GuiView #1") +_
        NewTag$("IMAGEFILE", "Crap.jpg"))
MainV2OpenButton$ = ButtonC$("INIT",_
        NewTag$("LEFT", "240") +_
        NewTag$("TOP", "20") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50") +_
        NewTag$("TEXT", "Open GuiView #2") +_
        NewTag$("IMAGEFILE", "Crap.jpg"))
MainV2CloseButton$ = ButtonC$("INIT",_
        NewTag$("LEFT", "240") +_
        NewTag$("TOP", "90") +_
        NewTag$("WIDTH", "200") +_
        NewTag$("HEIGHT", "50") +_
        NewTag$("TEXT", "Close GuiView #2") +_
        NewTag$("IMAGEFILE", "Crap.jpg"))
MainRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "168") +_
        NewTag$("LENGTH", "420") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Some cross-window interconnections"))
MainText$ = TextC$("INIT",_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "195") +_
        NewTag$("WIDTH", "420") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("LABEL", "The text you may type in GuiView #1"))
MainSlider$ = SliderC$("INIT",_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "255") +_
        NewTag$("WIDTH", "420") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("MINIMUM", "0") +_
        NewTag$("MAXIMUM", "100") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("LABEL", "This slider is connected to one in GuiView #2"))
'--- following objects in GuiView #1 window ---
V1Ruler$ = RulerC$("INIT",_
        ViewTag$(v1&) +_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "20") +_
        NewTag$("LENGTH", "420") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Some cross-window interconnections"))
V1String$ = StringC$("INIT",_
        ViewTag$(v1&) +_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "47") +_
        NewTag$("WIDTH", "420") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("MAXIMUM", "50") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("LABEL", "Typed text will also go to other windows"))
V1Progress$ = ProgressC$("INIT",_
        ViewTag$(v1&) +_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "107") +_
        NewTag$("WIDTH", "420") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("LABEL", "This progess is connected to the sliders"))
'--- following objects in GuiView #2 window ---
V2Ruler$ = RulerC$("INIT",_
        ViewTag$(v2&) +_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "70") +_
        NewTag$("LENGTH", "420") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", "Some cross-window interconnections"))
V2Text$ = TextC$("INIT",_
        ViewTag$(v2&) +_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "117") +_
        NewTag$("WIDTH", "420") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("LABEL", "The text you may type in GuiView #1"))
V2Slider$ = SliderC$("INIT",_
        ViewTag$(v2&) +_
        NewTag$("LEFT", "20") +_
        NewTag$("TOP", "197") +_
        NewTag$("WIDTH", "420") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("MINIMUM", "0") +_
        NewTag$("MAXIMUM", "100") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("LABEL", "This slider is connected to one in main window"))
'--- finally the interconnections ---
IcSliderMainV1$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(MainSlider$) +_
        NewTag$("PRITAG", "LEVEL") +_
        FwdSecTag$(V1Progress$) +_
        NewTag$("SECTAG", "LEVEL"))
IcSliderMainV2$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(MainSlider$) +_
        NewTag$("PRITAG", "LEVEL") +_
        FwdSecTag$(V2Slider$) +_
        NewTag$("SECTAG", "LEVEL"))
IcTextV1Main$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(V1String$) +_
        NewTag$("PRITAG", "TEXT") +_
        FwdSecTag$(MainText$) +_
        NewTag$("SECTAG", "TEXT"))
IcTextV1V2$ = ModelC$("INIT",_
        NewTag$("WHICH", "Forward") +_
        FwdPriTag$(V1String$) +_
        NewTag$("PRITAG", "TEXT") +_
        FwdSecTag$(V2Text$) +_
        NewTag$("SECTAG", "TEXT"))
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

