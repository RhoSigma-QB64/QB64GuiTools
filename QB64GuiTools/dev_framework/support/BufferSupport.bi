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
'| === BufferSupport.bi ===                                          |
'|                                                                   |
'| == This include file is part of the GuiTools Framework Project.   |
'| == It provides some constants needed for the String Buffers API.  |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

'--- The internal array for data storage
'-----
'never access this directly, use functions in simplebuffer.bm
REDIM SHARED simplebuffer_array$(0 TO 105)

'--- Simplebuffer Errors (most FUNCTIONs)
'-----
'initializer error returns
CONST SBE_NoMoreBuffers = -1
CONST SBE_NoMoreIDs = -2
CONST SBE_EmptyFind = -3
'operational error returns
CONST SBE_UnknownMode = -11
CONST SBE_OutOfBounds = -12
CONST SBE_BadIDNumber = -13
CONST SBE_UnusedID = -14
CONST SBE_ClearedID = -15

'--- Simplebuffer Modes (SeekBuf) ---
'-----
'use for mode% argument
CONST SBM_PosRestore = -21
CONST SBM_BufStart = -22
CONST SBM_BufCurrent = -23
CONST SBM_BufEnd = -24
CONST SBM_LineStart = -25
CONST SBM_LineEnd = -26

'--- Simplebuffer Flags (FindBufFwd/Rev) ---
'-----
'use for method% argument
CONST SBF_FullData = 0
CONST SBF_Delimiter = 1
CONST SBF_InvDelimiter = -1
'use for treat% argument
CONST SBF_AsWritten = 0
CONST SBF_IgnoreCase = -1

