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
'| === GTPrefsEditor.bas ===                                         |
'|                                                                   |
'| == With this program users may easily alterate the internal       |
'| == default settings of all GuiTools object classes and also       |
'| == change the used default color scheme. The made settings are    |
'| == permanently saved in the %localappdata% folder and all running |
'| == GuiTools based applications will use it. Hence every user can  |
'| == create his own desired look, which all GuiTools applications   |
'| == will follow, doesn't matter what colors or object background   |
'| == images were originally defined by the application developer.   |
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

SetupScreen 640, 480, 0
appCR$ = "The GuiTools Preferences Editor v1.0, Done by RhoSigma, Roland Heyder"
_TITLE appExeName$ + " - " + appCR$

mtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-gtprefs.bin" + CHR$(0))
pff% = SafeOpenFile%("B", appLocalDir$ + "gtprefs.bin")
num% = LOF(pff%)
GET pff%, 51, ac% 'current accessor count
CLOSE pff%
UnlockMutex mtx%&
IF num% < 60 THEN
    nam$ = MessageBox$("Problem16px.png", appExeName$, "No preferences found, please choose a preset.", "Standard|RhoSigma's Favorite")
    IF nam$ = "RhoSigma's Favorite" THEN
        mtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-gtprefs.bin" + CHR$(0))
        KILL appLocalDir$ + "gtprefs.bin"
        nam$ = WritePresetsArray$(appLocalDir$ + "gtprefs.bin", 0)
        pff% = SafeOpenFile%("B", appLocalDir$ + "gtprefs.bin")
        PUT pff%, 51, ac% 'current accessor count
        CLOSE pff%
        UnlockMutex mtx%&
    END IF
END IF

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
numSect$ = "2" 'initial prefs section list entry
section$ = "ImageC.Backfill" 'initial prefs section name
oldSect$ = "" 'last active prefs section name
DIM options AS ChunkCSET 'class settings chunk
GetPrefs section$, options 'read initial settings
actPen% = 1 'active GUI context pen
actCol% = 0 'active PaletteTool color

'~~~ My GUI Setup
'-----------------------------
'--- Init GUI objects here ---
'-----------------------------
'--- init several constant option lists ---
SectList$ = ListC$("INIT", "")
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "Global.Colors"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "ImageC.Backfill"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "PagerC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "PagerC.WallImg"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "PagerC.WallPen"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "ButtonC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "CheckboxC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "StringC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "TextC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "ProgressC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "CycleC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "ListviewC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "RadioC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "ColorwheelC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "SliderC"))
res$ = ListC$("STORE", SectList$ + NewTag$("DATA", "ScrollerC"))
PenList$ = ListC$("INIT", "")
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Blank Background"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Normal Text/Drawing"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Highlight Text/Drawing"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Fill (selected) BG"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Fill (selected) Text"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Shine Text/Edges"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Shadow Text/Edges"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Solid Fill (Frame/Ruler)"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Green Condition Pen"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "Red Condition Pen"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "LoadMode BG (FileSelect)"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "SaveMode BG (FileSelect)"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "MediaDisk (FileSelect)"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "MediaDrawer (FileSelect)"))
res$ = ListC$("STORE", PenList$ + NewTag$("DATA", "MediaFile (FileSelect)"))
ColorList$ = ListC$("INIT", "")
FOR i% = 0 TO 23
    res$ = SymbolC$("INIT", NewTag$("LEFT", "0") + NewTag$("TOP", "0") + NewTag$("WIDTH", "23") + NewTag$("HEIGHT", "17") + NewTag$("WHICH", "TapeStop") + NewTag$("SHINEPEN", LTRIM$(STR$(i%))))
    res$ = ListC$("STORE", ColorList$ + NewTag$("DATA", "Color" + STR$(i%)) + SymbolTag$(res$))
NEXT i%
TileList$ = ListC$("INIT", "")
res$ = ListC$("STORE", TileList$ + NewTag$("DATA", "tile default image to fill area"))
res$ = ListC$("STORE", TileList$ + NewTag$("DATA", "scale default image to fit area"))
PModList$ = ListC$("INIT", "")
res$ = ListC$("STORE", PModList$ + NewTag$("DATA", "blank objects use default image"))
res$ = ListC$("STORE", PModList$ + NewTag$("DATA", "do not overpaint blank objects"))
PModListWall$ = ListC$("INIT", "")
res$ = ListC$("STORE", PModListWall$ + NewTag$("DATA", "blank walls use default image or pen"))
res$ = ListC$("STORE", PModListWall$ + NewTag$("DATA", "do not overpaint blank walls"))
DemoHList$ = ListC$("INIT", "")
res$ = ListC$("STORE", DemoHList$ + NewTag$("DATA", "IMAGEHANDLE tag"))
res$ = ListC$("STORE", DemoHList$ + NewTag$("DATA", "Option 2"))
res$ = ListC$("STORE", DemoHList$ + NewTag$("DATA", "Option 3"))
res$ = ListC$("STORE", DemoHList$ + NewTag$("DATA", "Option 4"))
res$ = ListC$("STORE", DemoHList$ + NewTag$("DATA", "Option 5"))
DemoFList$ = ListC$("INIT", "")
res$ = ListC$("STORE", DemoFList$ + NewTag$("DATA", "IMAGEFILE tag"))
res$ = ListC$("STORE", DemoFList$ + NewTag$("DATA", "Option 2"))
res$ = ListC$("STORE", DemoFList$ + NewTag$("DATA", "Option 3"))
res$ = ListC$("STORE", DemoFList$ + NewTag$("DATA", "Option 4"))
res$ = ListC$("STORE", DemoFList$ + NewTag$("DATA", "Option 5"))

BuildGUI:
'--- on section change destroy affected objects ---
IF oldSect$ <> "" THEN GOSUB ClearGUI

'--- preselect some texts ---
IF section$ = "Global.Colors" THEN
    sbt$ = "Reset to standard color scheme." 'Standard Button tooltip
    pvr$ = "Palette Tool" 'Preview Ruler text
ELSE
    sbt$ = "Reset the selected Section to|standard (ie. full control|on the application's side)."
    pvr$ = "Object Preview"
END IF

'--- then rebuild destroyed main GUI objects,  ---
'--- first the config/section independent ones ---
IF SectLView$ = "" THEN SectLView$ = ListviewC$("INIT",_
        ListTag$(SectList$) +_
        NewTag$("LEFT", "25") +_
        NewTag$("TOP", "30") +_
        NewTag$("WIDTH", "151") +_
        NewTag$("HEIGHT", "211") +_
        NewTag$("SPACING", "2") +_
        NewTag$("ACTUAL", numSect$) +_
        NewTag$("LABEL", "Sections") +_
        NewTag$("LABELHIGH", "on") +_
        NewTag$("TOOLTIP", "Select the desired|Preferences Section."))
IF StdButt$ = "" THEN StdButt$ = ButtonC$("INIT",_
        NewTag$("LEFT", "25") +_
        NewTag$("TOP", "244") +_
        NewTag$("WIDTH", "151") +_
        NewTag$("HEIGHT", "31") +_
        NewTag$("TEXT", "Standard") +_
        NewTag$("TOOLTIP", sbt$))
IF OptsFrame$ = "" THEN OptsFrame$ = FrameC$("INIT",_
        NewTag$("LEFT", "200") +_
        NewTag$("TOP", "30") +_
        NewTag$("WIDTH", "415") +_
        NewTag$("HEIGHT", "245") +_
        NewTag$("FORM", "ridge") +_
        NewTag$("RECESSED", "on") +_
        NewTag$("LABEL", "Options") +_
        NewTag$("LABELHIGH", "on"))
IF PreviewRuler$ = "" THEN PreviewRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "15") +_
        NewTag$("TOP", "300") +_
        NewTag$("LENGTH", "610") +_
        NewTag$("FORM", "solid") +_
        NewTag$("TEXT", pvr$))
IF GetFileSym$ = "" THEN GetFileSym$ = SymbolC$("INIT",_
        NewTag$("LEFT", "7") +_
        NewTag$("TOP", "7") +_
        NewTag$("WIDTH", "17") +_
        NewTag$("HEIGHT", "17") +_
        NewTag$("WHICH", "MediaDisk"))
'--- then the objects which change between sections ---
SELECT CASE section$
    CASE "Global.Colors"
        IF PenLView$ = "" THEN PenLView$ = ListviewC$("INIT",_
                ListTag$(PenList$) +_
                NewTag$("LEFT", "226") +_
                NewTag$("TOP", "65") +_
                NewTag$("WIDTH", "218") +_
                NewTag$("HEIGHT", "190") +_
                NewTag$("SPACING", "2") +_
                NewTag$("ACTUAL", LTRIM$(STR$(actPen%))) +_
                NewTag$("LABEL", "Context Pens") +_
                NewTag$("LABELPLACE", "above") +_
                NewTag$("TOOLTIP", "Select the GUI context pen to change."))
        SELECT CASE actPen%
            CASE 1: col% = guiBackPen%
            CASE 2: col% = guiTextPen%
            CASE 3: col% = guiHighPen%
            CASE 4: col% = guiFillPen%
            CASE 5: col% = guiFillTextPen%
            CASE 6: col% = guiShinePen%
            CASE 7: col% = guiShadowPen%
            CASE 8: col% = guiSolidPen%
            CASE 9: col% = guiGreenPen%
            CASE 10: col% = guiRedPen%
            CASE 11: col% = guiLoadBack%
            CASE 12: col% = guiSaveBack%
            CASE 13: col% = guiMediaDisk%
            CASE 14: col% = guiMediaDrawer%
            CASE 15: col% = guiMediaFile%
        END SELECT
        IF ColorLView$ = "" THEN ColorLView$ = ListviewC$("INIT",_
                ListTag$(ColorList$) +_
                NewTag$("LEFT", "464") +_
                NewTag$("TOP", "65") +_
                NewTag$("WIDTH", "126") +_
                NewTag$("HEIGHT", "190") +_
                NewTag$("SPACING", "2") +_
                NewTag$("ACTUAL", LTRIM$(STR$(col% + 1))) +_
                NewTag$("LABEL", "Colors") +_
                NewTag$("LABELPLACE", "above") +_
                NewTag$("TOOLTIP", "Assign a color to the|selected GUI context pen."))
        IF PalColor$ = "" THEN PalColor$ = SliderC$("INIT",_
                NewTag$("TOP", "319") +_
                NewTag$("LEFT", "225") +_
                NewTag$("WIDTH", "405") +_
                NewTag$("HEIGHT", "31") +_
                NewTag$("MINIMUM", "0") +_
                NewTag$("MAXIMUM", "23") +_
                NewTag$("LEVEL", LTRIM$(STR$(col%))) +_
                NewTag$("LABEL", "Color") +_
                NewTag$("LABELPLACE", "left") +_
                NewTag$("TOOLTIP", "Select the palette color to change."))
        IF PalGauge$ = "" THEN PalGauge$ = SymbolC$("INIT",_
                NewTag$("LEFT", "170") +_
                NewTag$("TOP", "363") +_
                NewTag$("WIDTH", "60") +_
                NewTag$("HEIGHT", "97") +_
                NewTag$("STANDALONE", "yes") +_
                NewTag$("WHICH", "TapeStop") +_
                NewTag$("SHINEPEN", "0") +_
                NewTag$("TOOLTIP", "Shows the mixed color."))
        IF PalWheel$ = "" THEN PalWheel$ = ColorwheelC$("INIT",_
                NewTag$("LEFT", "10") +_
                NewTag$("TOP", "320") +_
                NewTag$("HUE", "0") +_
                NewTag$("SATURATION", "0") +_
                NewTag$("WIDTH", "150") +_
                NewTag$("TOOLTIP", "Roughly adjust the selected color."))
        PalSliderCommonProps$ =_
                NewTag$("WIDTH", "180") +_
                NewTag$("HEIGHT", "37") +_
                NewTag$("MINIMUM", "0") +_
                NewTag$("LABELPLACE", "left")
        IF PalHSBSliderH$ = "" THEN
            'make a Hue gradient image for the slider
            gradient& = _NEWIMAGE(180, 37, 32): _DEST gradient&
            FOR x% = 0 TO 175
                HSBtoRGB CLNG(x% * (65535 / 175)), 65535, 65535, re&, gr&, bl&
                LINE (x% + 2, 2)-(x% + 2, 34), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
            NEXT x%: _DEST 0
            PalHSBSliderH$ = SliderC$("INIT", PalSliderCommonProps$ +_
                    NewTag$("TOP", "353") +_
                    NewTag$("LEFT", "250") +_
                    NewTag$("MAXIMUM", "359") +_
                    NewTag$("LABEL", "H") +_
                    NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))) +_
                    NewTag$("TOOLTIP", "Finetune the Hue value."))
        END IF
        IF PalHSBSliderS$ = "" THEN
            'make a Saturation gradient image for the slider
            gradient& = _NEWIMAGE(180, 37, 32): _DEST gradient&
            FOR x% = 0 TO 175
                FOR y% = 0 TO 32
                    HSBtoRGB CLNG(y% * (65535 / 32)), CLNG(x% * (65535 / 175)), 65535, re&, gr&, bl&
                    PSET (x% + 2, y% + 2), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
                NEXT y%
            NEXT x%: _DEST 0
            PalHSBSliderS$ = SliderC$("INIT", PalSliderCommonProps$ +_
                    NewTag$("TOP", "393") +_
                    NewTag$("LEFT", "250") +_
                    NewTag$("MAXIMUM", "100") +_
                    NewTag$("LABEL", "S") +_
                    NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))) +_
                    NewTag$("TOOLTIP", "Finetune the Saturation value."))
        END IF
        IF PalHSBSliderB$ = "" THEN
            'make a Brightness gradient image for the slider
            gradient& = _NEWIMAGE(180, 37, 32): _DEST gradient&
            FOR x% = 0 TO 175
                HSBtoRGB 0, 0, CLNG(x% * (65535 / 175)), re&, gr&, bl&
                LINE (x% + 2, 2)-(x% + 2, 34), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
            NEXT x%: _DEST 0
            PalHSBSliderB$ = SliderC$("INIT", PalSliderCommonProps$ +_
                    NewTag$("TOP", "433") +_
                    NewTag$("LEFT", "250") +_
                    NewTag$("MAXIMUM", "100") +_
                    NewTag$("LEVEL", "100") +_
                    NewTag$("LABEL", "B") +_
                    NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))) +_
                    NewTag$("TOOLTIP", "Finetune the Brightness value."))
        END IF
        IF PalRGBSliderR$ = "" THEN
            'make a Red gradient image for the slider
            gradient& = _NEWIMAGE(180, 37, 32): _DEST gradient&
            FOR x% = 0 TO 175
                HSBtoRGB 0, 65535, CLNG(x% * (65535 / 175)), re&, gr&, bl&
                LINE (x% + 2, 2)-(x% + 2, 34), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
            NEXT x%: _DEST 0
            PalRGBSliderR$ = SliderC$("INIT", PalSliderCommonProps$ +_
                    NewTag$("TOP", "353") +_
                    NewTag$("LEFT", "450") +_
                    NewTag$("MAXIMUM", "255") +_
                    NewTag$("LEVEL", "255") +_
                    NewTag$("LABEL", "R") +_
                    NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))) +_
                    NewTag$("TOOLTIP", "Finetune the Red value."))
        END IF
        IF PalRGBSliderG$ = "" THEN
            'make a Green gradient image for the slider
            gradient& = _NEWIMAGE(180, 37, 32): _DEST gradient&
            FOR x% = 0 TO 175
                HSBtoRGB 21845, 65535, CLNG(x% * (65535 / 175)), re&, gr&, bl&
                LINE (x% + 2, 2)-(x% + 2, 34), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
            NEXT x%: _DEST 0
            PalRGBSliderG$ = SliderC$("INIT", PalSliderCommonProps$ +_
                    NewTag$("TOP", "393") +_
                    NewTag$("LEFT", "450") +_
                    NewTag$("MAXIMUM", "255") +_
                    NewTag$("LEVEL", "255") +_
                    NewTag$("LABEL", "G") +_
                    NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))) +_
                    NewTag$("TOOLTIP", "Finetune the Green value."))
        END IF
        IF PalRGBSliderB$ = "" THEN
            'make a Blue gradient image for the slider
            gradient& = _NEWIMAGE(180, 37, 32): _DEST gradient&
            FOR x% = 0 TO 175
                HSBtoRGB 43690, 65535, CLNG(x% * (65535 / 175)), re&, gr&, bl&
                LINE (x% + 2, 2)-(x% + 2, 34), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
            NEXT x%: _DEST 0
            PalRGBSliderB$ = SliderC$("INIT", PalSliderCommonProps$ +_
                    NewTag$("TOP", "433") +_
                    NewTag$("LEFT", "450") +_
                    NewTag$("MAXIMUM", "255") +_
                    NewTag$("LEVEL", "255") +_
                    NewTag$("LABEL", "B") +_
                    NewTag$("IMAGEHANDLE", LTRIM$(STR$(gradient&))) +_
                    NewTag$("TOOLTIP", "Finetune the Blue value."))
        END IF
        'establish HSB-RGB interconnections
        PalIcHue$ = ModelC$("INIT", NewTag$("WHICH", "Forward") +_
                FwdPriTag$(PalWheel$) + NewTag$("PRITAG", "HUE") +_
                FwdSecTag$(PalHSBSliderH$) + NewTag$("SECTAG", "LEVEL"))
        PalIcSat$ = ModelC$("INIT", NewTag$("WHICH", "Forward") +_
                FwdPriTag$(PalWheel$) + NewTag$("PRITAG", "SATURATION") +_
                FwdSecTag$(PalHSBSliderS$) + NewTag$("SECTAG", "LEVEL"))
        PalIcHsbRgb$ = ModelC$("INIT", NewTag$("WHICH", "HsbRgb") +_
                HsbHueTag$(PalHSBSliderH$) + NewTag$("HUETAG", "LEVEL") +_
                HsbSatTag$(PalHSBSliderS$) + NewTag$("SATTAG", "LEVEL") +_
                HsbBriTag$(PalHSBSliderB$) + NewTag$("BRITAG", "LEVEL") +_
                RgbRedTag$(PalRGBSliderR$) + NewTag$("REDTAG", "LEVEL") +_
                RgbGreTag$(PalRGBSliderG$) + NewTag$("GRETAG", "LEVEL") +_
                RgbBluTag$(PalRGBSliderB$) + NewTag$("BLUTAG", "LEVEL"))
    CASE "PagerC.WallPen"
        IF InfoTxt$ = "" THEN InfoTxt$ = TextC$("INIT",_
                NewTag$("LEFT", "226") +_
                NewTag$("TOP", "45") +_
                NewTag$("WIDTH", "364") +_
                NewTag$("HEIGHT", "67") +_
                NewTag$("FORM", "ridge"))
        IF InfoTxt1$ = "" THEN InfoTxt1$ = TextC$("INIT",_
                NewTag$("LEFT", "229") +_
                NewTag$("TOP", "49") +_
                NewTag$("WIDTH", "356") +_
                NewTag$("HEIGHT", "19") +_
                NewTag$("TEXTPLACE", "center") +_
                NewTag$("TEXT", "Note that images, given or allowed in the"))
        IF InfoTxt2$ = "" THEN InfoTxt2$ = TextC$("INIT",_
                NewTag$("LEFT", "229") +_
                NewTag$("TOP", "68") +_
                NewTag$("WIDTH", "356") +_
                NewTag$("HEIGHT", "19") +_
                NewTag$("TEXTPLACE", "center") +_
                NewTag$("TEXT", "PagerC.WallImg section, do superset the wall"))
        IF InfoTxt3$ = "" THEN InfoTxt3$ = TextC$("INIT",_
                NewTag$("LEFT", "229") +_
                NewTag$("TOP", "87") +_
                NewTag$("WIDTH", "356") +_
                NewTag$("HEIGHT", "19") +_
                NewTag$("TEXTPLACE", "center") +_
                NewTag$("TEXT", "pen setting on WALLHANDLE/WALLIMAGE walls."))
    CASE ELSE
        IF ImageOpt$ = "" THEN ImageOpt$ = StringC$("INIT",_
                NewTag$("LEFT", "226") +_
                NewTag$("TOP", "45") +_
                NewTag$("WIDTH", "330") +_
                NewTag$("HEIGHT", "31") +_
                NewTag$("MAXIMUM", "259") +_
                NewTag$("ALLOWED", pfnChars$) +_
                NewTag$("LABEL", "Default background Image") +_
                NewTag$("LABELPLACE", "below") +_
                NewTag$("TOOLTIP", "Path & Name of the default Image file.|If none is given and also no Image overrides|are allowed, then Objects remain always blank."))
        IF GetFile$ = "" THEN GetFile$ = ButtonC$("INIT",_
                SymbolTag$(GetFileSym$) +_
                NewTag$("LEFT", "559") +_
                NewTag$("TOP", "45") +_
                NewTag$("WIDTH", "31") +_
                NewTag$("HEIGHT", "31") +_
                NewTag$("TOOLTIP", "Select an Image."))
END SELECT
'--- common option objects ---
SELECT CASE section$
    CASE "PagerC.WallImg"
        IF TileOpt$ = "" THEN TileOpt$ = CycleC$("INIT",_
                ListTag$(TileList$) +_
                NewTag$("LEFT", "226") +_
                NewTag$("TOP", "110") +_
                NewTag$("WIDTH", "364") +_
                NewTag$("HEIGHT", "31") +_
                NewTag$("TOOLTIP", "<<< Image Area Mode >>>|Will affect the default Image only,|but not application defined Images."))
        IF HOvrOpt$ = "" THEN HOvrOpt$ = CheckboxC$("INIT",_
                NewTag$("LEFT", "235") +_
                NewTag$("TOP", "150") +_
                NewTag$("LABEL", "Allow override by WALLHANDLE tag") +_
                NewTag$("LABELPLACE", "right") +_
                NewTag$("TOOLTIP", "Give permission to the application to override|the default Image using the WALLHANDLE tag.|This tag does usually set a software generated|Image (eg. color gradients)."))
        IF FOvrOpt$ = "" THEN FOvrOpt$ = CheckboxC$("INIT",_
                NewTag$("LEFT", "235") +_
                NewTag$("TOP", "190") +_
                NewTag$("LABEL", "Allow override by WALLIMAGE tag") +_
                NewTag$("LABELPLACE", "right") +_
                NewTag$("TOOLTIP", "Give permission to the application to override|the default Image using the WALLIMAGE tag.|Disable this one, if the application shall|use the default Image instead of its own."))
        IF PModOpt$ = "" THEN PModOpt$ = CycleC$("INIT",_
                ListTag$(PModListWall$) +_
                NewTag$("LEFT", "226") +_
                NewTag$("TOP", "230") +_
                NewTag$("WIDTH", "364") +_
                NewTag$("HEIGHT", "31") +_
                NewTag$("TOOLTIP", "<<< Blank Walls Mode >>>|Defines how to handle Walls, which the|application did explicitly define|without an background Image or Wall pen."))
    CASE "PagerC.WallPen"
        IF HOvrOpt$ = "" THEN HOvrOpt$ = SliderC$("INIT",_
                NewTag$("LEFT", "226") +_
                NewTag$("TOP", "140") +_
                NewTag$("WIDTH", "364") +_
                NewTag$("HEIGHT", "41") +_
                NewTag$("MINIMUM", "-1") +_
                NewTag$("MAXIMUM", "23") +_
                NewTag$("LEVEL", LTRIM$(STR$(options.csetHOVR))) +_
                NewTag$("ALTMIN", "N/A") +_
                NewTag$("LABEL", "Currently used default Wall pen") +_
                NewTag$("LABELPLACE", "above") +_
                NewTag$("TOOLTIP", "If none (N/A) is given and also no override is allowed,|then Walls remain always blank unless the PagerC.WallImg|section defines a default Image for blank Walls."))
        IF FOvrOpt$ = "" THEN FOvrOpt$ = CheckboxC$("INIT",_
                NewTag$("LEFT", "235") +_
                NewTag$("TOP", "190") +_
                NewTag$("LABEL", "Allow override by WALLPEN tag") +_
                NewTag$("LABELPLACE", "right") +_
                NewTag$("TOOLTIP", "Give permission to the application to override|the default Wall pen using the WALLPEN tag.|Disable this one, if the application shall|use the default Wall pen instead of its own."))
        IF PModOpt$ = "" THEN PModOpt$ = CycleC$("INIT",_
                ListTag$(PModListWall$) +_
                NewTag$("LEFT", "226") +_
                NewTag$("TOP", "230") +_
                NewTag$("WIDTH", "364") +_
                NewTag$("HEIGHT", "31") +_
                NewTag$("TOOLTIP", "<<< Blank Walls Mode >>>|Defines how to handle Walls, which the|application did explicitly define|without an background Image or Wall pen."))
    CASE ELSE
        IF section$ <> "Global.Colors" THEN
            IF TileOpt$ = "" THEN TileOpt$ = CycleC$("INIT",_
                    ListTag$(TileList$) +_
                    NewTag$("LEFT", "226") +_
                    NewTag$("TOP", "110") +_
                    NewTag$("WIDTH", "364") +_
                    NewTag$("HEIGHT", "31") +_
                    NewTag$("TOOLTIP", "<<< Image Area Mode >>>|Will affect the default Image only,|but not application defined Images."))
            IF HOvrOpt$ = "" THEN HOvrOpt$ = CheckboxC$("INIT",_
                    NewTag$("LEFT", "235") +_
                    NewTag$("TOP", "150") +_
                    NewTag$("LABEL", "Allow override by IMAGEHANDLE tag") +_
                    NewTag$("LABELPLACE", "right") +_
                    NewTag$("TOOLTIP", "Give permission to the application to override|the default Image using the IMAGEHANDLE tag.|For some Objects it's useful to enable it, as|this tag does usually set a software generated|Image (eg. color gradients for sliders)."))
            IF FOvrOpt$ = "" THEN FOvrOpt$ = CheckboxC$("INIT",_
                    NewTag$("LEFT", "235") +_
                    NewTag$("TOP", "190") +_
                    NewTag$("LABEL", "Allow override by IMAGEFILE tag") +_
                    NewTag$("LABELPLACE", "right") +_
                    NewTag$("TOOLTIP", "Give permission to the application to override|the default Image using the IMAGEFILE tag.|Disable this one, if the application shall|use the default Image instead of its own."))
            IF PModOpt$ = "" THEN PModOpt$ = CycleC$("INIT",_
                    ListTag$(PModList$) +_
                    NewTag$("LEFT", "226") +_
                    NewTag$("TOP", "230") +_
                    NewTag$("WIDTH", "364") +_
                    NewTag$("HEIGHT", "31") +_
                    NewTag$("TOOLTIP", "<<< Blank Objects Mode >>>|Defines how to handle Objects, which the application|did explicitly define without an background Image."))
        END IF
END SELECT
'--- and finally the test (preview) objects for current section ---
SELECT CASE section$
    CASE "ImageC.Backfill"
        PreObjCommon$ = NewTag$("TOP", "329") + NewTag$("WIDTH", "150") + NewTag$("HEIGHT", "110") + NewTag$("PREVIEW", "yes")
        PreObjCommon2$ = NewTag$("TOP", "324") + NewTag$("WIDTH", "160") + NewTag$("HEIGHT", "120") + NewTag$("FORM", "solid") + NewTag$("LABELPLACE", "below")
        PreObjBlank$ = ImageC$("INIT", PreObjCommon$ + NewTag$("LEFT", "45"))
        PreObjBlank2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "40") + NewTag$("LABEL", "Blank Background"))
        PreHImg& = _NEWIMAGE(150, 110, 32): _DEST PreHImg&
        FOR x% = 0 TO 147
            HSBtoRGB CLNG((147 - x%) * (21845 / 147)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 1, 1)-(x% + 1, 108), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        IF options.csetHOVR THEN imgTT$ = NewTag$("TOOLTIP", "Software generated Image"): ELSE imgTT$ = ""
        PreObjHandle$ = ImageC$("INIT", PreObjCommon$ + NewTag$("LEFT", "245") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))) + imgTT$)
        PreObjHandle2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "240") + NewTag$("LABEL", "IMAGEHANDLE tag"))
        PreObjFile$ = ImageC$("INIT", PreObjCommon$ + NewTag$("LEFT", "445") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
        PreObjFile2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "440") + NewTag$("LABEL", "IMAGEFILE tag"))
    CASE "PagerC", "PagerC.WallImg", "PagerC.WallPen"
        PreObjCommon$ = NewTag$("TOP", "323") + NewTag$("WIDTH", "130") + NewTag$("HEIGHT", "31") + NewTag$("WALLLEFT", "50") + NewTag$("WALLRIGHT", "594") + NewTag$("WALLBOTTOM", "459")
        PreObjCommon2$ = NewTag$("LEFT", "220") + NewTag$("TOP", "390") + NewTag$("WIDTH", "200") + NewTag$("HEIGHT", "31") + NewTag$("TEXTPLACE", "center") + NewTag$("FORM", "ridge")
        PreObjBlank$ = PagerC$("INIT", PreObjCommon$ + NewTag$("LEFT", "55") + NewTag$("TEXT", "Blank Pager"))
        PreObjBlank2$ = TextC$("INIT", PreObjCommon2$ + PagerTag$(PreObjBlank$) + NewTag$("TEXT", "Blank Wall"))
        PreObjPen$ = PagerC$("INIT", PreObjCommon$ + NewTag$("LEFT", "190") + NewTag$("TEXT", "Blank Pager") + NewTag$("WALLPEN", "160"))
        PreObjPen2$ = TextC$("INIT", PreObjCommon2$ + PagerTag$(PreObjPen$) + NewTag$("TEXT", "WALLPEN tag"))
        PreHImg& = _NEWIMAGE(150, 31, 32): _DEST PreHImg&
        FOR x% = 0 TO 145
            HSBtoRGB CLNG((145 - x%) * (21845 / 145)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 30), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreHImg2& = _NEWIMAGE(545, 106, 32): _DEST PreHImg2&
        FOR x% = 0 TO 540
            HSBtoRGB CLNG((540 - x%) * (21845 / 540)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 0)-(x% + 2, 103), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = PagerC$("INIT", PreObjCommon$ + NewTag$("LEFT", "325") + NewTag$("TEXT", "IMAGEHANDLE tag") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))) + NewTag$("WALLHANDLE", LTRIM$(STR$(PreHImg2&))))
        PreObjHandle2$ = TextC$("INIT", PreObjCommon2$ + PagerTag$(PreObjHandle$) + NewTag$("TEXT", "WALLHANDLE tag"))
        PreObjFile$ = PagerC$("INIT", PreObjCommon$ + NewTag$("LEFT", "460") + NewTag$("TEXT", "IMAGEFILE tag") + NewTag$("IMAGEFILE", "RhoSigma32px.png") + NewTag$("WALLIMAGE", "RhoSigma32px.png"))
        PreObjFile2$ = TextC$("INIT", PreObjCommon2$ + PagerTag$(PreObjFile$) + NewTag$("TEXT", "WALLIMAGE tag"))
        IF GetTag$(bActTag$ + pActTag$ + hActTag$ + fActTag$, "ACTIVE") = "" THEN bActTag$ = NewTag$("ACTIVE", "true")
    CASE "ButtonC"
        PreObjCommon$ = NewTag$("WIDTH", "200") + NewTag$("HEIGHT", "50")
        PreObjBlank$ = ButtonC$("INIT", PreObjCommon$ + NewTag$("LEFT", "220") + NewTag$("TOP", "329") + NewTag$("TEXT", "Blank Button"))
        PreHImg& = _NEWIMAGE(200, 50, 32): _DEST PreHImg&
        FOR x% = 0 TO 195
            HSBtoRGB CLNG((195 - x%) * (21845 / 195)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 47), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = ButtonC$("INIT", PreObjCommon$ + NewTag$("LEFT", "80") + NewTag$("TOP", "405") + NewTag$("TEXT", "IMAGEHANDLE tag") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = ButtonC$("INIT", PreObjCommon$ + NewTag$("LEFT", "360") + NewTag$("TOP", "405") + NewTag$("TEXT", "IMAGEFILE tag") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "CheckboxC"
        PreObjCommon$ = NewTag$("LEFT", "238") + NewTag$("WIDTH", "44") + NewTag$("HEIGHT", "44") + NewTag$("LABELPLACE", "right") + NewTag$("CHECKED", "yes")
        PreObjBlank$ = CheckboxC$("INIT", PreObjCommon$ + NewTag$("TOP", "314") + NewTag$("LABEL", "Blank Checkbox"))
        PreHImg& = _NEWIMAGE(44, 44, 32): _DEST PreHImg&
        FOR x% = 0 TO 39
            HSBtoRGB CLNG((39 - x%) * (21845 / 39)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 41), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = CheckboxC$("INIT", PreObjCommon$ + NewTag$("TOP", "370") + NewTag$("LABEL", "IMAGEHANDLE tag") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = CheckboxC$("INIT", PreObjCommon$ + NewTag$("TOP", "426") + NewTag$("LABEL", "IMAGEFILE tag") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "StringC"
        PreObjCommon$ = NewTag$("LEFT", "145") + NewTag$("WIDTH", "350") + NewTag$("HEIGHT", "31") + NewTag$("TEXTPLACE", "center")
        PreObjBlank$ = StringC$("INIT", PreObjCommon$ + NewTag$("TOP", "324") + NewTag$("TEXT", "Blank Input Field"))
        PreHImg& = _NEWIMAGE(350, 31, 32): _DEST PreHImg&
        FOR x% = 0 TO 345
            HSBtoRGB CLNG((345 - x%) * (21845 / 345)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 28), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = StringC$("INIT", PreObjCommon$ + NewTag$("TOP", "377") + NewTag$("TEXT", "IMAGEHANDLE tag") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = StringC$("INIT", PreObjCommon$ + NewTag$("TOP", "430") + NewTag$("TEXT", "IMAGEFILE tag") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "TextC"
        PreObjCommon$ = NewTag$("LEFT", "145") + NewTag$("WIDTH", "350") + NewTag$("HEIGHT", "31") + NewTag$("TEXTPLACE", "center") + NewTag$("FORM", "simple")
        PreObjBlank$ = TextC$("INIT", PreObjCommon$ + NewTag$("TOP", "324") + NewTag$("TEXT", "Blank Output Field"))
        PreHImg& = _NEWIMAGE(350, 31, 32): _DEST PreHImg&
        FOR x% = 0 TO 345
            HSBtoRGB CLNG((345 - x%) * (21845 / 345)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 28), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = TextC$("INIT", PreObjCommon$ + NewTag$("TOP", "377") + NewTag$("TEXT", "IMAGEHANDLE tag") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = TextC$("INIT", PreObjCommon$ + NewTag$("TOP", "430") + NewTag$("TEXT", "IMAGEFILE tag") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "ProgressC"
        PreObjCommon$ = NewTag$("WIDTH", "250") + NewTag$("HEIGHT", "31") + NewTag$("LABELPLACE", "below")
        PreObjBlank$ = ProgressC$("INIT", PreObjCommon$ + NewTag$("LEFT", "195") + NewTag$("TOP", "327") + NewTag$("LABEL", "Blank Progress Indicator") + NewTag$("LEVEL", "65"))
        PreHImg& = _NEWIMAGE(250, 31, 32): _DEST PreHImg&
        FOR x% = 0 TO 245
            HSBtoRGB CLNG((245 - x%) * (21845 / 245)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 28), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = ProgressC$("INIT", PreObjCommon$ + NewTag$("LEFT", "46") + NewTag$("TOP", "404") + NewTag$("LABEL", "IMAGEHANDLE tag") + NewTag$("LEVEL", "5") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = ProgressC$("INIT", PreObjCommon$ + NewTag$("LEFT", "343") + NewTag$("TOP", "404") + NewTag$("LABEL", "IMAGEFILE tag") + NewTag$("LEVEL", "40") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "CycleC"
        PreObjCommon$ = NewTag$("LEFT", "145") + NewTag$("WIDTH", "350") + NewTag$("HEIGHT", "31")
        PreObjBlank2$ = ListC$("INIT", "")
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Blank Cycler"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 2"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 3"))
        PreObjBlank$ = CycleC$("INIT", PreObjCommon$ + NewTag$("TOP", "324") + ListTag$(PreObjBlank2$))
        PreHImg& = _NEWIMAGE(350, 31, 32): _DEST PreHImg&
        FOR x% = 0 TO 345
            HSBtoRGB CLNG((345 - x%) * (21845 / 345)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 28), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = CycleC$("INIT", PreObjCommon$ + NewTag$("TOP", "377") + ListTag$(DemoHList$) + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = CycleC$("INIT", PreObjCommon$ + NewTag$("TOP", "430") + ListTag$(DemoFList$) + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "ListviewC"
        PreObjCommon$ = NewTag$("TOP", "322") + NewTag$("WIDTH", "145") + NewTag$("HEIGHT", "140")
        PreObjBlank2$ = ListC$("INIT", "")
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Blank Listview"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 2"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 3"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 4"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 5"))
        PreObjBlank$ = ListviewC$("INIT", PreObjCommon$ + NewTag$("LEFT", "51") + ListTag$(PreObjBlank2$))
        PreHImg& = _NEWIMAGE(145, 140, 32): _DEST PreHImg&
        FOR x% = 0 TO 140
            HSBtoRGB CLNG((140 - x%) * (21845 / 140)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 137), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = ListviewC$("INIT", PreObjCommon$ + NewTag$("LEFT", "248") + ListTag$(DemoHList$) + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = ListviewC$("INIT", PreObjCommon$ + NewTag$("LEFT", "444") + ListTag$(DemoFList$) + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "RadioC"
        PreObjCommon$ = NewTag$("TOP", "342") + NewTag$("WIDTH", "20") + NewTag$("FORM", "ridge") + NewTag$("RECESSED", "yes")
        PreObjBlank2$ = ListC$("INIT", "")
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Blank Radiobutton"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 2"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 3"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 4"))
        res$ = ListC$("STORE", PreObjBlank2$ + NewTag$("DATA", "Option 5"))
        PreObjBlank$ = RadioC$("INIT", PreObjCommon$ + NewTag$("LEFT", "55") + ListTag$(PreObjBlank2$))
        PreHImg& = _NEWIMAGE(166, 140, 32): _DEST PreHImg&
        FOR x% = 0 TO 161
            HSBtoRGB CLNG((161 - x%) * (21845 / 161)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 137), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = RadioC$("INIT", PreObjCommon$ + NewTag$("LEFT", "273") + ListTag$(DemoHList$) + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = RadioC$("INIT", PreObjCommon$ + NewTag$("LEFT", "474") + ListTag$(DemoFList$) + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "ColorwheelC"
        PreObjCommon2$ = NewTag$("TOP", "323") + NewTag$("WIDTH", "120") + NewTag$("HEIGHT", "120") + NewTag$("LABELPLACE", "below")
        PreObjCommon$ = NewTag$("TOP", "323") + NewTag$("WIDTH", "120")
        PreObjBlank2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "70") + NewTag$("LABEL", "Blank Wheel"))
        PreObjBlank$ = ColorwheelC$("INIT", PreObjCommon$ + NewTag$("LEFT", "70"))
        PreHImg& = _NEWIMAGE(120, 120, 32): _DEST PreHImg&
        FOR x% = 0 TO 115
            HSBtoRGB CLNG((115 - x%) * (21845 / 115)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 117), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "260") + NewTag$("LABEL", "IMAGEHANDLE tag"))
        PreObjHandle$ = ColorwheelC$("INIT", PreObjCommon$ + NewTag$("LEFT", "260") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "450") + NewTag$("LABEL", "IMAGEFILE tag"))
        PreObjFile$ = ColorwheelC$("INIT", PreObjCommon$ + NewTag$("LEFT", "450") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "SliderC"
        PreObjCommon$ = NewTag$("WIDTH", "250") + NewTag$("HEIGHT", "31") + NewTag$("LABELPLACE", "below") + NewTag$("MINIMUM", "0") + NewTag$("MAXIMUM", "99")
        PreObjBlank$ = SliderC$("INIT", PreObjCommon$ + NewTag$("LEFT", "195") + NewTag$("TOP", "327") + NewTag$("LABEL", "Blank Slider") + NewTag$("LEVEL", "65"))
        PreHImg& = _NEWIMAGE(250, 31, 32): _DEST PreHImg&
        FOR x% = 0 TO 245
            HSBtoRGB CLNG((245 - x%) * (21845 / 245)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 28), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle$ = SliderC$("INIT", PreObjCommon$ + NewTag$("LEFT", "46") + NewTag$("TOP", "404") + NewTag$("LABEL", "IMAGEHANDLE tag") + NewTag$("LEVEL", "5") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile$ = SliderC$("INIT", PreObjCommon$ + NewTag$("LEFT", "343") + NewTag$("TOP", "404") + NewTag$("LABEL", "IMAGEFILE tag") + NewTag$("LEVEL", "40") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
    CASE "ScrollerC"
        PreObjCommon2$ = NewTag$("WIDTH", "250") + NewTag$("HEIGHT", "31") + NewTag$("LABELPLACE", "below")
        PreObjCommon$ = NewTag$("WIDTH", "250") + NewTag$("HEIGHT", "31")
        PreObjBlank2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "195") + NewTag$("TOP", "327") + NewTag$("LABEL", "Blank Scroller"))
        PreObjBlank$ = ScrollerC$("INIT", PreObjCommon$ + NewTag$("LEFT", "195") + NewTag$("TOP", "327") + NewTag$("TOTALNUM", "100") + NewTag$("VISIBLENUM", "20") + NewTag$("TOPNUM", "65"))
        PreHImg& = _NEWIMAGE(250, 31, 32): _DEST PreHImg&
        FOR x% = 0 TO 245
            HSBtoRGB CLNG((245 - x%) * (21845 / 245)) + 21845, 45875, 52428, re&, gr&, bl&
            LINE (x% + 2, 2)-(x% + 2, 28), _RGB32(re& \ 256, gr& \ 256, bl& \ 256)
        NEXT x%: _DEST 0
        PreObjHandle2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "46") + NewTag$("TOP", "404") + NewTag$("LABEL", "IMAGEHANDLE tag"))
        PreObjHandle$ = ScrollerC$("INIT", PreObjCommon$ + NewTag$("LEFT", "46") + NewTag$("TOP", "404") + NewTag$("TOTALNUM", "100") + NewTag$("VISIBLENUM", "8") + NewTag$("TOPNUM", "50") + NewTag$("IMAGEHANDLE", LTRIM$(STR$(PreHImg&))))
        PreObjFile2$ = FrameC$("INIT", PreObjCommon2$ + NewTag$("LEFT", "343") + NewTag$("TOP", "404") + NewTag$("LABEL", "IMAGEFILE tag"))
        PreObjFile$ = ScrollerC$("INIT", PreObjCommon$ + NewTag$("LEFT", "343") + NewTag$("TOP", "404") + NewTag$("TOTALNUM", "70") + NewTag$("VISIBLENUM", "35") + NewTag$("TOPNUM", "10") + NewTag$("IMAGEFILE", "RhoSigma32px.png"))
END SELECT
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
ClearGUI:
'--- first get active pager states (if any) ---
fActTag$ = GenC$("GET", PreObjFile$ + NewTag$("TAGNAMES", "ACTIVE"))
hActTag$ = GenC$("GET", PreObjHandle$ + NewTag$("TAGNAMES", "ACTIVE"))
pActTag$ = GenC$("GET", PreObjPen$ + NewTag$("TAGNAMES", "ACTIVE"))
bActTag$ = GenC$("GET", PreObjBlank$ + NewTag$("TAGNAMES", "ACTIVE"))
'--- then always destroy regular test (preview) objects ---
res$ = GenC$("KILL", PreObjFile$): PreObjFile$ = ""
res$ = GenC$("KILL", PreObjHandle$): PreObjHandle$ = ""
res$ = GenC$("KILL", PreObjPen$): PreObjPen$ = ""
res$ = GenC$("KILL", PreObjBlank$): PreObjBlank$ = ""
'--- selectivly destroy secondary test objects ---
'--- and/or affected main GUI objects          ---
SELECT CASE oldSect$
    CASE "Global.Colors"
        GOSUB ClearGlobal
        PalRGBSliderB$ = GenC$("KILL", PalRGBSliderB$): PalRGBSliderB$ = ""
        PalRGBSliderG$ = GenC$("KILL", PalRGBSliderG$): PalRGBSliderG$ = ""
        PalRGBSliderR$ = GenC$("KILL", PalRGBSliderR$): PalRGBSliderR$ = ""
        PalHSBSliderB$ = GenC$("KILL", PalHSBSliderB$): PalHSBSliderB$ = ""
        PalHSBSliderS$ = GenC$("KILL", PalHSBSliderS$): PalHSBSliderS$ = ""
        PalHSBSliderH$ = GenC$("KILL", PalHSBSliderH$): PalHSBSliderH$ = ""
        PalWheel$ = GenC$("KILL", PalWheel$): PalWheel$ = ""
        PalGauge$ = GenC$("KILL", PalGauge$): PalGauge$ = ""
        PalColor$ = GenC$("KILL", PalColor$): PalColor$ = ""
        ColorLView$ = GenC$("KILL", ColorLView$): ColorLView$ = ""
        PenLView$ = GenC$("KILL", PenLView$): PenLView$ = ""
    CASE "ImageC.Backfill"
        GOSUB ClearSecondary
        GOSUB ClearImageC
    CASE "PagerC", "RadioC", "ColorwheelC", "ScrollerC"
        GOSUB ClearSecondary
    CASE "PagerC.WallImg"
        GOSUB ClearSecondary
        GOSUB ClearCycleC
        GOSUB ClearCheckboxC
    CASE "PagerC.WallPen"
        GOSUB ClearSecondary
        GOSUB ClearCycleC
        GOSUB ClearCheckboxC
        res$ = GenC$("KILL", InfoTxt$): InfoTxt$ = ""
        res$ = GenC$("KILL", InfoTxt1$): InfoTxt1$ = ""
        res$ = GenC$("KILL", InfoTxt2$): InfoTxt2$ = ""
        res$ = GenC$("KILL", InfoTxt3$): InfoTxt3$ = ""
    CASE "ButtonC"
        GOSUB ClearButtonC
    CASE "CheckboxC"
        GOSUB ClearCheckboxC
    CASE "StringC"
        GOSUB ClearStringC
    CASE "CycleC"
        GOSUB ClearSecondary
        GOSUB ClearCycleC
    CASE "ListviewC"
        GOSUB ClearSecondary
        GOSUB ClearListviewC
END SELECT
'--- and those, which need to be changed ---
'--- according to the new chosen section ---
SELECT CASE section$
    CASE "Global.Colors"
        GOSUB ClearGlobal
    CASE "PagerC.WallImg"
        GOSUB ClearCycleC
        GOSUB ClearCheckboxC
    CASE "PagerC.WallPen"
        GOSUB ClearStringC
        GOSUB ClearCycleC
        GOSUB ClearCheckboxC
        res$ = GenC$("KILL", GetFile$): GetFile$ = ""
END SELECT
RETURN
'---------------
ClearSecondary:
res$ = GenC$("KILL", PreObjFile2$): PreObjFile2$ = ""
res$ = GenC$("KILL", PreObjHandle2$): PreObjHandle2$ = ""
res$ = GenC$("KILL", PreObjPen2$): PreObjPen2$ = ""
res$ = GenC$("KILL", PreObjBlank2$): PreObjBlank2$ = ""
IF oldSect$ <> section$ THEN BeginGUIRefresh: EndGUIRefresh 'force immediate GUI refresh
RETURN
'---------------
ClearGlobal:
GOSUB ClearImageC: GOSUB ClearButtonC: GOSUB ClearCheckboxC
GOSUB ClearStringC: GOSUB ClearCycleC: GOSUB ClearListviewC
res$ = GenC$("KILL", PreviewRuler$): PreviewRuler$ = ""
res$ = GenC$("KILL", OptsFrame$): OptsFrame$ = ""
res$ = GenC$("KILL", GetFileSym$): GetFileSym$ = ""
RETURN
'---------------
ClearImageC:
res$ = GenC$("KILL", NewTag$("OBJECT", LTRIM$(STR$(guiABIObject&)))) 'active back image
RETURN
'---------------
ClearButtonC:
res$ = GenC$("KILL", GetFile$): GetFile$ = ""
res$ = GenC$("KILL", StdButt$): StdButt$ = ""
RETURN
'---------------
ClearCheckboxC:
res$ = GenC$("KILL", FOvrOpt$): FOvrOpt$ = ""
res$ = GenC$("KILL", HOvrOpt$): HOvrOpt$ = ""
RETURN
'---------------
ClearStringC:
res$ = GenC$("KILL", ImageOpt$): ImageOpt$ = ""
RETURN
'---------------
ClearCycleC:
res$ = GenC$("KILL", PModOpt$): PModOpt$ = ""
res$ = GenC$("KILL", TileOpt$): TileOpt$ = ""
RETURN
'---------------
ClearListviewC:
res$ = GenC$("KILL", SectLView$): SectLView$ = ""
RETURN
'----------------------------------
ChangePalette:
col% = VAL(GetObjTagData$(PalColor$, "LEVEL", "0"))
red% = VAL(GetObjTagData$(PalRGBSliderR$, "LEVEL", "0"))
gre% = VAL(GetObjTagData$(PalRGBSliderG$, "LEVEL", "0"))
blu% = VAL(GetObjTagData$(PalRGBSliderB$, "LEVEL", "0"))
_PALETTECOLOR col%, _RGB32(red%, gre%, blu%)
RETURN
'----------------------------------
UpdatePaletteTool:
IF section$ = "Global.Colors" THEN
    pen$ = GetObjTagData$(PalColor$, "LEVEL", "0")
    res$ = GenC$("SET", PalGauge$ + NewTag$("SHINEPEN", pen$)): actCol% = VAL(pen$)
    res$ = GenC$("SET", PalRGBSliderR$ + NewTag$("LEVEL", LTRIM$(STR$(_RED(VAL(pen$))))))
    res$ = GenC$("SET", PalRGBSliderG$ + NewTag$("LEVEL", LTRIM$(STR$(_GREEN(VAL(pen$))))))
    res$ = GenC$("SET", PalRGBSliderB$ + NewTag$("LEVEL", LTRIM$(STR$(_BLUE(VAL(pen$))))))
END IF
RETURN
'----------------------------------
UpdateOptionsView:
'--- update display after section selection ---
sectTags$ = GenC$("GET", SectLView$ + NewTag$("TAGNAMES", "DATA"))
section$ = GetTagData$(sectTags$, "DATA", "")
GetPrefs section$, options
IF section$ <> "Global.Colors" THEN
    fsDir$ = RStrip$(stmFIXED%, options.csetIMAGE)
    IF fsDir$ <> "" THEN
        sPo% = RInstr&(0, fsDir$, "\")
        IF sPo% > 0 THEN
            fsFile$ = MID$(fsDir$, sPo% + 1)
            fsDir$ = LEFT$(fsDir$, sPo% - 1)
        ELSE
            fsFile$ = fsDir$
            IF _FILEEXISTS("qb64.exe") OR _FILEEXISTS("qb64pe.exe") THEN
                fsDir$ = "QB64GuiTools\images\patterns"
            ELSE
                fsDir$ = "..\images\patterns"
            END IF
        END IF
    END IF
    tmpF$ = RStrip$(stmFIXED%, options.csetIMAGE)
    res$ = GenC$("SET", ImageOpt$ + NewTag$("TEXT", tmpF$))
    IF tmpF$ <> "" OR section$ = "PagerC.WallPen" THEN
        res$ = GenC$("SET", TileOpt$ + NewTag$("ACTUAL", LTRIM$(STR$(options.csetTILE + 2))) + NewTag$("DISABLED", "no"))
        res$ = GenC$("SET", PModOpt$ + NewTag$("ACTUAL", LTRIM$(STR$(options.csetPMOD + 2))) + NewTag$("DISABLED", "no"))
    ELSE
        options.csetTILE = 0: options.csetPMOD = 0
        res$ = GenC$("SET", TileOpt$ + NewTag$("ACTUAL", "2") + NewTag$("DISABLED", "yes"))
        res$ = GenC$("SET", PModOpt$ + NewTag$("ACTUAL", "2") + NewTag$("DISABLED", "yes"))
    END IF
    IF section$ = "PagerC.WallPen" THEN
        res$ = GenC$("SET", HOvrOpt$ + NewTag$("LEVEL", LTRIM$(STR$(options.csetHOVR))))
    ELSE
        res$ = GenC$("SET", HOvrOpt$ + NewTag$("CHECKED", LTRIM$(STR$(options.csetHOVR))))
    END IF
    res$ = GenC$("SET", FOvrOpt$ + NewTag$("CHECKED", LTRIM$(STR$(options.csetFOVR))))
END IF
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
FUNCTION VersionGTPrefsEditor$
    VersionGTPrefsEditor$ = MID$("$VER: GTPrefsEditor 1.0 (15-Nov-2018) by RhoSigma :END$", 7, 43)
END FUNCTION
'----------------------------------
SUB GetPrefs (sect$, opts AS ChunkCSET)
    '--- exclusivly search prefs ---
    mtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-gtprefs.bin" + CHR$(0))
    iff% = SafeOpenFile%("B", appLocalDir$ + "gtprefs.bin")
    found% = 0
    IF SeekChunk&(iff%, 1, CHcsetID$) > 0 THEN
        WHILE NOT EOF(iff%)
            GET iff%, , opts
            IF RStrip$(stmFIXED%, opts.csetCLASS) = sect$ THEN
                found% = -1
                EXIT WHILE
            END IF
        WEND
    END IF
    '--- found = ok, missed = init defaults ---
    IF found% THEN
        IF sect$ = "Global.Colors" THEN SetColors opts.csetIMAGE
    ELSE
        opts.csetSTDC.chunkID = CHcsetID$
        opts.csetSTDC.chunkLEN = CHcsetLEN%
        opts.csetCLASS = sect$
        opts.csetIMAGE = "": opts.csetTILE = 0
        opts.csetHOVR = -1: opts.csetFOVR = -1: opts.csetPMOD = 0
        IF sect$ = "Global.Colors" THEN
            opts.csetIMAGE = StdColors$
            opts.csetHOVR = 0: opts.csetFOVR = 0
            SetColors opts.csetIMAGE
        END IF
        PUT iff%, LOF(iff%) + 1, opts
        SizeUpdate iff%, csetSIZEOF%
    END IF
    '--- cleanup ---
    CLOSE iff%
    UnlockMutex mtx%&
END SUB
'----------------------------------
SUB SetPrefs (sect$, opts AS ChunkCSET)
    '--- exclusivly search prefs ---
    mtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-gtprefs.bin" + CHR$(0))
    iff% = SafeOpenFile%("B", appLocalDir$ + "gtprefs.bin")
    IF SeekChunk&(iff%, 1, CHcsetID$) > 0 THEN
        REDIM temp(0) AS ChunkCSET
        WHILE NOT EOF(iff%)
            ptr& = SEEK(iff%)
            GET iff%, , temp(0)
            IF RStrip$(stmFIXED%, temp(0).csetCLASS) = sect$ THEN EXIT WHILE
        WEND
        ERASE temp
    END IF
    '--- write ---
    IF sect$ = "Global.Colors" THEN
        prefs$ = ""
        FOR i% = 0 TO 23
            prefs$ = prefs$ + CHR$(_RED(i%)) + CHR$(_GREEN(i%)) + CHR$(_BLUE(i%))
        NEXT i%
        prefs$ = prefs$ + SPACE$(177)
        prefs$ = prefs$ + CHR$(guiMediaFile%) + CHR$(guiMediaDrawer%) + CHR$(guiMediaDisk%) + CHR$(guiSaveBack%) + CHR$(guiLoadBack%)
        prefs$ = prefs$ + CHR$(guiRedPen%) + CHR$(guiGreenPen%) + CHR$(guiSolidPen%) + CHR$(guiShadowPen%) + CHR$(guiShinePen%)
        prefs$ = prefs$ + CHR$(guiFillTextPen%) + CHR$(guiFillPen%) + CHR$(guiHighPen%) + CHR$(guiTextPen%) + CHR$(guiBackPen%)
        opts.csetIMAGE = prefs$: opts.csetTILE = 0
        opts.csetHOVR = 0: opts.csetFOVR = 0: opts.csetPMOD = 0
    END IF
    PUT iff%, ptr&, opts
    '--- cleanup ---
    CLOSE iff%
    UnlockMutex mtx%&
END SUB
'----------------------------------
SUB SetColors (prefs$)
    FOR i% = 0 TO 23
        _PALETTECOLOR i%, _RGB32(ASC(prefs$, (i% * 3) + 1), ASC(prefs$, (i% * 3) + 2), ASC(prefs$, (i% * 3) + 3))
    NEXT i%
    guiBackPen% = ASC(prefs$, 264): guiTextPen% = ASC(prefs$, 263): guiHighPen% = ASC(prefs$, 262)
    guiFillPen% = ASC(prefs$, 261): guiFillTextPen% = ASC(prefs$, 260)
    guiShinePen% = ASC(prefs$, 259): guiShadowPen% = ASC(prefs$, 258): guiSolidPen% = ASC(prefs$, 257)
    guiGreenPen% = ASC(prefs$, 256): guiRedPen% = ASC(prefs$, 255)
    guiLoadBack% = ASC(prefs$, 254): guiSaveBack% = ASC(prefs$, 253)
    guiMediaDisk% = ASC(prefs$, 252): guiMediaDrawer% = ASC(prefs$, 251): guiMediaFile% = ASC(prefs$, 250)
END SUB
'----------------------------------
FUNCTION StdColors$
    temp$ = CHR$(136) + CHR$(136) + CHR$(136) + CHR$(0) + CHR$(0) + CHR$(0)
    temp$ = temp$ + CHR$(51) + CHR$(51) + CHR$(51) + CHR$(238) + CHR$(238) + CHR$(238)
    temp$ = temp$ + CHR$(170) + CHR$(34) + CHR$(0) + CHR$(221) + CHR$(85) + CHR$(0)
    temp$ = temp$ + CHR$(238) + CHR$(187) + CHR$(0) + CHR$(0) + CHR$(136) + CHR$(0)
    temp$ = temp$ + CHR$(102) + CHR$(187) + CHR$(0) + CHR$(102) + CHR$(136) + CHR$(102)
    temp$ = temp$ + CHR$(85) + CHR$(187) + CHR$(204) + CHR$(51) + CHR$(102) + CHR$(119)
    temp$ = temp$ + CHR$(0) + CHR$(119) + CHR$(187) + CHR$(136) + CHR$(34) + CHR$(0)
    temp$ = temp$ + CHR$(238) + CHR$(136) + CHR$(136) + CHR$(187) + CHR$(85) + CHR$(85)
    temp$ = temp$ + CHR$(238) + CHR$(119) + CHR$(34) + CHR$(221) + CHR$(136) + CHR$(68)
    temp$ = temp$ + CHR$(68) + CHR$(170) + CHR$(119) + CHR$(17) + CHR$(119) + CHR$(85)
    temp$ = temp$ + CHR$(153) + CHR$(0) + CHR$(255) + CHR$(102) + CHR$(0) + CHR$(204)
    temp$ = temp$ + CHR$(187) + CHR$(119) + CHR$(0) + CHR$(153) + CHR$(85) + CHR$(0)
    temp$ = temp$ + SPACE$(177)
    temp$ = temp$ + CHR$(18) + CHR$(22) + CHR$(12) + CHR$(13) + CHR$(11)
    temp$ = temp$ + CHR$(4) + CHR$(7) + CHR$(0) + CHR$(2) + CHR$(3)
    temp$ = temp$ + CHR$(13) + CHR$(17) + CHR$(6) + CHR$(1) + CHR$(9)
    StdColors$ = temp$
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
    'appIcon& = _LOADIMAGE("..\images\icons\RhoSigma32px.png", 32)
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

'$INCLUDE: 'inline\Info16Img.bm'
'$INCLUDE: 'inline\Info32Img.bm'
'$INCLUDE: 'inline\Problem16Img.bm'
'$INCLUDE: 'inline\Problem32Img.bm'
'$INCLUDE: 'inline\Error16Img.bm'
'$INCLUDE: 'inline\Error32Img.bm'
'$INCLUDE: 'inline\Presets.bm'

