QB64 COMPILER V0.91
===================

V0.91 Updates
=============
22/8/2010:
 -The DATA folder (and its contents) are no longer required. You may delete them when/if you wish.
 -Various bugs & incompatibilites addressed [http://www.qb64.net/forum/index.php?board=3.0]
   (of note: FREEFILE, FIX, INT, INPUT, INCLUDE)
 -Improved syntax checking
 -Removed blank pixel lines occurring between box drawing characters when using .TTF fonts
7/8/2010:
 -FILES command implemented

V0.91 Specific
==============
-Primarily implements the QB64 auto-updater. [http://www.qb64.net/forum/index.php?topic=1110.msg8195#msg8195]
 QB64 now checks for and applies updates to QB64 automatically or according the update options you specify in the IDE.

V0.9 Specific
=============
(Linux users must now run the batch/script file 'setup.sh' to build/setup/install QB64)
-Primarily updates Linux pure 64-bit support
-C++ components have been overhauled to be 64-bit compatible (affects all versions of QB64)
-Further bugs/incompatibilities fixed (see forum for details)
-Samples have been checked for Linux compatibility (eg. case sensitive filenames)

V0.88 Specific
==============
-Primarily updates Linux support
-Some bugs/incompatibilities fixed

V0.874 Specific
===============
Minor update:
-LPRINT & LPOS implemented
-'_PRINTIMAGE imagehandle&' command added to print an image on the printer (stretching it to full paper size first)
-OPEN(gw-basic style support)
-KILL now supports wildcards
-_SNDCOPY & _SNDPLAYCOPY fixed to inherit capabilities properly
-SCREEN 10 support fixed
-Autoformat bug in CASE IS = corrected

V0.873 Specific
===============
-_MOUSEMOVEMENTX & _MOUSEMOVEMENTY functions added (these hide mouse cursor in windowed mode)
-Improvements to handling of DATA:
 -faster compilation (at all stages)
 -able to handle larger amounts of DATA
-1 critical bug related to autoformat removing content addressed [http://www.qb64.net/forum/index.php?PHPSESSID=1bhq9ol1gsqrd4s9ser0ko6jd6&topic=940.0]
-Other problems fixed include:
 -detecting EOF CHR$(26) [http://www.qb64.net/forum/index.php?PHPSESSID=1bhq9ol1gsqrd4s9ser0ko6jd6&topic=915.0]
 -DRAW E/G command incorrect vector error
 -maintaining same VIEW/WINDOW/screen settings as QB between pages
 -freeze when _FULLSCREEN called after _DISPLAY
 -& other minor problems

V0.872 Specific
===============
-QB64 compiler/ide source code released!
 (.bas file located in download in qb64\source\ folder)
-Implemented REDIM _PRESERVE array-name(...) [http://www.qb64.net/forum/index.php?topic=863.0]
 (QB64 uses _PRESERVE to dynamically scale itself and can now compile even larger programs)
-New commands added to control/automate the desktop: [http://www.qb64.net/forum/index.php?topic=849.0]
 i=_SCREENIMAGE 'creates a new image of the desktop (always a 32-bit image, don't forget to free it later)
 _SCREENCLICK x,y 'simulates a left mouse click on your desktop at x,y
 _SCREENPRINT "hello" 'simulates typing on your keyboard
-Multiple instances of QB64 can be run at the same time
-If an exe file is in use, the QB64 IDE will build filename(2).exe, or filename(3).exe etc.
-Further improvements to file LOCKing & error system
-Many bugs/incompatibilities fixed

V0.871 Specific
===============
Minor update to fix a locking problem.

V0.87 Specific
==============
Primarily changes the internal process used by QB64 to access files giving QB64 greater OS-specific control when available:
-LOCK/UNLOCK implemented
-More specific errors such as "Path not found" (instead of "File not found") occur, as in QBASIC
Note: V0.87 contains few (if any) bug fixes since the previous release and implementing the above was
      the only goal. In 2 weeks time V0.871 will be released and address any recently reported bugs
      or problems.

V0.86 Specific
==============
Primarily improves the QB64 IDE with:
-CTRL+C/V/X alternatives for copy,paste,cut
-User selectable font (any monospace TTF font), font size and window dimensions
-Auto-spacing and capitalization complete with the only exceptions (which will be addressed soon) being:
 CONST equations like CONST A=B+1
 DATA statements
 Lines ending with a colon
 DECLARE statements (completely ignored by QB64)
 Line labels are kept in the same case as they are typed

Other changes:
-GCC compiler updated latest TDM version
-Changes to generated C++ code makes C++ compiling large .BAS programs much faster and results in a smaller .EXE file
 Some larger .BAS programs which previously froze/failed the C++ compilation process now compile OK
-ON TIMER interval corrected
-_CLIPBOARD sub changed to avoid reported freeze/GPF on some systems
-Many other reported (and unreported) bugs are fixed. (Some minor issues, such as specific error codes and VAL oddities will be addressed soon)

V0.851 Specific
===============
-Programs now resolve their own directory regardless of how/where they are run from (caused many 'file not found' problems)
-ON TIMER (and related commands) added [http://www.qb64.net/forum/index.php?topic=572.0]
-CHAIN now preserves the screen state and manages path/directory issues [http://www.qb64.net/forum/index.php?topic=517.0]
-_MOUSEWHEEL function added [http://www.qb64.net/forum/index.php?topic=595.0]
-_FULLSCREEN command (sub & function) added to control full screen mode [http://www.qb64.net/forum/index.php?topic=581.0]
-"OPTIONS" menu added to the IDE to control/disable auto-format and/or auto-indent
-New options in the IDE "RUN" menu added (make .EXE only & start detached)
-Auto-indent improved
-Lots of great extra samples programs added to try
-Many significant bugs/problems have been fixed

V0.85 Specific
==============
Major stages in the exciting transition to IDE autoformatting and autolayout are complete.
Code will auto-indent.
The spacing of some statements will be done by autolayout.
The capitalization of some names will be maintained by autolayout.
This release has no option to disable the above yet.
Every effort has been made to make sure autolayout/autoformat do not damage your code.
If you encounter a problem related to autolayout/autoformatting please report it immediately.

* NOTE: The QB64 IDE now uses the Windows clipboard for copy/paste operations (this is very useful)
* CHAIN implemented (maintains COMMON data but doesn't maintain open files or the screen state yet)
* _CLIPBOARD$ string added to use/access the Windows clipboard
  PRINT _CLIPBOARD$ 'prints the contents of the clipboard
  _CLIPBOARD$="This is line 1"+CHR$(13)+CHR$(10)+"This is line 2" 'sets 2 lines of text in the clipboard
* _EXIT function implemented to let a program know if the user has used the close button or CTRL+BREAK
  After the first time this function is called, the programmer can no longer manually exit the program.
  _EXIT returns 0 - no exit request made
                1 - exit via X box
                2 - exit via CTRL+BREAK
                3 - both CTRL+BREAK and the X box have been used since last call
* Some sample programs (eg. samples\original\qb64\ripples.bas) stopped working (across several releases) and the various causes have been fixed
* Many reported (and unreported) bugs have been fixed

V0.841b Specific
================
Implemented TCP/IP support.
Refer to the following QB64 forum thread for details/documentation:
http://www.qb64.net/forum/index.php?topic=397.0
Further TCP/IP documentation can be found on the QB64 Wiki:
http://qb64.net/wiki/index.php?title=Keyword_Reference_-_By_usage#TCP.2FIP

V0.841 Specific
===============
Again, QBASIC compatibility has been improved.
New commands supported: DRAW, $INCLUDE, KEY OFF(does nothing), ENVIRON, LEN(of variables/types/arrays)
Many minor bugs/incompatibilities have been addressed.

V0.84 Specific
==============
Stability & QBASIC compatibility have been significantly improved. Many problems not listed here have also been addressed.

New commands specific to QB64:
_ICON imagehandle 'changes the program's icon
_TITLE string$ 'changes the text in the title bar
_DELAY x 'waits for x seconds (accurate to nearest millisecond), relinquishing cpu cycles to other applications
_LIMIT x 'limits the fps/rate of a program to x loops/frames/etc per second, relinquishing any spare cpu cycles to other applications
t=TIMER(0.001) 'returns TIMER value rounded to nearest 0.001 of a second (highest accuracy possible is to the nearest millisecond)
_DISPLAY (no parameters) 'This command manually updates the monitor using the data of the currently selected display page. The command also disables the autodisplay of display page data to the monitor (the default) if it is on.
_AUTODISPLAY (no parameters) 'This command enables autodisplay so the display page data will automatically be updated to the monitor.
x=_ERRORLINE 'Returns the source code line number that caused the most recent runtime error

Added support for QBASIC commands:
CALL INTERRUPT
CLEAR
COMMON (when used in programs without multiple modules)
RUN

Other improvements:
-Severe memory leaks fixed
-can PEEK timer bytes at &H46C-E (46c+46d*256+46e*65536)
-division error fixed [(tx<2)/2.0 VS print (tx<2)/2]
-INP(&H3C9) for palette reading
-power-of [^] bug (related to order of operations)
-Reading "" in DATA statements
-Many fixes/improvements to referencing/allocating variables (including user defined types) in conventional memory
-SUBs/FUNCTIONs requiring variables in comventional-memory now supported
-Problems calling CALL ABSOLUTE addressed

IDE improvements:
-Severe memory leak which affected the IDE fixed
-Uses 50% less memory (RAM)
-Minimal CPU usage
-Many freeze/crash related problems addressed

A repository of QBASIC programs which run without modifications has been started in the \qb64\samples\ folder. See \qb64\samples\info.txt for more details.

V0.83 Specific
==============
Primarily improves cross-platform support.
1) Windows 98/ME support restored (broken since late 2008!)
2) Linux support improved:
 -_INTEGER64 data type now supported (C++ compilation failed before)
 -READing numbers from DATA statements fixed
 -EOF() not being detected problem fixed
 -\ automatically changed to / in OPEN,BLOAD,KILL,CHDIR,etc.
 (Many sample programs now run correctly as a result of these changes)
3) Many bug fixes to compiler & IDE;
  Of note:
 -Incorrect errors were reported when editing programs conatining user defined types in the IDE
 -GET from file treats # as optional
 
V0.82 Specific
==============
Primarily implements:
1) PRINT USING [#] command
2) STATIC command (all usages)
3) Major bug fixes to the QB64 IDE
4) Major bug fixes and improvements to the QB64 compiler
This is a Windows only release of V0.82, a Linux version will become available in 1-2 weeks time.

V0.81x Specific
===============
V0.81x implements 2 major changes:
1) Provides an IDE remarkably similar (in look and interface) to the QBASIC IDE called qb64.exe
notes:
-qb64.exe can perform command line compilation (similar to previous versions of QB64) using the -c switch, for example:
 qb64 -c mycode.bas
-many bugs/issues remain to be fixed, report them in the forum (gripes are ok too!)
-many more features are planned, at present the IDE is essentially a text editor that checks your code as you type it
-code may have "OK" status but fail C++ compilation (on F5) due to the underlying QB64 compiler not checking code thouroughly enough
-programs using the underscore (_) symbol for line don't work in the IDE yet
-the IDE features an autosave feature which silently saves your code after every 10 changes, you will be automatically prompted to restore this upon restart if you didn't exit normally (via the file menu's "exit" command)
-C++ compilation failure and some preprocessing errors are reported with incorrect line numbers, which can be misleading

2) Linux support
notes:
-you must have downloaded the Linux version of QB64 from the qb64.net forums and followed necessary installation steps
-64 bit Linux systems are not supported yet (it may be possible to edit ./internal/c/makeline.txt to force compilation for a 32-bit system)
-EOF() doesn't work correctly
-Type _UNSIGNED INTEGER64 (only the unsigned version) cannot be used due to an incompatibility
-check forward slashes and backslashes are correct for the Linux filesystem (QB64 will address this automatically in later versions)
-check case of referenced filenames carefully (QB64 will address this automatically in later versions)
-unhandled (ie. not handled by ON ERROR GOTO ...) errors when your code is running currently result in immediate program termination without warning
-lots of other compatibility problems exist and will be fixed in later versions, report them in the forum

general notes about V0.81x:
-compile.exe is not in V0.81x but will be provided alongside qb64.exe in subsequent versions
-temporarily removed support for SETTING the time/date

V0.81 Specific
==============
V0.81 primarily implements support for constants (refer to the CONST keyword)
Handling of numbers written in the code has been improved to support all type symbol extensions (even the newer QB64 types), this also applies to &H..., &O... and the newly implemented binary prefix &B... (note that &B... only currently works when used with numbers directly in your code, further support for &B... will be added later). This provides better compatibility with QBASIC's handling of numbers.
Several bugs causing compilation to fail on valid code have been corrected, but always check that the program to be compiled doesn't include any as yet unimplemented features listed later in this document.
No new sample programs have been added in this release.

V0.8 Specific
=============
V0.8 primarily implements the QB64 2D prototype 1.0, a fully integrated 2D graphics interface which encapsulates and extends upon QBASIC's standard graphics capabilities. It incorporates .TGA .BMP .PNM .XPM .XCF .PCX .GIF .JPG .TIF .LBM .PNG graphics formats, .TTF (true type) fonts, 32-bit RGBA, alpha blended drawing, color-key'd palette indexed images, RGB to palette matching, stretching, flipping, mirroring, and other functionality. Multiple graphics surfaces can be used of differing dimensions and formats simultaneously, and operations can be performed any these surfaces interchangeably.

The 2D prototype is fully implemented but still in the process of being documented in detail. Please refer to the following webpage for the latest documentation:
http://www.qb64.net/2d
Feel free to enquire about the 2D prototype & its usage at:
http://www.network54.com/Forum/585676/
No official example programs are available which demonstrate the 2D prototype yet, however they will be released soon.



Thanks for trying QB64!
The goal of QB64 is to create programs from BASIC source for Windows, Mac OSX and Linux whilst being 100% compatible with Microsoft QBASIC/QB4.5

Make sure original .BAS files from QB4.5 are saved in text format not the compressed file format.

Read \qb64\samples\info.txt for information about included .BAS example programs.

UNIMPLEMENTED FEATURES
======================
The majority of QBASIC commands are implemented.
Only the following are NOT IMPLEMENTED yet:
 -Some ON ... GOTO/GOSUB EVENTS (ON ERROR & ON TIMER are both implemented)
 -Devices (SCRN:,LPT...,KYBD:,CONS:) in an OPEN statement
 -CALL INTERRUPT (QB64 only supports INT 33h)
 -CALL ABSOLUTE (QB64 only has support for PUSH/POP/MOV/RET/INT 33h)
 -Port access ((QB64 only supports OUT &H3C8/&H3C9 and INP &H3DA/&H60)
 -Multimodular support
 -Other commands: TRON/TROFF, FILEATTR, FIELD, IOCTL, IOCTL$, PEN, STICK, STRIG, SETMEM, FRE, FIELD, KEY ON, PALETTE USING (note: PALETTE is implemented)

QB64 SPECIFIC FEATURES (FEATURES THAT QBASIC DOES NOT HAVE)
===========================================================

INPUT Protection
----------------
"Intelligently" restricts keyboard input. Avoids "redo from start" messages. Limits screen space used by input for fixed length strings and numbers (eg. INTEGER cannot use more than 6 spaces)

New Data Types
--------------
_BIT			name` or name`1
_UNSIGNED _BIT		name~` or name~`1
_BIT*4			name`4
_UNSIGNED _BIT*4	name~`4
_BYTE			name%%
_UNSIGNED _BYTE		name~%%
INTEGER			name%
_UNSIGNED INTEGER	name~%
LONG			name&
_UNSIGNED LONG		name~&
_INTEGER64		name&&
_UNSIGNED _INTEGER64	name~&&
SINGLE			name!
DOUBLE			name#
_FLOAT			name##
STRING			name$
STRING*100		name$100

_DEFINE Command
---------------
Instead of having DEFBIT,DEFUBT,DEFBYT,DEFUBY etc. for all the new data types there is a simple command which can be used like DEFINT for new types (or old types if you want to) as follows:
_DEFINE A-C,Z AS DOUBLE 'the same as DEFDBL A-C,Z

Larger Maximum RANDOM File Access Field Sizes
---------------------------------------------
For RANDOM access files, record lengths can now be greater than 32767 bytes. Variable length string headers allow for larger strings whilst still being 100% QBASIC compatible with smaller strings.

BLOAD/BSAVE Limit
-----------------
Can save/load 65536 bytes, not just 65535.

_MK$(variable-type,value)
-------------------------
Like MKI$/MKS$/etc., this converts numbers into a binary string. The advantage of _MK$() is it allows conversion into the newer QB64 data types as apose to just the QBASIC types. Example usage:
a$=_MK$(_UNSIGNED _INTEGER64,100)
Note: _CV(variable-type,string) can also be used.

_ROUND 
------
This can be used to round values to integers (CINT & CLNG imposed limitations on the output)

Graphics GET/PUT
----------------
GET supports a new optional argument. If used the area to store can be partially/all off-screen and off-screen pixels are set to the value specified:
GET (-10,-10)-(10,10),a,3
PUT format has been extended to PUT[{STEP}](?,?),?[,[{_CLIP}][{PSET|PRESET|AND|OR|XOR}][,?]] where _CLIP allows drawing partially/all off-screen and the final optional argument can specify a mask color to skip when drawing.

Better Sound/Audio Support
--------------------------
Support for playing .MID, .WAV, .MP3 and many other formats.
Commands include:
_SNDPLAYFILE		Simple command to play a sound file (with limited options)
_SNDOPEN		Returns a handle to a sound file
_SNDCLOSE		Unloads a sound file (waits until after it has finished playing)
_SNDPLAY		Plays a sound
_SNDSTOP		Stops a playing (or paused) sound
_SNDPLAYING		Returns whether a sound is being played
_SNDLOOP		Like _SNDPLAY but sound is looped
_SNDLIMIT		Stops playing a sound after it has been playing for a set number of seconds
_SNDGETPOS		Returns to current playing position in seconds
_SNDCOPY		Copies a sound (so two or more of the same sound can be played at once)
_SNDPLAYCOPY		Copies a sound, plays it and automatically closes the copy
_SNDPAUSE		Pauses a sound
_SNDPAUSED		Checks if a sound is paused
_SNDLEN			Returns the length of a sound in seconds
_SNDVOL			Sets the volume of a sound
_SNDBAL			Sets the balance/3D position of a sound
_SNDSETPOS		Changes the current/starting playing position of a sound in seconds
For more information, read "AUDIO.TXT" in your "QB64" folder.
Also check out "AUDIO.BAS" in the samples folder, you'll need some audio files to test this with!

Mouse Support
-------------
_MOUSESHOW		Displays the mouse cursor (sub)
_MOUSEHIDE		Hides the mouse cursor (sub)
_MOUSEINPUT		MUST BE CALLED UNTIL IT RETURNS 0, it reads the next mouse message and returns -1 if new information was available otherwise 0 (func)
_MOUSEX			(func)
_MOUSEY			(func)
_MOUSEBUTTON(n)		-1 if button n (a value of 1 or more) is down

Improved 2D Graphics Support
----------------------------
Although not fully documented, these new 2D commands are fully implemented.
Refer to http://www.qb64.net/2d for usage/details.
