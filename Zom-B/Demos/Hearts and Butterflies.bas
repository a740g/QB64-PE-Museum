'> Merged with Zom-B's smart $include merger 0.51

DefSng A-Z

'####################################################################################################################
'# Math Library V1.0 (include)
'# By Zom-B
'####################################################################################################################

Const sqrt2 = 1.41421356237309504880168872420969807856967187537695 ' Knuth01
Const sqrt3 = 1.73205080756887729352744634150587236694280525381038 ' Knuth02
Const sqrt5 = 2.23606797749978969640917366873127623544061835961153 ' Knuth03
Const sqrt10 = 3.16227766016837933199889354443271853371955513932522 ' Knuth04
Const cubert2 = 1.25992104989487316476721060727822835057025146470151 ' Knuth05
Const cubert3 = 1.44224957030740838232163831078010958839186925349935 ' Knuth06
Const q2pow025 = 1.18920711500272106671749997056047591529297209246382 ' Knuth07
Const phi = 1.61803398874989484820458683436563811772030917980576 ' Knuth08
Const log2 = 0.69314718055994530941723212145817656807550013436026 ' Knuth09
Const log3 = 1.09861228866810969139524523692252570464749055782275 ' Knuth10
Const log10 = 2.30258509299404568401799145468436420760110148862877 ' Knuth11
Const logpi = 1.14472988584940017414342735135305871164729481291531 ' Knuth12
Const logphi = 0.48121182505960344749775891342436842313518433438566 ' Knuth13
Const q1log2 = 1.44269504088896340735992468100189213742664595415299 ' Knuth14
Const q1log10 = 0.43429448190325182765112891891660508229439700580367 ' Knuth15
Const q1logphi = 2.07808692123502753760132260611779576774219226778328 ' Knuth16
Const pi = 3.14159265358979323846264338327950288419716939937511 ' Knuth17
Const deg2rad = 0.01745329251994329576923690768488612713442871888542 ' Knuth18
Const q1pi = 0.31830988618379067153776752674502872406891929148091 ' Knuth19
Const pisqr = 9.86960440108935861883449099987615113531369940724079 ' Knuth20
Const gamma05 = 1.7724538509055160272981674833411451827975494561224 '  Knuth21
Const gamma033 = 2.6789385347077476336556929409746776441286893779573 '  Knuth22
Const gamma067 = 1.3541179394264004169452880281545137855193272660568 '  Knuth23
Const e = 2.71828182845904523536028747135266249775724709369996 ' Knuth24
Const q1e = 0.36787944117144232159552377016146086744581113103177 ' Knuth25
Const esqr = 7.38905609893065022723042746057500781318031557055185 ' Knuth26
Const eulergamma = 0.57721566490153286060651209008240243104215933593992 ' Knuth27
Const expeulergamma = 1.7810724179901979852365041031071795491696452143034 '  Knuth28
Const exppi025 = 2.19328005073801545655976965927873822346163764199427 ' Knuth29
Const sin1 = 0.84147098480789650665250232163029899962256306079837 ' Knuth30
Const cos1 = 0.54030230586813971740093660744297660373231042061792 ' Knuth31
Const zeta3 = 1.2020569031595942853997381615114499907649862923405 '  Knuth32
Const nloglog2 = 0.36651292058166432701243915823266946945426344783711 ' Knuth33

Const logr10 = 0.43429448190325182765112891891660508229439700580367
Const logr2 = 1.44269504088896340735992468100189213742664595415299
Const pi05 = 1.57079632679489661923132169163975144209858469968755
Const pi2 = 6.28318530717958647692528676655900576839433879875021
Const q05log10 = 0.21714724095162591382556445945830254114719850290183
Const q05log2 = 0.72134752044448170367996234050094606871332297707649
Const q05pi = 0.15915494309189533576888376337251436203445964574046
Const q13 = 0.33333333333333333333333333333333333333333333333333
Const q16 = 0.16666666666666666666666666666666666666666666666667
Const q2pi = 0.63661977236758134307553505349005744813783858296183
Const q2sqrt5 = 0.89442719099991587856366946749251049417624734384461
Const rad2deg = 57.2957795130823208767981548141051703324054724665643
Const sqrt02 = 0.44721359549995793928183473374625524708812367192231
Const sqrt05 = 0.70710678118654752440084436210484903928483593768847
Const sqrt075 = 0.86602540378443864676372317075293618347140262690519
Const y2q112 = 1.05946309435929526456182529494634170077920431749419 ' Chromatic base

'####################################################################################################################
'# Screen mode selector v1.0 (include)
'# By Zom-B
'####################################################################################################################

videoaspect:
Data "all aspect",15
Data "4:3",11
Data "16:10",10
Data "16:9",14
Data "5:4",13
Data "3:2",12
Data "5:3",9
Data "1:1",7
Data "other",8
Data ,

videomodes:
Data 256,256,7
Data 320,240,1
Data 400,300,1
Data 512,384,1
Data 512,512,7
Data 640,480,1
Data 720,540,1
Data 768,576,1
Data 800,480,2
Data 800,600,1
Data 854,480,3
Data 1024,600,8
Data 1024,640,2
Data 1024,768,1
Data 1024,1024,7
Data 1152,768,5
Data 1152,864,1
Data 1280,720,3
Data 1280,768,6
Data 1280,800,2
Data 1280,854,5
Data 1280,960,1
Data 1280,1024,4
Data 1366,768,3
Data 1400,1050,1
Data 1440,900,2
Data 1440,960,5
Data 1600,900,3
Data 1600,1200,1
Data 1680,1050,2
Data 1920,1080,3
Data 1920,1200,2
Data 2048,1152,3
Data 2048,1536,1
Data 2048,2048,7
Data ,,

'####################################################################################################################
'# Ultra Fractal Gradient library v1.0 (include)
'# By Zom-B
'#
'# Smooth Gradient algorithm from Ultra Fractal (www.ultrafractal.com)
'####################################################################################################################

Type GRADIENTPOINT
    index As Single
    r As Single
    g As Single
    b As Single
    rdr As Single
    rdl As Single
    gdr As Single
    gdl As Single
    bdr As Single
    bdl As Single
End Type

'$dynamic

Dim Shared gradientSmooth(1) As _Byte '_BIT <- bugged
Dim Shared gradientPoints(1) As Integer
Dim Shared gradient(1, 1) As GRADIENTPOINT


'####################################################################################################################
'# InterestingSpiral2
'# By Zom-B
'#
'# Original art by Mark Hammond (markch1@mindspring.com) (Sep 10, 2002)
'####################################################################################################################

Const Doantialias = -1
Const Usegaussian = 0

'####################################################################################################################

_Title "Hearts and Butterflies"
Width 80, 40

Color 11
Print
Print Tab(29); "Hearts and Butterflies"
Color 7
Print
Print Tab(4); "Original artwork by Joy A. Stevenson <jars7@bellsouth.net> (Sep 6, 2002)"
Print Tab(29); "Palette tweak by Zom-B"
Print Tab(19); "Converted to Quick Basic and QB64 by Zom-B"

selectScreenMode 7, 32

'####################################################################################################################

Dim Shared sizeX%, sizeY%
Dim Shared maxX%, maxY%
Dim Shared halfX%, halfY%

sizeX% = _Width
sizeY% = _Height
maxX% = sizeX% - 1
maxY% = sizeY% - 1
halfX% = sizeX% \ 2
halfY% = sizeY% \ 2

Dim Shared magn

magn = 0.92905402789825371908069484570116 / halfY%

Dim Shared px, py
Dim Shared zx(100), zy(100), numIter%

'####################################################################################################################

setNumGradients 2

addGradientPoint 0, -0.0850, 0.314, 0.004, 0.000
addGradientPoint 0, 0.1325, 0.988, 0.627, 0.471
addGradientPoint 0, 0.3075, 0.235, 0.000, 0.000
addGradientPoint 0, 0.5425, 1.000, 1.000, 1.000
addGradientPoint 0, 0.6850, 0.314, 0.000, 0.000
addGradientPoint 0, 0.7675, 1.000, 0.616, 0.906
addGradientPoint 0, 0.8625, 0.996, 0.098, 0.000
addGradientPoint 0, 0.9150, 0.314, 0.004, 0.000
addGradientPoint 0, 1.1325, 0.988, 0.627, 0.471
setGradientSmooth 0, -1

addGradientPoint 1, -0.0975, 0.988, 0.902, 0.627
addGradientPoint 1, 0.0150, 0.314, 0.000, 0.000
addGradientPoint 1, 0.0925, 0.482, 0.161, 0.161
addGradientPoint 1, 0.3875, 0.988, 0.471, 0.471
addGradientPoint 1, 0.4575, 0.235, 0.000, 0.000
addGradientPoint 1, 0.6050, 1.000, 0.459, 0.459
addGradientPoint 1, 0.7025, 0.314, 0.000, 0.000
addGradientPoint 1, 0.9025, 0.988, 0.902, 0.627
addGradientPoint 1, 1.0150, 0.314, 0.000, 0.000
setGradientSmooth 1, -1

renderProgressive 256, 4

i$ = Input$(1)
End

'####################################################################################################################

Sub renderProgressive (startSize%, endSize%)
    pixStep% = startSize%

    pixWidth% = pixStep% - 1
    For y% = 0 To maxY% Step pixStep%
        For x% = 0 To maxX% Step pixStep%
            calcPoint x%, y%, r%, g%, b%
            Line (x%, y%)-Step(pixWidth%, pixWidth%), _RGB(r%, g%, b%), BF
        Next
        If InKey$ = Chr$(27) Then System
    Next

    While pixStep% > 2
        pixSize% = pixStep% \ 2
        pixWidth% = pixSize% - 1
        For y% = 0 To maxY% Step pixStep%
            y1% = y% + pixSize%
            For x% = 0 To maxX% Step pixStep%
                x1% = x% + pixSize%

                If x1% < sizeX% Then
                    calcPoint x1%, y%, r%, g%, b%
                    Line (x1%, y%)-Step(pixWidth%, pixWidth%), _RGB(r%, g%, b%), BF
                End If
                If y1% < sizeY% Then
                    calcPoint x%, y1%, r%, g%, b%
                    Line (x%, y1%)-Step(pixWidth%, pixWidth%), _RGB(r%, g%, b%), BF
                    If x1% < sizeX% Then
                        calcPoint x1%, y1%, r%, g%, b%
                        Line (x1%, y1%)-Step(pixWidth%, pixWidth%), _RGB(r%, g%, b%), BF
                    End If
                End If
            Next
            If InKey$ = Chr$(27) Then System
        Next
        pixStep% = pixStep% \ 2
    Wend

    For y% = 0 To maxY% Step 2
        y1% = y% + 1
        For x% = 0 To maxX% Step 2
            x1% = x% + 1

            If x1% < sizeX% Then
                calcPoint x1%, y%, r%, g%, b%
                PSet (x1%, y%), _RGB(r%, g%, b%)
            End If
            If y1% < sizeY% Then
                calcPoint x%, y1%, r%, g%, b%
                PSet (x%, y1%), _RGB(r%, g%, b%)
                If x1% < sizeX% Then
                    calcPoint x1%, y1%, r%, g%, b%
                    PSet (x1%, y1%), _RGB(r%, g%, b%)
                End If
            End If
        Next
        If InKey$ = Chr$(27) Then System
    Next

    If Not Doantialias Then Exit Sub

    endArea% = endSize% * endSize%

    If Usegaussian Then
        For y% = 0 To maxY%
            For x% = 0 To maxX%
                c& = Point(x%, y%)
                r% = _Red(c&)
                g% = _Green(c&)
                b% = _Blue(c&)
                For i% = 2 To endArea%
                    Do 'Marsaglia polar method for random gaussian
                        u! = Rnd * 2 - 1
                        v! = Rnd * 2 - 1
                        s! = u! * u! + v! * v!
                    Loop While s! >= 1 Or s! = 0
                    s! = Sqr(-2 * Log(s!) / s!) * 0.5
                    u! = u! * s!
                    v! = v! * s!

                    calcPoint x% + u!, y% + v!, r1%, g1%, b1%

                    r% = r% + r1%
                    g% = g% + g1%
                    b% = b% + b1%
                Next

                PSet (x%, y%), _RGB(CInt(r% / endArea%), CInt(g% / endArea%), CInt(b% / endArea%))
                If InKey$ = Chr$(27) Then System
            Next
        Next
    Else
        For y% = 0 To maxY%
            For x% = 0 To maxX%
                r% = 0
                g% = 0
                b% = 0
                For v% = 0 To endSize% - 1
                    y1! = y% + v% / endSize%
                    For u% = 0 To endSize% - 1
                        If u% = 0 And v& = 0 Then
                            c& = Point(x%, y%)
                        Else
                            x1! = x% + u% / endSize%
                            calcPoint x1!, y1!, r1%, g1%, b1%
                        End If
                        r% = r% + r1%
                        g% = g% + g1%
                        b% = b% + b1%
                    Next
                Next
                PSet (x%, y%), _RGB(CInt(r% / endArea%), CInt(g% / endArea%), CInt(b% / endArea%))
                If InKey$ = Chr$(27) Then System
            Next
        Next
    End If
End Sub

'####################################################################################################################

Sub calcPoint (screenX!, screenY!, r%, g%, b%)
    applyLocation screenX!, screenY!

    calcFractal

    If numIter% < 100 Then
        calcOutside index1!, index2!

        getGradient 0, index1!, r!, g!, b!
        getGradient 1, index2!, r2!, g2!, b2!

        mergeHSLAddition r!, g!, b!, r2!, g2!, b2!
    Else
        'r! = 0: g! = 0: b! = 0
    End If

    r% = r! * 255
    g% = g! * 255
    b% = b! * 255
End Sub

'####################################################################################################################

Sub applyLocation (inX!, inY!)
    px = (inX! - halfX%) * magn + 1.27027027032
    py = (halfY% - inY!) * magn + -.02027027035
End Sub

'####################################################################################################################

Sub calcFractal
    zx(0) = px: zy(0) = py
    x = px: y = py

    outside% = false
    For numIter% = 1 To 100
        t = x
        x = t * 0.3508212350261158# - y * 1.1517464294873868# + .9287217468784809#
        y = y * 0.3508212350261158# + t * 1.1517464294873868# - 1.296066350576871#

        zx(numIter%) = x: zy(numIter%) = y

        If x * x + y * y >= 44 Then Exit For
    Next

    numIter% = numIter% - 1
End Sub

'####################################################################################################################

Sub calcOutside (index1!, index2!)
    dist1 = 1E38: dist2 = 1E38
    For a% = 1 To numIter%
        x = zx(a%): y = zy(a%)
        ax = Abs(x)
        r2 = x * x + y * y
        r = Sqr(r2)

        y2 = r - ax
        dy = y2 * y2 - 1
        If dy < 0 Then
            x2 = Log(y2 * y2 - dy) * 0.5
            y2 = Atn(Sqr(-dy) / y2)
            dx = x2 * x2 + y2 * y2
            x2 = x - dx + r2 * r2
            y2 = y - 2 * Sqr(dx) * r2
        Else
            x2 = y2 + Sqr(dy)
            dx = Log(x2 * x2) / 2
            x2 = x - dx * dx + r2 * r2
            y2 = y - 2 * dx * r2
        End If

        x2 = x2 * x2 + y2 * y2
        If dist2 > x2 Then dist2 = x2

        y2 = Abs(ax - r)

        dy = y2 * y2 - 1
        If dy < 0 Then
            dy = Sqr(-dy)
            x2 = Log(y2 * y2 + dy * dy) * 0.5
            y2 = Atn(dy / (y2 + .0000001))
            dx = Sqr(x2 * x2 + y2 * y2)
        Else
            dx = Log(y2 + Sqr(dy))
        End If

        dy = r - Abs(Abs(Abs(y) + x) - r) / r
        dx = dx - 3 * (dy + Abs(dy))

        x2 = x + dx * dx - dy * dy
        y2 = y + 2 * dx * dy

        x2 = x2 * x2 + y2 * y2
        If dist1 > x2 Then dist1 = x2
    Next
    dist1 = Sqr(dist1) ^ .1
    dist2 = Sqr(dist2) ^ .1

    r = 1 - dist1 * dist1
    If r < 0 Then
        y = Sqr(-r) + dist1
        x = Log(y * y) * 0.5
        dist1 = x * x + 2.467401100272339#
    Else
        y = Sqr(r)
        x = Log(y * y + dist1 * dist1) * 0.5
        y = Atn(dist1 / (y + .0000001))
        dist1 = x * x + y * y
    End If

    index1! = Sqr(dist1) * 0.5

    r = 1 - dist2 * dist2
    If r < 0 Then
        y = Sqr(-r) + dist2
        x = Log(y * y) * 0.5
        y = 1.570796326794897#
    Else
        r = Sqr(r)
        x = Log(r * r + dist2 * dist2) * 0.5
        y = Atn(dist2 / r)
    End If

    x2 = x * x - y * y
    y2 = 2 * x * y
    index2! = Sqr(Sqr(x2 * x2 + y2 * y2)) * 0.5
End Sub

'####################################################################################################################
'# Math Library V0.11 (routines)
'# By Zom-B
'####################################################################################################################

'> merger: Skipping unused FUNCTION remainder% (a%, b%)

'> merger: Skipping unused FUNCTION fRemainder (a, b)

'####################################################################################################################

'> merger: Skipping unused FUNCTION safeLog (x)

'####################################################################################################################

'> merger: Skipping unused FUNCTION asin (y)

'> merger: Skipping unused FUNCTION acos (y)

'> merger: Skipping unused FUNCTION safeAcos (y)

'> merger: Skipping unused FUNCTION atan2 (y, x)

'####################################################################################################################
'# Screen mode selector v1.0 (routines)
'# By Zom-B
'####################################################################################################################

Sub selectScreenMode (yOffset%, colors%)
    Dim aspectName$(10), aspectCol%(10)
    Restore videoaspect
    For y% = 0 To 10
        Read aspectName$(y%), aspectCol%(y%)
        If aspectCol%(y%) = 0 Then numAspect% = y% - 1: Exit For
    Next

    Dim vidX%(100), vidY%(100), vidA%(100)
    Restore videomodes
    For y% = 1 To 100
        Read vidX%(y%), vidY%(y%), vidA%(y%)
        If (vidX%(y%) <= 0) Then numModes% = y% - 1: Exit For
    Next

    If numModes% > _Height - yOffset% - 1 Then numModes% = _Height - yOffset% - 1

    Def Seg = &HB800
    Locate yOffset% + 1, 1
    Print "Select video mode:"; Tab(61); "Click "
    Poke yOffset% * 160 + 132, 31

    y% = 0
    lastY% = 0
    selectedAspect% = 0
    reprint% = 1
    lastButton% = 0
    Do
        If InKey$ = Chr$(27) Then Cls: System
        If reprint% Then
            reprint% = 0

            For x% = 1 To numModes%
                Locate yOffset% + x% + 1, 1
                Color 7, 0
                Print Using "##:"; x%;
                If selectedAspect% = 0 Then
                    Color aspectCol%(vidA%(x%))
                ElseIf selectedAspect% = vidA%(x%) Then
                    Color 15
                Else
                    Color 8
                End If
                Print Str$(vidX%(x%)); ","; vidY%(x%);
            Next

            For x% = 0 To numAspect%
                If x% > 0 And selectedAspect% = x% Then
                    Color aspectCol%(x%), 3
                Else
                    Color aspectCol%(x%), 0
                End If
                Locate yOffset% + x% + 2, 64
                Print "<"; aspectName$(x%); ">"
            Next
        End If
        If _MouseInput Then
            If lastY% > 0 Then
                For x% = 0 To 159 Step 2
                    Poke lastY% + x%, Peek(lastY% + x%) And &HEF
                Next
            End If

            x% = _MouseX
            y% = _MouseY - yOffset% - 1

            If x% <= 60 Then
                If y% > 0 And y% <= numModes% Then
                    If _MouseButton(1) = 0 And lastButton% Then Exit Do
                    y% = (yOffset% + y%) * 160 + 1
                    For x% = 0 To 119 Step 2
                        Poke y% + x%, Peek(y% + x%) Or &H10
                    Next
                Else
                    y% = 0
                End If
            Else
                If y% > 0 And y% - 1 <= numAspect% Then
                    If _MouseButton(1) Then
                        selectedAspect% = y% - 1
                        reprint% = 1
                    End If
                    y% = (yOffset% + y%) * 160 + 1
                    For x% = 120 To 159 Step 2
                        Poke y% + x%, Peek(y% + x%) Or &H10
                    Next
                Else
                    y% = 0
                End If
            End If
            lastY% = y%
            lastButton% = _MouseButton(1)
        End If
    Loop

    Cls 'bug evasion for small video modes
    Screen _NewImage(vidX%(y%), vidY%(y%), colors%)
End Sub

'####################################################################################################################
'# Ultra Fractal Gradient library v1.1 (routines)
'# By Zom-B
'#
'# Smooth Gradient algorithm from Ultra Fractal (www.ultrafractal.com)
'####################################################################################################################

'> merger: Skipping unused SUB defaultGradient (gi%)

'> merger: Skipping unused SUB grayscaleGradient (gi%)

'####################################################################################################################

Sub setNumGradients (gi%)
    offset% = LBound(gradientPoints) - 1
    ReDim _Preserve gradientSmooth(gi% + offset%) As _Byte '_BIT <- bugged
    ReDim _Preserve gradientPoints(gi% + offset%) As Integer
    ReDim _Preserve gradient(gi% + offset%, 1) As GRADIENTPOINT
End Sub

Sub addGradientPoint (gi%, index!, r!, g!, b!)
    p% = gradientPoints(gi%)

    If UBound(gradient, 2) < p% Then
        ReDim _Preserve gradient(0 To UBound(gradient, 1), 0 To p%) As GRADIENTPOINT
    End If

    gradient(gi%, p%).index = index!
    gradient(gi%, p%).r = r!
    gradient(gi%, p%).g = g!
    gradient(gi%, p%).b = b!
    gradientPoints(gi%) = p% + 1
End Sub

Sub setGradientSmooth (gi%, s%)
    gradientSmooth(gi%) = s%

    If gradientSmooth(0) = 0 Then Exit Sub

    For i% = 0 To gradientPoints(gi%) - 1
        ip1% = i% + 1
        If ip1% = gradientPoints(gi%) Then ip1% = 2
        in1% = i% - 1
        If in1% = -1 Then in1% = gradientPoints(gi%) - 3

        dxl! = gradient(gi%, i%).index - gradient(gi%, in1%).index
        dxr! = gradient(gi%, ip1%).index - gradient(gi%, i%).index
        If dxl! < 0 Then dxl! = dxl! + 1
        If dxr! < 0 Then dxr! = dxr! + 1

        d! = (gradient(gi%, i%).r - gradient(gi%, in1%).r) * dxr!
        If d! = 0 Then
            gradient(gi%, i%).rdr = 0
            gradient(gi%, i%).rdl = 0
        Else
            d! = (gradient(gi%, ip1%).r - gradient(gi%, i%).r) * dxl! / d!
            If d! <= 0 Then
                gradient(gi%, i%).rdr = 0
                gradient(gi%, i%).rdl = 0
            Else
                gradient(gi%, i%).rdr = 1 / (1 + d!)
                gradient(gi%, i%).rdl = gradient(gi%, i%).rdr - 1
            End If
        End If

        d! = (gradient(gi%, i%).g - gradient(gi%, in1%).g) * dxr!
        If d! = 0 Then
            gradient(gi%, i%).gdr = 0
            gradient(gi%, i%).gdl = 0
        Else
            d! = (gradient(gi%, ip1%).g - gradient(gi%, i%).g) * dxl! / d!
            If d! <= 0 Then
                gradient(gi%, i%).gdr = 0
                gradient(gi%, i%).gdl = 0
            Else
                gradient(gi%, i%).gdr = 1 / (1 + d!)
                gradient(gi%, i%).gdl = gradient(gi%, i%).gdr - 1
            End If
        End If

        d! = (gradient(gi%, i%).b - gradient(gi%, in1%).b) * dxr!
        If d! = 0 Then
            gradient(gi%, i%).bdr = 0
            gradient(gi%, i%).bdl = 0
        Else
            d! = (gradient(gi%, ip1%).b - gradient(gi%, i%).b) * dxl! / d!
            If d! <= 0 Then
                gradient(gi%, i%).bdr = 0
                gradient(gi%, i%).bdl = 0
            Else
                gradient(gi%, i%).bdr = 1 / (1 + d!)
                gradient(gi%, i%).bdl = gradient(gi%, i%).bdr - 1
            End If
        End If
    Next
End Sub

'####################################################################################################################

Sub getGradient (gi%, index!, red!, green!, blue!)
    If index! < 0 Then x! = 0 Else x! = index! - Int(index!)

    For l% = gradientPoints(gi%) - 2 To 1 Step -1
        If gradient(gi%, l%).index <= x! Then
            Exit For
        End If
    Next

    r% = l% + 1
    u! = (x! - gradient(gi%, l%).index) / (gradient(gi%, r%).index - gradient(gi%, l%).index)

    If gradientSmooth(gi%) Then
        u2! = u! * u!
        u3! = u2! * u!
        ur! = u3! - (u2! + u2!) + u!
        ul! = u2! - u3!

        red! = gradient(gi%, l%).r + (gradient(gi%, r%).r - gradient(gi%, l%).r) * (u3! + 3 * (gradient(gi%, l%).rdr * ur! + (1 + gradient(gi%, r%).rdl) * ul!))
        green! = gradient(gi%, l%).g + (gradient(gi%, r%).g - gradient(gi%, l%).g) * (u3! + 3 * (gradient(gi%, l%).gdr * ur! + (1 + gradient(gi%, r%).gdl) * ul!))
        blue! = gradient(gi%, l%).b + (gradient(gi%, r%).b - gradient(gi%, l%).b) * (u3! + 3 * (gradient(gi%, l%).bdr * ur! + (1 + gradient(gi%, r%).bdl) * ul!))
    Else
        red! = gradient(gi%, l%).r + (gradient(gi%, r%).r - gradient(gi%, l%).r) * u!
        green! = gradient(gi%, l%).g + (gradient(gi%, r%).g - gradient(gi%, l%).g) * u!
        blue! = gradient(gi%, l%).b + (gradient(gi%, r%).b - gradient(gi%, l%).b) * u!
    End If
End Sub

'> merger: Skipping unused SUB testGradient (gi%)

'####################################################################################################################
'# Merge modes library v0.11 (routines)
'# By Zom-B
'####################################################################################################################

'> merger: Skipping unused SUB testMerge

'####################################################################################################################

'> merger: Skipping unused SUB mergeOverlay (br!, bg!, bb!, tr!, tg!, tb!)

'> merger: Skipping unused SUB mergeHardLight (br!, bg!, bb!, tr!, tg!, tb!)

'> merger: Skipping unused SUB mergeSoftLight (br!, bg!, bb!, tr!, tg!, tb!)

'> merger: Skipping unused SUB mergeColor (r!, g!, b!, r2!, g2!, b2!)

Sub mergeHSLAddition (r!, g!, b!, r2!, g2!, b2!)
    largest! = r!
    smallest! = r!
    If largest! < g! Then largest! = g!
    If smallest! > g! Then smallest! = g!
    If largest! < b! Then largest! = b!
    If smallest! > b! Then smallest! = b!

    lum! = (largest! + smallest!) * 0.5
    chr! = largest! - smallest!

    If lum! < 0.5 Then
        sat! = chr! / (2 * lum!)
    Else
        sat! = chr! / (2 - 2 * lum!)
    End If
    If chr! = 0 Then
        hue! = 0
    ElseIf largest! = r! Then
        hue! = (g! - b!) / chr!
    ElseIf largest! = g! Then
        hue! = (b! - r!) / chr! + 2
    Else
        hue! = (r! - g!) / chr! + 4
    End If

    largest! = r2!
    smallest! = r2!
    If largest! < g2! Then largest! = g2!
    If smallest! > g2! Then smallest! = g2!
    If largest! < b2! Then largest! = b2!
    If smallest! > b2! Then smallest! = b2!

    lum2! = (largest! + smallest!) * 0.5
    chr2! = largest! - smallest!

    If lum2! < 0.5 Then
        sat2! = chr2! / (2 * lum2!)
    Else
        sat2! = chr2! / (2 - 2 * lum2!)
    End If
    If chr2! = 0 Then
        hue! = hue!
    ElseIf largest! = r2! Then
        hue! = hue! + (g2! - b2!) / chr2!
    ElseIf largest! = g2! Then
        hue! = hue! + (b2! - r2!) / chr2! + 2
    Else
        hue! = hue! + (r2! - g2!) / chr2! + 4
    End If
    If hue! < 0 Then hue! = hue! + 6 Else If hue! > 6 Then hue! = hue! - 6

    sat! = sat! + sat2! - 0.5: If sat! < 0 Then sat! = 0 Else If sat! > 1 Then sat! = 1
    lum! = lum! + lum2! - 0.5: If lum! < 0 Then lum! = 0 Else If lum! > 1 Then lum! = 1

    If lum! < 0.5 Then
        chr! = sat! * 2 * lum!
    Else
        chr! = sat! * (2 - 2 * lum!)
    End If

    smallest! = lum! - chr! * 0.5

    x! = chr! * (1 - Abs(hue! - Int(hue! / 2) * 2 - 1))
    Select Case hue!
        Case Is <= 1: r! = chr! + smallest!: g! = x! + smallest!: b! = smallest!
        Case Is <= 2: r! = x! + smallest!: g! = chr! + smallest!: b! = smallest!
        Case Is <= 3: r! = smallest!: g! = chr! + smallest!: b! = x! + smallest!
        Case Is <= 4: r! = smallest!: g! = x! + smallest!: b! = chr! + smallest!
        Case Is <= 5: r! = x! + smallest!: g! = smallest!: b! = chr! + smallest!
        Case Else: r! = chr! + smallest!: g! = smallest!: b! = x! + smallest!
    End Select
End Sub

'####################################################################################################################

'> merger: Skipping unused SUB mergeHue (r!, g!, b!, r2!, g2!, b2!)

'> merger: Skipping unused SUB rgb2hsl (r!, g!, b!, chr!, smallest!, hue!, sat!, lum!)

'> merger: Skipping unused SUB hsl2rgb (hue!, sat!, lum!, r!, g!, b!)

'> merger: Skipping unused SUB hsl2rgb2 (hue!, chr!, smallest!, r!, g!, b!)

