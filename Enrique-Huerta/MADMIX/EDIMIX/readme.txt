
                         EDIMIX BETA - README.TXT file

             Thanks for any suggestion, hint or bug you report to:

                   Enrique Huerta - enriquemail@mixmail.com

        Please report any good changes! we will give you credit for it.

  You'll find this source and much more in 'The FreeSource Page' located at:

                     http://www11.brinkster.com/freesource

      Soon we will have lots of sources in many languages so don't forget

TABLE OF CONTENTS -----------------------------------------------------------

1 - Important information
 1.1 - This is freeware
 1.2 - Files distributed
 1.3 - About http://www11.brinkster.com/freesource
 1.4 - Don't forget to download Madmix and Edimix files
2 - Playing Madmix Game
 2.1 - Your objective
 2.2 - The game menu
 2.3 - Custom levels
 2.4 - Controls
3 - Using the editor
 3.1 - Mouse
 3.2 - Rules to make levels
 3.3 - The working menu
 3.4 - The options menu
 3.5 - Send to me your work

-----------------------------------------------------------------------------


=============================================================================
1 - IMPORTANT INFORMATION
=============================================================================

1.1 - This is freeware

EDIMIX is freeware and this means you can redistribute and change it in your 
own. Because i want to keep this so, you must redistribute at least the six 
files which originally came in 'edimix.zip' and, of course, it is forbidden 
to sell any part of this program.
The author is not liable for any damages caused by an improper use of this
software.


1.2 - Files distributed

'edimix.zip' comes with:

readme.txt       =     This file
edimix.exe       =     Executable Program
edimix.bas       =     Program source
default.pcx      =     Default game graphics
tiles.pcx        =     Additional Information for edimix users
module.zip       =     Module Source for compilation 


1.3 - About http://www11.brinkster.com/freesource

This URL was made for all people who were looking for a meeting place where
they could share they knowledge with other people developping all advantages
of freesource.
This URL will probably disappear inside some years but we won't, soon we
will have our domain (something like www.freesource.com)


1.4 - Don't forget to download Madmix and Edimix files

They both are needed to have fun, the first is the game and the second is the
editor. Get them from http://www11.brinkster.com/freesource


=============================================================================
2 - PLAYING MADMIX GAME
=============================================================================

2.1 - Your objective

Your missiom is to lead pac in his adventure along the fifteen default stages
where it is needed to be very patient and clever to clean all them of balls.

In the game you will find the following characters and elements:
PACMAN     This is the main character of the game, it is the most vulnerable.
ANGRY PAC  Always you eat the red face icon you'll convert to this character,
           it can eat all phantoms although it won't be so easy because these
           will try to escape from us. The time this effect last is limited.
PHANTOM    These are in all default stages. If we destroy it, it will restart
           at phantom prison.         
BUG        This is a ladybug which replaces all balls we already ate. it is
           not dangerous for us but it is very annoying because we have to
           repeat the work already done. Pacman cannot destroy it but Angry
           pac will do.
BALL       This is the rubbish you must clean to pass to the next stage.
PAC LANE   These are obligatory direction arrows which make our character to
           move automatically along a lane.
TRAPDOOR   These are doors which let us mislead our enemies but be careful
           because it also may be a trap for you.


2.2 - The game menu

It's easy to use: START GAME, LOAD CUSTOM, HALL OF FAME, CREDITS and EXIT.
Select any of them with a number. If you wait five seconds the demo starts.


2.3 - Custom levels

If you want to play other than default levels you must use the menu option
LOAD CUSTOM and introduce the entire path of the file.
For making custom levels use the editor, but before, read the information
below titled 'using the editor'.


2.4 - Controls

The keys cannot be changed and these are:

           PLAYER CONTROL          OTHER
           LEFT:  4                F8:    EXIT
           RIGHT: 6                ESC:   CANCEL
           UP:    8                ENTER: ACCEPT
           DOWN:  2


=============================================================================
3 - USING THE EDITOR
=============================================================================

3.1 - Mouse

MOUSE IS REQUIRED AND TWO BUTTONS ARE USEFUL!

You can do the next actions:
MOVE       Move the mouse to the borders to see the entire work area.
CLICK      Use left button for putting or selecting a single element.
           Use right button for automatic walls. You will put the last wall
           type selected.
It's important to say that mouse runs properly under windows but i have had
problems with dos because of pcopy instruction.
If the mouse runs too slow, click right mouse button when the options menu 
window is opened, the mouse pointer will change.


3.2 - Rules to make levels

This editor help you to make new levels but there are some things you must
know:

- Any level must have at least the pacman starting direction (represented with
faces) and one 'ball' or 'pac lane' to run.
- Pacman cannot leave the area between upper and lower red lines.
- Phantom cannot leave the play area to up or down.
- Trapdoor must have walls above and below.
- Trapdoor mustn't have walls close his right or left.

If you want to insert more than one level in one file read the following:
Open the txt file you have made with the editor...

- The first number indicates the number of levels the file has, it is 1
- Erase this line in all levels you want to insert.
- Cut all levels and paste them consecutive in the same text file.
- Insert a line at the beginning of the new file with the number of levels
the file has.
- Open it from the second option of the game menu and play...


3.3 - The working menu

The working menu is all squares you see up of the screen and it has the next
elements, from left to right:

The ERASER is at the upper left corner.

Just on his right you will find all elements you can put:
- There are two phantom prison door: opened and closed in this order.
- You must put the phantom starting coordinates before increasing the number
of phantoms or bugs to the right.
- You can put only one phantom and one pac starting coordinates.

At the upper right corner you can change some variables:
- Extra lives            (0 TO 20)
- Number of phantoms     (0 TO 20)
- Number of bugs         (0 TO 20)
- Bad pac time           (59 TO 499)
Note: phantoms + bugs = 20 at maximum

The upper arrow at the corner opens the menu window. More information
below.


3.4 - The options menu

The upper arrow at the corner opens this menu window and the lower arrow
closes it.
It's easy to use: NEW MAP, OPEN MAP, SAVE MAP, FIRST TEXT, SECOND TEXT and
EXIT EDITOR.
FIRST TEXT and SECOND TEXT buttons change the text you can read at the
beginning of the stage.
You may select, accept and cancel with the mouse or use <enter> for accepting
and <esc> for cancelling.
Be careful selecting and accepting because i haven't done errortrapping nor
confirmation windows.


3.5 - Send to me your work

I will add to 'http://www11.brinkster.com/freesource' all levels you send to
me at freesource@mixmail.com, thanks for your contribution.
