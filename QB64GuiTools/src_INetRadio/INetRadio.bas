$IF VERSION < 3.12.0 THEN
    $ERROR 'This program requires at least QB64-PE v3.12.0 to compile.'
$END IF

'-----------------------------------------------------------
$VERSIONINFO:FILEVERSION#=1,1,0,0
$VERSIONINFO:FileDescription='A neat small Web-Radio player'
$VERSIONINFO:LegalCopyright='MIT License'
'-----------------------------------------------------------

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
'| == A small neat Web-Radio player. Listen to your favorite Radio   |
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
'--- defaults for 1st start ---
IF NOT _FILEEXISTS(appLocalDir$ + "INR-Options.bin") THEN
    ok$ = WriteOptionsBinArray$(appLocalDir$ + "INR-Options.bin", 0)
END IF
IF NOT _FILEEXISTS(appLocalDir$ + "INR-Stations.txt") THEN
    ok$ = WriteStationsTxtArray$(appLocalDir$ + "INR-Stations.txt", 0)
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
MainStationsList$ = ListC$("INIT", NewTag$("SORT", "alphabet"))
listFile% = FileToBuf%(appLocalDir$ + "INR-Stations.txt")
WHILE NOT EndOfBuf%(bh%)
    ok$ = ListC$("STORE", MainStationsList$ +_
        NewTag$("DATA", ReadBufLine$(listFile%)) +_
        NewTag$("STREAM_URL", ReadBufLine$(listFile%)))
WEND
DisposeBuf listFile%
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
IF opts.remStation THEN opts.idxStation = VAL(GetObjTagData$(MainStationsList$, "ACTUAL", "0"))
IF _FILEEXISTS(appTempDir$ + "INR-Stream.bin") THEN KILL appTempDir$ + "INR-Stream.bin"
'--- save Stations list ---
listFile% = CreateBuf%
FOR i% = 1 TO VAL(GetObjTagData$(MainStationsList$, "RECORDS", "0"))
    record$ = ListC$("READ", MainStationsList$)
    WriteBufLine listFile%, GetTagData$(record$, "DATA", "")
    WriteBufLine listFile%, GetTagData$(record$, "STREAM_URL", "")
NEXT i%
BufToFile listFile%, appLocalDir$ + "INR-Stations.txt"
DisposeBuf listFile%
'--- save settings ---
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

SetupScreen 640, 230, 0
appCR$ = "The Internet Radio Player v1.1, Done by RhoSigma, Roland Heyder"
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
COLOR 39: _PRINTSTRING (260, 110), "initializing..."
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
IF opts.remStation THEN actu% = opts.idxStation: ELSE actu% = 1
temp$ = GetTagData$(ListC$("READ", MainStationsList$ + NewTag$("ACTUAL", LTRIM$(STR$(actu%))) + NewTag$("HOLD", "true")), "DATA", "")
IF opts.scrStation THEN WHILE _UPRINTWIDTH(temp$, 8) < 400: temp$ = temp$ + " - - - - - " + temp$: WEND
MainStationText$ = TextC$("INIT", MainTextCommon$ +_
        NewTag$("TOP", "26") +_
        NewTag$("TEXT", temp$))
MainFeedsText$ = TextC$("INIT", MainTextCommon$ +_
        NewTag$("TOP", "104") +_
        NewTag$("TEXT", "press play to listen..."))
'--- Toolbar ---
MainToolRuler$ = RulerC$("INIT",_
        NewTag$("LEFT", "10") +_
        NewTag$("TOP", "168") +_
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
MainPreviousImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "GoPrev32px.png"))
MainNextImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "GoNext32px.png"))
MainEditImage$ = ImageC$("INIT", MainToolimageCommon$ +_
        NewTag$("IMAGEFILE", "Edit32px.png"))
MainToolbuttonCommon$ =_
        NewTag$("TOP", "179") +_
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
        NewTag$("TOOLTIP", "More info") +_
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
MainVolumeSlider$ = SliderC$("INIT",_
        NewTag$("LEFT", "295") +_
        NewTag$("TOP", "179") +_
        NewTag$("WIDTH", "180") +_
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
init% = -1 'init phase, goes zero after 1st handler loop
done% = 0 'our main loop continuation boolean
'-----
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

startPlay:
'--- prepare args ---
IF LEFT$(LCASE$(streamUrl$), 8) = "https://" THEN
    IF NOT opts.chgQuiet THEN
        ok$ = MessageBox$("Error16px.png", appExeName$,_
                "This Station uses https:// connections, which is not supported.|" +_
                "It is now changed to use a http:// connection instead. However,|" +_
                "if it fails, then this Station is unusable and can be deleted.",_
                "{IMG Error16px.png 0}Ok, got it...")
    END IF
    streamUrl$ = "http://" + MID$(streamUrl$, 9)
END IF
IF LEFT$(LCASE$(streamUrl$), 7) = "http://" THEN streamUrl$ = MID$(streamUrl$, 8)
sl% = INSTR(streamUrl$, "/")
host$ = LEFT$(streamUrl$, sl% - 1)
file$ = MID$(streamUrl$, sl%)
streamFile% = FREEFILE
'--- open client ---
stream& = _OPENCLIENT("TCP/IP:80:" + host$)
IF stream& = 0 THEN
    ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "press play to listen..."))
    ok$ = MessageBox$("Error16px.png", appExeName$,_
            "Sorry, no connection could be|established to that Station.|" +_
            "- Make sure you are online.",_
            "{IMG Error16px.png 0}Ok, got it...")
    RETURN
END IF
OPEN "O", streamFile%, appTempDir$ + "INR-Stream.bin": CLOSE streamFile%
OPEN "B", streamFile%, appTempDir$ + "INR-Stream.bin"
'--- send request ---
request$ = "GET " + file$ + " HTTP/1.0" + eol$ '1.0 to avoid "chunked" transfer
request$ = request$ + "Host: " + host$ + eol$
request$ = request$ + "User-Agent: INetRadio/1.1 (QB64-PE; GuiTools Framework;)" + eol$
request$ = request$ + "Accept: audio/mpeg, audio/ogg, audio/wav, audio/x-aiff" + eol$
request$ = request$ + "Accept-Charset: utf-8" + eol$
request$ = request$ + "Icy-MetaData: 1" + eol$
request$ = request$ + eol$
PUT stream&, , request$
'--- reset state variables ---
received$ = "": response$ = "": metainterval& = 0: soundHandle& = 0
RETURN

streamPlay:
'--- wait for response ---
GET stream&, , incomming$
received$ = received$ + incomming$
IF LEN(received$) < 12 AND LEN(response$) = 0 THEN
    RETURN
ELSEIF MID$(received$, 10, 3) <> "404" AND MID$(received$, 10, 3) <> "302" AND _
       MID$(received$, 10, 3) <> "200" AND LEN(response$) = 0 THEN
    er% = INSTR(received$, eol$ + eol$)
    IF er% > 0 THEN
        _WRITEFILE "INR-SvrRes.txt", LEFT$(received$, er% + 3)
        GOSUB togglePlayingState: GOSUB stopPlay
        ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "press play to listen..."))
        ok$ = MessageBox$("Error16px.png", appExeName$,_
                "Sorry, got a Server response which INetRadio can't handle.|" +_
                "- See logfile INR-SvrRes.txt for response details.",_
                "{IMG Error16px.png 0}Ok, got it...")
    END IF
    RETURN
ELSEIF MID$(received$, 10, 3) = "404" AND LEN(response$) = 0 THEN
    GOSUB togglePlayingState: GOSUB stopPlay
    ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "press play to listen..."))
    ok$ = MessageBox$("Error16px.png", appExeName$,_
            "Sorry, that Station was not found (404).|" +_
            "- Delete it and try re-importing it.",_
            "{IMG Error16px.png 0}Ok, got it...")
    RETURN
ELSEIF MID$(received$, 10, 3) = "302" AND LEN(response$) = 0 THEN
    lo% = INSTR(LCASE$(received$), "location:")
    IF lo% > 0 THEN el% = INSTR(lo%, received$, eol$)
    IF lo% > 0 AND el% > 0 THEN
        streamUrl$ = LTRIM$(RTRIM$(MID$(received$, lo% + 9, el% - (lo% + 9))))
        GOSUB stopPlay: _DELAY 0.1: GOSUB startPlay
        redirects% = redirects% + 1
    END IF
ELSEIF MID$(received$, 10, 3) = "200" AND LEN(response$) = 0 THEN
    ct% = INSTR(LCASE$(received$), "content-type:")
    IF ct% > 0 THEN
        et% = INSTR(ct%, received$, eol$)
        IF et% > 0 THEN mime$ = LTRIM$(RTRIM$(MID$(received$, ct% + 13, et% - ct% - 13)))
        IF INSTR("audio/mpeg,audio/ogg,audio/wav,audio/x-aiff", mime$) = 0 THEN
            GOSUB togglePlayingState: GOSUB stopPlay
            ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "press play to listen..."))
            ok$ = MessageBox$("Error16px.png", appExeName$,_
                    "Sorry, that Station is using an unsupported audio format.|" +_
                    "- If the Station offers multiple stream formats, then|" +_
                    "  take Mp3, Ogg, Wav or Aiff/Aifc, if available.",_
                    "{IMG Error16px.png 0}Ok, got it...")
            RETURN
        END IF
    END IF
    mi% = INSTR(LCASE$(received$), "icy-metaint:")
    IF mi% > 0 THEN metainterval& = VAL(MID$(received$, mi% + 12))
    er% = INSTR(received$, eol$ + eol$)
    IF er% > 0 THEN
        response$ = LEFT$(received$, er% + 3)
        _WRITEFILE appTempDir$ + "INR-SvrRes.txt", response$
        TempLog "INR-SvrRes.txt", "CONTENTS: Server response from Radio Station."
        ok$ = GenC$("SET", MainInfoButton$ + NewTag$("DISABLED", "false"))
        GOSUB updateInfoView
        received$ = MID$(received$, er% + 4)
        IF metainterval& = 0 THEN
            ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "--- not available ---"))
        END IF
    END IF
ELSEIF LEN(response$) > 0 THEN
    IF soundHandle& = 0 AND LOF(streamFile%) > (opts.bufSize * 1024) THEN
        soundHandle& = _SNDOPEN(appTempDir$ + "INR-Stream.bin", "stream")
        IF soundHandle& > 0 THEN
            _SNDVOL soundHandle&, VAL(GetObjTagData$(MainVolumeSlider$, "LEVEL", "67")) / 100
            _SNDPLAY soundHandle&
        END IF
    ELSEIF soundHandle& > 0 THEN
        IF NOT _SNDPLAYING(soundHandle&) THEN 'stalled ?
            IF opts.autoRetry THEN 'retry ?
                GOSUB stopPlay: _DELAY 0.1: GOSUB startPlay
            ELSE
                GOSUB togglePlayingState: GOSUB stopPlay
                ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", "Stream has stalled, press play to restart. If it happens frequently, then try raising the buffer size."))
                RETURN
            END IF
        END IF
    END IF
    IF metainterval& > 0 THEN
        IF LEN(received$) < metainterval& + 4081 THEN RETURN
        soundData$ = LEFT$(received$, metainterval&): PUT streamFile%, , soundData$
        received$ = MID$(received$, metainterval& + 1)
        metalength% = ASC(received$, 1) * 16 + 1
        IF metalength% > 1 THEN
            feeds$ = LEFT$(received$, metalength%)
            st% = INSTR(LCASE$(feeds$), "streamtitle='") + 13
            ste% = INSTR(st%, feeds$, "';")
            feeds$ = MID$(feeds$, st%, ste% - st%)
            IF _UPRINTWIDTH(feeds$, 8) = 0 THEN feeds$ = AnsiTextToUtf8Text$(feeds$, "Win1252")
            IF opts.scrFeeds THEN WHILE _UPRINTWIDTH(feeds$, 8) < 400: feeds$ = feeds$ + " - - - - - " + feeds$: WEND
            ok$ = GenC$("SET", MainFeedsText$ + NewTag$("TEXT", feeds$))
        END IF
        received$ = MID$(received$, metalength% + 1): RETURN
    END IF
    PUT streamFile%, , received$: received$ = ""
END IF
RETURN

stopPlay:
IF soundHandle& > 0 THEN _SNDSTOP soundHandle&: _SNDCLOSE soundHandle&
CLOSE streamFile%
CLOSE stream&: stream& = 0
RETURN
'~~~~~
'---------------------------------------------------------------------
'~~~ My SUBs/FUNCs
'=====================================================================
'Next is a simple help function for debugging. If any method call seems
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
                             "{IMG Error16px.png 0}Ok, got it...")
    ELSEIF ValidateTags%(tagString$, "WARNING", -1) THEN
        dummy$ = MessageBox$("Problem16px.png", "Warning Tag",_
                             GetTagData$(tagString$, "WARNING", "empty"),_
                             "{IMG Problem16px.png 0}Ok, got it...")
    END IF
END IF
END FUNCTION
'--- Function to define/return the program's version string.
'-----
FUNCTION VersionINetRadio$
VersionINetRadio$ = MID$("$VER: INetRadio 1.1 (26-Apr-2025) by RhoSigma :END$", 7, 39)
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
'newIcon& = _LOADIMAGE("QB64GuiTools\images\icons\RhoSigma32px.png", 32)
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

'$INCLUDE: 'inline\OptionsBin.bm'
'$INCLUDE: 'inline\StationsTxt.bm'

