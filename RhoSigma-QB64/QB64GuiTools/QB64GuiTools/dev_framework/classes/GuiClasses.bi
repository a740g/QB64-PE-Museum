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
'| === GuiClasses.bi ===                                             |
'|                                                                   |
'| == This include file is part of the GuiTools Framework Project.   |
'| == It provides values required by all GuiTools object classes.    |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

'-----------------------------
'--- Various GUI constants ---
'-----------------------------
'--- These are the default drawing pens according to the GuiTools its
'--- standard palette (dev_framework\GuiAppPalette.bm). All pens should
'--- be in the lower 24 palette entries, however colors may be reused for
'--- several pen types. Note that these definitions may be overwritten
'--- by individual user preferences.
'-----
'--- global pens ---
DIM SHARED guiBackPen%: guiBackPen% = 9 'regular background pen
DIM SHARED guiTextPen%: guiTextPen% = 1 'regular text (foreground) pen
DIM SHARED guiHighPen%: guiHighPen% = 6 'regular text pen for highlighted (important) text
DIM SHARED guiFillPen%: guiFillPen% = 17 'background pen for currently selected objects
DIM SHARED guiFillTextPen%: guiFillTextPen% = 13 'text pen for text in selected objects
DIM SHARED guiShinePen%: guiShinePen% = 3 'used for light edges of any rulers/frames
DIM SHARED guiShadowPen%: guiShadowPen% = 2 'used for dark edges of any rulers/frames
DIM SHARED guiSolidPen%: guiSolidPen% = 0 'used for solid fills in any rulers/frames
DIM SHARED guiGreenPen%: guiGreenPen% = 7 'green condition pen (eg. Checkmark in "Ok" buttons)
DIM SHARED guiRedPen%: guiRedPen% = 4 'red condition pen (eg. Cross in "Cancel" buttons)
'--- FileSelect$() pens ---
DIM SHARED guiLoadBack%: guiLoadBack% = 11 'background pens for FileSelect$() dialog to quickly
DIM SHARED guiSaveBack%: guiSaveBack% = 13 'show the user if in load/open mode or save mode
DIM SHARED guiMediaDisk%: guiMediaDisk% = 12 'main colors of the respective media symbols used
DIM SHARED guiMediaDrawer%: guiMediaDrawer% = 22 'in the file listings and buttons
DIM SHARED guiMediaFile%: guiMediaFile% = 18

'--- These are constants of all (documented) tags known to GuiTools.
'--- There are four groups, which depend on the tag's usage. Note the
'--- trailing comma in the tag name lists, it's important for easy
'--- concatenation of several lists (see also docs\KnownTags.txt).
'-----
'--- required and/or optional tags for object initialization ---
CONST guiInitTags$ = "CLASSNAME,LISTOBJECT,SORT,DATA,CONTINUE,NOCASE,PARTIAL,ACTUAL,REVERSE,HOLD,INTONLY,VALOBJECT,VALTAG,INCDECVAL,TRIGOBJECT,PRIOBJECT,PRITAG,SECOBJECT,SECTAG,MULOBJECT,MULTAG,MULFORMAT,RATIO,DIVOBJECT,DIVTAG,DIVFORMAT,HUEOBJECT,HUETAG,SATOBJECT,SATTAG,BRIOBJECT,BRITAG,REDOBJECT,REDTAG,GREOBJECT,GRETAG,BLUOBJECT,BLUTAG,GUIVIEW,LEFT,TOP,WIDTH,HEIGHT,LENGTH,ALIGN,SPACING,FORM,RECESSED,TEXT,TEXTPLACE,TEXTMOVEX,TEXTMOVEY,LABEL,LABELHIGH,LABELPLACE,LABELMOVEX,LABELMOVEY,IMAGEOBJECT,IMAGEFILE,IMAGEHANDLE,AREA,CLEARCOLOR,BACKFILL,SYMBOLOBJECT,WHICH,BACKPEN,SHADOWPEN,SHINEPEN,BORDERPEN,KEEPASPECT,STANDALONE,ALLOWED,MAXIMUM,MINIMUM,LEVEL,ALTMIN,ALTMAX,NOSHOW,VISIBLENUM,TOPNUM,TOTALNUM,HUE,SATURATION,PAGEROBJECT,WALLLEFT,WALLRIGHT,WALLBOTTOM,WALLIMAGE,WALLHANDLE,WALLAREA,WALLPEN,TOOLTIP,SHORTCUT,DISABLED,PASSIVE,ACTIVE,CHECKED,READONLY,"
'--- method call inputs and/or results ---
CONST guiCallTags$ = "OBJECT,ERROR,WARNING,TAGNAMES,"
'--- event types returned by the input handler (GetGUIMsg$()) ---
CONST guiEvntTags$ = "GUIREFRESH,USERBREAK,KEYPRESS,KEY,MOUSELBDOWN,MOUSELBUP,MOUSEMBDOWN,MOUSEMBUP,MOUSERBDOWN,MOUSERBUP,MOUSESCROLL,SCRVAL,MOUSEMOVE,MOUSEIN,MOUSEOUT,MOUSEOVER,GADGETDOWN,GADGETUP,SHIFT,CTRL,ALT,MODKEYS,MOUSEX,MOUSEY,MOUSELB,MOUSEMB,MOUSERB,"
'--- private (object internal) tags not allowed for public manipulation ---
CONST guiPrivTags$ = "RECORDS,FIRST,PREVIOUS,CURRENT,NEXT,LAST,REFOBJ,IHANDLE,RHANDLE,FOCUS,SELECTED,RELEASED,"

