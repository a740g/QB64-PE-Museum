digital reality by plasma
.........................
www.phatcode.net

[11-01-2004] updated final release
[07-16-2002] final release
[11-01-2001] contest release

created for Toshi's Fall 2001 "Pure QB" demo competition
placed 3rd out of 6 entries

(If you were wondering, Nemesis QB is now defunct)

just run digireal.exe and select your configuration. you can also specify
your sound card / vsync settings on the command line. for a list of command
line switches, type "digireal -?".


a note about the final release
..............................

i finally realized i was never going to get the MPU-401/MIDI patch mappings
the way i wanted them, so i figured i might as well release the final version.
everything is pretty much the same, except a few effects have been shortened.
(it looks better this way :p )

anyway, i got a few tricks up my sleeve for the next demo...  ;)


in case you were wondering
..........................

: pure QB single module EXE
  - NO call absolute
  - NO call interrupt
  - NO ISR loopholes used

: all external data packed in one file

: graphics
  - true scaled fading
  - crossfading
  - smooth masked scrolling
  - pixel morphing
  - 3d rotation/morphing
  - fire
  - texture mapping
  - plasma
  - double sinewave distortion with shading
  - smooth vertical text mode scrolling

: music
  - Adlib / Sound Blaster OPL2/3 FM synth support
  - realtime OPL2 software emulation using MPU-401 General MIDI
