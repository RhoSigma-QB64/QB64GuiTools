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
$SCREENHIDE

'---------------------------------------------
'--- Public Application wide SHARED values ---
'---------------------------------------------
DIM SHARED appProgID$ 'unique ID of this program (every running GuiTools based program will get its own)

DIM SHARED appHomeDrive$ 'this program's home drive, ie. where the executable is located (eg. "C:\")
DIM SHARED appHomePath$ 'this program's home directory, ie. where the executable is located (eg. "C:\qb64\")
DIM SHARED appFullExe$ 'full path/name of this program's executable file (eg. "C:\qb64\GuiApp.exe")
DIM SHARED appExeName$ 'name only of this program's executable file (eg. "GuiApp.exe")

DIM SHARED appPCName$ 'this computer's name from environment set (eg. "My Computer")
DIM SHARED appDrives$ 'the drives available on this computer in one string (eg. "CDEGHI")
DIM SHARED appLocalDir$ 'the local appdata folder from environment set (eg. "C:\Users\RhoSigma\AppData\Local\")
DIM SHARED appTempDir$ 'the temporary folder from environment set (eg. "C:\Users\RhoSigma\AppData\Local\temp\")

DIM SHARED appLastErr% 'the last occurred runtime error number (if any)
DIM SHARED appScreen& 'the image handle of the main screen (see SetupScreen()/CloseScreen())
'use SourceDestGuiView() to activate any GuiViews for rendering, SourceDestGuiView(0) = appScreen&

'---------------------------
'--- Public CONST values ---
'---------------------------
'--- operation modes for FileSelect$() ---
'--- see docs\doc_GuiAppframe.bm\FileSelect.html ---
CONST fsmLOAD% = 1
CONST fsmSAVE% = 2
CONST fsmDIRS% = 3

'--- print modes for SetPrintMode() ---
'--- according to the results of the _PRINTMODE function ---
'--- see docs\doc_GuiAppframe.bm\SetPrintMode.html ---
CONST pmKEEP% = 1
CONST pmONLY% = 2
CONST pmFILL% = 3

'--- strip modes for LStrip$() and RStrip$() ---
'--- see docs\doc_GuiAppframe.bm\LRStrip.html ---
CONST stripZERO% = 1
CONST stripTAB% = 2
CONST stripSPACE% = 3
CONST stripQUOTE% = 4
CONST stripFIX% = 5
CONST stripWHITE% = 6
CONST stripALL% = 7
'--- special modes ---
CONST stripTEXT% = 8
CONST stripVALUE% = 9

'-------------------------------
'--- Public TYPE definitions ---
'-------------------------------
'--- The GuiTools Framework will maintain its global data in so called
'--- IFF files. These are the basic building blocks of those files.
'-----
TYPE Chunk 'general IFF chunk define
    chunkID AS STRING * 4 'the four character ID of this chunk
    chunkLEN AS LONG 'the bytesize of the content following after chunkLEN (ie. excl. chunkSIZEOF%)
END TYPE
CONST chunkSIZEOF% = 4 + 4
CONST CHfreeID$ = "FREE" 'indicates an unused chunk entry for recycling

TYPE ChunkFORM 'IFF filetype introducer (always the 1st chunk in any IFF file)
    formSTDC AS Chunk 'standard chunk (chunkLEN = file length - chunkSIZEOF%)
    formTYPE AS STRING * 4 'the four character type ID of this file
END TYPE
CONST CHformID$ = "FORM"
CONST CHformLEN% = 4
CONST formSIZEOF% = chunkSIZEOF% + CHformLEN%
CONST CHformTYPEpref$ = "PREF" 'global GuiTools preferences file
CONST CHformTYPEwinb$ = "WINB" 'global window positions brain file
CONST CHformTYPEuvar$ = "UVAR" 'GetUniqueID$() source file
CONST CHformTYPEtmpl$ = "TMPL" 'TempLog() record file

TYPE ChunkTHDR 'header chunk for any global .tmp files
    thdrSTDC AS Chunk 'standard chunk
    thdrNAME AS STRING * 30 'the name of this global .tmp file (max. 30 chars)
    thdrACCESSORS AS INTEGER 'that many GuiTools based programs are currently running and hence using this file
    thdrUNUSED AS LONG 'the file contains that many unused chunk entries for recycling
END TYPE
CONST CHthdrID$ = "THDR"
CONST CHthdrLEN% = 30 + 2 + 4
CONST thdrSIZEOF% = chunkSIZEOF% + CHthdrLEN%

TYPE ChunkCSET 'holds preferred settings of one specific GUI object class
    csetSTDC AS Chunk 'standard chunk
    csetCLASS AS STRING * 16 'the class ID
    csetIMAGE AS STRING * 264 'path/name of default backimage file
    csetTILE AS INTEGER 'flag: scale(0) to fit or tile(-1) the image
    csetHOVR AS INTEGER 'flag: allow(-1) app override with handle?
    csetFOVR AS INTEGER 'flag: allow(-1) app override with file?
    csetPMOD AS INTEGER 'flag: paint mode overpaint(-1) or keep blank(0)
END TYPE
CONST CHcsetID$ = "CSET"
CONST CHcsetLEN% = 16 + 264 + 2 + 2 + 2 + 2
CONST csetSIZEOF% = chunkSIZEOF% + CHcsetLEN%

TYPE ChunkWPOS 'holds the last window position of a named application
    wposSTDC AS Chunk 'standard chunk
    wposNAME AS STRING * 30 'application's EXE name
    wposXPOS AS INTEGER 'window's left position
    wposYPOS AS INTEGER 'window's top position
END TYPE
CONST CHwposID$ = "WPOS"
CONST CHwposLEN% = 30 + 2 + 2
CONST wposSIZEOF% = chunkSIZEOF% + CHwposLEN%

TYPE ChunkVARS 'holds the source values for GetUniqueID$()
    varsSTDC AS Chunk 'standard chunk
    varsFID AS LONG 'the front/name ID counter
    varsEID AS INTEGER 'the extension ID counter
    varsIDF AS INTEGER 'the restart flag
END TYPE
CONST CHvarsID$ = "VARS"
CONST CHvarsLEN% = 4 + 2 + 2
CONST varsSIZEOF% = chunkSIZEOF% + CHvarsLEN%

TYPE ChunkTLOG 'holds a .tmp file record for TempLog()
    tlogSTDC AS Chunk 'standard chunk
    tlogNAME AS STRING * 30 'the name of the logged .tmp file
    tlogACCESSOR AS STRING * 12 'appProgID$ of the program, which created the .tmp file
    tlogCOMMENT AS STRING * 80 'optional comment for the .tmp file (purpose, contents etc.)
END TYPE
CONST CHtlogID$ = "TLOG"
CONST CHtlogLEN% = 30 + 12 + 80
CONST tlogSIZEOF% = chunkSIZEOF% + CHtlogLEN%

'--------------------------------------------
'--- Various (internal) LIBRARY functions ---
'--------------------------------------------
DECLARE LIBRARY
    FUNCTION GetModuleFileNameA& (BYVAL module&, buffer$, BYVAL bufSize&)
    'Used during program init to setup the SHARED variables
    'appHomeDrive$, appHomePath$, appFullExe$ and appExeName$.
    FUNCTION GetLogicalDriveStringsA& (BYVAL bufSize&, buffer$)
    'Used during program init to setup the SHARED variable appDrives$.
    FUNCTION GetCurrentDirectoryA& (BYVAL bufSize&, buffer$)
    'Used in the dev_framework\GuiAppFrame.bm function CurrDIR$().
    FUNCTION GetKeyboardLayout&& (BYVAL thread&)
    'Used during program init to setup some internal input flags.
END DECLARE
DECLARE LIBRARY "QB64GuiTools\dev_framework\GuiAppFrame" 'Do not add .h here !!
    SUB QB64ErrorOff ()
    SUB QB64ErrorOn ()
    'Two tiny routines to cheat QB64's error handling logic to allow for
    'nested error handling abilities, used in the UserErrorHandler, don't
    'mess with these, consider it as internal only.
    FUNCTION LockMutex%& (mtxName$) 'add CHR$(0) to name
    SUB UnlockMutex (BYVAL mtxHandle%&)
    'These two functions can be used to synchronize access to any globally
    'shared resources in such a way, that only one program at a time is
    'allowed to access the protected resource.
    FUNCTION PlantMutex%& (mtxName$) 'add CHR$(0) to name
    SUB RemoveMutex (BYVAL mtxHandle%&)
    FUNCTION CheckMutex% (mtxName$) 'add CHR$(0) to name
    'Some more functions for mutual exclusion handling, but these will not
    'lock access, but can be used to flag/check unique condition states.
    FUNCTION BeginDirRead%& (pathName$) 'add CHR$(0) to name
    FUNCTION GetDirEntry$ (BYVAL dirHandle%&)
    SUB EndDirRead (BYVAL dirHandle%&)
    'These three can be used to read the entries of a given directory.
    FUNCTION RegexMatch% (qbStr$, qbRegex$) 'add CHR$(0) to both
    FUNCTION RegexError$ (BYVAL errCode%)
    FUNCTION RegexIsActive% ()
    'Regular expression matching must be explicitly enabled in the file
    'GuiAppFrame.h (dev_framework). Carfully read the notes given there.
    SUB UntitledToTop ()
    'Bring the still untitled window to the top of the Z-Order.
    FUNCTION FindColor& (BYVAL r&, BYVAL g&, BYVAL b&, BYVAL i&, BYVAL mi&, BYVAL ma&)
    'This is a replacement for the _RGB function. It works for upto 8-bit
    '(256 colors) images only and needs a valid image. It can limit the
    'number of pens to search and uses a better color matching algorithm.
    FUNCTION CreateSMObject%& (smName$, BYVAL smSize&) 'add CHR$(0) to name
    SUB RemoveSMObject (BYVAL smObj%&)
    FUNCTION OpenSMObject%& (smName$, BYVAL smSize&) 'add CHR$(0) to name
    SUB CloseSMObject (BYVAL smObj%&)
    'Four routines to establish shared memory for IPC purposes, the master
    'process must use create/remove, slaves use open/close.
    SUB PutSMString (BYVAL smObj%&, qbStr$) 'add CHR$(0) to string
    FUNCTION GetSMString$ (BYVAL smObj%&)
    SUB ImageToSM (BYVAL smObj%&, BYVAL i&)
    SUB SMToImage (BYVAL smObj%&, BYVAL i&)
    'Some routines for IPC data exchange through shared memory (internal).
END DECLARE

'*********************************************************************
'*** Here comes the sensitive part of the GuiTools Framework its   ***
'*** init procedure. While you may safely add your own data to the ***
'*** SHARED, CONST, TYPE and LIBRARY sections above, you shouldn't ***
'*** change anything beyond this point, at least as long until you ***
'*** exactly understand, how the init procedure works with all its ***
'*** scattered GOSUB calls and Mutex locks.                        ***
'*********************************************************************
dummy% = _EXIT 'take over exit handling

'--- create/init some internally required arrays and variables ---
'--- colorspace ---
'Support array to hold once found nearest color matches of the Floyd-
'Steinberg remapper for quicker access. This is made global, as color
'matching depends on the screen palette only, not on the processed images.
'This way every further image to process does profit from matches already
'found by earlier remapped images. Note that this array must be cleared,
'if the screen palette changes during runtime. This is normally done by
'calling the "NEWPAL" method of the "ImageC" class.
REDIM SHARED fsNearCol%(&HFFFFFF)
'--- stack ---
REDIM SHARED appStackArr$(0)
appStackArr$(0) = "*** RhoSigma-Stack-Bottom ***"
'--- views ---
REDIM SHARED guiViews$(0)
DIM SHARED guiAGVIndex& 'active GuiView index
guiAGVIndex& = 0
DIM SHARED appIcon& 'image handle of program icon
DIM SHARED appFont& 'font handle used on all GuiViews (if any)
'--- objects ---
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
DIM SHARED guiATTProps$ 'active ToolTip properties
guiATTProps$ = ""
DIM SHARED guiWinX%, guiWinY% 'current window position
'--- flow control ---
DIM SHARED appSSSEarly% 'SetupScreen() show early yes(-1)/no(0)
appSSSEarly% = 0
DIM SHARED appGMRInkey% 'GetGUIMsg$() regular INKEY$ yes(-1)/no(0)
appGMRInkey% = -1
'--- errors ---
appErrCnt% = 0: appErrMax% = 5
REDIM appErrorArr%(1 TO appErrMax%, 1)
UserErrHandler

'--- check/parse shell command line ---
temp$ = COMMAND$
IF INSTR(temp$, "IUGNEPO") = 0 AND INSTR(temp$, "XOBEGASSEM") = 0 AND INSTR(temp$, "TCELESELIF") = 0 AND INSTR(temp$, "WEIVEDIUG") = 0 THEN
    'NOTE: GuiTools internal command names are spelled in reverse order to
    '      avoid faulty detection in regular command lines given by the user.
    temp$ = "NOTHING" 'for any unrecognized command line
ELSE
    FOR i% = 1 TO LEN(temp$)
        IF MID$(temp$, i%, 1) = "'" THEN MID$(temp$, i%, 1) = CHR$(34)
    NEXT i%
END IF
REDIM cmdArgs$(0)
dummy% = ParseLine&(temp$, cmdArgs$(), 5)

'--- init some computer/program related variables ---
appPCName$ = ENVIRON$("COMPUTERNAME")
GOSUB GetHomeDriveVars
OPEN "B", #1, appFullExe$: temp$ = SPACE$(LOF(1)): GET #1, , temp$: CLOSE #1
IF INSTR(temp$, UCASE$("opengl32.")) > 0 THEN
    appSSSEarly% = -1
    IF (GetKeyboardLayout&&(0) \ 65536) = &H0407 THEN appGMRInkey% = 0
END IF
temp$ = ""

'--- init global GuiApps management ---
GOSUB CreateGlobalTemps
'Starting from this point, GetUniqueID$(), TempLog() and all other
'SUBs/FUNCTIONs which are calling any of the two routines can be used,
'also appLocalDir$ and appTempDir$ are initialized for use.
defIcoImg$ = WriteGuiAppIconArray$(appTempDir$ + GetUniqueID$, -1)
IF defIcoImg$ <> "" THEN
    TempLog defIcoImg$, "MODULE: Init CONTENTS: The GuiTools Framework's default window icon."
    defIcon& = _LOADIMAGE(defIcoImg$, 32): appIcon& = defIcon&
END IF

'--- finally init the private program ID ---
appProgID$ = GetUniqueID$
appSMObj%& = CreateSMObject%&("RhoSigma-GuiApp-MainInpSM-" + appProgID$ + CHR$(0), 8192)
'Now all "appXXXXX" variables from the DIM SHARED block above are
'initialized with their respective values.

'--- ready to go ---
GOSUB UserInitHandler
SELECT CASE cmdArgs$(0)
    CASE "IUGNEPO"
        '====================================================================
        'Every program can have several independed GuiViews which appear in
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
    IF temp& < -1 THEN _FREEIMAGE temp&
    RemoveSMObject VAL(GetTagData$(guiViews$(i&), "SMOBJ", "0"))
    RemoveMutex VAL(GetTagData$(guiViews$(vix&), "ISOPEN", "0"))
NEXT i&
RemoveSMObject appSMObj%&

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
'**********************************************************************
'**********************************************************************

'----------------------------------------------
'--- Get EXE's home vars & available drives ---
'----------------------------------------------
GetHomeDriveVars:
'--- full .exe path/name ---
ghdvTmp$ = SPACE$(264)
ghdvLen% = GetModuleFileNameA&(0, ghdvTmp$, LEN(ghdvTmp$))
appFullExe$ = LEFT$(ghdvTmp$, ghdvLen%)
'--- home drive ---
appHomeDrive$ = LEFT$(appFullExe$, 3)
'--- home path & .exe (name only) ---
appHomePath$ = PathPart$(appFullExe$)
appExeName$ = FilePart$(appFullExe$)
'--- available drives ---
ghdvTmp$ = SPACE$(112)
ghdvLen% = GetLogicalDriveStringsA&(LEN(ghdvTmp$), ghdvTmp$)
appDrives$ = ""
FOR ghdvPos% = 1 TO ghdvLen% STEP 4
    appDrives$ = appDrives$ + MID$(ghdvTmp$, ghdvPos%, 1)
NEXT ghdvPos%
RETURN

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
IF appTempDir$ = "" THEN appTempDir$ = ENVIRON$("DOSTMP")
IF appTempDir$ = "" THEN appTempDir$ = ENVIRON$("DOSTEMP")
IF appTempDir$ = "" THEN appTempDir$ = ENVIRON$("WINTMP")
IF appTempDir$ = "" THEN appTempDir$ = ENVIRON$("WINTEMP")
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
    IF LCASE$(RIGHT$(crgtName$, 4)) = ".tmp" THEN crgtPath$ = appTempDir$: ELSE crgtPath$ = appLocalDir$
    crgtMtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-" + crgtName$ + CHR$(0))
    IF _FILEEXISTS(crgtPath$ + crgtName$) THEN
        crgtFile% = SafeOpenFile%("B", crgtPath$ + crgtName$)
        crgtHdr& = SeekChunk&(crgtFile%, CHthdrID$)
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
crgtHdr& = SeekChunk&(crgtFile%, CHthdrID$)
GET crgtFile%, , crgtTHDR(0)
IF SeekChunk&(crgtFile%, CHtlogID$) THEN
    WHILE NOT EOF(crgtFile%)
        crgtLog& = SEEK(crgtFile%)
        GET crgtFile%, , crgtTLOG(0)
        IF appProgID$ = "" OR crgtTLOG(0).tlogACCESSOR = appProgID$ THEN
            InternalErrHandler
            KILL appTempDir$ + RStrip$(stripFIX%, crgtTLOG(0).tlogNAME)
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
    IF LCASE$(RIGHT$(crgtName$, 4)) = ".tmp" THEN crgtPath$ = appTempDir$: ELSE crgtPath$ = appLocalDir$
    crgtMtx%& = LockMutex%&("Global\RhoSigma-GuiApp-FileAccess-" + crgtName$ + CHR$(0))
    crgtFile% = SafeOpenFile%("B", crgtPath$ + crgtName$)
    crgtHdr& = SeekChunk&(crgtFile%, CHthdrID$)
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
