' direntry.h needs to be in QB64 folder '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< see b+ Very Simple GUI.txt file end
Declare CustomType Library ".\direntry"
    Function load_dir& (s As String)
    Function has_next_entry& ()
    Sub close_dir ()
    Sub get_next_entry (s As String, flags As Long, file_size As Long)
End Declare

'reset your Default colors here   FC = ForeColor  BC = Back Color  All the RGB32() are right here in constants section!
Dim Shared As _Unsigned Long Black, White, screenBC, BtnFC, BtnBC, TbFC, TbBC, LstFC, LstBC, LblFC
Black = _RGB32(0, 0, 0)
White = _RGB32(255, 255, 255)
screenBC = _RGB32(168, 168, 252) '  = 669 in C3 system
BtnFC = _RGB32(0, 0, 0)
BtnBC = _RGB32(250, 250, 250)
TbFC = _RGB32(180, 180, 255)
TbBC = _RGB32(0, 0, 128)
LstFC = _RGB32(255, 180, 180)
LstBC = _RGB32(190, 0, 0)
LblFC = _RGB32(0, 0, 68)

Type Control ' all are boxes with colors, 1 is active
    As Long ConType, X, Y, W, H, FontH, TabStop, Hide, N1, N2, N3, N4, N5 ' N1, N2 sometimes controls need extra numbers for special functions
    As String Text ' dims are pixels
    As _Unsigned Long FC, BC
End Type
Dim Shared GuiTitle$ ' WindowOpen
Dim Shared curPath$ ' _CWD$ in OpenWindow for file stuff
Dim Shared As Long Xmax, Ymax, NControls, ActiveControl
ReDim Shared con(0) As Control
Dim Shared fontHandle&(6 To 128) ' more range? to 128 set in OpenWindow

