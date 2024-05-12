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
'| === GuiAppFrame.bi ===                                            |
'|                                                                   |
'| == This include file is part of the GuiTools Framework Project.   |
'| == It provides the general defines & init/cleanup procedures.     |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

'--- no Screen until init is done ---
$ScreenHide

'---------------------------------------------
'--- Public Application wide SHARED values ---
'---------------------------------------------
Dim Shared appProgID$ 'unique ID of this program (every running GuiTools based program will get its own)

Dim Shared appHomeDrive$ 'this program's home drive, ie. where the executable is located (eg. "C:\")
Dim Shared appHomePath$ 'this program's home directory, ie. where the executable is located (eg. "C:\qb64\")
Dim Shared appFullExe$ 'full path/name of this program's executable file (eg. "C:\qb64\GuiApp.exe")
Dim Shared appExeName$ 'name only of this program's executable file (eg. "GuiApp.exe")

Dim Shared appPCName$ 'this computer's name from environment set (eg. "My Computer")
Dim Shared appLocalDir$ 'the local appdata folder from environment set (eg. "C:\Users\RhoSigma\AppData\Local\")
Dim Shared appTempDir$ 'the temporary folder from environment set (eg. "C:\Users\RhoSigma\AppData\Local\temp\")
Dim Shared appLastErr% 'the last occurred runtime error number (if any)

'---------------------------
'--- Public CONST values ---
'---------------------------
'--- print modes for SetPrintMode() ---
'--- according to the results of the _PRINTMODE function ---
'--- see docs\doc_GuiAppframe.bm\SetPrintMode.html ---
Const pmKEEP% = 1
Const pmONLY% = 2
Const pmFILL% = 3

'--- strip modes for LStrip$() and RStrip$() ---
'--- see docs\doc_GuiAppframe.bm\LRStrip.html ---
Const stmZERO% = 1
Const stmCTRL% = 2
Const stmBLANK% = 3
Const stmWHITE% = 4
Const stmQUOTE% = 5
'--- special modes ---
Const stmFIXED% = 6
Const stmTEXT% = 7
Const stmVALUE% = 8

'--- operation modes for FileSelect$() ---
'--- see docs\doc_GuiAppframe.bm\FileSelect.html ---
Const fsmLOAD% = 1
Const fsmSAVE% = 2
Const fsmDIRS% = 3

'-------------------------------
'--- Public TYPE definitions ---
'-------------------------------
'--- The GuiTools Framework does maintain its global data in so called
'--- IFF files as of the EA IFF-85 standard introduced by Jerry Morrison
'--- of Electronic Arts. These are the basic building blocks of those
'--- files. See https://1fish2.github.io/IFF/ for the full specification.
'-----
Type Chunk 'general IFF chunk define
    chunkID As String * 4 'the four character ID of this chunk
    chunkLEN As Long 'the bytesize of the content following after chunkLEN (ie. excl. chunkSIZEOF%)
End Type
Const chunkSIZEOF% = 4 + 4
Const CHfreeID$ = "FREE" 'indicates an unused chunk entry for recycling

Type ChunkFORM 'IFF filetype introducer (always the 1st chunk in any IFF file)
    formSTDC As Chunk 'standard chunk (chunkLEN = file length - chunkSIZEOF%)
    formTYPE As String * 4 'the four character type ID of this file
End Type
Const CHformID$ = "FORM"
Const CHformLEN% = 4
Const formSIZEOF% = chunkSIZEOF% + CHformLEN%
Const CHformTYPEpref$ = "PREF" 'global GuiTools preferences file
Const CHformTYPEwinb$ = "WINB" 'global window positions brain file
Const CHformTYPEuvar$ = "UVAR" 'GetUniqueID$() source file
Const CHformTYPEtmpl$ = "TMPL" 'TempLog() record file

Type ChunkTHDR 'header chunk for any global .tmp files
    thdrSTDC As Chunk 'standard chunk
    thdrNAME As String * 30 'the name of this global .tmp file (max. 30 chars)
    thdrACCESSORS As Integer 'that many GuiTools based programs are currently running and hence using this file
    thdrUNUSED As Long 'the file contains that many unused chunk entries for recycling
End Type
Const CHthdrID$ = "THDR"
Const CHthdrLEN% = 30 + 2 + 4
Const thdrSIZEOF% = chunkSIZEOF% + CHthdrLEN%

Type ChunkCSET 'holds preferred settings of one specific GUI object class
    csetSTDC As Chunk 'standard chunk
    csetCLASS As String * 16 'the class ID
    csetIMAGE As String * 264 'path/name of default backimage file
    csetTILE As Integer 'flag: scale(0) to fit or tile(-1) the image
    csetHOVR As Integer 'flag: allow(-1) app override with handle?
    csetFOVR As Integer 'flag: allow(-1) app override with file?
    csetPMOD As Integer 'flag: paint mode overpaint(-1) or keep blank(0)
End Type
Const CHcsetID$ = "CSET"
Const CHcsetLEN% = 16 + 264 + 2 + 2 + 2 + 2
Const csetSIZEOF% = chunkSIZEOF% + CHcsetLEN%

Type ChunkWPOS 'holds the last window position of a named application
    wposSTDC As Chunk 'standard chunk
    wposNAME As String * 30 'application's EXE name
    wposXPOS As Integer 'window's left position
    wposYPOS As Integer 'window's top position
End Type
Const CHwposID$ = "WPOS"
Const CHwposLEN% = 30 + 2 + 2
Const wposSIZEOF% = chunkSIZEOF% + CHwposLEN%

Type ChunkVARS 'holds the source values for GetUniqueID$()
    varsSTDC As Chunk 'standard chunk
    varsFID As Long 'the front/name ID counter
    varsEID As Integer 'the extension ID counter
    varsIDF As Integer 'the restart flag
End Type
Const CHvarsID$ = "VARS"
Const CHvarsLEN% = 4 + 2 + 2
Const varsSIZEOF% = chunkSIZEOF% + CHvarsLEN%

Type ChunkTLOG 'holds a .tmp file record for TempLog()
    tlogSTDC As Chunk 'standard chunk
    tlogNAME As String * 30 'the name of the logged .tmp file
    tlogACCESSOR As String * 12 'appProgID$ of the program, which created the .tmp file
    tlogCOMMENT As String * 80 'optional comment for the .tmp file (purpose, contents etc.)
End Type
Const CHtlogID$ = "TLOG"
Const CHtlogLEN% = 30 + 12 + 80
Const tlogSIZEOF% = chunkSIZEOF% + CHtlogLEN%

'--------------------------------------------
'--- Various (internal) LIBRARY functions ---
'--------------------------------------------
Declare Library
    Function GetModuleFileNameA& (ByVal module&, buffer$, Byval bufSize&)
    'Used during program init to setup the SHARED variables
    'appHomeDrive$, appHomePath$, appFullExe$ and appExeName$.
    Function GetLogicalDrives& ()
    'Used in the dev_framework\GuiAppFrame.bm function CurrDrives$().
    Function GetCurrentDirectoryA& (ByVal bufSize&, buffer$)
    'Used in the dev_framework\GuiAppFrame.bm function CurrDIR$().
    Function GetKeyboardLayout&& (ByVal thread&)
    'Used during program init to setup some internal input flags.
End Declare
Declare Library "..\dev_framework\GuiAppFrame" 'Do not add .h here !!
    Sub QB64ErrorOff ()
    Sub QB64ErrorOn ()
    'Two tiny routines to cheat QB64's error handling logic to allow for
    'nested error handling abilities, used in the UserErrorHandler, don't
    'mess with these, consider it as internal only.
    Function LockMutex%& (mtxName$) 'add CHR$(0) to name
    Sub UnlockMutex (ByVal mtxHandle%&)
    'These two functions can be used to synchronize access to any globally
    'shared resources in such a way, that only one program at a time is
    'allowed to access the protected resource.
    Function PlantMutex%& (mtxName$) 'add CHR$(0) to name
    Sub RemoveMutex (ByVal mtxHandle%&)
    Function CheckMutex% (mtxName$) 'add CHR$(0) to name
    'Some more functions for mutual exclusion handling, but these will not
    'lock access, but can be used to flag/check unique condition states.
    Function BeginDirRead%& (pathName$) 'add CHR$(0) to name
    Function GetDirEntry$ (ByVal dirHandle%&)
    Sub EndDirRead (ByVal dirHandle%&)
    'These three can be used to read the entries of a given directory.
    Function RegexMatch% (qbStr$, qbRegex$) 'add CHR$(0) to both
    Function RegexError$ (ByVal errCode%)
    Function RegexIsActive% ()
    'Regular expression matching must be explicitly enabled in the file
    'GuiAppFrame.h (dev_framework). Carfully read the notes given there.
    Sub UntitledToTop ()
    'Bring the still untitled window to the top of the Z-Order.
    Function FindColor& (ByVal r&, Byval g&, Byval b&, Byval i&, Byval mi&, Byval ma&)
    'This is a replacement for the _RGB function. It works for up to 8-bit
    '(256 colors) images only and needs a valid image. It can limit the
    'number of pens to search and uses a better color matching algorithm.
    Function CreateSMObject%& (smName$, Byval smSize&) 'add CHR$(0) to name
    Sub RemoveSMObject (ByVal smObj%&)
    Function OpenSMObject%& (smName$, Byval smSize&) 'add CHR$(0) to name
    Sub CloseSMObject (ByVal smObj%&)
    'Four routines to establish shared memory for IPC purposes, the master
    'process must use create/remove, slaves use open/close.
    Sub PutSMString (ByVal smObj%&, qbStr$) 'add CHR$(0) to string
    Function GetSMString$ (ByVal smObj%&)
    Sub ImageToSM (ByVal smObj%&, Byval i&)
    Sub SMToImage (ByVal smObj%&, Byval i&)
    'Some routines for IPC data exchange through shared memory (internal).
End Declare

'*********************************************************************
'*** Here comes the sensitive part of the GuiTools Framework its   ***
'*** init procedure. While you may safely add your own data to the ***
'*** SHARED, CONST, TYPE and LIBRARY sections above, you shouldn't ***
'*** change anything beyond this point, at least as long until you ***
'*** exactly understand, how the init procedure works with all its ***
'*** scattered GOSUB calls and Mutex locks.                        ***
'*********************************************************************
dummy% = _Exit 'take over exit handling

'--- create/init some internally required arrays and variables ---
'--- stack setup ---
ReDim Shared appStackArr$(0)
appStackArr$(0) = "*** RhoSigma-Stack-Bottom ***"
'--- error handler ---
appErrCnt% = 0: appErrMax% = 5
ReDim appErrorArr%(1 To appErrMax%, 1)
UserErrHandler
'--- flow control ---
DIM SHARED appGLVComp% 'compiled with QB64-GL yes(-1), no(0) = QB64-SDL
appGLVComp% = -1
DIM SHARED appKBLIdent% 'detected keyboard layout identifier
appKBLIdent% = 0
'--- main view handles ---
DIM SHARED appScreen& 'main screen handle (see SetupScreen())
DIM SHARED appIcon& 'default icon handle
DIM SHARED appFont& 'default font handle
'--- additional views ---
REDIM SHARED guiViews$(0)
DIM SHARED guiAGVIndex& 'active GuiView index
guiAGVIndex& = 0
DIM SHARED guiPGVCount% 'pending GuiViews counter
guiPGVCount% = 0
DIM SHARED guiWinX%, guiWinY% 'current window (GuiView) position
'--- colorspace (ImageClass) ---
'This array must be cleared, if the screen palette changes during runtime.
'It's normally done by calling the "NEWPAL" method of the "ImageC" class.
REDIM SHARED fsNearCol%(&HFFFFFF)
'--- objects control ---
CONST objData% = 0, objType% = 1, objFlags% = 2, objConn% = 3 '1st dimension IDs
REDIM SHARED guiObjects$(3, 0)
SetTag guiObjects$(0, 0), "MOUSEX", "0"
SetTag guiObjects$(0, 0), "MOUSEY", "0"
SetTag guiObjects$(0, 0), "MOUSELB", "0"
SetTag guiObjects$(0, 0), "MOUSEMB", "0"
SetTag guiObjects$(0, 0), "MOUSERB", "0"
DIM SHARED guiALBIndex& 'active lower bound index
guiALBIndex& = 1
DIM SHARED guiCOINestCnt% 'child object init nesting counter
guiCOINestCnt% = 0
DIM SHARED guiASCObject& 'active StringC object
guiASCObject& = 0
'--- tooltips ---
DIM SHARED guiATTProps$ 'active ToolTip properties
guiATTProps$ = ""

'--- check/parse shell command line ---
temp$ = COMMAND$
IF INSTR(temp$, "IUGNEPO") = 0 AND INSTR(temp$, "XOBEGASSEM") = 0 AND INSTR(temp$, "TCELESELIF") = 0 AND INSTR(temp$, "WEIVEDIUG") = 0 THEN
    'NOTE: GuiTools internal command names are spelled in reverse order to
    '      avoid faulty detection in regular command lines given by the user.
    temp$ = "NWONKNU" 'regular user given command line
END IF
REDIM cmdArgs$(0)
dummy% = ParseLine&(temp$, MKI$(&H0920), "'", cmdArgs$(), 5)

'--- init some computer/program related variables ---
appPCName$ = ENVIRON$("COMPUTERNAME")
temp$ = SPACE$(264): i% = GetModuleFileNameA&(0, temp$, 264)
appFullExe$ = LEFT$(temp$, i%): appHomeDrive$ = LEFT$(appFullExe$, 3)
appHomePath$ = PathPart$(appFullExe$): appExeName$ = FilePart$(appFullExe$)
OPEN "B", #1, appFullExe$: temp$ = SPACE$(LOF(1)): GET #1, , temp$: CLOSE #1
IF INSTR(temp$, UCASE$("sdl.") + "dll") > 0 AND _
   INSTR(temp$, UCASE$("opengl32.") + "dll") = 0 AND _
   INSTR(temp$, UCASE$("opengl32.dll")) = 0 THEN appGLVComp% = 0
IF appGLVComp% THEN
    kbli% = GetKeyboardLayout&&(0) \ 65536
    temp$ = "," + LTRIM$(STR$(kbli%)) + ","
    i% = INSTR(",1030,1031,1033,1034,1036,1040,1043,1044,1053,2055,2057,2058,2060,2070,4108,6153,", temp$)
    IF i% > 0 THEN appKBLIdent% = kbli%
END IF
temp$ = "" 'erase temp data

'--- init global GuiApps management ---
GOSUB CreateGlobalTemps
'Starting from this point, GetUniqueID$(), TempLog() and all other
'SUBs/FUNCTIONs which are calling any of the two routines can be used,
'also appLocalDir$ and appTempDir$ are initialized for use.
appProgID$ = GetUniqueID$
'Now all "appXXXXX" variables from the DIM SHARED block above are
'initialized with their respective values.
defIcoImg$ = WriteGuiAppIconArray$(appTempDir$ + GetUniqueID$, -1)
IF defIcoImg$ <> "" THEN
    TempLog defIcoImg$, "MODULE: Init CONTENTS: The GuiTools Framework's default window icon."
    defIcon& = _LOADIMAGE(defIcoImg$, 32): appIcon& = defIcon&
END IF

'--- init views & shared memory ---
appSMObj%& = CreateSMObject%&("RhoSigma-GuiApp-MainInpSM-" + appProgID$ + CHR$(0), 8192)

'--- ready to go ---
GOSUB UserInitHandler
SELECT CASE cmdArgs$(0)
    CASE "IUGNEPO"
        '====================================================================
        'Every program can have several independent GuiViews which appear in
        'its own detached windows (see SUB OpenGuiView()). The program simply
        'calls itself given the appropriate command line options.
        '--------------------------------------------------------------------
        OpenGuiView cmdArgs$(1), "*** RhoSigma-OpenGuiView-HandlerCall ***", VAL(cmdArgs$(2))
        '====================================================================
    CASE "XOBEGASSEM"
        '================================================================
        'Programs also deliver its own detached Message Box viewer, which
        'is called by the FUNCTION MessageBox$().
        '----------------------------------------------------------------
        dummy$ = MessageBox$(cmdArgs$(1), "*** RhoSigma-MessageBox-HandlerCall ***",_
                             cmdArgs$(2), cmdArgs$(3))
        '================================================================
    CASE "TCELESELIF"
        '==================================================================
        'Similar to the above, there's also an detached File Select viewer,
        'which is called by the FUNCTION FileSelect$().
        '------------------------------------------------------------------
        dummy$ = FileSelect$(cmdArgs$(1), "*** RhoSigma-FileSelect-HandlerCall ***",_
                             VAL(cmdArgs$(2)), cmdArgs$(3), cmdArgs$(4))
        '==================================================================
    CASE "WEIVEDIUG"
        '=======================================================================
        'Also every program has its own detached Guide Viewer, which is called
        'by the SUB Guide(), if the asyncron flag is set or if it must follow an
        'ALINK in any guide database.
        '-----------------------------------------------------------------------
        _TITLE "GuideView"
        '--- not yet implemented ---
        '=======================================================================
    CASE ELSE
        '===============================================================
        'If no OPENGUI, MESSAGEBOX, FILESELECT or GUIDEVIEW command line
        'is detected, then it's considered a regular program start.
        '---------------------------------------------------------------
        GOSUB UserMain 'call user's main program
        '===============================================================
END SELECT
emergencyExit:
LastPosUpdate -1 'save last known win pos
CloseScreen
GOSUB UserExitHandler
CLOSE

'--- cleanup views & shared memory ---
FOR i& = 1 TO UBOUND(guiViews$)
    temp& = VAL(GetTagData$(guiViews$(i&), "IHANDLE", "-1"))
    IF temp& < -1 THEN _FONT 16, temp&: _FREEIMAGE temp&
    RemoveSMObject VAL(GetTagData$(guiViews$(i&), "SMOBJ", "0"))
    RemoveMutex VAL(GetTagData$(guiViews$(i&), "ISOPEN", "0"))
NEXT i&
RemoveSMObject appSMObj%&
IF appFont& > 0 THEN _FREEFONT appFont&

'--- cleanup temporary data ---
InternalErrHandler
IF defIcon& < -1 THEN _FREEIMAGE defIcon&
GOSUB CleanupGlobalTemps
GOSUB RemoveGlobalTemps

'--- cleanup used arrays ---
ERASE cmdArgs$
ERASE appErrorArr%
ERASE guiObjects$
ERASE guiViews$
ERASE appStackArr$
SYSTEM
'*********************************************************************
'*********************************************************************

'--------------------------------------------------------------------
'--- Create/Remove the global .tmp files. These are shared by all ---
'--- GuiTools based programs, which are running at the same time. ---
'--------------------------------------------------------------------
GuiApp_GlobalTemps:
'--- number of global .tmp files defined in following DATAs ---
DATA 4
'--- DATA filename(max. 30 chars), type(max. 4 chars all upper case) ---
'--- use types as defined at "TYPE ChunkFORM" above ---
'--- *.tmp files go into appTempDir$ and are temporary in the session, ---
'--- other extensions go into appLocalDir$ and will survive sessions   ---
DATA "gtprefs.bin","PREF"
DATA "wpbrain.bin","WINB"
DATA "univars.tmp","UVAR"
DATA "templog.tmp","TMPL"

CreateGlobalTemps:
'--- get local appdata folder ---
appLocalDir$ = ENVIRON$("LOCALAPPDATA")
IF appLocalDir$ = "" THEN appLocalDir$ = appHomePath$
IF RIGHT$(appLocalDir$, 1) <> "\" THEN appLocalDir$ = appLocalDir$ + "\"
InternalErrHandler
IF NOT _DIREXISTS(appLocalDir$ + "RhoSigma") THEN MKDIR appLocalDir$ + "RhoSigma"
UserErrHandler
IF appLastErr% = 0 THEN appLocalDir$ = appLocalDir$ + "RhoSigma\"
'--- get temporary folder ---
appTempDir$ = ENVIRON$("TMP")
IF appTempDir$ = "" THEN appTempDir$ = ENVIRON$("TEMP")
IF appTempDir$ = "" THEN appTempDir$ = appHomePath$
IF RIGHT$(appTempDir$, 1) <> "\" THEN appTempDir$ = appTempDir$ + "\"
InternalErrHandler
IF NOT _DIREXISTS(appTempDir$ + "RhoSigma-GuiApps") THEN MKDIR appTempDir$ + "RhoSigma-GuiApps"
UserErrHandler
IF appLastErr% = 0 THEN appTempDir$ = appTempDir$ + "RhoSigma-GuiApps\"
'--- lock global temps init procedure ---
crgtInitMtx%& = LockMutex%&("Global\RhoSigma-GuiApp-Framework-Init" + CHR$(0))
'--- cleanup crash remains (if any) ---
IF NOT CheckMutex%("Global\RhoSigma-GuiApp-Framework-InUse" + CHR$(0)) THEN
    GOSUB CleanupGlobalTemps
    InternalErrHandler
    KILL appTempDir$ + "templog.tmp"
    UserErrHandler
END IF
'--- now create files or raise its accessor count ---
REDIM crgtFORM(0) AS ChunkFORM
REDIM crgtTHDR(0) AS ChunkTHDR
RESTORE GuiApp_GlobalTemps
READ crgtCnt%
FOR crgtLoop% = 1 TO crgtCnt%
    READ crgtName$, crgtType$
    IF LCASE$(FileExtension$(crgtName$)) = ".tmp" THEN crgtPath$ = appTempDir$: ELSE crgtPath$ = appLocalDir$
    crgtMtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-" + crgtName$ + CHR$(0))
    IF _FILEEXISTS(crgtPath$ + crgtName$) THEN
        crgtFile% = SafeOpenFile%("B", crgtPath$ + crgtName$)
        crgtHdr& = SeekChunk&(crgtFile%, 1, CHthdrID$)
        GET crgtFile%, , crgtTHDR(0)
        IF NOT CheckMutex%("Global\RhoSigma-GuiApp-Framework-InUse" + CHR$(0)) THEN
            crgtTHDR(0).thdrACCESSORS = 1
        ELSE
            crgtTHDR(0).thdrACCESSORS = crgtTHDR(0).thdrACCESSORS + 1
        END IF
        PUT crgtFile%, crgtHdr&, crgtTHDR(0)
        CLOSE crgtFile%
    ELSE
        crgtFORM(0).formSTDC.chunkID = CHformID$
        crgtFORM(0).formSTDC.chunkLEN = CHformLEN% + thdrSIZEOF%
        crgtFORM(0).formTYPE = crgtType$
        crgtTHDR(0).thdrSTDC.chunkID = CHthdrID$
        crgtTHDR(0).thdrSTDC.chunkLEN = CHthdrLEN%
        crgtTHDR(0).thdrNAME = crgtName$
        crgtTHDR(0).thdrACCESSORS = 1
        crgtTHDR(0).thdrUNUSED = 0
        crgtFile% = SafeOpenFile%("B", crgtPath$ + crgtName$)
        PUT crgtFile%, , crgtFORM(0)
        PUT crgtFile%, , crgtTHDR(0)
        IF crgtType$ = CHformTYPEuvar$ THEN
            REDIM crgtVARS(0) AS ChunkVARS
            crgtVARS(0).varsSTDC.chunkID = CHvarsID$
            crgtVARS(0).varsSTDC.chunkLEN = CHvarsLEN%
            crgtVARS(0).varsFID = -2147483648
            crgtVARS(0).varsEID = 0
            crgtVARS(0).varsIDF = 0
            PUT crgtFile%, , crgtVARS(0)
            SizeUpdate crgtFile%, varsSIZEOF%
            ERASE crgtVARS
        END IF
        CLOSE crgtFile%
    END IF
    UnlockMutex crgtMtx%&
NEXT crgtLoop%
ERASE crgtTHDR
ERASE crgtFORM
'--- set global temps init done marker & unlock init ---
crgtUseMtx%& = PlantMutex%&("Global\RhoSigma-GuiApp-Framework-InUse" + CHR$(0))
UnlockMutex crgtInitMtx%&
RETURN

CleanupGlobalTemps:
'--- kill all remaining logged .tmp files of this program ---
REDIM crgtTHDR(0) AS ChunkTHDR
REDIM crgtTLOG(0) AS ChunkTLOG
crgtMtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-templog.tmp" + CHR$(0))
crgtFile% = SafeOpenFile%("B", appTempDir$ + "templog.tmp")
crgtHdr& = SeekChunk&(crgtFile%, 1, CHthdrID$)
GET crgtFile%, , crgtTHDR(0)
IF SeekChunk&(crgtFile%, 1, CHtlogID$) > 0 THEN
    WHILE NOT EOF(crgtFile%)
        crgtLog& = SEEK(crgtFile%)
        GET crgtFile%, , crgtTLOG(0)
        IF appProgID$ = "" OR crgtTLOG(0).tlogACCESSOR = appProgID$ THEN
            InternalErrHandler
            KILL appTempDir$ + RStrip$(stmFIXED%, crgtTLOG(0).tlogNAME)
            UserErrHandler
            crgtTLOG(0).tlogSTDC.chunkID = CHfreeID$
            crgtTLOG(0).tlogNAME = ""
            crgtTLOG(0).tlogACCESSOR = ""
            crgtTLOG(0).tlogCOMMENT = ""
            PUT crgtFile%, crgtLog&, crgtTLOG(0)
            crgtTHDR(0).thdrUNUSED = crgtTHDR(0).thdrUNUSED + 1
        END IF
    WEND
    PUT crgtFile%, crgtHdr&, crgtTHDR(0)
END IF
CLOSE crgtFile%
UnlockMutex crgtMtx%&
ERASE crgtTLOG
ERASE crgtTHDR
RETURN

RemoveGlobalTemps:
'--- lower accessor count, kill global .tmp file if zero ---
REDIM crgtTHDR(0) AS ChunkTHDR
RESTORE GuiApp_GlobalTemps
READ crgtCnt%
FOR crgtLoop% = 1 TO crgtCnt%
    READ crgtName$, crgtType$
    IF LCASE$(FileExtension$(crgtName$)) = ".tmp" THEN crgtPath$ = appTempDir$: ELSE crgtPath$ = appLocalDir$
    crgtMtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-" + crgtName$ + CHR$(0))
    crgtFile% = SafeOpenFile%("B", crgtPath$ + crgtName$)
    crgtHdr& = SeekChunk&(crgtFile%, 1, CHthdrID$)
    GET crgtFile%, , crgtTHDR(0)
    crgtTHDR(0).thdrACCESSORS = crgtTHDR(0).thdrACCESSORS - 1
    PUT crgtFile%, crgtHdr&, crgtTHDR(0)
    CLOSE crgtFile%
    IF crgtPath$ = appTempDir$ THEN
        IF crgtTHDR(0).thdrACCESSORS = 0 THEN KILL crgtPath$ + crgtName$
    END IF
    UnlockMutex crgtMtx%&
NEXT crgtLoop%
ERASE crgtTHDR
RemoveMutex crgtUseMtx%&
RETURN

'-----------------------------------
'--- A very simple error handler ---
'-----------------------------------
InternalErrorHandler:
appLastErr% = ERR
IF appLastErr% = 1000 THEN RESUME emergencyExit 'immediate exit request
RESUME NEXT

