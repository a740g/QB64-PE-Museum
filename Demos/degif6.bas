'DEGIF6.BAS - No frills GIF decoder for the VGA's 320x200x256 mode.
'By Rich Geldreich 1993 (Public domain, use as you wish.)
'This version should properly decode all LZW encoded images in
'GIF image files. I've finally added GIF89a and local colormap
'support, so it more closely follows the GIF specification. It
'still doesn't support the entire GIF89a specification, but it'll
'show most GIF files fine.
'The GIF decoding speed of this program isn't great, but I'd say
'for an all QB/PDS decoder it's not bad!
'Note: This program does not stop decoding the GIF image after the
'rest of the scanlines become invisible! This happens with images
'larger than the 320x200 screen. So if the program seems to be
'just sitting there, accessing your hard disk, don't worry...
'It'll beep when it's done.
$NoPrefix
DefInt A-Z
$Resize:Smooth
'Prefix() and Suffix() hold the LZW phrase dictionary.
'OutStack() is used as a decoding stack.
'ShiftOut() as a power of two table used to quickly retrieve the LZW
'multibit codes.
Dim Prefix(4095), Suffix(4095), OutStack(4095), ShiftOut(8)

'The following line is for the QB environment(slow).
Dim YBase As Long, Powersof2(11) As Long, WorkCode As Long
'For a little more speed, unremark the next line and remark the one
'above, before you compile... You'll get an overflow error if the
'following line is used in the QB environment, so change it back.
'DIM YBase AS INTEGER, Powersof2(11) AS INTEGER, WorkCode AS INTEGER

'Precalculate power of two tables for fast shifts.
For a = 0 To 8: ShiftOut(8 - a) = 2 ^ a: Next
For a = 0 To 11: Powersof2(a) = 2 ^ a: Next

'Get GIF filename.
a$ = Command$: If a$ = "" Then Input "GIF file"; a$: If a$ = "" Then End
'Add GIF extension if the given filename doesn't have one.
For a = Len(a$) To 1 Step -1
    Select Case Mid$(a$, a, 1)
        Case "\", ":": Exit For
        Case ".": Extension = -1: Exit For
    End Select
Next
If Extension = 0 Then a$ = a$ + ".GIF"

'Open file for input so QB stops with an error if it doesn't exist.
Open a$ For Input As #1: Close #1
Open a$ For Binary As #1

'Check to see if GIF file. Ignore GIF version number.
a$ = "      ": Get #1, , a$
If Left$(a$, 3) <> "GIF" Then Print "Not a GIF file.": End

'Get logical screen's X and Y resolution.
Get #1, , TotalX: Get #1, , TotalY: GoSub GetByte
'Calculate number of colors and find out if a global palette exists.
NumColors = 2 ^ ((a And 7) + 1): NoPalette = (a And 128) = 0
'Retrieve background color.
GoSub GetByte: Background = a

'Get aspect ratio and ignore it.
GoSub GetByte

'Retrieve global palette if it exists.
If NoPalette = 0 Then P$ = Space$(NumColors * 3): Get #1, , P$

Do 'Image decode loop

    'Skip by any GIF extensions.
    '(With a few modifications this code could also fetch comments.)
    Do
        'Skip by any zeros at end of image (why must I do this? the
        'GIF spec never mentioned it)
        Do
            If EOF(1) Then Exit Do 'if at end of file, exit
            GoSub GetByte
        Loop While a = 0 'loop while byte fetched is zero

        Select Case a
            Case 44 'We've found an image descriptor!
                Exit Do
            Case 59 'GIF trailer, stop decoding.
                GoTo AllDone
            Case Is <> 33
                Print "Unknown GIF extension type.": End
        End Select
        'Skip by blocked extension data.
        GoSub GetByte
        Do: GoSub GetByte: a$ = Space$(a): Get #1, , a$: Loop Until a = 0
    Loop
    'Get image's start coordinates and size.
    Get #1, , XStart: Get #1, , YStart: Get #1, , XLength: Get #1, , YLength
    XEnd = XStart + XLength: YEnd = YStart + YLength

    'Check for local colormap, and fetch it if it exists.
    GoSub GetByte
    If (a And 128) Then
        NoPalette = 0
        NumColors = 2 ^ ((a And 7) + 1)
        P$ = Space$(NumColors * 3): Get #1, , P$
    End If

    'Check for interlaced image.
    Interlaced = (a And 64) > 0: PassNumber = 0: PassStep = 8

    'Get LZW starting code size.
    GoSub GetByte

    'Calculate clear code, end of stream code, and first free LZW code.
    ClearCode = 2 ^ a
    EOSCode = ClearCode + 1
    FirstCode = ClearCode + 2: NextCode = FirstCode
    StartCodeSize = a + 1: CodeSize = StartCodeSize

    'Find maximum code for the current code size.
    StartMaxCode = 2 ^ (a + 1) - 1: MaxCode = StartMaxCode

    BitsIn = 0: BlockSize = 0: BlockPointer = 1

    X = XStart: y = YStart: YBase = y * 320&

    'Set screen 13 in not set yet.
    If FirstTime = 0 Then
        'Go to VGA mode 13 (320x200x256).
        Screen 13: Def Seg = &HA000
    End If

    'Set palette, if there was one.
    If NoPalette = 0 Then
        'Use OUTs for speed.
        Out &H3C8, 0
        For a = 1 To NumColors * 3: Out &H3C9, Asc(Mid$(P$, a, 1)) \ 4: Next
        'Save palette of image to disk.
        'OPEN "pal." FOR BINARY AS #2: PUT #2, , P$: CLOSE #2
    End If

    If FirstTime = 0 Then
        'Clear entire screen to background color. This isn't
        'done until the image's palette is set, to avoid flicker
        'on some GIFs.
        Line (0, 0)-(319, 199), Background, BF
        FirstTime = -1
    End If

    'Decode LZW data stream to screen.
    Do
        'Retrieve one LZW code.
        GoSub GetCode
        'Is it an end of stream code?
        If Code <> EOSCode Then
            'Is it a clear code? (The clear code resets the sliding
            'dictionary - it *should* be the first LZW code present in
            'the data stream.)
            If Code = ClearCode Then
                NextCode = FirstCode
                CodeSize = StartCodeSize
                MaxCode = StartMaxCode
                GoSub GetCode
                CurCode = Code: LastCode = Code: LastPixel = Code
                If X < 320 And y < 200 Then Poke X + YBase, LastPixel
                X = X + 1: If X = XEnd Then GoSub NextScanLine
            Else
                CurCode = Code: StackPointer = 0

                'Have we entered this code into the dictionary yet?
                If Code >= NextCode Then
                    If Code > NextCode Then GoTo AllDone 'Bad GIF if this happens.
                    'mimick last code if we haven't entered the requested
                    'code into the dictionary yet
                    CurCode = LastCode
                    OutStack(StackPointer) = LastPixel
                    StackPointer = StackPointer + 1
                End If

                'Recursively get each character of the string.
                'Since we get the characters in reverse, "push" them
                'onto a stack so we can "pop" them off later.
                'Hint: There is another, much faster way to accomplish
                'this that doesn't involve a decoding stack at all...
                Do While CurCode >= FirstCode
                    OutStack(StackPointer) = Suffix(CurCode)
                    StackPointer = StackPointer + 1
                    CurCode = Prefix(CurCode)
                Loop

                LastPixel = CurCode
                If X < 320 And y < 200 Then Poke X + YBase, LastPixel
                X = X + 1: If X = XEnd Then GoSub NextScanLine

                '"Pop" each character onto the display.
                For a = StackPointer - 1 To 0 Step -1
                    If X < 320 And y < 200 Then Poke X + YBase, OutStack(a)
                    X = X + 1: If X = XEnd Then GoSub NextScanLine
                Next

                'Can we put this new string into our dictionary? (Some GIF
                'encoders will wait a bit when the dictionary is full
                'before sending a clear code- this increases compression
                'because the dictionary's contents are thrown away less
                'often.)
                If NextCode < 4096 Then
                    'Store new string in the dictionary for later use.
                    Prefix(NextCode) = LastCode
                    Suffix(NextCode) = LastPixel
                    NextCode = NextCode + 1
                    'Time to increase the LZW code size?
                    If (NextCode > MaxCode) And (CodeSize < 12) Then
                        CodeSize = CodeSize + 1
                        MaxCode = MaxCode * 2 + 1
                    End If
                End If
                LastCode = Code
            End If
        End If
    Loop Until Code = EOSCode

Loop

AllDone:

'Save image and palette to BSAVE file.
Def Seg = &HA000
Out &H3C7, 0
For a = 0 To 767
    Poke a + 64000, Inp(&H3C9)
Next
BSave "image.bin", 0, 64768

'Load images saved with the above code with this:
'DEF SEG= &HA000
'BLOAD "image.bin"
'OUT &H3C8, 0
'FOR a = 0 To 767
'     OUT &H3C9, Peek(a+ 64000)
'NEXT

Do: Loop While InKey$ <> "": Do: Loop Until InKey$ <> ""
End

'Slowly reads one byte from the GIF file...
GetByte: a$ = " ": Get #1, , a$: a = Asc(a$): Return

'Moves down one scanline. If the GIF is interlaced, then the number
'of scanlines skipped is based on the current pass.
NextScanLine:
If Interlaced Then
    y = y + PassStep
    If y >= YEnd Then
        PassNumber = PassNumber + 1
        Select Case PassNumber
            Case 1: y = 4: PassStep = 8
            Case 2: y = 2: PassStep = 4
            Case 3: y = 1: PassStep = 2
        End Select
    End If
Else
    y = y + 1
End If
X = XStart: YBase = y * 320&
Return

'Reads a multibit code from the data stream. Look ma, see how
'simple it is now!
GetCode:
WorkCode = LastChar \ ShiftOut(BitsIn)
'Loop while more bits are needed.
Do While CodeSize > BitsIn
    'Reads a byte from the LZW data stream. Since the data stream is
    'blocked, a check is performed for the end of the current block
    'before each byte is fetched.
    If BlockPointer > BlockSize Then
        'Retrieve block's length
        GoSub GetByte: BlockSize = a
        a$ = Space$(BlockSize): Get #1, , a$
        BlockPointer = 1
    End If
    'Yuck, ASC() and MID$() aren't that fast.
    ' a740: removed unnecessary mid$
    LastChar = Asc(a$, BlockPointer)
    BlockPointer = BlockPointer + 1
    'Append 8 more bits to the input buffer
    WorkCode = WorkCode Or LastChar * Powersof2(BitsIn)
    BitsIn = BitsIn + 8
Loop
'Take away x number of bits.
BitsIn = BitsIn - CodeSize
'Return code to caller.
Code = WorkCode And MaxCode
Return

