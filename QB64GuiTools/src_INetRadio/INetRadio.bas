$IF VERSION < 3.14.0 THEN
    $ERROR 'INetRadio requires at least QB64-PE v3.14.0 !!'
$END IF

'-----------------------------------------------------------
$VERSIONINFO:FILEVERSION#=1,4,0,0
$VERSIONINFO:FileDescription='A neat small Web-Radio player'
$VERSIONINFO:LegalCopyright='MIT License'
'-----------------------------------------------------------

'$INCLUDE: 'QB64GuiTools\src_INetRadio\inline\mp3dec.bi'

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
'| === INetRadio.bas ===                                             |
'|                                                                   |
'| == A neat small Web-Radio player. Listen to your favorite Radio   |
'| == Stations without much hassle, see INetRadio.txt for more info. |
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
Add16ImgName$ = WriteAdd16ImgArray$(appTempDir$ + "Add16px.png", -1)
Cancel16ImgName$ = WriteCancel16ImgArray$(appTempDir$ + "Cancel16px.png", -1)
Import16ImgName$ = WriteImport16ImgArray$(appTempDir$ + "Import16px.png", -1)
BackImgName$ = WriteBackImgArray$(appTempDir$ + "Back.jpg", -1)
MarbleImgName$ = WriteMarbleImgArray$(appTempDir$ + "Marble.jpg", -1)
TissueImgName$ = WriteTissueImgArray$(appTempDir$ + "Tissue.jpg", -1)
TempLog Add16ImgName$, "": TempLog Cancel16ImgName$, "": TempLog Import16ImgName$, ""
TempLog BackImgName$, "": TempLog MarbleImgName$, "": TempLog TissueImgName$, ""
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
'--- prepare defaults for 1st start ---
userList% = -1 'user list handle invalid for now
cvfs% = 0 '(c)urrent (v)ersion (f)irst (s)tart flag
IF (NOT _FILEEXISTS(appLocalDir$ + "INR-Options.bin")) OR _
   (NOT _FILEEXISTS(appLocalDir$ + "INR-Stations.txt")) THEN
    cvfs% = -1
ELSE
    IF NOT _FILEEXISTS(appLocalDir$ + "INR-Version.txt") THEN
        ivs$ = "1.0": cvfs% = -1
    ELSE
        ivs$ = _READFILE$(appLocalDir$ + "INR-Version.txt")
        IF ivs$ <> VersionINetRadio$ THEN cvfs% = -1
    END IF
END IF
IF cvfs% THEN
    IF INSTR(ivs$, "1.3") = 0 THEN
        sta% = SafeOpenFile%("I", appLocalDir$ + "INR-Stations.txt")
        IF sta% > 0 THEN
            nsl$ = ReadStationsTxtArray$: userList% = CreateBuf%
            WHILE NOT EOF(sta%)
                LINE INPUT #sta%, sn$: LINE INPUT #sta%, tsu$: su$ = tsu$
                IF LCASE$(LEFT$(tsu$, 4)) = "http" THEN tsu$ = MID$(tsu$, INSTR(tsu$, "://") + 3)
                IF INSTR(nsl$, tsu$) = 0 THEN
                    WriteBufLine userList%, sn$: WriteBufLine userList%, su$
                    WriteBufLine userList%, "": WriteBufLine userList%, ""
                END IF
            WEND
            CLOSE sta%
        END IF
        IF NOT _FILEEXISTS(appLocalDir$ + "INR-Options.bin") THEN
            _WRITEFILE appLocalDir$ + "INR-Options.bin", ReadOptionsBinArray$
        END IF
        _WRITEFILE appLocalDir$ + "INR-Stations.txt", ReadStationsTxtArray$
    END IF
    _WRITEFILE appLocalDir$ + "INR-Version.txt", VersionINetRadio$
END IF
'--- read settings ---
TYPE Settings
    scrStation AS INTEGER 'always scroll Station name
    scrFeeds AS INTEGER 'always scroll Feeds text
    volReset AS INTEGER 'reset volume when changing station
    volStart AS INTEGER 'volume level at program start
    bufSize AS INTEGER 'pre-buffering size in KiB
    autoPlay AS INTEGER 'auto-start playing at program start/station change
    autoRetry AS INTEGER 'auto-restart play after stall
    chgQuiet AS INTEGER 'quietly changing https:// to http:// (no warning)
    remStation AS INTEGER 'remember last active station
    idxStation AS INTEGER 'last active station index
END TYPE
DIM SHARED opts AS Settings
optsFile% = SafeOpenFile%("B", appLocalDir$ + "INR-Options.bin")
GET optsFile%, , opts: CLOSE optsFile%
'--- read Stations list ---
listFile% = FileToBuf%(appLocalDir$ + "INR-Stations.txt")
IF CheckHandle%(userList%) _ANDALSO GetBufLen&(userList%) >= 10 THEN
    BufInsertBuf listFile%, userList%
    DisposeBuf userList%: userList% = -1 'invalidate
    nul& = SeekBuf&(listFile%, 0, SBM_BufStart)
END IF
StationsList$ = ListC$("INIT", NewTag$("SORT", "alphabet"))
WHILE NOT EndOfBuf%(listFile%)
    sn$ = ReadBufLine$(listFile%): su$ = ReadBufLine$(listFile%)
    ad$ = ReadBufLine$(listFile%): md$ = ReadBufLine$(listFile%)
    ok$ = ListC$("STORE", StationsList$ +_
        NewTag$("DATA", sn$) +_
        NewTag$("STREAM_URL", su$) +_
        NewTag$("ADVERT_TEXT", ad$) +_
        NewTag$("META_DELAY", md$))
WEND
DisposeBuf listFile%
'--- preparations for recent view ---
RecentFile% = CreateBuf%: RecentMarked% = 0
RecentList$ = ListC$("INIT", NewTag$("SORT", "lifo"))
ok$ = ListC$("STORE", RecentList$ + NewTag$("DATA", CHR$(255)))
'--- further temporary file names ---
svrresName$ = "INR-SvrRes(" + appProgID$ + ").txt"
TempLog svrresName$, "CONTENTS: Server response from Radio Station."
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
'-----
IF nowPlaying% THEN GOSUB togglePlayingState: GOSUB stopPlay
'--- save Stations list ---
ok$ = ListC$("SET", StationsList$ + NewTag$("ACTUAL", "1") + NewTag$("REVERSE", "false"))
listFile% = CreateBuf%: reco% = VAL(GetObjTagData$(StationsList$, "RECORDS", "1"))
FOR i% = 1 TO reco%
    record$ = ListC$("READ", StationsList$)
    WriteBufLine listFile%, GetTagData$(record$, "DATA", "")
    WriteBufLine listFile%, GetTagData$(record$, "STREAM_URL", "")
    WriteBufLine listFile%, GetTagData$(record$, "ADVERT_TEXT", "")
    WriteBufLine listFile%, GetTagData$(record$, "META_DELAY", "")
NEXT i%
BufToFile listFile%, appLocalDir$ + "INR-Stations.txt"
DisposeBuf listFile%
'--- save settings ---
IF NOT opts.remStation THEN
    RANDOMIZE TIMER: opts.idxStation = INT(RND(1) * reco%) + 1
END IF
optsFile% = SafeOpenFile%("B", appLocalDir$ + "INR-Options.bin")
PUT optsFile%, , opts: CLOSE optsFile%
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
IF appLastErr% = 1001 THEN GOSUB MainLoop_PermanentHandler: RESUME NEXT

IF appErrCnt% >= appErrMax% THEN
    dummy$ = MessageBox$("Error16px.png", appExeName$,_
                         "Error handler reports too many|" +_
                         "recursive Errors !!|~" +_
                         "Program will cleanup and terminate|" +_
                         "via internal emergency exit.",_
                         "{IMG Error16px.png 0}Ok, got it...")
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
                             "{IMG Error16px.png 0}Ok, got it...")
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

SetupScreen 640, 312, 0
appCR$ = "The Internet Radio Player v1.4, Done by RhoSigma, Roland Heyder"
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
COLOR 39: _PRINTSTRING (260, 150), "initializing..."
about$ = VersionINetRadio$ + "|Powered by QB64-PE"
MID$(about$, INSTR(about$, ")") + 1, 1) = "|"

'~~~ My GUI Setup
'-----------------------------
'--- Init GUI objects here ---
'-----------------------------
MainBackImage$ = ImageC$("INIT",_
        NewTag$("IMAGEFILE", "Back.jpg") +_
        NewTag$("BACKFILL", "true") +_
        NewTag$("AREA", "false") +_
        NewTag$("LEFT", "0") +_
        NewTag$("TOP", "0"))
MainLogoImage$ = ImageC$("INIT",_
        NewTag$("LEFT", "9") +_
        NewTag$("TOP", "-8") +_
        NewTag$("WIDTH", "180") +_
        NewTag$("HEIGHT", "180") +_
        NewTag$("STANDALONE", "true") +_
        NewTag$("CLEARCOLOR", "0") +_
        NewTag$("TOOLTIP", about$) +_
        NewTag$("IMAGEFILE", "Radio.png"))
'--- Station/Feeds fields ---
MainFrameCommon$ =_
        NewTag$("LEFT", "195") +_
        NewTag$("WIDTH", "430") +_
        NewTag$("HEIGHT", "60") +_
        NewTag$("FORM", "solid") +_
        NewTag$("RECESSED", "true") +_
        NewTag$("TEXTPLACE", "topright")
MainStationFrame$ = FrameC$("INIT", MainFrameCommon$ +_
        NewTag$("TOP", "12") +_
        NewTag$("TEXT", "Radio Station"))
MainFeedsFrame$ = FrameC$("INIT", MainFrameCommon$ +_
        NewTag$("TOP", "90") +_
        NewTag$("TEXT", "Feeds display"))
MainTextCommon$ =_
        NewTag$("LEFT", "209") +_
        NewTag$("WIDTH", "402") +_
        NewTag$("HEIGHT", "32") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("TEXTSCROLL", "true") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "Tissue.jpg")
temp$ = GetTagData$(ListC$("READ", StationsList$ + NewTag$("ACTUAL", LTRIM$(STR$(opts.idxStation)))), "DATA", "")
IF opts.scrStation THEN WHILE _UPRINTWIDTH(temp$, 8) < 400: temp$ = temp$ + " - - - - - " + temp$: WEND
MainStationText$ = TextC$("INIT", MainTextCommon$ +_
        NewTag$("TOP", "26") +_
        NewTag$("TEXT", temp$))
MainFeedsText$ = TextC$("INIT", MainTextCommon$ +_
        NewTag$("TOP", "104") +_
        NewTag$("TEXT", "press play to listen..."))
'--- Spectrum ---
MainSpecRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "10") +_
        NewTag$("TOP", "167") +_
        NewTag$("LENGTH", "620") +_
        NewTag$("FORM", "ridge"))
MainSpecCommon$ =_
        NewTag$("TOP", "178") +_
        NewTag$("WIDTH", "298") +_
        NewTag$("HEIGHT", "60") +_
        NewTag$("FORM", "simple") +_
        NewTag$("TEXTPLACE", "center") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "Tissue.jpg")
MainSpecLeft$ = TextC$("INIT", MainSpecCommon$ +_
        NewTag$("LEFT", "15"))
MainSpecRight$ = TextC$("INIT", MainSpecCommon$ +_
        NewTag$("LEFT", "327") )
'--- Toolbar ---
MainToolRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "10") +_
        NewTag$("TOP", "250") +_
        NewTag$("LENGTH", "620") +_
        NewTag$("FORM", "ridge"))
MainToolimageCommon$ =_
        NewTag$("CLEARCOLOR", "0") +_
        NewTag$("LEFT", "6") +_
        NewTag$("TOP", "6")
MainExitImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "Exit32px.png"))
MainSettingsImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "Settings32px.png"))
MainInfoImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "Info32px.png"))
MainPlayImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "StartPlay32px.png"))
MainStopImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "StopPlay32px.png"))
MainRecentImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "Recent32px.png"))
MainPreviousImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "GoPrev32px.png"))
MainNextImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "GoNext32px.png"))
MainEditImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "Edit32px.png"))
MainToolbuttonCommon$ =_
        NewTag$("TOP", "261") +_
        NewTag$("WIDTH", "44") +_
        NewTag$("HEIGHT", "44") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "Marble.jpg")
MainExitButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "15") +_
        NewTag$("TOOLTIP", "Exit program") +_
        ImageTag$(MainExitImage$))
MainSettingsButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "65") +_
        NewTag$("TOOLTIP", "Settings") +_
        ImageTag$(MainSettingsImage$))
MainInfoButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "115") +_
        NewTag$("TOOLTIP", "Server info") +_
        NewTag$("DISABLED", "true") +_
        ImageTag$(MainInfoImage$))
MainPlayButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "195") +_
        NewTag$("TOOLTIP", "Start playing") +_
        ImageTag$(MainPlayImage$))
MainStopButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "245") +_
        NewTag$("TOOLTIP", "Stop playing") +_
        NewTag$("DISABLED", "true") +_
        ImageTag$(MainStopImage$))
MainRecentButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "295") +_
        NewTag$("TOOLTIP", "Recent titles") +_
        ImageTag$(MainRecentImage$))
MainVolumeSlider$ = SliderC$("INIT",_
        NewTag$("LEFT", "345") +_
        NewTag$("TOP", "261") +_
        NewTag$("WIDTH", "130") +_
        NewTag$("HEIGHT", "25") +_
        NewTag$("MINIMUM", "0") +_
        NewTag$("MAXIMUM", "100") +_
        NewTag$("LEVEL", LTRIM$(STR$(opts.volStart))) +_
        NewTag$("NOSHOW", "true") +_
        NewTag$("LABEL", "Volume") +_
        NewTag$("LABELPLACE", "below") +_
        NewTag$("AREA", "true") +_
        NewTag$("IMAGEFILE", "Marble.jpg"))
MainPreviousButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "481") +_
        NewTag$("TOOLTIP", "Previous Station") +_
        ImageTag$(MainPreviousImage$))
MainNextButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "531") +_
        NewTag$("TOOLTIP", "Next Station") +_
        ImageTag$(MainNextImage$))
MainEditButton$ = ButtonC$("INIT", MainToolbuttonCommon$ +_
        NewTag$("LEFT", "581") +_
        NewTag$("TOOLTIP", "List/Edit Stations") +_
        ImageTag$(MainEditImage$))
'~~~~~

'-----------------------
'--- Runtime Globals ---
'-----------------------
'--- Here we can define the remaining global variables, which are not
'--- needed for object initialization, but during runtime.
'-----
init% = -1 'init state indicator (handler control, don't touch)
done% = 0 'main loop (ie. program) keeps running until this is set true
'-----
DIM decInfo AS mp3_decoder_info, pcm AS _MEM 'decoder info data
REDIM lSig#(2048, 100), rSig#(2048, 100) 'rFFT input
REDIM FFTr#(2048), FFTi#(2048) 'rFFT output
eol$ = CHR$(13) + CHR$(10) 'http headers & parsing
nowPlaying% = 0 'current playing state

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
    mess$ = GetGUIMsg$(0)
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
    '-----
    'The next two handlers are independend from any GUI events.
    '-----
    '$INCLUDE: 'handlers\initdone.bm'
    '$INCLUDE: 'handlers\permanent.bm'
    '---------------- END OF EVENT HANDLER ----------------
    init% = 0
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
togglePlayingState:
nowPlaying% = NOT nowPlaying%
ok$ = GenC$("SET", MainPlayButton$ + NewTag$("DISABLED", LTRIM$(STR$(nowPlaying%))))
ok$ = GenC$("SET", MainStopButton$ + NewTag$("DISABLED", LTRIM$(STR$(NOT nowPlaying%))))
temp$ = GetObjTagData$(MainStationText$, "TEXT", ""): deli% = INSTR(temp$, " - - - - - ")
IF deli% > 0 THEN temp$ = LEFT$(temp$, deli% - 1)
IF NOT nowPlaying% THEN
    ok$ = GenC$("SET", MainInfoButton$ + NewTag$("DISABLED", "true"))
    IF InfoView& > 0 THEN
        ok$ = GenC$("SET", InfoNameText$ + NewTag$("TEXT", ""))
        ok$ = GenC$("SET", InfoUrlText$ + NewTag$("TEXT", ""))
        ok$ = GenC$("SET", InfoGenreText$ + NewTag$("TEXT", ""))
        ok$ = GenC$("SET", InfoDescriptionText$ + NewTag$("TEXT", ""))
        ok$ = GenC$("SET", InfoRedirectsText$ + NewTag$("TEXT", ""))
        ok$ = GenC$("SET", InfoCopyButton$ + NewTag$("DISABLED", "true"))
        ok$ = GenC$("SET", InfoOpenButton$ + NewTag$("DISABLED", "true"))
    END IF
    AddMarkRecent "playback stopped - " + temp$
ELSE
    AddMarkRecent "-----"
    AddMarkRecent "playback started - " + temp$
END IF
RETURN

updateInfoView:
lo% = INSTR(LCASE$(response$), "icy-name:"): icy$ = ""
IF lo% > 0 THEN el% = INSTR(lo%, response$, eol$)
IF lo% > 0 AND el% > 0 THEN icy$ = LTRIM$(RTRIM$(MID$(response$, lo% + 9, el% - (lo% + 9))))
IF icy$ = "" THEN icy$ = "--- not available ---"
ok$ = GenC$("SET", InfoNameText$ + NewTag$("TEXT", icy$))
lo% = INSTR(LCASE$(response$), "icy-url:"): icy$ = ""
IF lo% > 0 THEN el% = INSTR(lo%, response$, eol$)
IF lo% > 0 AND el% > 0 THEN icy$ = LTRIM$(RTRIM$(MID$(response$, lo% + 8, el% - (lo% + 8))))
IF icy$ = "" THEN
    icy$ = "--- not available ---"
    ok$ = GenC$("SET", InfoCopyButton$ + NewTag$("DISABLED", "true"))
    ok$ = GenC$("SET", InfoOpenButton$ + NewTag$("DISABLED", "true"))
ELSE
    ok$ = GenC$("SET", InfoCopyButton$ + NewTag$("DISABLED", "false"))
    ok$ = GenC$("SET", InfoOpenButton$ + NewTag$("DISABLED", "false"))
END IF
ok$ = GenC$("SET", InfoUrlText$ + NewTag$("TEXT", icy$))
lo% = INSTR(LCASE$(response$), "icy-genre:"): icy$ = ""
IF lo% > 0 THEN el% = INSTR(lo%, response$, eol$)
IF lo% > 0 AND el% > 0 THEN icy$ = LTRIM$(RTRIM$(MID$(response$, lo% + 10, el% - (lo% + 10))))
IF icy$ = "" THEN icy$ = "--- not available ---"
ok$ = GenC$("SET", InfoGenreText$ + NewTag$("TEXT", icy$))
lo% = INSTR(LCASE$(response$), "icy-description:"): icy$ = ""
IF lo% > 0 THEN el% = INSTR(lo%, response$, eol$)
IF lo% > 0 AND el% > 0 THEN icy$ = LTRIM$(RTRIM$(MID$(response$, lo% + 16, el% - (lo% + 16))))
IF icy$ = "" THEN icy$ = "--- not available ---"
ok$ = GenC$("SET", InfoDescriptionText$ + NewTag$("TEXT", icy$))
ok$ = GenC$("SET", InfoRedirectsText$ + NewTag$("TEXT", LTRIM$(STR$(redirects%))))
RETURN

saveRecent:
result$ = MessageBox$("", appExeName$,_
                      "You've marked titles in the recent list.|" +_
                      "Do you wanna save the list before exit?",_
                      "{SYM Checkmark * * * *}Yes||{SYM Cross * * * *}No")
IF result$ = "Yes" THEN
    saveRecentDirect:
    rtlFile$ = FileSelect$("", "Choose a filename to save...", fsmSAVE%, _DIR$("Documents"), "INR-RecentTitles.txt")
    IF LEN(rtlFile$) > 0 THEN
        ext$ = LCASE$(FileExtension$(rtlFile$))
        IF ext$ = "" THEN rtlFile$ = rtlFile$ + ".txt"
        IF _FILEEXISTS(rtlFile$) THEN
            result$ = MessageBox$("", appExeName$,_
                                  "File already exists, overwrite?",_
                                  "{SYM Checkmark * * * *}Yes||{SYM Cross * * * *}No")
            IF result$ = "No" GOTO saveRecentDirect
        END IF
        BufToFile RecentFile%, rtlFile$
    END IF
END IF
RETURN

startPlay:
'--- prepare args ---
IF LEFT$(LCASE$(streamUrl$), 8) = "https://" THEN
    IF NOT opts.chgQuiet THEN
        ok$ = MessageBox$("", appExeName$,_
                "This Station uses https:// connections, which is not supported.|" +_
                "It is now changed to use a http:// connection instead. However,|" +_
                "if it fails, then this Station is unusable and can be deleted.",_
                "{IMG Error16px.png 0}Ok, got it...|{IMG Cancel16px.png 0}Ok, don't show again...")
        IF ok$ = "Ok, don't show again..." THEN
            opts.chgQuiet = -1
            IF SettingsView& > 0 THEN ok$ = GenC$("SET", SettingsNoWarningCheckbox$ + NewTag$("CHECKED", "true"))
        END IF
    END IF
    streamUrl$ = "http://" + MID$(streamUrl$, 9)
END IF
IF LEFT$(LCASE$(streamUrl$), 7) = "http://" THEN streamUrl$ = MID$(streamUrl$, 8)
sl% = INSTR(streamUrl$, "/")
host$ = LEFT$(streamUrl$, sl% - 1)
file$ = MID$(streamUrl$, sl%)
'--- open client ---
stream& = _OPENCLIENT("TCP/IP:80:" + host$)
IF stream& = 0 THEN
    ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "press play to listen..."))
    ok$ = MessageBox$("", appExeName$,_
            "Sorry, no connection could be|established to that Station.|" +_
            "- Make sure you are online.",_
            "{IMG Error16px.png 0}Ok, got it...")
    RETURN
END IF
'--- send request ---
request$ = "GET " + file$ + " HTTP/1.0" + eol$ '1.0 to avoid "chunked" transfer
request$ = request$ + "Host: " + host$ + eol$
request$ = request$ + "User-Agent: INetRadio/1.4 (QB64-PE; GuiTools Framework;)" + eol$
request$ = request$ + "Accept: audio/mpeg" + eol$
request$ = request$ + "Accept-Charset: utf-8" + eol$
request$ = request$ + "Icy-MetaData: 1" + eol$ 'https://stackoverflow.com/questions/44050266/get-info-from-streaming-radio
request$ = request$ + eol$
PUT stream&, , request$
'--- reset state variables ---
streamData$ = "": received$ = "": response$ = "": mime$ = ""
decoding% = 0: rawAhead# = 0.3: sig$ = "": sig% = 0
metainterval& = 0: metaDelay% = 0: oldFeeds$ = ""
fadeDelay% = 0: fadeOut% = 0: fadeIn% = 0: oldLevel% = 0
ok$ = TextC$("SET", MainSpecLeft$ + NewTag$("TEXT", "buffering..."))
ok$ = TextC$("SET", MainSpecRight$ + NewTag$("TEXT", LTRIM$(STR$(LEN(streamData$))) + " / " + LTRIM$(STR$(opts.bufSize * 1024)) + " bytes"))
opss& = SetThreadExecutionState&(&H80000003) 'disable power saving options
RETURN

streamPlay:
'--- wait for response ---
GET stream&, , incomming$
received$ = received$ + incomming$
IF LEN(received$) < 12 AND LEN(response$) = 0 THEN
    RETURN
ELSEIF MID$(received$, 10, 3) <> "404" AND MID$(received$, 10, 3) <> "302" AND _
       MID$(received$, 10, 3) <> "301" AND MID$(received$, 10, 3) <> "200" AND LEN(response$) = 0 THEN
    er% = INSTR(received$, eol$ + eol$)
    IF er% > 0 THEN
        _WRITEFILE "INR-SvrRes.txt", LEFT$(received$, er% + 3)
        GOSUB togglePlayingState: GOSUB stopPlay
        ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "press play to listen..."))
        ok$ = MessageBox$("", appExeName$,_
                "Sorry, got a Server response which INetRadio can't handle.|" +_
                "- See logfile INR-SvrRes.txt for response details.",_
                "{IMG Error16px.png 0}Ok, got it...")
    END IF
    RETURN
ELSEIF MID$(received$, 10, 3) = "404" AND LEN(response$) = 0 THEN
    GOSUB togglePlayingState: GOSUB stopPlay
    ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "press play to listen..."))
    ok$ = MessageBox$("", appExeName$,_
            "Sorry, that Station was not found (404).|" +_
            "- Delete it and try re-importing it.",_
            "{IMG Error16px.png 0}Ok, got it...")
    RETURN
ELSEIF (MID$(received$, 10, 3) = "302" OR MID$(received$, 10, 3) = "301") AND LEN(response$) = 0 THEN
    lo% = INSTR(LCASE$(received$), "location:")
    IF lo% > 0 THEN el% = INSTR(lo%, received$, eol$)
    IF lo% > 0 AND el% > 0 THEN
        streamUrl$ = LTRIM$(RTRIM$(MID$(received$, lo% + 9, el% - (lo% + 9))))
        GOSUB stopPlay: _DELAY 0.1: GOSUB startPlay: IF stream& = 0 THEN GOSUB togglePlayingState: RETURN
        redirects% = redirects% + 1
    END IF
ELSEIF MID$(received$, 10, 3) = "200" AND LEN(response$) = 0 THEN
    ct% = INSTR(LCASE$(received$), "content-type:")
    IF ct% > 0 THEN
        et% = INSTR(ct%, received$, eol$)
        IF et% > 0 THEN mime$ = LCASE$(LTRIM$(RTRIM$(MID$(received$, ct% + 13, et% - ct% - 13))))
        IF INSTR("audio/mpeg", mime$) = 0 THEN
            GOSUB togglePlayingState: GOSUB stopPlay
            ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "press play to listen..."))
            ok$ = MessageBox$("", appExeName$,_
                    "Sorry, that Station is using an unsupported audio format.|" +_
                    "- If the Station offers multiple stream formats, then|" +_
                    "  take Mp3, if available.",_
                    "{IMG Error16px.png 0}Ok, got it...")
            RETURN
        END IF
    END IF
    mi% = INSTR(LCASE$(received$), "icy-metaint:") 'https://stackoverflow.com/questions/44050266/get-info-from-streaming-radio
    IF mi% > 0 THEN metainterval& = VAL(MID$(received$, mi% + 12))
    er% = INSTR(received$, eol$ + eol$)
    IF er% > 0 THEN
        response$ = LEFT$(received$, er% + 3)
        _WRITEFILE appTempDir$ + svrresName$, response$
        ok$ = GenC$("SET", MainInfoButton$ + NewTag$("DISABLED", "false"))
        GOSUB updateInfoView
        received$ = MID$(received$, er% + 4)
        IF metainterval& = 0 THEN
            ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "--- not available ---"))
        END IF
    END IF
ELSEIF LEN(response$) > 0 THEN
    IF decoding% = 0 AND LEN(streamData$) < (opts.bufSize * 1024) THEN
        ok$ = TextC$("SET", MainSpecRight$ + NewTag$("TEXT", LTRIM$(STR$(LEN(streamData$))) + " / " + LTRIM$(STR$(opts.bufSize * 1024)) + " bytes"))
    ELSEIF decoding% = 0 AND LEN(streamData$) >= (opts.bufSize * 1024) THEN
        IF mp3_decoder_init% THEN decoding% = -1: ELSE ERROR 7
        ok$ = TextC$("SET", MainSpecLeft$ + NewTag$("TEXT", ""))
        ok$ = TextC$("SET", MainSpecRight$ + NewTag$("TEXT", ""))
        dbBT# = TIMER(0.001): dbST# = 0: dbDT# = TIMER(0.001)
    ELSEIF decoding% THEN
        IF _SNDRAWLEN = 0 AND LEN(streamData$) < 5230 THEN 'stalled ?
            IF opts.autoRetry THEN 'retry ?
                GOSUB stopPlay: _DELAY 0.1: GOSUB startPlay: IF stream& = 0 THEN GOSUB togglePlayingState: RETURN
            ELSE
                GOSUB togglePlayingState: GOSUB stopPlay
                ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "Stream has stalled, press play to restart. If it happens frequently, then try raising the buffer size."))
                RETURN
            END IF
        ELSE
            dbRT# = TIMER(0.001) - dbBT#
            IF dbRT# < 0 THEN dbRT# = dbRT# + 86400 'midnight fix
            IF dbRT# >= dbST# + 0.1 THEN 'out of sync? (4+ frames behind)
                dbBT# = TIMER(0.001): dbST# = 0: dbDT# = TIMER(0.001)
            END IF
        END IF
    END IF
    IF metainterval& > 0 THEN
        'https://stackoverflow.com/questions/44050266/get-info-from-streaming-radio
        IF LEN(received$) < metainterval& + 4081 THEN RETURN
        soundData$ = LEFT$(received$, metainterval&): streamData$ = streamData$ + soundData$
        received$ = MID$(received$, metainterval& + 1)
        metalength% = ASC(received$, 1) * 16 + 1
        IF metalength% > 1 THEN
            feeds$ = LEFT$(received$, metalength%)
            st% = INSTR(LCASE$(feeds$), "streamtitle='") + 13
            ste% = INSTR(st%, feeds$, "';")
            feeds$ = MID$(feeds$, st%, ste% - st%)
            IF _UPRINTWIDTH(feeds$, 8) = 0 THEN feeds$ = AnsiTextToUtf8Text$(feeds$, "Win1252")
            IF LEN(advertTxt$) > 0 THEN
                adver$ = AnsiTextToUtf8Text$(advertTxt$, "")
                IF INSTR(feeds$, adver$) > 0 AND INSTR(oldFeeds$, adver$) = 0 THEN
                    IF LEN(oldFeeds$) > 0 THEN fadeDelay% = VAL(metaDelay$) - 10
                    fadeOut% = 25
                ELSEIF INSTR(feeds$, adver$) = 0 AND INSTR(oldFeeds$, adver$) > 0 THEN
                    fadeDelay% = VAL(metaDelay$) + 10: fadeIn% = 25
                END IF
            END IF
            IF LEN(oldFeeds$) > 0 THEN
                IF metaDelay% <= 0 OR fadeIn% > 0 THEN metaDelay% = VAL(metaDelay$): fcBT# = TIMER(0.001): fcET# = 0
            ELSE
                IF LEN(advertTxt$) = 0 _ORELSE INSTR(feeds$, adver$) = 0 THEN AddMarkRecent feeds$
                IF opts.scrFeeds THEN
                    WHILE _UPRINTWIDTH(feeds$, 8) < 400: feeds$ = feeds$ + " - - - - - " + feeds$: WEND
                END IF
                ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", feeds$))
            END IF
            oldFeeds$ = feeds$
        END IF
        received$ = MID$(received$, metalength% + 1): RETURN
    END IF
    streamData$ = streamData$ + received$: received$ = ""
END IF
RETURN
mp3decode:
WHILE _SNDRAWLEN < (0.2 + rawAhead#) AND LEN(streamData$) > 5230
    IF mp3_decoder_loop%(streamData$, LEN(streamData$), -1, _OFFSET(decInfo)) THEN
        streamData$ = MID$(streamData$, decInfo.fit.frame_bytes + 1)
        IF decInfo.pcm_frames > 0 THEN
            volu! = VAL(GetObjTagData$(MainVolumeSlider$, "LEVEL", "67")) / 100
            sig$ = sig$ + MKD$(dbST#) + CHR$(sig%)
            sig% = sig% + 1: IF sig% = 100 THEN sig% = 0
            dbST# = dbST# + (decInfo.pcm_frames / _SNDRATE)
            'make sure we only pass a power of 2 to the FFT algorithm
            'by leaving out every n-th sample
            pow% = 2 ^ INT(LOG(decInfo.pcm_frames) / LOG(2))
            dif% = decInfo.pcm_frames - pow%: fft% = 0
            nth% = INT(decInfo.pcm_frames / dif%) + 1
            '-----
            pcm = _MEM(decInfo.pcm_out, PCM_OUT_SIZE): pcmOff%& = pcm.OFFSET
            FOR i% = 0 TO decInfo.pcm_frames - 1
                lsv# = _MEMGET(pcm, pcmOff%&, SINGLE)
                pcmOff%& = pcmOff%& + 4
                IF decInfo.fit.channels = 2 THEN
                    rsv# = _MEMGET(pcm, pcmOff%&, SINGLE)
                    pcmOff%& = pcmOff%& + 4
                ELSE
                    rsv# = lsv# 'right = left signal for mono
                END IF
                '-----
                IF (i% MOD nth%) > 0 THEN
                    lSig#(fft%, sig%) = lsv# 'fill FFT signal array with
                    rSig#(fft%, sig%) = rsv# 'original signal levels
                    IF fft% < pow% THEN fft% = fft% + 1 'stop at calculated power
                END IF
                '-----
                lsv# = lsv# * volu!: rsv# = rsv# * volu! 'apply volume factor
                IF ABS(lsv#) > 1 THEN lsv# = SGN(lsv#) 'clip out of range peaks
                IF ABS(rsv#) > 1 THEN rsv# = SGN(rsv#) 'before sending to soundcard
                _SNDRAW lsv#, rsv#
            NEXT i%
            _MEMFREE pcm
        END IF
    END IF
WEND
RETURN

stopPlay:
IF decoding% THEN mp3_decoder_free: decoding% = 0
CLOSE stream&: stream& = 0
ok$ = TextC$("SET", MainSpecLeft$ + NewTag$("TEXT", ""))
ok$ = TextC$("SET", MainSpecRight$ + NewTag$("TEXT", ""))
ok& = SetThreadExecutionState&(opss&) 'restore power saving options
RETURN

feedsControl:
fcRT# = TIMER(0.001) - fcBT#
IF fcRT# < 0 THEN fcRT# = fcRT# + 86400 'midnight fix
IF fcRT# >= 0.1# THEN 'keep fading logic low on 10 FPS
    fcBT# = TIMER(0.001): fcET# = fcET# + (fcRT# - 0.1#)
    IF metaDelay% > 0 THEN
        metaDelay% = metaDelay% - 1
        IF fcET# >= 0.1# THEN metaDelay% = metaDelay% - 1
        IF metaDelay% <= 0 THEN
            IF LEN(advertTxt$) = 0 _ORELSE INSTR(feeds$, adver$) = 0 THEN AddMarkRecent feeds$
            IF opts.scrFeeds THEN
                WHILE _UPRINTWIDTH(feeds$, 8) < 400: feeds$ = feeds$ + " - - - - - " + feeds$: WEND
            END IF
            ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", feeds$))
        END IF
    END IF
    IF fadeDelay% > 0 THEN
        fadeDelay% = fadeDelay% - 1
        IF fcET# >= 0.1# THEN fadeDelay% = fadeDelay% - 1
    ELSEIF fadeOut% > 0 THEN
        IF oldLevel% = 0 THEN
            oldLevel% = VAL(GetObjTagData$(MainVolumeSlider$, "LEVEL", "67"))
            fadeLevel! = oldLevel% / 100: fadeStep! = fadeLevel! / fadeOut%
        END IF
        fadeLevel! = fadeLevel! - fadeStep!: fadeOut% = fadeOut% - 1
        IF fcET# >= 0.1# THEN fadeLevel! = fadeLevel! - fadeStep!: fadeOut% = fadeOut% - 1
        IF fadeLevel! < 0 THEN fadeLevel! = 0
        ok$ = GenC$("SET", MainVolumeSlider$ + NewTag$("LEVEL", LTRIM$(STR$(CINT(fadeLevel! * 100)))))
    ELSEIF fadeIn% > 0 THEN
        IF oldLevel% > 0 THEN
            fadeLevel! = 0: fadeStep! = (oldLevel% / 100) / fadeIn%
            oldLevel% = -oldLevel%
        END IF
        fadeLevel! = fadeLevel! + fadeStep!: fadeIn% = fadeIn% - 1
        IF fcET# >= 0.1# THEN fadeLevel! = fadeLevel! + fadeStep!: fadeIn% = fadeIn% - 1
        IF fadeLevel! > (-oldLevel% / 100) THEN fadeLevel! = (-oldLevel% / 100)
        ok$ = GenC$("SET", MainVolumeSlider$ + NewTag$("LEVEL", LTRIM$(STR$(CINT(fadeLevel! * 100)))))
    ELSEIF oldLevel% < 0 THEN
        oldLevel% = 0
    END IF
    IF fcET# >= 0.1# THEN fcET# = fcET# - 0.1#
END IF
RETURN

drawBars:
dbRT# = TIMER(0.001) - dbDT#
IF dbRT# < 0 THEN dbRT# = dbRT# + 86400 'midnight fix
IF dbRT# < 0.05 THEN RETURN
dbDT# = TIMER(0.001)
'-----
dbRT# = TIMER(0.001) - dbBT#
IF dbRT# < 0 THEN dbRT# = dbRT# + 86400 'midnight fix
WHILE dbRT# >= CVD(LEFT$(sig$, 8))
    sig$ = MID$(sig$, 10): IF LEN(sig$) = 0 THEN RETURN
WEND
_DISPLAY
'-----
tto& = VAL(GetTagData$(guiATTProps$, "OBJECT", "0"))
ttv& = VAL(GetTagData$(guiATTProps$, "GUIVIEW", "0")) 
IF tto& > 0 AND ttv& = 0 THEN PrintObjectTooltip 0
'-----
ok$ = TextC$("DRAW", MainSpecLeft$)
VinceRFFT FFTr#(), FFTi#(), lSig#(), ASC(sig$, 9), fft%
oh% = 54: x% = 22: y% = 235
RESTORE barRanges
FOR bar% = 0 TO 31
    READ n1%, n2%
    xp% = ((31 - bar%) * 9) + x%
    yp% = (GetMax#(FFTr#(), FFTi#(), n1%, n2%) / 128) * oh%
    IF yp% > oh% THEN yp% = y% - oh%: ELSE yp% = y% - yp%
    LINE (xp%, y%)-(xp% + 4, yp%), 184 + bar%, BF
NEXT bar%
'-----
ok$ = TextC$("DRAW", MainSpecRight$)
VinceRFFT FFTr#(), FFTi#(), rSig#(), ASC(sig$, 9), fft%
oh% = 54: x% = 334: y% = 235
RESTORE barRanges
FOR bar% = 0 TO 31
    READ n1%, n2%
    xp% = (bar% * 9) + x%
    yp% = (GetMax#(FFTr#(), FFTi#(), n1%, n2%) / 128) * oh%
    IF yp% > oh% THEN yp% = y% - oh%: ELSE yp% = y% - yp%
    LINE (xp%, y%)-(xp% + 4, yp%), 184 + bar%, BF
NEXT bar%
'-----
IF tto& > 0 AND ttv& = 0 THEN PrintObjectTooltip tto&
'-----
_AUTODISPLAY
sig$ = MID$(sig$, 10)
RETURN
barRanges:
'8 bars taking 1 slot each (47-376Hz)
DATA 1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8
'8 bars taking 2 slots each (423-1128Hz)
DATA 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
'4 bars taking 4 slots each (1175-1880Hz)
DATA 25,28,29,32,33,36,37,40
'4 bars taking 8 slots each (1927-3384Hz)
DATA 41,48,49,56,57,64,65,72
'2 bars taking 16 slots each (3431-4888Hz)
DATA 73,88,89,104
'2 bars taking 32 slots each (4935-7896Hz)
DATA 105,136,137,168
'2 bars taking 64 slots each (7943-13912Hz)
DATA 169,232,233,296
'1 bar taking 128 slots (13959-19928Hz)
DATA 297,424
'1 bar takes the remaining 87 slots (19975-24000Hz) = inaudible
DATA 425,511
'~~~~~
'---------------------------------------------------------------------
'~~~ My SUBs/FUNCs
'=====================================================================
'Next is a simple help function for debugging. If any method call seems
'not to give you the expected results, then you can enclose the call with
'this function. If the method call will return any errors or warnings,
'then these will be shown to you in a MessageBox. If no errors/warnings
'are returned, then it will simply put through the method call's result.
'You may also specify a description to better identify multiple checks.
'  USAGE:  result$ = ShowErr$("desc", AnyClassC$("ANYMETHOD", methodTags$))
'You should remove this function again, after all bugs are fixed and your
'method calls do work properly without errors/warnings, or at least set
'the CONST ShowErrSwitch$ right below to "OFF".
'=====================================================================
CONST ShowErrSwitch$ = "ON" 'ON or OFF
'-----
FUNCTION ShowErr$ (desc$, tagString$)
IF desc$ = "" THEN iDesc$ = "": ELSE iDesc$ = desc$ + "|"
ShowErr$ = tagString$
IF UCASE$(ShowErrSwitch$) = "ON" THEN
    IF ValidateTags%(tagString$, "ERROR", -1) THEN
        dummy$ = MessageBox$("Error16px.png", "Error Tag", iDesc$ +_
                             GetTagData$(tagString$, "ERROR", "empty"),_
                             "{IMG Error16px.png 0}Ok, got it...")
    ELSEIF ValidateTags%(tagString$, "WARNING", -1) THEN
        dummy$ = MessageBox$("Problem16px.png", "Warning Tag", iDesc$ +_
                             GetTagData$(tagString$, "WARNING", "empty"),_
                             "{IMG Problem16px.png 0}Ok, got it...")
    END IF
END IF
END FUNCTION
'-----
SUB AddMarkRecent (entry$)
SHARED RecentFile%, RecentMarked%, RecentList$
STATIC amrFirstCallDone%
nul& = SeekBuf&(RecentFile%, 0, SBM_BufStart)
IF entry$ = "*****" AND GetBufLen&(RecentFile%) >= 9 THEN
    tmp$ = ReadBufRawData$(RecentFile%, 7)
    nul& = SeekBuf&(RecentFile%, 6, SBM_BufStart)
    IF ASC(tmp$, 7) = 226 THEN
        DeleteBufRawData RecentFile%, 3: WriteBufRawData RecentFile%, ">"
        RecentMarked% = RecentMarked% + 1
    ELSE
        DeleteBufRawData RecentFile%, 1: WriteBufRawData RecentFile%, AnsiTextToUtf8Text$(CHR$(179), "Pc437")
        IF RecentMarked% > 0 THEN RecentMarked% = RecentMarked% - 1
    END IF
ELSEIF entry$ = "-----" THEN
    WriteBufLine RecentFile%, AnsiTextToUtf8Text$(MKI$(&HFFFF) + STRING$(32, 196), "Pc437")
ELSEIF entry$ <> "*****" AND entry$ <> "-----" THEN
    WriteBufLine RecentFile%, AnsiTextToUtf8Text$(LEFT$(TIME$, 5) + " " + CHR$(179) + " " + entry$, "Pc437")
END IF
nul& = SeekBuf&(RecentFile%, 0, SBM_BufStart)
IF entry$ = "*****" THEN ok$ = ListC$("DELETE", RecentList$ + NewTag$("ACTUAL", "1"))
ok$ = ListC$("STORE", RecentList$ + NewTag$("DATA", ReadBufLine$(RecentFile%)))
IF NOT amrFirstCallDone% THEN
    ok$ = ListC$("DELETE", RecentList$ + NewTag$("ACTUAL", "-1"))
    IF NOT ValidateTags%(ok$, "ERROR", -1) THEN amrFirstCallDone% = -1
END IF
END SUB
'-----
FUNCTION GetMax# (xx_r#(), xx_i#(), n1%, n2%)
res# = 0.0
FOR i% = n1% TO n2%
    cur# = SQR((xx_r#(i%) * xx_r#(i%)) + (xx_i#(i%) * xx_i#(i%)))
    IF cur# > res# THEN res# = cur#
NEXT i%
GetMax# = res#
END FUNCTION
'-----
'--- Real signal FFT by _vince (changed to use type suffixes)
'--- https://qb64forum.alephc.xyz/index.php?topic=1938.msg111661#msg111661
'---------------------------------------------------------------------
SUB VinceRFFT (xx_r#(), xx_i#(), x_r#(), c%, n%)
DIM w_r#, w_i#, wm_r#, wm_i#, u_r#, u_i#, v_r#, v_i#
DIM pi#, xpr#, xpi#, xmr#, xmi#
DIM log2n%, rev%, i%, j%, k%, m%, p%, q%
pi# = 3.141592653589793
log2n% = LOG(n% / 2) / LOG(2)
FOR i% = 0 TO n% / 2 - 1
    rev% = 0
    FOR j% = 0 TO log2n% - 1
        IF i% AND (2 ^ j%) THEN rev% = rev% + (2 ^ (log2n% - 1 - j%))
    NEXT
    xx_r#(i%) = x_r#(2 * rev%, c%)
    xx_i#(i%) = x_r#(2 * rev% + 1, c%)
NEXT
FOR i% = 1 TO log2n%
    m% = 2 ^ i%
    wm_r# = COS(-2 * pi# / m%)
    wm_i# = SIN(-2 * pi# / m%)
    FOR j% = 0 TO n% / 2 - 1 STEP m%
        w_r# = 1
        w_i# = 0
        FOR k% = 0 TO m% / 2 - 1
            p% = j% + k%
            q% = p% + (m% \ 2)
            u_r# = w_r# * xx_r#(q%) - w_i# * xx_i#(q%)
            u_i# = w_r# * xx_i#(q%) + w_i# * xx_r#(q%)
            v_r# = xx_r#(p%)
            v_i# = xx_i#(p%)
            xx_r#(p%) = v_r# + u_r#
            xx_i#(p%) = v_i# + u_i#
            xx_r#(q%) = v_r# - u_r#
            xx_i#(q%) = v_i# - u_i#
            u_r# = w_r#
            u_i# = w_i#
            w_r# = u_r# * wm_r# - u_i# * wm_i#
            w_i# = u_r# * wm_i# + u_i# * wm_r#
        NEXT
    NEXT
NEXT
xx_r#(n% / 2) = xx_r#(0)
xx_i#(n% / 2) = xx_i#(0)
FOR i% = 1 TO n% / 2 - 1
    xx_r#(n% / 2 + i%) = xx_r#(n% / 2 - i%)
    xx_i#(n% / 2 + i%) = xx_i#(n% / 2 - i%)
NEXT
FOR i% = 0 TO n% / 2 - 1
    xpr# = (xx_r#(i%) + xx_r#(n% / 2 + i%)) / 2
    xpi# = (xx_i#(i%) + xx_i#(n% / 2 + i%)) / 2
    xmr# = (xx_r#(i%) - xx_r#(n% / 2 + i%)) / 2
    xmi# = (xx_i#(i%) - xx_i#(n% / 2 + i%)) / 2
    xx_r#(i%) = xpr# + xpi# * COS(2 * pi# * i% / n%) - xmr# * SIN(2 * pi# * i% / n%)
    xx_i#(i%) = xmi# - xpi# * SIN(2 * pi# * i% / n%) - xmr# * COS(2 * pi# * i% / n%)
NEXT
'symmetry, complex conj
FOR i% = 0 TO n% / 2 - 1
    xx_r#(n% / 2 + i%) = xx_r#(n% / 2 - 1 - i%)
    xx_i#(n% / 2 + i%) = -xx_i#(n% / 2 - 1 - i%)
NEXT
END SUB
'--- Function to define/return the program's version string.
'-----
FUNCTION VersionINetRadio$
VersionINetRadio$ = MID$("$VER: INetRadio 1.4 (12-Sep-2026) by RhoSigma :END$", 7, 39)
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
appFont& = _LOADFONT(SearchFile$(appHomePath$, "", "arialuni.ttf"), 18)
IF appFont& > 0 THEN _FONT appFont&: ELSE _FONT 16
'--- set default icon ---
'uncomment and adjust the _LOADIMAGE line below to load a specific icon,
'otherwise the GuiTools Framework's default icon is used as embedded via
'the GuiAppIcon.h/.bm files located in the dev_framework folder
'newIcon& = _LOADIMAGE(SearchFile$(appHomePath$, "", "radio.png"), 32)
IF newIcon& < -1 THEN appIcon& = newIcon& 'on success override default with new one
'IF appIcon& < -1 THEN _ICON appIcon&
'if you rather use $EXEICON then comment out the IF appIcon& ... line above
'and uncomment and adjust the $EXEICON line below as you need instead, but
'note it's QB64 v1.1+ then, older versions will throw an error on $EXEICON
$EXEICON:'.\INR-Assets\radio.ico'
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
IF appGLVComp% THEN _DELAY 0.05: WindowToTop ("Untitled" + CHR$(0))
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
IF appScreen& < -1 THEN _FREEIMAGE appScreen&: appScreen& = 0
END SUB
'~~~~~

'*****************************************************
'$INCLUDE: 'QB64GuiTools\dev_framework\GuiAppFrame.bm'
'*****************************************************

'$INCLUDE: 'QB64GuiTools\dev_framework\support\BufferSupport.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\support\CharsetSupport.bm'
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
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\TextClassUTF8.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ProgressClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\PagerClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ButtonClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\CheckboxClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\CycleClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\RadioClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ListviewClassUTF8.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\SliderClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ScrollerClass.bm'
'$INCLUDE: 'QB64GuiTools\dev_framework\classes\ColorwheelClass.bm'

'$INCLUDE: 'inline\Info16Img.bm'
'$INCLUDE: 'inline\Info32Img.bm'
'$INCLUDE: 'inline\Problem16Img.bm'
'$INCLUDE: 'inline\Problem32Img.bm'
'$INCLUDE: 'inline\Error16Img.bm'
'$INCLUDE: 'inline\Error32Img.bm'

'$INCLUDE: 'inline\Add16Img.bm'
'$INCLUDE: 'inline\Cancel16Img.bm'
'$INCLUDE: 'inline\Import16Img.bm'
'$INCLUDE: 'inline\BackImg.bm'
'$INCLUDE: 'inline\MarbleImg.bm'
'$INCLUDE: 'inline\TissueImg.bm'
'$INCLUDE: 'inline\OptionsBin.bm'
'$INCLUDE: 'inline\StationsTxt.bm'

