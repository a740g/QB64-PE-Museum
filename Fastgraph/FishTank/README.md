# Fastgraph Fish Tank

QB64-PE port by ***a740g***.

Get the original sources [here](http://www.fastgraph.com/demos.html).

---

The Fishtank program is a good example of multi-object, non-destructive
animation using Fastgraph for Windows. In this program, several types of
tropical fish swim back and forth against a coral reef background.

The files in the Fishtank distribution are:

   ReadMe.txt    this file (ASCII text format)
   Fishtank.exe  Win32 executable
   Coral.pcx     PCX file containing the coral background
   Fish.pcx      PCX run file containing the fish bitmaps

   C.zip         C/C++ source code files
   Builder1.zip  C++Builder 1.0 source code files
   Builder3.zip  C++Builder 3.0 or later source code files
   Delphi.zip    Delphi source code files
   MFC.zip       MFC source code files (unzip with -d option)
   PB.zip        PowerBASIC source code files
   VB.zip        Visual Basic source code files

## How the program works: C/C++ and PowerBASIC

The Fishtank program's startup tasks take place in the WM_CREATE handler.
After we set up the device context and default logical palette in the usual
manner, WM_CREATE creates two 320x200 virtual buffers. It loads the coral
background from the file CORAL.PCX into the second virtual buffer (this
virtual buffer will always contain a clean copy of the background).

The next thing WM_CREATE does is load the fish bitmaps, using the function
GetFish(). This function loads the six fish sprites from the file FISH.PCX
into the first virtual buffer. The GetFish() function uses fg_getimage() to
retrieve each of the six fish into a 256-color bitmap. The FishX and FishY
arrays contain the (x,y) coordinates for the lower left corner of each
bitmap, while the FishWidth and FishHeight arrays define the size of each
bitmap. We store the fish bitmaps in the arrays Fish1 through Fish6, and
notice especially how we set up the Fishes array with pointers to the six
fish bitmap arrays. This lets us access the individual fish bitmaps through a
simple index. The fact that the background is color 0 is of particular
importance, for we want the pixels around the fish (but within the bitmap
rectangle) to be transparent when we display the bitmaps. Before returning,
GetFish() calls fg_erase() to clear the first virtual buffer. If we didn't do
this, the FISH.PCX image would appear briefly in the client area if a
WM_PAINT message occurs before we construct the first animation frame.

The Fishtank message loop controls the fish movement. We use the form of the
message loop that lets us do other activity when the message queue is empty.
That is, if messages are available, we process them in the usual manner with
the Windows API TranslateMessage() and DispatchMessage() functions, but if no
messages are waiting, we call GoFish() to perform one animation frame.

## How the program works: C++Builder and Delphi

The Fishtank program's startup tasks take place in the FormCreate()
procedure. After we set up the device context and default logical palette in
the usual manner, FormCreate() creates two 320x200 virtual buffers. It loads
the coral background from the file CORAL.PCX into the second virtual buffer
(this virtual buffer will always contain a clean copy of the background).

The next thing FormCreate() does is load the fish bitmaps, using the function
GetFish(). This function loads the six fish sprites from the file FISH.SPR
into the first virtual buffer. The GetFish() function uses fg_getimage() to
retrieve each of the six fish into a 256-color bitmap. The FishX and FishY
arrays contain the (x,y) coordinates for the lower left corner of each
bitmap, while the FishWidth and FishHeight arrays define the size of each
bitmap. We store the fish bitmaps in the arrays Fish1 through Fish6, and
notice especially how we set up the Fishes array with pointers to the six
fish bitmap arrays. This lets us access the individual fish bitmaps through a
simple index. The fact that the background is color 0 is of particular
importance, for we want the pixels around the fish (but within the bitmap
rectangle) to be transparent when we display the bitmaps. Before returning,
GetFish() calls fg_erase() to clear the first virtual buffer. If we didn't do
this, the FISH.PCX image would appear briefly in the client area if a Windows
paint message occurs before we construct the first animation frame.

The AppIdle() procedure, which C++Builder and Delphi call when no Windows
messages are waiting, controls the fish movement. AppIdle() calls GoFish() to
perform one animation frame.

## How the program works: Visual Basic

The Fishtank program's startup tasks take place in the Form_Load() function.
After we set up the device context and default logical palette in the usual
manner, Form_Load() creates two 320x200 virtual buffers. It loads the coral
background from the file CORAL.PCX into the second virtual buffer (this
virtual buffer will always contain a clean copy of the background).

The next thing Form_Load() does is load the fish bitmaps, using the function
GetFish(). This function loads the six fish sprites from the file FISH.PCX
into the first virtual buffer. The GetFish() function uses fg_getimage() to
retrieve each of the six fish into a 256-color bitmap. The FishX and FishY
arrays contain the (x,y) coordinates for the lower left corner of each
bitmap, while the FishWidth and FishHeight arrays define the size of each
bitmap. We store all six fish bitmaps in the array Fishes and store the array
offsets to the individual fish bitmaps in the FishOffset array. This lets us
access the individual fish bitmaps through a simple index. The fact that the
background is color 0 is of particular importance, for we want the pixels
around the fish (but within the bitmap rectangle) to be transparent when we
display the bitmaps. Before returning, GetFish() calls fg_erase() to clear
the first virtual buffer. If we didn't do this, the FISH.PCX image would
appear briefly in the client area if a Windows paint message occurs before we
construct the first animation frame.

The loop at the end of Form_Load() controls the fish movement. In each loop
iteration, the DoEvents statement processes any pending Windows messages, and
calling GoFish() performs one animation frame.

## Performing the animation

The GoFish() function builds each animation frame in the first virtual
buffer, which we'll call the workspace buffer. It starts constructing the new
frame by copying the background to the workspace buffer, which effectively
erases the previous frame. In each frame, we update the positions of 11 fish,
though we'll usually not see them all in a given frame. The arrays defined at
the top of GoFish() each contain 11 elements (one for each fish) that specify
the type of fish, and its current position, range, speed, and direction.
After we determine the new position of a fish, we call PutFish() to display
it at its new location in the workspace buffer. The PutFish() function just
uses fg_move() and either fg_clpimage() or fg_flpimage() to display the
bitmap, depending on whether we want a left-facing or right-facing fish.
After GoFish() places all 11 fish, the animation frame is ready, so we call
fg_vbscale() to display it in the client area.

## For more information about Fastgraph for Windows, contact

Ted Gruber Software
PO Box 13408
Las Vegas, NV  89112

(702) 735-1980 (voice)
(702) 735-4603 (fax)

email: <info@fastgraph.com>
  web: <http://www.fastgraph.com>
  ftp: ftp.fastgraph.com/fg/Windows
