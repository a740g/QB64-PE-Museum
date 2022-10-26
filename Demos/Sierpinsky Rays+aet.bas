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
'# Sierpinsky Rays+aet for QB64
'# By Zom-B
'#
'# Original art by Daniele (alcamese@libero.it)
'# Tweaked by Athena Tracey (athena_1963@hotmail.com)
'####################################################################################################################

Const Doantialias = -1
Const Usegaussian = 0

'####################################################################################################################

_Title "Sierpinsky Rays+aet"
Width 80, 40

Color 11
Print
Print Tab(30); "Sierpinsky Rays+aet"
Color 7
Print
Print Tab(18); "Original art by Daniele (alcamese@libero.it)"
Print Tab(15); "Tweaked by Athena Tracey (athena_1963@hotmail.com)"
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

Dim Shared magX, magY

magX = 1.300052002080083203328133125325 / halfY%
magY = 1.300052002080083203328133125325 / halfY%

Dim Shared zx(149), zy(149)

'####################################################################################################################

setNumGradients 5

addGradientPoint 0, -0.0450, 0.710, 1.000, 1.000
addGradientPoint 0, 0.0025, 1.000, 0.702, 0.729
addGradientPoint 0, 0.0850, 0.082, 0.431, 0.000
addGradientPoint 0, 0.2300, 0.812, 0.745, 0.824
addGradientPoint 0, 0.5500, 0.380, 0.000, 0.000
addGradientPoint 0, 0.7600, 1.000, 0.757, 1.000
addGradientPoint 0, 0.8800, 0.000, 0.263, 0.000
addGradientPoint 0, 0.9550, 0.710, 1.000, 1.000
addGradientPoint 0, 1.0025, 1.000, 0.702, 0.729
setGradientSmooth 0, -1

addGradientPoint 1, -0.0450, 0.165, 0.000, 0.184
addGradientPoint 1, 0.7475, 0.718, 0.918, 1.000
addGradientPoint 1, 0.8425, 0.945, 0.710, 1.000
addGradientPoint 1, 0.9550, 0.165, 0.000, 0.184
addGradientPoint 1, 1.7475, 0.718, 0.918, 1.000
setGradientSmooth 1, -1

addGradientPoint 2, -0.2750, 0.000, 0.973, 0.114
addGradientPoint 2, 0.0475, 1.000, 0.545, 0.875
addGradientPoint 2, 0.1725, 0.000, 0.345, 0.000
addGradientPoint 2, 0.5500, 1.000, 0.071, 1.000
addGradientPoint 2, 0.7250, 0.000, 0.973, 0.114
addGradientPoint 2, 1.0475, 1.000, 0.545, 0.875
setGradientSmooth 2, -1

addGradientPoint 3, -0.0675, 1.000, 0.502, 1.000
addGradientPoint 3, 0.0700, 0.000, 0.000, 0.698
addGradientPoint 3, 0.1650, 0.725, 0.741, 0.000
addGradientPoint 3, 0.3300, 0.290, 0.000, 0.757
addGradientPoint 3, 0.4550, 0.000, 0.251, 0.039
addGradientPoint 3, 0.6375, 0.584, 0.918, 1.000
addGradientPoint 3, 0.8250, 0.000, 0.165, 0.000
addGradientPoint 3, 0.9325, 1.000, 0.502, 1.000
addGradientPoint 3, 1.0700, 0.000, 0.000, 0.698
setGradientSmooth 3, -1

addGradientPoint 4, -0.1025, 1.000, 0.282, 0.082
addGradientPoint 4, 0.0775, 0.306, 0.376, 1.000
addGradientPoint 4, 0.2225, 0.333, 0.298, 0.000
addGradientPoint 4, 0.3000, 1.000, 1.000, 0.208
addGradientPoint 4, 0.3800, 0.337, 0.271, 0.741
addGradientPoint 4, 0.6400, 0.651, 0.404, 0.220
addGradientPoint 4, 0.8075, 0.000, 1.000, 1.000
addGradientPoint 4, 0.8975, 1.000, 0.282, 0.082
addGradientPoint 4, 1.0775, 0.306, 0.376, 1.000
setGradientSmooth 4, -1

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

    Do
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
    Loop While pixStep% > 2

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
    applyLocation screenX!, screenY!, px, py

    fractal px, py, numIter1%, numIter2%

    outside1 numIter1%, index!
    getGradient 0, index!, r!, g!, b!

    outside2 numIter2%, index!
    getGradient 1, index!, r2!, g2!, b2!
    r! = Abs(r! - r2!): g! = Abs(g! - g2!): b! = Abs(b! - b2!)

    outside3 numIter2%, index!
    getGradient 2, index!, r2!, g2!, b2!
    r1! = r!: g1! = g!: b1! = b!
    mergeOverlay r!, g!, b!, r2!, g2!, b2!
    r! = r1! + (r! - r1!) * 0.45
    g! = g1! + (g! - g1!) * 0.45
    b! = b1! + (b! - b1!) * 0.45

    outside4 numIter2%, index!
    getGradient 3, index!, r2!, g2!, b2!
    r! = r! + r2!: g! = g! + g2!: b! = b! + b2!

    outside5 px, py, numIter2%, index!
    getGradient 4, index!, r2!, g2!, b2!
    r1! = r!: g1! = g!: b1! = b!
    mergeColor r!, g!, b!, r2!, g2!, b2!
    r! = r1! + (r! - r1!) * 0.5
    g! = g1! + (g! - g1!) * 0.5
    b! = b1! + (b! - b1!) * 0.5

    r% = r! * 255
    g% = g! * 255
    b% = b! * 255
End Sub

'####################################################################################################################

Sub applyLocation (inX!, inY!, outX, outY)
    x = (inX! - halfX%) * magX
    y = (halfY% - inY!) * magY
    outX = 0.99999998476912904932780850903444 * x - 1.7453292431333680334067268304459D-4 * y - 0.01168313399#
    outY = 1.7453292431333680334067268304459D-4 * x + 0.99999998476912904932780850903444 * y - 0.00626625065#
End Sub

'####################################################################################################################

Sub fractal (px, py, numIter1%, numIter2%)
    xx = px * px: yy = py * py

    x = Abs(px * xx - 3 * px * yy) * 0.2
    y = Abs(3 * xx * py - py * yy) * 0.2
    x = x - Int(x * 2.5 + 0.5) * 0.4
    y = y - Int(y * 2.5 + 0.5) * 0.4

    zx(0) = x: zy(0) = y

    numIter1% = -1
    numIter2% = -1
    For numIter% = 1 To 149
        x = x * 2: y = y * 2

        If y > 1 Then
            y = y - 1
        ElseIf x > 1 Then
            x = x - 1
        End If

        zx(numIter%) = x: zy(numIter%) = y

        If x * x + y * y > 127 Then
            If numIter2% = -1 Then numIter2% = numIter% - 1
            If numIter1% >= 0 Then Exit Sub
        End If

        bail = Abs(x + y)
        If bail * bail > 127 Then
            If numIter1% = -1 Then numIter1% = numIter% - 1
            If numIter2% >= 0 Then Exit Sub
        End If
    Next

    If numIter1% = -1 Then numIter1% = 149
    If numIter2% = -1 Then numIter2% = 149
End Sub

'####################################################################################################################

Sub outside1 (numIter%, index!)
    index! = Atn(numIter% / 25)
End Sub

'####################################################################################################################

Sub outside2 (numIter%, index!)
    closest = 1E+38
    ix = 0
    iy = 0

    For a% = 1 To numIter%
        x = zx(a%) * zx(a%): y = zy(a%) * zy(a%)
        d = x * x + y * y

        If d < closest Then
            closest = d
            ix = zx(a%)
            iy = zy(a%)
        End If
    Next

    index! = Sqr(Sqr(ix * ix + iy * iy) * 2) / 2
End Sub

'####################################################################################################################

Sub outside3 (numIter%, index!)
    x = zx(numIter% + 1)
    y = zy(numIter% + 1)
    d = atan2(y, x) / pi2
    index! = Sqr((6.349563872353654# - 4.284804271440222# * Log(Log(Sqr(x * x + y * y))) + Abs((d - Int(d)) * 4 - 2)) * 2) / 2
End Sub

'####################################################################################################################

Sub outside4 (numIter%, index!)
    closest = 1E+38

    For a% = 1 To numIter%
        zy2 = zy(a%) * zy(a%)
        d = zx(a%) + zx(a%) * zx(a%) + zy2
        d = Sqr(d * d + zy2)

        If d < closest Then
            closest = d
        End If
    Next

    index! = asin(closest ^ .1) ^ (1 / 1.5) * .41577394#
End Sub

'####################################################################################################################

Sub outside5 (px, py, numIter%, index!)
    r = Sqr(px * px + py * py)
    cost = px / r
    sint = py / r

    ave = 0
    i% = 0
    For a% = 1 To numIter%
        prevave = ave

        x = zx(a%)
        y = zy(a%)
        r = Sqr(x * x + y * y)
        x = zx(a%) / r + cost
        y = zy(a%) / r + sint

        ave = ave + Sqr(x * x + y * y)

        cost = -cost
        sint = -sint
        i% = i% + 1
    Next

    ave = ave / numIter%
    prevave = prevave / (numIter% - 1)
    x = zx(numIter% + 1)
    y = zy(numIter% + 1)
    f = 2.2762545841680618369458486886285 - 1.4426950408889634073599246810019 * Log(Log(Sqr(x * x + y * y)))
    index! = prevave + (ave - prevave) * f

    index! = index! * 2
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

Function asin (y)
    If y = -1 Then asin = -pi05: Exit Function
    If y = 1 Then asin = pi05: Exit Function
    asin = Atn(y / Sqr(1 - y * y))
End Function

'> merger: Skipping unused FUNCTION acos (y)

'> merger: Skipping unused FUNCTION safeAcos (y)

Function atan2 (y, x)
    If x > 0 Then
        atan2 = Atn(y / x)
    ElseIf x < 0 Then
        If y > 0 Then
            atan2 = Atn(y / x) + pi
        Else
            atan2 = Atn(y / x) - pi
        End If
    ElseIf y > 0 Then
        atan2 = pi / 2
    Else
        atan2 = -pi / 2
    End If
End Function

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
'# Merge modes library v0.1 (routines)
'# By Zom-B
'####################################################################################################################

'> merger: Skipping unused SUB testMerge

'####################################################################################################################

Sub mergeOverlay (br!, bg!, bb!, tr!, tg!, tb!)
    If br! <= 0.5 Then br! = br! * tr! * 2 Else br! = 1 - (1 - br!) * (1 - tr!) * 2
    If bg! <= 0.5 Then bg! = bg! * tg! * 2 Else bg! = 1 - (1 - bg!) * (1 - tg!) * 2
    If bb! <= 0.5 Then bb! = bb! * tb! * 2 Else bb! = 1 - (1 - bb!) * (1 - tb!) * 2
End Sub

'> merger: Skipping unused SUB mergeHardLight (br!, bg!, bb!, tr!, tg!, tb!)

'> merger: Skipping unused SUB mergeSoftLight (br!, bg!, bb!, tr!, tg!, tb!)

Sub mergeColor (r!, g!, b!, r2!, g2!, b2!)
    max! = r!
    min! = r!
    If max! < g! Then max! = g!
    If min! > g! Then min! = g!
    If max! < b! Then max! = b!
    If min! > b! Then min! = b!

    lum1! = max! + min!

    max! = r2!
    min! = r2!
    If max! < g2! Then max! = g2!
    If min! > g2! Then min! = g2!
    If max! < b2! Then max! = b2!
    If min! > b2! Then min! = b2!

    sum! = max! + min!
    dif! = max! - min!

    If sum! < 1 Then
        sat2! = dif! / sum!
    Else
        sat2! = dif! / (2 - sum!)
    End If

    If dif! = 0 Then
        lum1! = lum1! * 0.5
        r! = lum1!: g! = lum1!: b! = lum1!
        Exit Sub
    End If

    If lum1! < 1 Then
        chr! = sat2! * lum1!
    Else
        chr! = sat2! * (2 - lum1!)
    End If
    min! = (lum1! - chr!) * 0.5

    If max! = r2! Then
        hue2! = (g2! - b2!) / dif!
        If hue2! < 0 Then
            r! = chr! + min!: g! = min!: b! = chr! * -hue2! + min!
        Else
            r! = chr! + min!: g! = chr! * hue2! + min!: b! = min!
        End If
    ElseIf max! = g2! Then
        hue2! = (b2! - r2!) / dif!
        If hue2! < 0 Then
            r! = chr! * -hue2! + min!: g! = chr! + min!: b! = min!
        Else
            r! = min!: g! = chr! + min!: b! = chr! * hue2! + min!
        End If
    Else
        hue2! = (r2! - g2!) / dif!
        If hue2! < 0 Then
            r! = min!: g! = chr! * -hue2! + min!: b! = chr! + min!
        Else
            r! = chr! * hue2! + min!: g! = min!: b! = chr! + min!
        End If
    End If
End Sub

'> merger: Skipping unused SUB mergeHSLAddition (r!, g!, b!, r2!, g2!, b2!)

'####################################################################################################################

'> merger: Skipping unused SUB mergeHue (r!, g!, b!, r2!, g2!, b2!)

'> merger: Skipping unused SUB rgb2hsl (r!, g!, b!, chr!, smallest!, hue!, sat!, lum!)

'> merger: Skipping unused SUB hsl2rgb (hue!, sat!, lum!, r!, g!, b!)

'> merger: Skipping unused SUB hsl2rgb2 (hue!, chr!, smallest!, r!, g!, b!)

