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

'--- StringBuffer Errors (most FUNCTIONs)
'-----
'function error returns
CONST SBE_UnknownMode = -1
CONST SBE_OutOfBounds = -2
CONST SBE_BadIDNumber = -3
CONST SBE_UnusedID = -4
CONST SBE_ClearedID = -5

'--- StringBuffer Modes (SeekBuf) ---
'-----
'use for mode% argument
CONST SBM_PosRestore = -11
CONST SBM_BufStart = -12
CONST SBM_BufCurrent = -13
CONST SBM_BufEnd = -14
CONST SBM_LineStart = -15
CONST SBM_LineEnd = -16

'--- StringBuffer Flags (FindBufFwd/Rev) ---
'-----
'use for method% argument
CONST SBF_FullData = 0
CONST SBF_Delimiter = 1
CONST SBF_InvDelimiter = -1
'use for treat% argument
CONST SBF_AsWritten = 0
CONST SBF_IgnoreCase = -1

