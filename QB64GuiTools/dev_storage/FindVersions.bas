'+---------------+---------------------------------------------------+
'| ###### ###### |     .--. .         .-.                            |
'| ##  ## ##   # |     |   )|        (   ) o                         |
'| ##  ##  ##    |     |--' |--. .-.  `-.  .  .-...--.--. .-.        |
'| ######   ##   |     |  \ |  |(   )(   ) | (   ||  |  |(   )       |
'| ##      ##    |     '   `'  `-`-'  `-'-' `-`-`|'  '  `-`-'`-      |
'| ##     ##   # |                            ._.'                   |
'| ##     ###### |  Sources & Documents placed in the Public Domain. |
'+---------------+---------------------------------------------------+
'|                                                                   |
'| === FindVersions.bas ===                                          |
'|                                                                   |
'| == All my public libraries and tools define a function which will |
'| == return a version string. You may call these functions directly |
'| == in your own code to get the version strings e.g. to show them  |
'| == in "About" or "DebugInfo" messages or similar.                 |
'|                                                                   |
'| == However, the strings are enclosed in special begin/end markers,|
'| == which also makes them identifiable when examining a file such  |
'| == as a compiled executable file or the .bas/.bi/.bm files itself.|
'| == Just use this program with any filename as argument,           |
'| ==     e.g. FindVersions myprog.exe                               |
'| == and it prints all the version strings it finds in that file.   |
'| == This is a quick way to check the version of compiled programs  |
'| == and to find out which libraries they use.                      |
'|                                                                   |
'| == I hereby encourage all other library and tool makers to place  |
'| == such a function containing version strings into their works.   |
'| == For an example scroll down to the end of this file.            |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

_TITLE "FindVersions Output"
COLOR 9: PRINT VersionFindVersions$: PRINT

cmd$ = COMMAND$
IF cmd$ = "" THEN
    COLOR 12: PRINT "ERROR: No file given !!": PRINT
    COLOR 15: PRINT "Usage:"
    COLOR 7: PRINT "  FindVersions [path/]file"
ELSEIF NOT _FILEEXISTS(cmd$) THEN
    COLOR 12: PRINT "ERROR: File "; cmd$; " not found !!": PRINT
    COLOR 15: PRINT "Please check your input !!"
ELSE
    COLOR 15: PRINT "Checking file "; cmd$; " ...": PRINT
    '--- read file ---
    OPEN cmd$ FOR BINARY AS #1
    dat$ = SPACE$(LOF(1))
    GET #1, , dat$
    CLOSE #1
    '--- find build info (if any) ---
    result$ = SearchBuildInfo$(dat$)
    IF result$ = "" THEN
        COLOR 12: PRINT "Sorry, the file does not contain any build informations !!": PRINT
    ELSE
        COLOR 10: PRINT "The file contains the following build informations:": PRINT
        COLOR 15: PRINT result$
    END IF
    '--- find version(s) ---
    result$ = SearchVers$(dat$)
    IF result$ = "" THEN
        COLOR 12: PRINT "Sorry, the file does not contain any version informations !!": PRINT
    ELSE
        COLOR 10: PRINT "The file contains the following version informations:": PRINT
        COLOR 15: PRINT result$
    END IF
END IF

COLOR 7
END

' This function searches for any build information in the provided data.
' All found build infos are returned, separated by CHR$(10).
'----------------------------------------------------------------------
FUNCTION SearchBuildInfo$ (dat$)
'--- find build info ---
year% = 2025: found% = 0: dLen& = LEN(dat$): bStr$ = ""
DO
    year% = year% + 1
    bPos& = INSTR(dat$, " " + LTRIM$(STR$(year%)) + CHR$(0))
    IF bPos& > 0 THEN
        IF dLen& >= bPos& + 20 THEN
            IF ASC(dat$, bPos& + 8) = 58 AND ASC(dat$, bPos& + 11) = 58 AND ASC(dat$, bPos& + 14) = 0 AND _
               MID$(dat$, bPos& + 15, 4) = "QB64" THEN
                bEnd& = INSTR(bPos& + 15, dat$, CHR$(0))
                bStr$ = "Build date: " + MID$(dat$, bPos& - 6, 11) + CHR$(10) +_
                        "Build time: " + MID$(dat$, bPos& + 6, 8) + CHR$(10) +_
                        "Compiler  : " + MID$(dat$, bPos& + 15, bEnd& - bPos& - 15) + CHR$(10)
                found% = -1
            END IF
        END IF
    END IF
LOOP UNTIL found% OR year% = 2050 'next 25 years
'--- set result ---
SearchBuildInfo$ = bStr$
END FUNCTION

' This function searches for any version strings in the provided data.
' All found version strings are returned, separated by CHR$(10).
'----------------------------------------------------------------------
FUNCTION SearchVers$ (dat$)
'--- find strings ---
vBeg& = 0: vEnd& = 0: vStr$ = ""
DO
    vBeg& = INSTR(vEnd& + 1, dat$, UCASE$("$ver: ")) 'do not remove UCASE$
    IF vBeg& > 0 THEN
        vEnd& = INSTR(vBeg& + 1, dat$, UCASE$(" :end$")) 'do not remove UCASE$
        IF vEnd& > 0 THEN
            vStr$ = vStr$ + MID$(dat$, vBeg& + 6, vEnd& - vBeg& - 6) + CHR$(10)
        END IF
    END IF
LOOP UNTIL vBeg& = 0
'--- set result ---
SearchVers$ = vStr$
END FUNCTION

' This function defines the version string of this program. If called
' directly, the function just returns the regular text part between the
' begin/end markers. Using uppercase for the markers is mandatory.
'----------------------------------------------------------------------
FUNCTION VersionFindVersions$
VersionFindVersions$ = MID$("$VER: FindVersions 2.0 (05-Mar-2026) by RhoSigma :END$", 7, 42)
END FUNCTION

