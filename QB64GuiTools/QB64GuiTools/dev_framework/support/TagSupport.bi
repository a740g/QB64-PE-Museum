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
'| === TagSupport.bi ===                                             |
'|                                                                   |
'| == This include file is part of the GuiTools Framework Project.   |
'| == It provides some constants needed for the Tag Strings API.     |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

'-----------------------------
'--- Various tag constants ---
'-----------------------------
'--- These constants define the tokens used to uniquely identify single
'--- tags within a tag string. There's also an CHR$(0) replacement, which
'--- is used internally to allow C/C++ level operations without problems.
'--- The used control chars (ASCII 28-31) do not conflict with regular
'--- tag data writings nor with Ctrl shortcut sequences.
'-----
CONST tagIntr$ = "" 'tag item introducer
CONST tagSepa$ = "" 'tag name <-> tag data separator
CONST tagTerm$ = "" 'tag item terminator
CONST tagRepl$ = "" 'tag item CHR$(0) replacement

