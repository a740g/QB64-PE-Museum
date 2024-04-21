# Adlib-S3M player for QuickBasic, with effects support

This is the documentation of fmengineqb-1.1.0. Some entirely in QuickBasic written subroutines for playing Adlib-S3M or MidiS3M files in a QuickBasic program.

## Short example

`'$INCLUDE: 'fmengine.bi'   pleiplei: IF FMtimer% THEN RETURN   IF FMinit < 0 THEN PRINT "FM sound not available.": END   FMload "mysidia.s3m"   ' The main loop   WHILE INKEY$ = "": WEND   FMend   END`  
Could it any way be simpler than this?  

(Note you must copy `FMinit()`, `MPUDetect()`, `MPUvol()`, `note2period()`, `VibVal()`, `BeSilent()`, `FMend()`, `FMload()`, `FMnoteoff()`, `FMplayeffect()`, `FMplayrowfrom()`, `FMtimer()`, `FMtouch()`, `FMupdate()`, `FMwrite()` and `MPUwrite()` to the program, but these do not bother your editing, do they? :) )

As an alternative, there is a shorter file "fm.inc" which can be simply concatenated to your program. it works even in QBasic (the stripped version of QuickBasic, distributed with MS-DOS 4 and 5).  
An example of its use can be seen at [Youtube, here](http://www.youtube.com/watch?v=TUa5HJUebEA).

## Neat features

* +Does not require any difficult timing loops or calling a subroutine regularly. It works "behind the scenes".
* +Supports changing the song any time you want.
* +Uses really little memory.
* \-It accesses your hard disk / floppy often: it loads and keeps only one pattern at time from the file to memory. You shouldn't notice this though if you're using a disk cache program like smartdrv).
* +Allows playing adlib sound effects on the top of music. The sound effects are actually music tracks.
* +Entirely written in QuickBasic. This does not require any assembler-written modules.
* +The following S3M effects and control codes are supported:  
    Axx, Txx, Dxx, Kxx, Exx, Fxx, Hxx, Cxx, Bxx, SBx, SCx, SDx, SEx
* +It supports MPU-401 (midi) playing also.
* +The subroutines are fairly easy to copy to your own program to add nice music.

## Notes

### Example songs

The archive contains some example songs and one example effect file.  
Two of the example songs are made by Future Crew, four by me, and two by Warp.

### Hazards

The current version just assumes you have MPU-401 too. If you don't have, just edit the `MPUwrite` subroutine and add a `EXIT SUB` clause there to be the first command.

### How does its timer handler work?

It uses `ON PLAY` event mechanism for the timing, and plays short silent pause commands. Therefore you can not make speaker beeps while the player is playing. This does not affect the performance of the main program.  
This causes some problems with dosemu though.

### If it does not play anything

In the example program, you must press a key (try a,b,c,d,e,f,i,j,g,h,v,0,1 keys).  
Note that your sound card must really be Adlib compatible. Creative Sound Blaster AudioPCI 128, for example, is not.

### Memory usage

The player uses following global static tables, and nothing else:  
| Variable   | Size in bytes | Type                |
|------------|---------------|---------------------|
| fmperiod   | 24            | int[0..11]          |
| order      | 512           | int[0..255]         |
| adldata    | 2400          | int[1..100,0..11]   |
| insdata    | 1200          | {6 ints}[1..100]    |
| adlchan    | 896           | {14 ints}[0..31]    |
| MIDInote   | 64            | int[0..31]          |
| MIDIchan   | 64            | int[0..31]          |
| fmfilename | 4+n           | string              |
| fmpattern  | 4+n           | string              |
| fmeffect   | 4+n           | string              |
| fmdata     | 46            | {17 ints,double,long} |
| fmeff      | 24            | {3 ints}[0..3]      |
| Total      | 5242+n        |                     |

(I am sorry for the big amount of names used, but QuickBasic does not allow putting arrays or dynamic strings inside typedefs.)

The engine loads and keeps only one pattern at time from the file to memory. This means that the engine accesses the media every time the pattern changes. Patterns usually are about 1kB long per average.

## Discussion

Okay, who uses QuickBASIC today? If you find this program useful, you are strongly encouraged to tell me.  
However I'm planning to make a QuickBASIC compiler for \*nix systems like Linux. See the [project page](http://iki.fi/bisqwit/source/qbc.html) for details. You are encouraged to join as a developer if possible :)

### Feedback

If you have problems using this program or ideas how to develop it, email me your questions or ideas.  
Please do not omit the details.  
My email address (sigh) is: _bisqwit a**t i**ki dot fi_

## Copying

fmengineqb has been written by Joel Yliluoma, a.k.a. [Bisqwit](http://iki.fi/bisqwit/),  
and is distributed under the following terms:

> `* No warranty. You are free to modify this source and to   * distribute the modified sources, as long as you keep the   * existing copyright messages intact and as long as you   * remember to add your own copyright markings.   * You are not allowed to distribute the program or modified versions   * of the program without including the source code (or a reference to   * the publicly available source) and this notice with it.`

## See also

* [sndtool2](/source/sndtool2.html), which handles NES music, is somewhat related to OPL, although NES doesn't use FM synthesis (except on one extension chip).
* [opl3emu](/source/opl3emu.html) emulates the OPL3 chip (which is known also as the FM synthesis chip or AdLib). Embed it with this player and you don't need OPL3 anymore 😊
* [qbc](/source/qbc.html) - I am developing a portable QuickBASIC clone. It isn't of any use yet, but perhaps it would be if you joined to the development.

## Downloading

The official home page of fmengineqb is at [http://iki.fi/bisqwit/source/fmengineqb.html](http://iki.fi/bisqwit/source/fmengineqb.html).  
Check there for new versions.
