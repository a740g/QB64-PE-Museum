'********************************************************************
' File:     MINIMAX.BAS
' Purpose:  A Didactics Chessprogram
' Compiler: compiles with QB64 version 1.5
' Authors:  D.Steinwender, Ch.Donninger
' Date:     May 1,1995
' Support files:
'    tf.bas (to/from, interface to Dodo)
'    chessdat\chess.ico
'    chessdat\fonts\liberati.ttf
'    chessdat\s9\ (optional pieces)
' Modified by: R.Frost (converted to QB64, added graphics)
'********************************************************************
'--------------------------------------------------------------------
' Definition of symbolic Constants.
'--------------------------------------------------------------------
Const BoardDim% = 119 ' Dimension of Expanded Chess Board
Const MaxDepth% = 19 ' Maximum search depth
Const Movedirections% = 15 ' Number of Move directions for all Piece.
Const PieceTypes% = 6 ' Number of Piecetypes - considering
' the Move directions (wQueen = bQueen)
Const MoveStackDim% = 1000 ' Dimension of move stacks

' Piece <Colour><Piece>

Const BK% = -6 ' Black piece
Const BQ% = -5
Const BN% = -4
Const BB% = -3
Const BR% = -2
Const BP% = -1
Const Empty% = 0 ' Empty field
Const WP% = 1 ' White piece
Const WR% = 2
Const WB% = 3
Const WN% = 4
Const WQ% = 5
Const WK% = 6
Const Edge% = 100 ' The edge of the chess board

' Material value of the Pieces

Const MatP% = 100
Const MatR% = 500
Const MatB% = 350
Const MatN% = 325
Const MatQ% = 900
Const MatK% = 0 ' As both Sides have just one king, the value can be set to 0

' Assessment for Mate

Const MateValue% = 32000
Const MaxPos% = MatB% ' Maximum of the position assessment

' Bonus for main variants and Killer moves used for the sorting of moves

Const MainVariantBonus% = 500
Const Killer1Bonus% = 250
Const Killer2Bonus% = 150

' Total material value in the initial position

Const MaterialSum% = 4 * (MatR% + MatB% + MatN%) + (2 * MatQ%)
Const EndgameMaterial% = 4 * MatR% + 2 * MatB%

' Field numbers of frequently used Fields ("if Board(E1%)=WK%" means "if Board(25)=6")

Const A1% = 21
Const B1% = 22
Const C1% = 23
Const D1% = 24
Const E1% = 25
Const F1% = 26
Const G1% = 27
Const H1% = 28
Const C2% = 33
Const H2% = 38
Const A3% = 41
Const C3% = 43
Const D3% = 44
Const E3% = 45
Const A6% = 71
Const C6% = 73
Const D6% = 74
Const E6% = 75
Const H6% = 78
Const A7% = 81
Const C7% = 83
Const H7% = 88
Const A8% = 91
Const B8% = 92
Const C8% = 93
Const D8% = 94
Const E8% = 95
Const F8% = 96
Const G8% = 97
Const H8% = 98

' Values of columns and rows

Const ARow% = 1
Const BRow% = 2
Const CRow% = 3
Const DRow% = 4
Const ERow% = 5
Const FRow% = 6
Const GRow% = 7
Const HRow% = 8
Const Column1% = 2
Const Column2% = 3
Const Column3% = 4
Const Column4% = 5
Const Column5% = 6
Const Column6% = 7
Const Column7% = 8
Const Column8% = 9

' Castling numbering (Index into castling array) of move is not a castling move

Const NoCastlingMove% = 0
Const ShortCastlingMove% = 1
Const LongCastlingMove% = 2

' Color of the man who is moving

Const White% = 1
Const Black% = -1

' Symbolic logical Constants

Const True% = 1
Const False% = 0
Const Legal% = 1
Const Illegal% = 0

'-------------------------------------------------------------------
' Definition of data types.
'-------------------------------------------------------------------

' Information for one move, the data type of the move stacks

Type MoveType
    from As Integer ' From field
    too As Integer ' To field
    CapturedPiece As Integer ' Captured piece
    PromotedPiece As Integer ' Promoted piece
    CastlingNr As Integer ' Type of castling move
    EpField As Integer ' Enpassant field
    Value As Integer ' Assessment for the sorting of moves
End Type

' Index of the pieces in the offset list and long/short paths (used by the move generator)

Type PieceOffsetType
    Start As Integer
    Ends As Integer
    Longpaths As Integer
End Type

' Information on pawn/piece constellations

Type BothColourTypes
    White As Integer
    Black As Integer
End Type

' Information on From/Too field (Moves without additional Information)
' Used for the storing promising moves in (main variants, killer moves)

Type FromTooType
    from As Integer
    too As Integer
End Type

' Data structure for storing killer moves.

Type KillerType
    Killer1 As FromTooType
    Killer2 As FromTooType
End Type

'--------------------------------------------------------------------
' Definition of global variables and tables
'--------------------------------------------------------------------

Dim Shared Board(BoardDim%) As Integer
Dim Shared EpField(MaxDepth%) As Integer
Dim Shared MoveStack(MoveStackDim%) As MoveType
Dim Shared MoveControl(H8%) As Integer
' Counts how often a piece has moved from a field. Used to determine castling
' rights (also useable for Assessment)

Dim Shared Castling(2) As Integer ' Has White/Black already Castled?
Dim Shared Index As Integer ' Index in MoveStack

' Saves the position in the MoveStack. Moves of Depth 'n' are stored in
' range (StackLimit(n), StackLimit(n+1)) in MoveStack.

Dim Shared StackLimit(MaxDepth%) As Integer
Dim Shared MVar(MaxDepth%, MaxDepth%) As FromTooType ' Main variants table
Dim Shared KillerTab(MaxDepth%) As KillerType ' Killer moves table

' Tables for Assessment function

Dim Shared PawnControlled(BoardDim%) As BothColourTypes ' Fields that are controlled by pawns

Dim Shared Pawns(HRow% + 1) As BothColourTypes ' Number of pawns per row
Dim Shared Rooks(HRow% + 1) As BothColourTypes ' Number of rooks per row

Dim Shared Mobility(MaxDepth%) As Integer ' Mobility of bishops and rooks
Dim Shared TooFeld(MaxDepth%) As Integer ' TooField of the moves`, used for
' Sorting of moves and for extension of searches
Dim Shared wKing As Integer ' Position of the white king
Dim Shared bKing As Integer ' Position of the black king
Dim Shared MaterialBalance(MaxDepth%) As Integer ' Material balance between White/Black
Dim Shared MaterialTotal(MaxDepth%) As Integer ' Total material on board
Dim Shared Colour As Integer ' Who is to make a move
Dim Shared PlayerPlayer As Integer ' Player vs Player (Memo)Mode on/off
Dim Shared MinDepth As Integer ' Generally searches are performed until MinDepth
Dim Shared MaxExtension As Integer ' Extensions in search tree because of
' Checks and Captures are only carried out until MaxExtension (otheriwse the search can explode)
Dim Shared Depth As Integer ' Search depth = the number of half moves from the initial position
Dim Shared NodeCount As Long ' Number of examined positions/nodes
Dim Shared LastMove As Integer ' Last performed move
Dim Shared InCheck As Integer ' Player is being checked
Dim Shared MoveCount As Integer ' Number of half moves done so far

' InitialPosition of 10 by 12 Board

Dim Shared InitialPosition(BoardDim%) As Integer

For i% = 0 To BoardDim%
    Read InitialPosition(i%)
Next i%

Data 100,100,100,100,100,100,100,100,100,100
Data 100,100,100,100,100,100,100,100,100,100
Data 100,2,4,3,5,6,3,4,2,100
Data 100,1,1,1,1,1,1,1,1,100
Data 100,0,0,0,0,0,0,0,0,100
Data 100,0,0,0,0,0,0,0,0,100
Data 100,0,0,0,0,0,0,0,0,100
Data 100,0,0,0,0,0,0,0,0,100
Data 100,-1,-1,-1,-1,-1,-1,-1,-1,100
Data 100,-2,-4,-3,-5,-6,-3,-4,-2,100
Data 100,100,100,100,100,100,100,100,100,100
Data 100,100,100,100,100,100,100,100,100,100

' Move generator tables

Dim Shared Offset(Movedirections%) As Integer

Offset(0) = -9 ' Diagonal paths
Offset(1) = -11
Offset(2) = 9
Offset(3) = 11

Offset(4) = -1 ' Straight paths
Offset(5) = 10
Offset(6) = 1
Offset(7) = -10

Offset(8) = 19 ' Knight paths
Offset(9) = 21
Offset(10) = 12
Offset(11) = -8
Offset(12) = -19
Offset(13) = -21
Offset(14) = -12
Offset(15) = 8

Dim Shared FigOffset(PieceTypes%) As PieceOffsetType

FigOffset(Empty%).Start = 0 ' Empty field
FigOffset(Empty%).Ends = 0
FigOffset(Empty%).Longpaths = False%

FigOffset(WP%).Start = -1 ' Pawn Moves are produced seperately
FigOffset(WP%).Ends = -1
FigOffset(WP%).Longpaths = False%

FigOffset(WR%).Start = 4 ' Rook
FigOffset(WR%).Ends = 7
FigOffset(WR%).Longpaths = True%

FigOffset(WB%).Start = 0 ' Bishop
FigOffset(WB%).Ends = 3
FigOffset(WB%).Longpaths = True%

FigOffset(WN%).Start = 8 ' Knight
FigOffset(WN%).Ends = 15
FigOffset(WN%).Longpaths = False%

FigOffset(WQ%).Start = 0 ' Queen
FigOffset(WQ%).Ends = 7
FigOffset(WQ%).Longpaths = True%

FigOffset(WK%).Start = 0 ' King
FigOffset(WK%).Ends = 7
FigOffset(WK%).Longpaths = False%

' Centralization tables. We only need files 0..H8, as
' piece can't stand on a field outside H8.
' The lower edge is preserved as we would otherwise have to
' transform board coordinates into centrality coordinates.
' H1 is is further away from the center than is G1. In spite of this,
' H1 has a better center value than G1.
' This Table is used i.e. for king Assessment.
' The Values of G1,H1 imply that the king remains on G1
' after castling and doesn't perform the unnecessary move G1-H1.
' (The knight is neither very well placed on G1 nor H1).

Dim Shared CenterTable(H8%) As Integer

For i% = 0 To H8%
    Read CenterTable(i%)
Next i%

' --- A B C D E F G H ---
Data 0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,0
Data 0,4,0,8,12,12,8,0,4,0
Data 0,4,8,12,16,16,12,8,4,0
Data 0,8,12,16,20,20,16,12,8,0
Data 0,12,16,20,24,24,20,16,12,0
Data 0,12,16,20,24,24,20,16,12,0
Data 0,8,12,16,20,20,16,12,8,0
Data 0,4,8,12,16,16,12,8,4,0
Data 0,4,0,8,12,12,8,0,4

' Assessment of the fields for the pawns.
' Is used the position assessment.
' Center pawns on the 2nd row is bad (they belong in the front).
' F-H pawns should be behind for protection of the king.

Dim Shared wPFieldValue(H7%) As Integer ' White pawns

For i% = 0 To H7%
    Read wPFieldValue(i%)
Next i%

' --- A B C D E F G H ---
Data 0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,0
Data 0,4,4,0,0,0,6,6,6,0
Data 0,6,6,8,8,8,4,6,6,0
Data 0,8,8,16,22,22,4,4,4,0
Data 0,10,10,20,26,26,10,10,10,0
Data 0,12,12,22,28,28,14,14,14,0
Data 0,18,18,28,32,32,20,20,20
' No pawn can stay on the 8th row.

Dim Shared bPFieldValue(H7%) As Integer ' Black pawns

For i% = 0 To H7%
    Read bPFieldValue(i%)
Next i%

' --- A B C D E F G H ---
Data 0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,0
Data 0,18,18,28,32,32,20,20,20,0
Data 0,12,12,22,28,28,14,14,14,0
Data 0,10,10,20,26,26,10,10,10,0
Data 0,8,8,16,22,22,4,4,4,0
Data 0,6,6,8,8,8,4,6,6,0
Data 0,4,4,0,0,0,6,6,6,0
' No pawn can stay on the 8th row.

' Material value of the pieces

Dim Shared PieceMaterial(PieceTypes%) As Integer

PieceMaterial(Empty%) = 0 ' Emptyfield
PieceMaterial(WP%) = MatP% ' Pawn
PieceMaterial(WR%) = MatR% ' Rook
PieceMaterial(WB%) = MatB% ' Bishop
PieceMaterial(WN%) = MatN% ' Knight
PieceMaterial(WQ%) = MatQ% ' Queen
PieceMaterial(WK%) = MatK% ' King

' Symbolic representation of the pieces

Dim Shared FigSymbol(PieceTypes%) As String * 1

FigSymbol(Empty%) = "." ' Emptyfield
FigSymbol(WP%) = "P" ' Pawn
FigSymbol(WR%) = "R" ' Rook
FigSymbol(WB%) = "B" ' Bishop
FigSymbol(WN%) = "N" ' Knight
FigSymbol(WQ%) = "Q" ' Queen
FigSymbol(WK%) = "K" ' King

' Symbolic representations of the pieces for printing

Dim Shared PrintSymbol(PieceTypes%) As String * 1

PrintSymbol(Empty%) = " " ' Emptyfield
PrintSymbol(WP%) = " " ' Pawn
PrintSymbol(WR%) = "R" ' Rook
PrintSymbol(WB%) = "B" ' Bishop
PrintSymbol(WN%) = "N" ' Knight
PrintSymbol(WQ%) = "Q" ' Queen
PrintSymbol(WK%) = "K" ' King

' Color symbols

Dim Shared ColourSymbol(2) As String * 1
ColourSymbol(0) = "." ' Black
ColourSymbol(1) = "." ' Empty field
ColourSymbol(2) = "*" ' White

' vars added by Frost

Dim Shared m$
Dim Shared init, pok, tbmax, ipfile
Dim Shared mfont&(50)
Dim Shared pix&(1, 6)
Dim Shared slash$
Dim Shared minty
'--------------------------------------------------------------------
' The actual program begins here.
'--------------------------------------------------------------------
Cls
Screen _NewImage(400, 400, 32)
$If WIN Then
    $ExeIcon:'./chessdat/chess.ico'
    slash$ = "\"
$Else
        $ExeIcon:'./chessdat/chess.ico'
        slash$ = "\"
        minty=1
$End If
_Title "Minimax by Steinwender/Donninger"
x = Val(Command$) - _Width
If x < 0 Then x = 0
_ScreenMove x, 50
If minty Then
    f$ = "chessdat/fonts/liberati.ttf"
Else
    f$ = "chessdat\fonts\liberati.ttf"
End If
For i = 8 To 32
    mfont&(i) = _LoadFont(f$, i)
    If mfont&(i) = -1 Then System
Next i

Initialize
minit '                                                    Frost initializations
CommandLoop

'--------------------------------------------------------------------
' Here ends the Program
'--------------------------------------------------------------------
Sub minit
    pok = 1 '                                              assume pieces will be loaded
    For i = 0 To 1 '                                       black, white
        For j = 1 To 6
            If i Then t$ = "_w" Else t$ = "_b"
            t$ = Mid$("prbnqk", j, 1) + t$
            If minty Then
                t$ = "chessdat/s9/" + t$ + ".png" '            2-9 sets
            Else
                t$ = "chessdat\s9\" + t$ + ".png" '            2-9 sets
            End If
            pix&(i, j) = _LoadImage(t$)
            If pix&(i, j) > -1 Then pok = 0: Exit Sub '    piece missing, use text
        Next j
    Next i
End Sub
'--------------------------------------------------------------------
' AlphaBeta: Function
' Alpha-Beta Tree search
' Returns Assessment from the viewpoint of the player who is to make
' a move. "Alpha" is lower limit, "Beta" is the upper limit and "Distance"
' the Number of half-moves until the horizon.
' If "Distance" positive, a normal Alpha-Beta search is performed,
' if less than 0 the quiescense search.
' Returns the NegaMax-Value form the point of view of the player who is
' to make a move.
' This procedure is called recursively.
' Locale Variables: i%, Value%, BestValue%, Check%
' Calls: GenerateMoves; PerformMove; TakeBackMove;CopyMainVariant;
' AssessPosition;NextBestMove;
' Calledby: ComputerMove
'---------------------------------------------------------------------
Function AlphaBeta% (Alpha%, Beta%, Distance%)
    NodeCount = NodeCount + 1 ' Additional position examined
    MVar(Depth, Depth).from = 0 ' Delete current main variant

    ' Position is always assessed, i.e. also inside of tree.
    ' This is necessary to recognize checkmate and stalemate. Also,
    ' the assessment is used to control search/extension.
    ' The number of nodes inside the tree is much smaller than that at
    ' the Horizon. i.e. the program does not become significantly slower
    ' because of that.

    ' Assessment from the viewpoint of the player who is to make a move
    Value% = AssessPosition%(Alpha%, Beta%, Colour)

    ' In the case of check, the search is extended, by up to four
    ' half moves total. Otherwise it may happen that the search tree
    ' becomes extremely large thru mutual checks and capture sequences.
    ' As a rule, these move sequences are completely meaningless.

    Check% = InCheck
    ' Side that is moving is in check, extend the search
    Condition1% = (Check% = True% And Depth + Distance% < MaxExtension + 1)

    ' By capture and re-capture on the same field, the search is
    ' extended if the material balance remains approximately
    ' the same and we didn't make too many extensions
    ' so far.
    Condition2% = (Depth >= 2 And Depth + Distance% < MaxExtension)
    Condition2% = Condition2% And TooFeld(Depth) = TooFeld(Depth - 1)
    Condition2% = Condition2% And Value% >= Alpha% - 150 And Value% <= Beta% + 150

    If Condition1% Or Condition2% Then Distance% = Distance% + 1

    ' If more than 5 moves were already performed in the quiescense search
    ' or the opponent is checkmated or we have reached maximunm search
    ' depth imposed by data structures, end the search.

    If Distance% < -5 Or Value% = MateValue% - Depth Or Depth >= MaxDepth% Then
        AlphaBeta% = Value%
        Exit Function
    End If

    ' If during the quiescence search - the player who is to move has a
    ' good position, the search is aborted since by definition the value
    ' can only become beter during the quiescense search.
    ' Warning: Aborts already at Distance 1, i.e. a half-move before the
    ' horizon, in case the player who is to move is not
    ' being checked. This is a selective deviation from
    ' the brute-force-Alpha-Beta scheme.

    If Value% >= Beta% And Distance% + Check% <= 1 Then
        AlphaBeta% = Value%
        Exit Function
    End If

    ' Compute Moves. If Distance <= 0 then (quiescense search) only
    ' capture moves and promotion moves are computed.

    GenerateMoves (Distance%) ' Examine if any moves are available
    If Distance% > 0 Then ' is directly done by determining
        BestValue% = -MateValue% ' BestValue.
    Else ' In quiescence search, the current
        BestValue% = Value% ' position assessment is the lower limit
    End If ' of the search value.

    i% = NextBestMove% ' Examine all moves in sorted sequence.
    Do While i% >= 0 ' So Long as any moves are left.
        PerformMove (i%)
        ' NegaMax principal: The sign is reversed and
        ' the roles of alpha and beta exchanged.
        Value% = -AlphaBeta(-Beta%, -Alpha%, Distance% - 1)
        TakeBackMove (i%)
        If Value% > BestValue% Then ' new best value found
            BestValue% = Value%
            If Value% >= Beta% Then ' Cutoff found
                ' Inside the tree, the main variants are still saved
                If Distance% > 0 Then CopyMainVariant (i%)
                GoTo Done
            End If
            If Value% > Alpha% Then ' Value is the improved lower limit
                If Distance% > 0 Then CopyMainVariant (i%) ' Main variants Saved
                Alpha% = Value% ' Improved alpha value
            End If
        End If
        i% = NextBestMove%
    Loop

    Done:
    ' A good move showing cutoff is entered into the killer table.
    ' Keep the best killer so far as the 2nd best killer.
    If Value% >= Beta% And i% >= 0 Then
        KillerTab(Depth).Killer2 = KillerTab(Depth).Killer1
        KillerTab(Depth).Killer1.from = MoveStack(i%).from
        KillerTab(Depth).Killer1.too = MoveStack(i%).too
    End If

    ' If player has no more legal moves...
    If BestValue% = -(MateValue% - (Depth + 1)) Then
        If Check% = False% Then ' ... but isn't being checked
            AlphaBeta% = 0 ' it's stalemate
            Exit Function
        End If
    End If
    AlphaBeta% = BestValue%
End Function

'--------------------------------------------------------------------
' AssessPosition: Function
' PositionsAssessment
' Returns value from the viewpoint of "Side".
' If material value deviates too far from the Alpha-Beta window
' only material is assessed.
' If "Side" is checkmating, returns (CheckMateValue -Depth).
' If "Side" is being checked, the variable InCheck is changed
' to "True".
' Warning: The Function assumes, both for check/checkmate and for the
' king opposition, that "Side" is the player who is to make move.
'
' Local Variables:
' Value%, PosValue%, i%, j%, k%, Feld%, wBishlop%, bBishlop%
' PawnCount%, MatNum%, wRookon7%, bRookon2%
' wDeveloped%, bDeveloped%
' Calls: InitAssessment; PerformMove; TakeBackMove; AttackingField;
' Calledby: AttackingField; BPAssessment; QPAssessment; CommandLoop;
' AlphaBeta; ComputerMove
'--------------------------------------------------------------------
Function AssessPosition% (Alpha%, Beta%, Side%)
    ' First examine if opponent is checkmated
    ' of "Side" is being checked.
    If Side% = White% Then
        If AttackingField%(bKing, White%) = True% Then
            AssessPosition% = MateValue% - Depth
            Exit Function
        End If
        InCheck = AttackingField%(wKing, Black%) ' Is white being checked?
    Else
        If AttackingField%(wKing, Black%) = True% Then
            AssessPosition% = MateValue% - Depth
            Exit Function
        End If
        InCheck = AttackingField%(bKing, White%) ' Is Black being checked?
    End If
    ' Positional Assessments factors do not outwiegh a heavy material
    ' imbalance. Hence, we omit the position assessment in this case
    ' Exception: The late endgame. Free Pawns have a high value.
    ' A minor piece without pawns is without effect.
    Value% = MaterialBalance(Depth)
    MatNum% = MaterialTotal(Depth)
    If MatNum% > MatB% + MatB% Then
        If Value% < Alpha% - MaxPos% Or Value% > Beta% + MaxPos% Then
            AssessPosition% = Value%
            Exit Function
        End If
    End If
    ' Initialize the lines of rooks and pawns as well as the pawn controls.
    ' This could be computed incrementally significantly faster when
    ' performing (and taking back) the moves. However, this incremental
    ' computation is difficult and error-prone due to the special cases
    ' castling, EnPassant, and promotion.
    ' You could also build a list of pieces in 'IninAssessment' and
    ' in the second turn go thru this list (and no longer the entire
    ' board).
    ' The fastest solution consists of computing this list of pieces
    ' incrementally, too. This complicates, however, the functions
    ' "PerformMove" and "TakeBackMove".
    ' Following the KISS prinipal (Keep It Simple Stupid) this
    ' solution was chosen in MiniMAX.
    InitAssessment
    PosValue% = 0
    ' Used for Assessing the Bishop pair.
    bBishlop% = 0
    wBishlop% = 0
    ' Used for determining insufficient material.
    PawnCount% = 0
    ' White rooks on 7/8th row, black rooks on the 1/2nd
    wRookon7% = 0
    bRookon2% = 0
    ' Developement state: Castled and minor piece developed.
    wDeveloped% = Castling(White% + 1)
    bDeveloped% = Castling(Black% + 1)
    ' Knight on B1 developed?
    If MoveControl(B1%) > 0 Then wDeveloped% = wDeveloped% + 1
    ' Bishop on C1 developed?
    If MoveControl(C1%) > 0 Then wDeveloped% = wDeveloped% + 1
    ' Bishop on F1 developed?
    If MoveControl(F1%) > 0 Then wDeveloped% = wDeveloped% + 1
    ' Knight on G1 developed?
    If MoveControl(G1%) > 0 Then wDeveloped% = wDeveloped% + 1
    ' Knight on B8 developed?
    If MoveControl(B8%) > 0 Then bDeveloped% = bDeveloped% + 1
    ' Bishop on C8 developed?
    If MoveControl(C8%) > 0 Then bDeveloped% = bDeveloped% + 1
    ' Bishop on F8 developed?
    If MoveControl(F8%) > 0 Then bDeveloped% = bDeveloped% + 1
    ' Knight on G8 developed?
    If MoveControl(G8%) > 0 Then bDeveloped% = bDeveloped% + 1
    ' Read the entire board and assess each piece.
    ' The assessment takes white's point of view. For the black
    ' pieces, a positive assessment means that this evaluation
    ' is unfavorable for black.
    For i% = Column1% To Column8%
        Feld% = i% * 10
        For j% = ARow% To HRow%
            Feld% = Feld% + 1
            Select Case Board(Feld%)
                Case BK%
                    If MatNum% < EndgameMaterial% Then ' Endgame assessment for king
                        ' Centralisze the king in the endgame.
                        PosValue% = PosValue% - CenterTable(Feld%)
                    Else
                        ' Not yet castled, but castling rights lost
                        If Castling(Black% + 1) = False% Then
                            If MoveControl(E8%) > 0 Or (MoveControl(H8%) > 0 And MoveControl(A8%) > 0) Then
                                PosValue% = PosValue% + 35
                            End If
                        End If
                        ' King preferably not in the center
                        PosValue% = PosValue% + 4 * CenterTable(Feld%)
                        For k% = -1 To 1
                            ' Bonus for pawn shield before the king
                            If Board(Feld% - 10 + k%) = BP% Then PosValue% = PosValue% - 15
                            ' Pawn shield 2 rows before the king
                            If Board(Feld% - 20 + k%) = BP% Then PosValue% = PosValue% - 6
                            ' Deduct for half-open line occupied by
                            ' enemy rook.
                            If Pawns(j% + k%).White = 0 And Rooks(j% + k%).White > 0 Then
                                PosValue% = PosValue% + 12
                            End If
                        Next k%
                    End If
                Case BQ%
                    ' Avoid Queen outings in the opening of the game.
                    If bDeveloped% < 4 Then
                        If Feld% < A8% Then PosValue% = PosValue% + 15
                    Else ' If development is completed, place the queen near
                        ' the enemy king. Column and row distance.
                        ' between queen and enemy king should be small.
                        ColumnnDiff% = Abs(wKing \ 10 - Feld% \ 10)
                        RownDiff% = Abs(wKing Mod 10 - Feld% Mod 10)
                        PosValue% = PosValue% + 2 * (ColumnnDiff% + RownDiff%)
                    End If
                Case BN% ' Black Knight
                    PosValue% = PosValue% - CenterTable(Feld%) / 2 ' Centralize knight
                Case BB%
                    ' Bishop should not impede black d7/e7 Pawns
                    ' Bishop is also assessed by variable mobility
                    ' in the move generator.
                    If (Feld% = D6% Or Feld% = E6%) And Board(Feld% + 10) = BP% Then
                        PosValue% = PosValue% + 20
                    End If
                    bBishlop% = bBishlop% + 1 ' No. of bishops for the bishop pair
                Case BR% ' Rook influences the king assessment
                    ' Black rook has penetrated row 1 or 2
                    If Feld% <= H2% Then bRookon2% = bRookon2% + 1
                    ' Bring rooks from a and h Columns into the center
                    If j% >= CRow% And j% <= ERow% Then PosValue% = PosValue% - 4
                    ' Rooks on half open and open lines
                    If Pawns(j%).White = 0 Then
                        PosValue% = PosValue% - 8 ' Rook on half open line
                        ' Rook on open line
                        If Pawns(j%).Black = 0 Then PosValue% = PosValue% - 5
                    End If
                Case BP% ' Pawn assessment is relatively complex.
                    ' thus it is accomplised in a seperate routine.
                    PosValue% = PosValue% - BPAssessment%((Feld%), (i%), (j%), (bDeveloped%))
                    PawnCount% = PawnCount% + 1
                Case Empty%
                    ' Do nothing
                Case WP% ' White Assessment is analogous to the black
                    PosValue% = PosValue% + WPAssessment%((Feld%), (i%), (j%), (wDeveloped%))
                    PawnCount% = PawnCount% + 1
                Case WR%
                    ' White rook on 7th or 8th row
                    If Feld% >= A7% Then wRookon7% = wRookon7% + 1
                    ' Bring rooks from a and h columns into the center
                    If j% >= CRow% And j% <= ERow% Then PosValue% = PosValue% + 4
                    ' Rooks on half open and open lines
                    If Pawns(j%).Black = 0 Then
                        PosValue% = PosValue% + 8 ' Rook on half open line
                        ' Rook on open line
                        If Pawns(j%).White = 0 Then PosValue% = PosValue% + 5
                    End If
                Case WB%
                    ' Bishop should not block pawns on D3/E3.
                    If (Feld% = D3% Or Feld% = E3%) And Board(Feld% - 10) = WP% Then
                        PosValue% = PosValue% - 20
                    End If
                    wBishlop% = wBishlop% + 1
                Case WN%
                    PosValue% = PosValue% + CenterTable(Feld%) \ 2
                Case WQ%
                    ' Avoid queen outings in the begining of the game.
                    If wDeveloped% < 4 Then
                        If Feld% > H1% Then PosValue% = PosValue% - 15
                    Else ' Place the queen near the enemy king.
                        ' Column and row distance.
                        ' between queen and enemy king should be small.
                        ColumnnDiff% = Abs(bKing \ 10 - Feld% \ 10)
                        RownDiff% = Abs(bKing Mod 10 - Feld% Mod 10)
                        PosValue% = PosValue% - 2 * (ColumnnDiff% + RownDiff%)
                    End If
                Case WK%
                    If MatNum% < EndgameMaterial% Then ' Endgame assessment for king
                        ' Centralize the king in the endgame
                        PosValue% = PosValue% + CenterTable(Feld%)
                        ' Near opposition of the kings
                        If Abs(Feld% - bKing) = 20 Or Abs(Feld% - bKing) = 2 Then
                            k% = 10
                            ' Opposition in the pawn endgame
                            If MatNum% = 0 Then k% = 30
                            If Colour = White% Then
                                PosValue% = PosValue% - k%
                            Else
                                PosValue% = PosValue% + k%
                            End If
                        End If
                    Else
                        ' Not castled yet, but Castling rights lost.
                        If Castling(White% + 1) = False% Then
                            If MoveControl(E1%) > 0 Or (MoveControl(H1%) > 0 And MoveControl(A1%) > 0) Then
                                PosValue% = PosValue% - 35
                            End If
                        End If
                        ' king preferable not in the center
                        PosValue% = PosValue% - 4 * CenterTable(Feld%)
                        For k% = -1 To 1
                            ' Bonus for pawn shield before the king
                            If Board(Feld% + 10 + k%) = WP% Then PosValue% = PosValue% + 15
                            ' Pawns shield 2 rows before the king
                            If Board(Feld% + 20 + k%) = WP% Then PosValue% = PosValue% + 6
                            ' Deduct for half open lines occupied by
                            ' enemy rook.
                            If Pawns(j% + k%).Black = 0 And Rooks(j% + k%).Black > 0 Then
                                PosValue% = PosValue% - 12
                            End If
                        Next k%
                    End If
            End Select
        Next j%
    Next i%
    ' No pawns left on board and insufficient material
    ' Recognized all elementary draw situations.
    ' KK, KLK, KSK, KSSK, KLKL, KSKL.
    If PawnCount% = 0 Then
        Bed1% = MatNum% <= MatB% ' Less than a bishop
        Bed2% = MatNum% = 2 * MatN% ' Two knights
        ' Two bishops, but material differece less than a pawn
        Bed3% = MatNum% <= 2 * MatB% And Abs(MaterialBalance(Depth)) < MatP%
        If Bed1% Or Bed2% Or Bed3% Then
            AssessPosition% = 0
            Exit Function
        End If
    End If
    ' Bishop pare bonus for White
    If wBishlop% >= 2 Then PosValue% = PosValue% + 15
    ' Bishop pair bonus for Black
    If bBishlop% >= 2 Then PosValue% = PosValue% - 15
    ' White rooks on 7/8th row and black king also
    ' on these rows
    If wRookon7% > 0 And bKing >= A7% Then
        PosValue% = PosValue% + 10
        ' Double rooks extra dangerous
        If wRookon7% > 1 Then PosValue% = PosValue% + 25
    End If
    ' Black rooks on 1/2nd row and white king also
    ' on these rows
    If bRookon2% > 0 And wKing <= H2% Then
        PosValue% = PosValue% - 10
        If bRookon2% > 1 Then PosValue% = PosValue% - 25
    End If
    If Side% = Black% Then ' Assessment was from white's point of view,
        PosValue% = -PosValue% ' changed sign for black
    End If
    ' Consider the mobility of bishop and rooks
    ' by the move generator. Mobility(Depth) is the
    ' mobility of the oppenent, Mobility(Depth-1) that of
    ' "Side" (before the oppenent has made a move).
    If Depth >= 1 Then
        PosValue% = PosValue% - ((Mobility(Depth) - Mobility(Depth - 1)) / 16)
    End If
    AssessPosition% = Value% + PosValue%
End Function

'--------------------------------------------------------------------
' AttackingField: Function
' Examine whether Player "Side" is attacking the field "Field".
' Returns "True" if field is attacked by "Side", otherwise "False".
' Algorithm: Imagine "Field" occupied by a super piece, that can move
' in any direction. If this super piece 'captures' e.g.
' a rook belonging to "Side" then the rook is actually
' attacking the field.
'
' Locale Variables: i%, Direction%, too%, Piece%, slide%
' Calls:
' Calledby: AssessPosition; GenerateMoves; InputMove; MoveList
'--------------------------------------------------------------------
Function AttackingField% (Feld%, Side%)
    ' First test the special case of pawns. They have the same direction
    ' as bishops but don't slide.

    If Side% = White% Then
        ' Must go in the opposite direction of pawns. D5 is attacked
        ' by pawn on E4.
        If Board(Feld% - 9) = WP% Or Board(Feld% - 11) = WP% Then
            AttackingField% = True%
            Exit Function
        End If
    End If
    If Side% = Black% Then
        If Board(Feld% + 9) = BP% Or Board(Feld% + 11) = BP% Then
            AttackingField% = True%
            Exit Function
        End If
    End If

    ' Examine the knight
    For i% = 8 To 15 ' Knight directions
        too% = Feld% + Offset(i%)
        If Board(too%) = Empty% Or Board(too%) = Edge% Then GoTo w1
        If Side% = White% Then
            If Board(too%) = WN% Then
                AttackingField% = True%
                Exit Function
            End If
        ElseIf Board(too%) = BN% Then
            AttackingField% = True%
            Exit Function
        End If
        w1:
    Next i%

    ' Examine sliding pieces and king.
    For i% = 0 To 7
        too% = Feld%
        Direction% = Offset(i%)
        Slide% = 0
        Slideon1:
        Slide% = Slide% + 1
        too% = too% + Direction%
        If Board(too%) = Empty% Then
            GoTo Slideon1
        End If
        ' When the edge is reached then new direction
        If Board(too%) = Edge% Then GoTo w2

        ' Hit a piece. Piece must be color side.
        ' Also, the current direction must be a possible move direction
        ' of the piece. The king can only do one step.

        Piece% = Board(too%)
        If Side% = White% Then
            If Piece% > 0 Then ' White Ppece
                If Piece% = WK% Then
                    If Slide% <= 1 Then ' king is slow paced
                        AttackingField% = True%
                        Exit Function
                    End If
                Else
                    ' As far as sliding pieces are concerned, the current
                    ' direction muse be a possible move diection of the piece.

                    If FigOffset(Piece%).Start <= i% Then
                        If FigOffset(Piece%).Ends >= i% Then
                            AttackingField% = True%
                            Exit Function
                        End If
                    End If
                End If
            End If
        Else
            If Piece% < 0 Then ' Black piece
                If Piece% = BK% Then
                    If Slide% <= 1 Then
                        AttackingField% = True%
                        Exit Function
                    End If
                Else
                    If FigOffset(-Piece%).Start <= i% Then
                        If FigOffset(-Piece%).Ends >= i% Then
                            AttackingField% = True%
                            Exit Function
                        End If
                    End If
                End If
            End If
        End If
        w2:
    Next i%

    ' All directions exhausted, didn't hit a piece.
    ' I.e. Side in not attacking the field.

    AttackingField% = False%
End Function

'--------------------------------------------------------------------
' BPAssessment: Function
' Assessment of one black pawn. Besides passed parameters, the
' pawn controls, pawn lines, and rook lines must be correctly
' engaged.
' Returns the assessment from black's point of view.
' Calls:
' Calledby: AssessPosition
'--------------------------------------------------------------------
Function BPAssessment% (Feld%, Column%, row%, developed%)
    Column% = (Column8% + Column1%) - Column% ' Flip row. This makes higher
    'row = better as for white.
    If MaterialTotal(Depth) > EndgameMaterial% Then ' Opening or midgame
        Value% = bPFieldValue(Feld%)
        ' If development incomplete, don't push edge pawns forward
        If developed% < 4 Then
            If (row% >= FRow% Or row% <= BRow%) And Column% > Column3% Then
                Value% = Value% - 15
            End If
        End If
    Else ' In the endgame, all lines are equally good.
        ' Bring pawns forward.
        Value% = Column% * 4
    End If

    ' Is the pawn isolated?
    ' Edge pawns don't require extra treatment. Pawns(ARow-1) is
    ' the left edge, Pawns(HRow+1) the right edge. No pawn is
    ' placed on these edges.
    If Pawns(row% - 1).Black = 0 And Pawns(row% + 1).Black = 0 Then
        Value% = Value% - 12 ' Isolated
        ' Isolated double pawn
        If Pawns(row%).Black > 1 Then Value% = Value% - 12
    End If

    ' double pawn
    If Pawns(row%).Black > 1 Then Value% = Value% - 15

    ' Duo or guarded pawns get a bonus
    ' e.g. e5,d5 is a Duo, d6 guards e5
    If PawnControlled(Feld%).Black > 0 Or PawnControlled(Feld% - 10).Black > 0 Then
        Value% = Value% + Column%
    End If
    If Pawns(row%).White = 0 Then ' Half-open column
        ' Pawn left behind on half-open column:
        ' Left-behind pawn is not guarded by its fellow pawns..
        Condition1% = PawnControlled(Feld%).Black = 0
        ' ... and can't advance because of enemy pawns
        ' control the field in front of him.
        Condition2% = PawnControlled(Feld% - 10).White > PawnControlled(Feld% - 10).Black
        If Condition1% And Condition2% Then
            Value% = Value% - 10
            ' Rook impeded by left-behind pawn
            If Rooks(row%).White > 0 Then Value% = Value% - 8
        Else
            ' Pawn is a free pawn, on an half-open column and the
            ' fields ahead on his column are not controlled by
            ' enemy pawns.
            For j% = Feld% To A3% Step -10 ' Until 3rd Row
                If PawnControlled(j%).White > 0 Then
                    BPAssessment% = Value%
                    Exit Function
                End If
            Next j%
            ' Found a free pawn. In the endgame, a free pawn is more important
            ' than in midgame.
            If MaterialTotal(Depth) < EndgameMaterial% Then
                Value% = Value% + Column% * 16 ' The more advanced, the better
                ' Rook guards a free pawn on the same column
                If Rooks(row%).Black > 0 Then Value% = Value% + Column% * 2
                ' Enemy rook on the same column
                If Rooks(row%).White > 0 Then Value% = Value% - Column% * 2
                ' Pure pawn endgame. Free pawn particularly valuable.
                If MaterialTotal(Depth) = 0 Then Value% = Value% + Column% * 8
                ' Guarded free pawn
                If PawnControlled(Feld%).Black > 0 Or PawnControlled(Feld% - 10).Black > 0 Then
                    Value% = Value% + Column% * 4
                End If
                ' Free pawn blocked by a white piece. This piece is not
                ' threatened by fellow pawns.
                If Board(Feld% - 10) < 0 And PawnControlled(Feld% - 10).Black = 0 Then
                    Value% = Value% - Column% * 4
                End If
            Else ' Free pawn in the midgame
                Value% = Value% + Column% * 8
                ' Guarded free pawn
                If PawnControlled(Feld%).Black > 0 Or PawnControlled(Feld% - 10).Black > 0 Then
                    Value% = Value% + Column% * 2
                End If
            End If
        End If
    End If
    BPAssessment% = Value%
End Function

'--------------------------------------------------------------------
' CommandLoop:
' Reads the player's commands in a loop and calls
' the appropriate functions. The loop is terminated by
' the "EN" command.
' If the input is not a command it is interpreted as a
' move (on the form "e2e4" (from-field,to-field).
' and ignored as a command. See also: PrintLogo
' Calls: Gameover; Initialize; Displayboard; InputPosition;
' ComputerMove; Flipboard; MoveList; MoveBack;
' ComputingDepth; InitGameTree; AssessPosition;
' Calledby: Main
'--------------------------------------------------------------------
Sub CommandLoop
    Do
        'Cls
        DisplayBoard (False%) ' my new line

        If init = 1 Then DisplayMove (0)
        init = 1

        If Len(Command$) Then
            ToFrom 1, "", 3
            Commands$ = m$
        Else
            Locate 2, 6: Print Space$(10);
            Locate 2, 6: Input Commands$
        End If

        Commands$ = UCase$(Commands$)

        Select Case Commands$
            Case "RE"
                Locate 2, 6: Print "White resigns"
                Sleep 5
                Locate 2, 6: Print Space$(20);
                Initialize
                init = 0
            Case "EN"
                Close
                System
            Case "NG"
                'Print " New Game"
                Initialize
                init = 0
            Case "DB"
                DisplayBoard (False%)
            Case "CP"
                InputPosition
            Case "PL"
                ComputerMove
            Case "ML"
                MoveList
            Case "TB"
                MoveBack
            Case "HE"
                PrintLogo
            Case "SD"
                ComputingDepth
            Case "DA"
                InitGameTree
                'Print " Assessment= "; AssessPosition%(-MateValue%, MateValue%, Colour)
            Case Else
                If InputMove%(Commands$) = False% Then
                    init = 0
                    'Print " Illegal move or unknown Command"
                Else
                    ComputerMove
                End If
        End Select
    Loop
End Sub
'--------------------------------------------------------------------
' ComputerMove:
' Computes the next computer move.
' The search is iteratively deepened until MinDepth.
' The search uses "Aspiration"-Alpha-Beta.
' The search process can be interupted by
' a keypress.
' If the search wasn't interupted and no checkmate/stalemate
' exists, the best move is performed.
' Calls: InitGameTree; GenerateMoves; DisplayMove; TakeBackMove;
' PerformMove; CopyMainVariant; DisplayMVar; PrintMove
' AssessPosition;
' Calledby: CopyMainVariant; AlphaBeta; AssessPosition; CommandLoop
'--------------------------------------------------------------------
Sub ComputerMove
    Dim tmp As MoveType ' Temporary MoveType Variable

    InitGameTree
    ' Assess the initial position. End search if opponent is already checkmate.
    Value% = AssessPosition%(-MateValue%, MateValue%, Colour)
    If Value% = MateValue% Then
        Locate 2, 7
        Print " Checkmate!"
        Exit Sub
    End If

    ' Store "Checked state". Required to recognize
    ' stalemate at the end of the search.
    Check% = InCheck
    NodeCount = 0

    ' Start time of the computation. Used for displaying nodes/second.
    Starttime = Timer

    ' Generate all pseudo-legal moves
    GenerateMoves (1)

    ' You should/could remove all illegal moves from the MoveStack
    ' here and only keep computing with legal moves.
    ' (Has only an optical effect, however, as the search is always aborted
    ' immediately after performing an illegal move).

    ' Iterative deepening: Distance is the number of half-moves until the
    ' horizon. Is not equal to the depth, however, as the distance can
    ' increased during the search process (e.g. by checks).

    For Distance% = 1 To MinDepth
        If Distance% = 1 Then ' On Depth 1, we compute with open windows
            Alpha% = -MateValue% ' We have no good assessment value for
            Beta% = MateValue% ' the position yet.
        Else ' On the higher levels, the result shold not
            Beta% = Alpha% + 100 ' differ significantly from the result of the
            Alpha% = Alpha% - 100 ' previous depth.
        End If

        ' For capture moves and checks, the search is extended.
        ' this variable limits the extensions.
        MaxExtension = Distance% + 3
        ' PRINT
        ' PRINT
        'Locate 0 + Distance%, 52
        'Print Distance%;
        ' PRINT " Alpha-Beta Window = ["; Alpha%; ","; Beta%; "]"
        MovesInLine% = 0
        ' PRINT " ";

        ' Compute the value of each move
        For i% = 0 To StackLimit(1) - 1
            If InKey$ <> "" Then
                ' Stop the calculation if a key is pressed.
                'Print " Computation interrupted!"
                Exit Sub
            End If

            MovesInLine% = MovesInLine% + 1
            ' Initialize the main variant and display
            ' the move just examined.
            MVar(Depth, Depth).from = 0
            'Locate i% + 1, 50
            ' DisplayMove(i%)
            If MovesInLine% Mod 9 = 8 Then ' Eight moves per line
                ' PRINT
                MovesInLine% = 0
                ' PRINT " ";
            End If
            ' Perform move, compute value, take back move.
            PerformMove ((i%))
            Value% = -AlphaBeta(-Beta%, -Alpha%, Distance% - 1)
            TakeBackMove ((i%))
            If i% = 0 Then ' Was it the first move (the best yet)?
                ' This move requires an exact value.
                If Value% < Alpha% Then
                    ' Search for the best move until now 'falls down' out the
                    ' window (the program understands the mishap). Requires
                    ' a renewed search with windows opened 'below'.
                    Alpha% = -MateValue%
                    Beta% = Value%
                    ' PRINT "? ["; Alpha%; ","; Beta%; "]"
                    MovesInLine% = 0
                    ' PRINT " ";
                    PerformMove ((i%))
                    Value% = -AlphaBeta(-Beta%, -Alpha%, Distance% - 1)
                    TakeBackMove ((i%))
                ElseIf Value% >= Beta% Then ' Falls up
                    Alpha% = Value%
                    Beta% = MateValue%
                    ' PRINT "! ["; Alpha%; ","; Beta%; "]"
                    MovesInLine% = 0
                    ' PRINT " ";
                    PerformMove ((i%))
                    Value% = -AlphaBeta(-Beta%, -Alpha%, Distance% - 1)
                    TakeBackMove ((i%))
                End If

                ' There is just a slim chance that a subsequent move is t,
                ' even better. We continue calculating with a null window
                ' as this expedites the search.

                Alpha% = Value%
                Beta% = Alpha% + 1
                ' PRINT
                'Locate 1, 51
                'Print " Best Move: ";
                'DisplayMove(i%)
                'Locate 16, 51
                'Print "Value ="; Value%
                CopyMainVariant (i%)
                ' LOCATE 0 + Distance%, 58
                DisplayMVar
                MovesInLine% = 0
                ' PRINT " ";
            Else ' Already computed the best move yet to SearchDepth
                If Value% > Alpha% Then
                    ' New best move found. Currently, it is only known
                    ' that it is better. The exact value must be computed
                    ' again with an open window.
                    BestValue% = Alpha%
                    Alpha% = Value%
                    Beta% = MateValue%
                    PerformMove ((i%))
                    Value% = -AlphaBeta(-Beta%, -Alpha%, Distance% - 1)
                    TakeBackMove ((i%))

                    ' Is it also better with the open window?
                    ' Solely applying alpha-beta, the move must always
                    ' be better with the open window. Since the window is
                    ' considered by the extensions and in the selectivity,
                    'the outcome may be different
                    ' in our case.

                    If Value% > BestValue% Then
                        Alpha% = Value%
                        Beta% = Alpha% + 1
                        ' PRINT
                        ' PRINT " Best Move: ";
                        ' DisplayMove(i%)
                        ' PRINT "Value ="; Value%
                        CopyMainVariant (i%)
                        ' LOCATE 0 + Distance%, 54
                        DisplayMVar
                        MovesInLine% = 0
                        ' PRINT " ";
                        ' Place the best move at the start of the MoveList.
                        ' Push the other moves one position up.
                        tmp = MoveStack(i%)
                        For j% = i% To 1 Step -1
                            MoveStack(j%) = MoveStack(j% - 1)
                        Next j%
                        MoveStack(0) = tmp
                    End If
                End If
            End If
        Next i%
    Next Distance%

    Endtime = Timer

    If Alpha% > -(MateValue% - 1) Then
        ' PRINT
        ' PRINT
        ' PRINT " Computer Player: ";
        'DisplayMove(0) ' Best Move is always sorted into
        ' position 0 of the Movestacks
        ' PRINT
        ' LOCATE 17, 51
        ' PRINT " Value ="; Alpha%; ", Positions ="; NodeCount;
        Time% = Endtime - Starttime
        Comtime% = Comtime% + Time%
        ' Locate 20, 50: Print "TOT "; Comtime%
        ' Prevent division by zero on nodes/second
        If Time% = 0 Then Time% = 1
        'Locate 18, 51
        ' Print ", Time="; Time%; "Sec., Positions/Sec. ="; NodeCount \ Time%

        PerformMove (0)
        'mdisp
        'PrintMove(0)
        Locate 1, 6
        If Alpha% >= MateValue% - 10 Then
            'Print " I checkmate in "; (MateValue% - 2 - Alpha%) \ 2; " moves "
        Else
            If Alpha% <= -MateValue% + 10 Then
                'Print " I'm checkmate in "; (Alpha% + MateValue% - 1) \ 2; " moves"
            End If
        End If
    Else
        Locate 2, 6
        If Check% = True% Then
            Print "Checkmate"
        Else
            Print " Stalemate"
        End If
        _Delay 2
        Cls
    End If
End Sub

' -----------------------------------------------------------------
' ComputingDepth:
' Input minimum computing depth
' Calls: None
' Calledby:
' -----------------------------------------------------------------
Sub ComputingDepth
    Print " Computing depth is"; MinDepth
    Input " New computing depth: ", Inputs$
    tmp% = Val(Inputs$)
    If tmp% > 0 And tmp% < MaxDepth% - 9 Then
        MinDepth = tmp%
    Else
        Print " Invalid computing depth"
    End If
End Sub

'--------------------------------------------------------------------
' CopyMainVariant:
' Saves the current move in the Main variant and copies
' the continuation that was found on the next depth.
' Calls:
' Calledby: ComputerMove;
'--------------------------------------------------------------------
Sub CopyMainVariant (CurrMove%)
    ' New main variant is a continuation of this variant
    MVar(Depth, Depth).from = MoveStack(CurrMove%).from
    MVar(Depth, Depth).too = MoveStack(CurrMove%).too
    i% = 0
    Do
        i% = i% + 1
        MVar(Depth, Depth + i%) = MVar(Depth + 1, Depth + i%)
    Loop Until MVar(Depth + 1, Depth + i%).from = 0
End Sub

'--------------------------------------------------------------------
' DisplayBoard:
' Display of the game board and the game/Board state
' Only displays game/board state if "BoardOnly" is false
'
' The SGN-Function (Sign) returns the sign, i.e. -1 or +1
' The ABS-Function returns the absolute value (without sign)
' Calls: Fieldnotation
' Calledby:
'--------------------------------------------------------------------
Sub DisplayBoard (BoardOnly%)
    mdisp
    Exit Sub
    ' Display board
    'Locate 1, 1
    For i% = Column8% To Column1% Step -1 ' For all rows
        'Print
        'Print i% - 1; " "; ' Row coordinates
        For j% = ARow% To HRow% ' For all lines
            Piece% = Board(i% * 10 + j%)
            Side% = Sgn(Piece%) ' Compute color from piece.
            ' Empty field has Color 0
            Piece% = Abs(Piece%) ' Piece type
            Print ColourSymbol(Side% + 1); FigSymbol(Piece%); " ";
        Next j%
    Next i%
    'Print
    'Print "   ";
    'For j% = ARow% To HRow% ' Line coordinates 'a'...'h'
    '    Print "  "; Chr$(Asc("a") - 1 + j%);
    'Next j%
    'Print ' Empty line
    'Print ' Empty line
    Exit Sub 'my new line

    If BoardOnly% Then Exit Sub

    ' Remaining board/game state

    If Colour = White% Then
        Print " White";
    Else
        Print " Black";
    End If
    Print " is to make a move"

    Print " Material balance = "; MaterialBalance(Depth)
    Print " En Passant Field = "; Fieldnotation$(EpField(Depth))

    ' Castling is in principle possible if the king and appropriate
    ' rook have not moved.

    Print " Castling state black = ";
    If MoveControl(E8%) + MoveControl(H8%) = 0 Then Print "0-0 ";
    If MoveControl(E8%) + MoveControl(A8%) = 0 Then Print "0-0-0";
    Print
    Print " Castling State white = ";
    If MoveControl(E1%) + MoveControl(H1%) = 0 Then Print "0-0 ";
    If MoveControl(E1%) + MoveControl(A1%) = 0 Then Print "0-0-0";
    Print
End Sub

Sub mdisp
    Dim s, s2, x, y, ts As _Unsigned Long
    s = 40: s2 = s - 1
    For i% = Column8% To Column1% Step -1 ' For all rows
        For j% = ARow% To HRow% ' For all lines
            x = j% * s
            y = (9 - i%) * s + 40
            Piece% = Board(i% * 10 + j%)
            Side% = Sgn(Piece%) ' Compute color from piece.
            Piece% = Abs(Piece%) ' Piece type
            If (i% + j%) Mod 2 Then ts = _RGB32(50) Else ts = _RGB32(100)
            Line (x, y)-Step(s2, s2), ts, BF
            If FigSymbol(Piece%) <> "." Then
                If pok Then
                    _PutImage (x, y)-(x + s2, y + s2), pix&(-(Side% = 1), Piece%), 0
                Else
                    Color _RGB32(Side% * 255), ts
                    _Font mfont&(32)
                    _PrintString (x + 7, y + 5), FigSymbol(Piece%)
                    _Font 16
                    Color _RGB32(255), _RGB32(0)
                End If
            End If
        Next j%
    Next i%
End Sub
'--------------------------------------------------------------------
' DisplayMove:
' Display the current move in chess notation.
' Castling is 'E1-G1' and not O-O
' CurrMove% is the index of the move into MoveStack.
' Calls:
' Calledby:
'--------------------------------------------------------------------
Sub DisplayMove (CurrMove%)
    from% = MoveStack(CurrMove%).from
    too% = MoveStack(CurrMove%).too
    Locate 2, 39: Print Space$(10);
    Locate 2, 39
    Print FigSymbol(Abs(Board(too%))); ' Type of piece
    Print Fieldnotation$(from%); ' Initial field
    If MoveStack(CurrMove%).CapturedPiece = Empty% Then
        Print "-"; ' Normal move
    Else
        Print "x"; ' Capture move
    End If
    Print Fieldnotation$(too%); ' Target field

    If Len(Command$) Then
        m$ = Fieldnotation$(from%) + Fieldnotation$(too%)
        ToFrom 0, m$, 3
    End If
    ' promoted, add promotion piece
    If MoveStack(CurrMove%).PromotedPiece <> Empty% Then
        'Print FigSymbol(MoveStack(CurrMove%).PromotedPiece);
    End If
    ' PRINT " ";
End Sub

'--------------------------------------------------------------------
' DisplayMVar:
' Display the current main variant, Only the from-to fields
' are output.
' Calls: Fieldnotation;
' Calledby:
'--------------------------------------------------------------------
Sub DisplayMVar
    Exit Sub
    'PRINT " Main variants: ";
    i% = 0

    Do While MVar(0, i%).from <> 0
        Locate 1 + i%, 56
        'Print Fieldnotation$(MVar(0, i%).from); "-";
        'Print Fieldnotation$(MVar(0, i%).too); " ";
        i% = i% + 1
    Loop
    'PRINT
End Sub

'-----------------------------------------------------------------------
' Fieldnotation: Function
' Converts internal FieldNumber to Fieldnotation.
' Returns '--' if the number is not on the board
'
' Notes:
' The \ Operator is integer division.
' The Mod (Modulo) operator returns the remainder of an intege division.
' Calls:
' Calledby:
'-----------------------------------------------------------------------
Function Fieldnotation$ (Fieldnum%)
    ' See if correct
    If Fieldnum% < A1% Or Fieldnum% > H8% Or Board(Fieldnum%) = Edge% Then
        Fieldnotation$ = "--"
    Else
        s$ = Chr$(Asc("A") - 1 + Fieldnum% Mod 10) ' Line
        s$ = s$ + Chr$(Asc("1") - 2 + Fieldnum% \ 10) ' Row
        Fieldnotation$ = LCase$(s$)
    End If
End Function

'--------------------------------------------------------------------
' Fieldnumber: Function
' Converts Fieldnotation (e.g. "A1") to internal Fieldnumber.
' Returns "Illegal" if input is incorrect
' Line coordinates must be passed as uppercase letters.
' Calls:
' Calledby: Fieldnotation
'--------------------------------------------------------------------
Function Fieldnumber% (Fieldnote$)
    row$ = Left$(Fieldnote$, 1)
    Column$ = Mid$(Fieldnote$, 2, 1)
    ' See if correct
    If row$ < "A" Or row$ > "H" Or Column$ < "1" Or Column$ > "8" Then
        Fieldnumber% = Illegal%
        Exit Function
    End If
    Fieldnumber% = (Asc(row$) - Asc("A") + 1) + 10 * (Asc(Column$) - Asc("1") + 2)
End Function
'---------------------------------------------------------------------
' GameOver:
' Stores the game and game parameters on the harddisk.
' Note: Not implemented in version 1.0
' Calls:
' Calledby:
'--------------------------------------------------------------------
' GenerateMoves:
' Generates moves and places them on the MoveStack
' Returns the number of moves.
' If "AllMoves" is greater than 0, all pseudo-legal
' moves are produced, otherwise all pseudo-legal capture moves,
' promotions, En Passant, and castling moves.
' Calls: SavePromotion; SaveMove; SaveCaptureMove; SaveEpMove
' AttackingField;
' Calledby: AttackingField, InputMove, MoveList, AlphaBeta,ComputerMove
'--------------------------------------------------------------------
Sub GenerateMoves (AllMoves%)
    Index = StackLimit(Depth) ' Start of MoveList on current depth
    Mobility(Depth) = 0

    ' Search the board for pieces

    For from% = A1% To H8%
        Piece% = Board(from%)
        ' Empty and edge fields make no moves
        If Piece% = Empty% Or Piece% = Edge% Then GoTo NextField
        ' Piece must also be of correct color
        If Colour = White% And Piece% < 0 Then GoTo NextField
        If Colour = Black% And Piece% > 0 Then GoTo NextField
        Piece% = Abs(Piece%) ' Type of Piece. Color doesn't influence
        ' (except for pawns) the move diretion.
        If Piece% = WP% Then ' Pawns moves
            If Colour = White% Then
                If Board(from% + 10) = Empty% Then
                    If from% >= A7% Then
                        Call SavePromotion(from%, from% + 10)
                    ElseIf AllMoves% > 0 Then
                        Call SaveMove(from%, from% + 10)
                        ' double-step possible?
                        If from% <= H2% And Board(from% + 20) = Empty% Then
                            Call SaveMove(from%, from% + 20)
                            ' Move has already increased Index
                            MoveStack(Index - 1).EpField = from% + 10
                        End If
                    End If
                End If
                If Board(from% + 11) < 0 Then ' Pawn can capture black piece
                    If from% >= A7% Then
                        Call SavePromotion(from%, from% + 11)
                    Else
                        Call SaveCaptureMove(from%, from% + 11)
                    End If
                End If
                If Board(from% + 9) < 0 Then ' Likewise in other capture direction
                    If from% >= A7% Then
                        Call SavePromotion(from%, from% + 9)
                    Else
                        Call SaveCaptureMove(from%, from% + 9)
                    End If
                End If
            ElseIf Colour = Black% Then ' Same for black pawns
                If Board(from% - 10) = Empty% Then
                    If from% <= H2% Then
                        Call SavePromotion(from%, from% - 10)
                    ElseIf AllMoves% > 0 Then
                        Call SaveMove(from%, from% - 10)
                        ' double-steps possible?
                        If from% >= A7% And Board(from% - 20) = Empty% Then
                            Call SaveMove(from%, from% - 20)
                            ' Move has already increased Index
                            MoveStack(Index - 1).EpField = from% - 10
                        End If
                    End If
                End If
                ' For black pawns also examine the edge,
                ' not for white as the edge > 0.
                If Board(from% - 11) > 0 And Board(from% - 11) <> Edge% Then
                    If from% <= H2% Then
                        Call SavePromotion(from%, from% - 11)
                    Else
                        Call SaveCaptureMove(from%, from% - 11)
                    End If
                End If
                If Board(from% - 9) > 0 And Board(from% - 9) <> Edge% Then
                    If from% <= H2% Then
                        Call SavePromotion(from%, from% - 9)
                    Else
                        Call SaveCaptureMove(from%, from% - 9)
                    End If
                End If
            End If
            GoTo NextField ' Examine next field
        End If

        ' Moves for all other pieces are computed
        ' by way of move offset.

        Longpaths% = FigOffset(Piece%).Longpaths
        For i% = FigOffset(Piece%).Start To FigOffset(Piece%).Ends
            Direction% = Offset(i%)
            too% = from%
            Slideon2:
            too% = too% + Direction%
            If Board(too%) = Empty% Then
                If AllMoves% > 0 Then
                    Call SaveMove(from%, too%)
                End If
                If Longpaths% Then ' Bishop, rook and queen
                    GoTo Slideon2
                Else ' Knight and king
                    GoTo NextDirection
                End If
            End If
            If Board(too%) = Edge% Then ' Hit the edge, keep searching
                GoTo NextDirection ' in an another direction.
            End If
            ' Hit a piece. Must be of the correct color.
            CaptureMove% = Colour = White% And Board(too%) < 0
            CaptureMove% = CaptureMove% Or (Colour = Black% And Board(too%) > 0)
            If CaptureMove% Then Call SaveCaptureMove(from%, too%)
            NextDirection:
        Next i%
        NextField:
    Next from%

    ' En Passant Move

    If EpField(Depth) <> Illegal% Then
        ep% = EpField(Depth)
        If Colour = White% Then
            If Board(ep% - 9) = WP% Then
                Call SaveEpMove(ep% - 9, ep%, ep% - 10)
            End If
            If Board(ep% - 11) = WP% Then
                Call SaveEpMove(ep% - 11, ep%, ep% - 10)
            End If
        Else
            If Board(ep% + 9) = BP% Then
                Call SaveEpMove(ep% + 9, ep%, ep% + 10)
            End If
            If Board(ep% + 11) = BP% Then
                Call SaveEpMove(ep% + 11, ep%, ep% + 10)
            End If
        End If
    End If

    ' Castling is also performed in the quiescence search because it has a
    ' strong influence on the assessment. (Whether this is appropriate,
    ' is a matter of dispute even amoung leading programmers).

    ' Compute castling
    If Colour = White% Then
        If wKing = E1% And MoveControl(E1%) = 0 Then
            ' Is short castling allowed?
            OK% = Board(H1%) = WR% And MoveControl(H1%) = 0
            OK% = OK% And Board(F1%) = Empty% And Board(G1%) = Empty%
            OK% = OK% And AttackingField%(E1%, Black%) = False%
            OK% = OK% And AttackingField%(F1%, Black%) = False%
            OK% = OK% And AttackingField%(G1%, Black%) = False%
            If OK% Then
                Call SaveMove(E1%, G1%) ' Save king's move
                MoveStack(Index - 1).CastlingNr = ShortCastlingMove%
            End If
            ' Is long castling allowed?
            OK% = Board(A1%) = WR% And MoveControl(A1%) = 0
            OK% = OK% And Board(D1%) = Empty%
            OK% = OK% And Board(C1%) = Empty%
            OK% = OK% And Board(B1%) = Empty%
            OK% = OK% And AttackingField%(E1%, Black%) = False%
            OK% = OK% And AttackingField%(D1%, Black%) = False%
            OK% = OK% And AttackingField%(C1%, Black%) = False%
            If OK% Then
                Call SaveMove(E1%, C1%) ' Save king's move
                ' Save type of castling
                MoveStack(Index - 1).CastlingNr = LongCastlingMove%
            End If
        End If
    Else ' Black is to make a move
        If bKing = E8% And MoveControl(E8%) = 0 Then
            ' Is short castling allowed?
            OK% = Board(H8%) = BR% And MoveControl(H8%) = 0
            OK% = OK% And Board(F8%) = Empty% And Board(G8%) = Empty%
            OK% = OK% And AttackingField%(E8%, White%) = False%
            OK% = OK% And AttackingField%(F8%, White%) = False%
            OK% = OK% And AttackingField%(G8%, White%) = False%
            If OK% Then
                Call SaveMove(E8%, G8%) ' Save king's move
                MoveStack(Index - 1).CastlingNr = ShortCastlingMove%
            End If
            ' Is long castling allowed?
            OK% = Board(A8%) = BR% And MoveControl(A8%) = 0
            OK% = OK% And Board(D8%) = Empty%
            OK% = OK% And Board(C8%) = Empty%
            OK% = OK% And Board(B8%) = Empty%
            OK% = OK% And AttackingField%(E8%, White%) = False%
            OK% = OK% And AttackingField%(D8%, White%) = False%
            OK% = OK% And AttackingField%(C8%, White%) = False%
            If OK% Then
                Call SaveMove(E8%, C8%) ' Save king's move
                ' Save type of castling
                MoveStack(Index - 1).CastlingNr = LongCastlingMove%
            End If
        End If
    End If
    StackLimit(Depth + 1) = Index ' Mark end of MoveList
End Sub

'--------------------------------------------------------------------
' InitAssessment:
' Compute the Pawn controls and the columns on which pawns and
' rooks are placed. Called by the assessment function
' for initialization.
' Calls:
' Calledby:
'--------------------------------------------------------------------
Sub InitAssessment
    ' Delete pawn controls
    For i% = A1% To H8%
        PawnControlled(i%).White = 0
        PawnControlled(i%).Black = 0
    Next i%

    ' Also initialize edges. This eliminates the
    ' need to examine edge columns.

    For i% = ARow% - 1 To HRow% + 1
        Pawns(i%).White = 0
        Pawns(i%).Black = 0
        Rooks(i%).White = 0
        Rooks(i%).Black = 0
    Next i%

    For i% = A1% To H8%
        If Board(i%) = Empty% Or Board(i%) = Edge% Then GoTo NextFeld
        Select Case Board(i%)
            Case WP%
                PawnControlled(i% + 9).White = PawnControlled(i% + 9).White + 1
                PawnControlled(i% + 11).White = PawnControlled(i% + 11).White + 1
                Pawns(i% Mod 10).White = Pawns(i% Mod 10).White + 1
            Case BP%
                PawnControlled(i% - 9).Black = PawnControlled(i% - 9).Black + 1
                PawnControlled(i% - 11).Black = PawnControlled(i% - 11).Black + 1
                Pawns(i% Mod 10).Black = Pawns(i% Mod 10).Black + 1
            Case BR%
                Rooks(i% Mod 10).Black = Rooks(i% Mod 10).Black + 1
            Case WR%
                Rooks(i% Mod 10).White = Rooks(i% Mod 10).White + 1
            Case Else
        End Select
        NextFeld:
    Next i%
End Sub

'--------------------------------------------------------------------
' InitGameTree:
' Initialize the GameTree
' Calls:
' Calledby:
'--------------------------------------------------------------------
Sub InitGameTree
    ' In Depth 0 nothing has been computed, game tree already initialized
    If Depth = 0 Then Exit Sub
    EpField(0) = EpField(1)
    MaterialBalance(0) = MaterialBalance(1)
    MaterialTotal(0) = MaterialTotal(1)
    Depth = 0
End Sub

'--------------------------------------------------------------------
' Initialize:
' Initialize the board and the game status
' Calls: None
' Calledby: Main
'--------------------------------------------------------------------
Sub Initialize
    ' Board Initialization, build InitialPosition
    MoveCount = 0 ' Counts the half-moves in the game

    For i% = 0 To BoardDim%
        Board(i%) = InitialPosition(i%)
    Next i%

    ' Positions of the kings in the InitialPosition
    wKing = E1%
    bKing = E8%

    ' No castling yet
    For i% = 0 To 2
        Castling(i%) = False%
    Next i%

    For i% = A1% To H8%
        MoveControl(i%) = 0 ' Initially no piece has moved
    Next i%

    EpField(0) = Illegal% ' En Passant status
    MaterialTotal(0) = MaterialSum% ' Material value (of pieces) in InitialPosition
    MaterialBalance(0) = 0 ' Material balance even
    PlayerPlayer = False%
    StackLimit(0) = 0 ' Limit of Movestacks
    MinDepth = 4 ' Default ComputingDepth
    Depth = 0 ' Current depth in the game tree
    Colour = White% ' White has the first move
End Sub

'--------------------------------------------------------------------
' InputMove: Function
' Attempts to interpret the passed string as a move.
' IF it's a legal move, that move is performed and the function
' returns the value "True%". If no (legal) move can be identified
' the function returns the value 'False%'.
' Calls: GenerateMoves; InitGameTree; DisplayMove; PerformMove
' TakeBackMove; PrintMove; AttackingField; Fieldnotation;
' Fieldnumber;
' Calledby:
'--------------------------------------------------------------------
Function InputMove% (Move$)
    If Len(Move$) < 4 Then ' Only from-to representation is allowed
        InputMove% = False%
        Exit Function
    End If

    from% = Fieldnumber%(Move$)
    too% = Fieldnumber%(Mid$(Move$, 3, 2))
    Call GenerateMoves(1)
    For i% = StackLimit(Depth) To StackLimit(Depth + 1) - 1
        If MoveStack(i%).from = from% And MoveStack(i%).too = too% Then
            If MoveStack(i%).PromotedPiece <> Empty% Then ' Promotions
                If Mid$(Move$, 5, 1) = "N" Then ' in the sequence queen, knight
                    i% = i% + 1 ' bishop and rook
                ElseIf Mid$(Move$, 5, 1) = "B" Then
                    i% = i% + 2
                ElseIf Mid$(Move$, 5, 1) = "R" Then
                    i% = i% + 3
                End If
            End If
            Call InitGameTree
            'Print " Your Move: ";
            'Call DisplayMove(i%)
            tmp% = LastMove ' Temp storage for last move so far.
            Call PerformMove(i%) ' Warning: PerformMove changes
            DisplayBoard (False%) ' my new line
            ' the Color. Next inquiry of color must
            ' compensate for this.
            If Colour = Black% Then
                If AttackingField%(wKing, Black%) = True% Then
                    Print " White king on "; Fieldnotation$(wKing); " is being checked"
                    Call TakeBackMove((i%))
                    LastMove = tmp% ' No new move made. Restore
                    InputMove% = False% ' last move.
                    Exit Function
                End If
            ElseIf AttackingField%(bKing, White%) = True% Then
                Print " Blackr king on "; Fieldnotation$(bKing); " is being checked"
                Call TakeBackMove((i%))
                LastMove = tmp%
                InputMove% = False%
                Exit Function
            End If
            InputMove% = True%
            Exit Function
        End If
    Next i%
    InputMove% = False% ' The input move was not found in MoveList
End Function

'--------------------------------------------------------------------
' InputPosition:
' Input of any position
' Calls: DisplayBoard; PrintPosition; ReadPiece;
' Calledby: CommandLoop
'--------------------------------------------------------------------
Sub InputPosition
    Depth = 0 ' Position becomes root of the search tree
    PieceInput:
    Input " Delete Board (Y/N) ", Inputs$
    Inputs$ = UCase$(Inputs$) ' change to upper case
    If Inputs$ = "Y" Then
        For i% = Column1% To Column8%
            For j% = ARow% To HRow%
                Board(i% * 10 + j%) = Empty%
            Next j%
        Next i%
    End If
    ' Do not interpret "Y" as no
    Print " White:"
    ReadPiece (White%)
    Print " Black:"
    ReadPiece (Black%)

    ' Compute material balance and examine if each side
    ' has just one king.

    MaterialBalance(0) = 0
    MaterialTotal(0) = 0
    wKings% = 0
    bKings% = 0
    For i% = A1% To H8% ' Read each field
        If Board(i%) = Empty% Or Board(i%) = Edge% Then
            GoTo Continue ' Empty or edge field found, go to next field
        End If
        ' New Material balance
        ' White piece positively affects the balance, back negatively
        MaterialBalance(0) = MaterialBalance(0) + Sgn(Board(i%)) * PieceMaterial(Abs(Board(i%)))
        If Abs(Board(i%)) <> WP% Then
            MaterialTotal(0) = MaterialTotal(0) + PieceMaterial(Abs(Board(i%)))
        End If
        If Board(i%) = WK% Then
            wKings% = wKings% + 1 ' Number and position of white kings
            wKing = i%
        End If
        If Board(i%) = BK% Then
            bKings% = bKings% + 1 ' Black kings
            bKing = i%
        End If
        Continue:
    Next i%
    If bKings% <> 1 Or wKings% <> 1 Then
        Print "Illegal position, each side must have exactly one king"
        Call DisplayBoard(True%)
        GoTo PieceInput
    End If

    Repeat: ' The entry must be complete with a legal position
    ' otherwise the movegenerator doesn't work.
    Input " Whose move (W/B): "; Inputs$
    Inputs$ = UCase$(Inputs$)
    If Inputs$ = "W" Then
        Colour = White%
    ElseIf Inputs$ = "B" Then
        Colour = Black% ' Material balance was computed from
        MaterialBalance(0) = -MaterialBalance(0) 'white's viewpoint until now.
    Else
        GoTo Repeat
    End If

    For i% = A1% To H8% ' To simplify, we assume here that
        MoveControl(i%) = 1 ' all pieces have already moved once.
    Next i% ' Otherwise, the assessment function
    ' believes this is an
    ' Initial position.
    MoveControl(E1%) = 0
    MoveControl(A1%) = 0 ' Single exception: The king and rook
    MoveControl(H1%) = 0 ' fields represent the castling state
    MoveControl(E8%) = 0 ' and must therefore be reset
    MoveControl(A8%) = 0 ' to zero.
    MoveControl(H8%) = 0

    EpField(0) = Illegal%
    Input " Change the status (Y/N): "; Inputs$
    Inputs$ = UCase$(Inputs$)
    If Inputs$ = "Y" Then
        ' Input the enpassant Field. if following input ins't correct,
        ' enpassant is not possible.
        Input " En passant column: "; Inputs$
        Inputs$ = UCase$(Inputs$)
        ep$ = Left$(Inputs$, 1)
        If ep$ >= "A" And ep$ <= "H" Then
            If Colour = White% Then
                EpField(0) = A6% + Asc(ep$) - Asc("A")
            Else
                EpField(0) = A3% + Asc(ep$) - Asc("A")
            End If
        End If
        ' Black short castling. By default, castling is possible.
        Input " Black 0-0 legal (Y/N) : "; Inputs$
        Inputs$ = UCase$(Inputs$)
        If Inputs$ = "N" Then
            MoveControl(H8%) = 1 ' Move the rook. This eliminates
            ' the castling.
        End If
        Input " Black 0-0-0 legal (Y/N): "; Inputs$
        Inputs$ = UCase$(Inputs$)
        If Inputs$ = "N" Then
            MoveControl(A8%) = 1
        End If
        Input " White 0-0 legal (Y/N) : "; Inputs$
        Inputs$ = UCase$(Inputs$)
        If Inputs$ = "N" Then
            MoveControl(H1%) = 1
        End If
        Input " White 0-0-0 legal (Y/N) : "; Inputs$
        Inputs$ = UCase$(Inputs$)
        If Inputs$ = "N" Then
            MoveControl(A1%) = 1
        End If
    End If
    MoveCount = 0 ' Reset the move count
    Call DisplayBoard(False%) ' Display the new board
End Sub
' -----------------------------------------------------------------
' MoveBack:
' Takes back a move
' Since the pllayer moves aaaaare not stored, a mizimun of
' one move can be taken back.
' Calls: TakeBackMove; DisplayBoard; PrintBack
' Calledby:
' -----------------------------------------------------------------
Sub MoveBack
    If Depth <> 1 Then
        Print " Unfortunately not possible."
        Exit Sub
    End If
    Call TakeBackMove(LastMove)
    Call DisplayBoard(False%)
End Sub
' -----------------------------------------------------------------
' MoveList:
' Generate all moves and display them on the monitor
' Calls: GenerateMoves; DisplayMove; AttackingField;
' Calledby:
' -----------------------------------------------------------------
Sub MoveList
    Call GenerateMoves(1)
    If Colour = White% Then
        CheckMated% = AttackingField%(bKing, White%)
    Else
        CheckMated% = AttackingField%(wKing, Black%)
    End If
    If CheckMated% Then
        Print " The king cannot be captured"
        Exit Sub
    End If
    'Print " "; Index - StackLimit(Depth); "pseudo legal moves`"
    For i% = StackLimit(Depth) To Index - 1
        'Call DisplayMove(i%)
        If (i% - StackLimit(Depth)) Mod 9 = 8 Then ' After 8 moves start
            'Print ' a new line.
        End If
    Next i%
    'Print ' Carriage return
End Sub
'--------------------------------------------------------------------
' NextBestMove: Function
' From the possible moves of a certain depth the best,
' not-yet-played move is selected. Returns the index of the move
' into MoveStack. If all moves were already played, an
' impossible index (-1) is returned.
' The value of a move is determined by the move generator.
' This function finishes the move sorting in the search.
' Calls:
' Calledby:
'--------------------------------------------------------------------
Function NextBestMove%
    BestMove% = -1
    BestValue% = -MateValue%
    For i% = StackLimit(Depth) To StackLimit(Depth + 1) - 1
        If MoveStack(i%).Value > BestValue% Then ' Found new best move
            BestMove% = i%
            BestValue% = MoveStack(i%).Value
        End If
    Next i%
    ' Mark the selected move so it isn't selected again
    ' on the next call.
    If BestMove% >= 0 Then MoveStack(BestMove%).Value = -MateValue%
    NextBestMove% = BestMove%
End Function

'--------------------------------------------------------------------
' PerformMove:
' Performs a move at the board and updates the status and
' the search depth.
' CurrMove% is the index of the move into MoveStack.
' Calls:
' Calledby:
'--------------------------------------------------------------------
Sub PerformMove (CurrMove%)
    MoveCount = MoveCount + 1 ' Increase move count by one half-move
    from% = MoveStack(CurrMove%).from
    too% = MoveStack(CurrMove%).too
    ep% = MoveStack(CurrMove%).EpField
    LastMove = CurrMove%
    Depth = Depth + 1 ' One step deeper in the tree
    TooFeld(Depth) = too% ' Used for move sorting and extension
    ' of the search.
    EpField(Depth) = Illegal%
    ' Material balance is always seen from the viewpoint of the player who is
    ' to make a move. Therefore, flip the sign.
    MaterialBalance(Depth) = -MaterialBalance(Depth - 1)
    MaterialTotal(Depth) = MaterialTotal(Depth - 1)
    ' The piece is moving from the 'from' field to the 'to' field
    MoveControl(from%) = MoveControl(from%) + 1
    MoveControl(too%) = MoveControl(too%) + 1
    If ep% <> Illegal% Then
        If Board(ep%) = Empty% Then ' Pawn move from 2nd to 4th row
            EpField(Depth) = ep%
        Else ' Enemy pawn is captured enpassant
            Board(ep%) = Empty% ' Remove captured pawn
            MaterialBalance(Depth) = MaterialBalance(Depth) - MatP%
        End If
    Else ' If a piece is captured, change the material balance
        If MoveStack(CurrMove%).CapturedPiece <> Empty% Then ' Piece was captured
            MatChange% = PieceMaterial(MoveStack(CurrMove%).CapturedPiece)
            MaterialBalance(Depth) = MaterialBalance(Depth) - MatChange%
            ' Sum up only the officer's material value
            If MatChange% <> MatP% Then
                MaterialTotal(Depth) = MaterialTotal(Depth) - MatChange%
            End If
        End If
    End If
    Board(too%) = Board(from%) ' Place onto board
    Board(from%) = Empty%

    ' Now the special cases promotion and castling
    If MoveStack(CurrMove%).PromotedPiece <> Empty% Then ' Pawn promotion
        Board(too%) = Colour * MoveStack(CurrMove%).PromotedPiece
        MatChange% = PieceMaterial(MoveStack(CurrMove%).PromotedPiece) - MatP%
        MaterialBalance(Depth) = MaterialBalance(Depth) - MatChange%
        ' Pawns are not included in MaterialTotal.
        MaterialTotal(Depth) = MaterialTotal(Depth) + MatChange% + MatP%
    Else
        If MoveStack(CurrMove%).CastlingNr = ShortCastlingMove% Then
            Board(too% + 1) = Empty% ' 'to' is G1 or G8 (depending on color)
            Board(too% - 1) = Colour * WR% ' Put white/black Rook on F1/F8
            Castling(Colour + 1) = True%
        ElseIf MoveStack(CurrMove%).CastlingNr = LongCastlingMove% Then
            Board(too% - 2) = Empty% ' 'to' is C1 or C8
            Board(too% + 1) = Colour * WR%
            Castling(Colour + 1) = True%
        End If
    End If
    ' If king has moved, update the king's position
    If Board(too%) = WK% Then
        wKing = too%
    ElseIf Board(too%) = BK% Then
        bKing = too%
    End If
    ' Flip the color (the Side who is to make the move)
    Colour = -Colour
End Sub

'--------------------------------------------------------------------
' PrintLogo:
' Displays the program logo/menu on the monitor (see CommandLoop
' Calls: None
' Calledby: Main;
'--------------------------------------------------------------------
Sub PrintLogo
    Cls
    Print "  MiniMAX 1.0 (Basic)"
    Print
    Print "  by Dieter Steinwender"
    Print "  and Chrilly Donninger"
    Print
    Print "  Input a move (e.g. G1F3)"
    Print "  or one of the following commands:"
    Print
    Print "  NG --> New game"
    Print "  EN --> End the program"
    Print "  DB --> Display board"
    Print "  CP --> Input position (chess problem)"
    Print "  PL --> Play, computer move"
    Print "  DL --> Display move list"
    Print "  TB --> Take back one move"
    Print "  SD --> Set computing depth"
    Print "  DA --> Display assessment"
    Sleep
End Sub
'--------------------------------------------------------------------
' ReadPiece:
' Reads the Piece for the "Side"
' Format is: <piece><field> e.g. "Ke1".
' "." is "empty field", i.e. removes any piece from that field.
' Calls: Fieldnumber;
' Calledby:
'--------------------------------------------------------------------
Sub ReadPiece (Side%)
    NextPiece:
    Input Inputs$
    If Inputs$ = "" Then Exit Sub ' Exit if input is void
    If Len(Inputs$) < 3 Then GoTo BadInput ' Input to short
    Inputs$ = UCase$(Inputs$) ' Uppercase
    Piece$ = Left$(Inputs$, 1)
    Feld$ = Mid$(Inputs$, 2, 2)
    For i% = 0 To PieceTypes% ' From empty field to king
        If Piece$ = FigSymbol(i%) Then
            ' Converts chess notation into field value
            ' First character of input was already used for the Piece
            Feld% = Fieldnumber%(Feld$)
            If Feld% = Illegal% Then GoTo BadInput
            If i% = WP% Then ' Pawns only legal on 2nd thru 7th row
                If Feld% <= H1% Or Feld% >= A8% Then GoTo BadInput
            End If
            Piece% = i% * Side% ' If color is black the sign
            ' of the piece is reversed.
            Board(Feld%) = Piece% ' Place piece on the board
            GoTo NextPiece
        End If
    Next i%
    BadInput:
    Print " Bad Input Entered "
    GoTo NextPiece
End Sub

'--------------------------------------------------------------------
' SaveCaptureMove:
' Save a capture move in MoveStack.
' Calls:
' Calledby:
'--------------------------------------------------------------------
Sub SaveCaptureMove (from%, too%)
    ' King cannot be captured
    If Board(too%) = WK% Or Board(too%) = BK% Then Exit Sub

    FigValue% = PieceMaterial(Abs(Board(too%)))
    MoveStack(Index).from = from%
    MoveStack(Index).too = too%
    MoveStack(Index).CapturedPiece = Abs(Board(too%))

    ' Rule for move sorting: Capturee the mose valuable piece
    ' using the the least valuable piece
    MoveStack(Index).Value = FigValue% - (PieceMaterial(Abs(Board(from%))) \ 8)

    ' Extra Bonus for capturing the piece just moved
    If Depth > 0 Then
        If too% = TooFeld(Depth - 1) Then
            MoveStack(Index).Value = MoveStack(Index).Value + 300
        End If
    End If

    ' Bonus for Main variant moves and "killer" moves
    Killer1% = KillerTab(Depth).Killer1.from = from%
    Killer1% = Killer1% And KillerTab(Depth).Killer1.too = too%
    Killer2% = KillerTab(Depth).Killer2.from = from%
    Killer2% = Killer2% And KillerTab(Depth).Killer2.too = too%
    MVarMove% = MVar(0, Depth).from = from% And MVar(0, Depth).too = too%
    If MVarMove% Then
        MoveStack(Index).Value = MoveStack(Index).Value + MainVariantBonus%
    ElseIf Killer1% Then
        MoveStack(Index).Value = MoveStack(Index).Value + Killer1Bonus%
    ElseIf Killer2% Then
        MoveStack(Index).Value = MoveStack(Index).Value + Killer2Bonus%
    End If

    MoveStack(Index).PromotedPiece = Empty%
    MoveStack(Index).CastlingNr = NoCastlingMove%
    MoveStack(Index).EpField = Illegal%
    If Index < MoveStackDim% Then ' Prevent MoveStack overflow
        Index = Index + 1
    Else
        Print " ERROR: Move stack overflow"
        System ' Exit to DOS
    End If
End Sub

'--------------------------------------------------------------------
' SaveEpMove:
' Save En Passant Move in the MoveStack.
' Calls:
' Calledby:
'--------------------------------------------------------------------
Sub SaveEpMove (from%, too%, ep%)
    ' King cannot be captured
    If Board(too%) = WK% Or Board(too%) = BK% Then Exit Sub
    MoveStack(Index).from = from%
    MoveStack(Index).too = too%
    MoveStack(Index).CapturedPiece = WP%
    MoveStack(Index).PromotedPiece = Empty%
    MoveStack(Index).CastlingNr = NoCastlingMove%
    MoveStack(Index).EpField = ep%
    MoveStack(Index).Value = MatP%

    If Index < MoveStackDim% Then ' Prevent MoveStack overflow
        Index = Index + 1
    Else
        Print " ERROR: Move stack overflow"
        System ' Exit to DOS
    End If
End Sub

'---------------------------------------------------------------------
' SaveMove:
' Save a normal move in the MoveStack.
' As a side effect, this procedure provides the mobility of bishop
' and rook, as well as the value of the move for the pre-sorting.
' Calls:
' Calledby:
'---------------------------------------------------------------------
Sub SaveMove (from%, too%)
    ' Increse the mobility of the bishop and Rook.
    ' Mobility in the center is rated higher
    ' than mobility at the edge.

    If Colour = White% Then
        If Board(from%) = WB% Or Board(from%) = WR% Then
            Mobility(Depth) = Mobility(Depth) + CenterTable(too%)
        End If
    Else
        If Board(from%) = BB% Or Board(from%) = BR% Then
            Mobility(Depth) = Mobility(Depth) + CenterTable(too%)
        End If
    End If

    ' Assess the move for move sorting. Bonus for main variant or "killer"
    Killer1% = KillerTab(Depth).Killer1.from = from%
    Killer1% = Killer1% And KillerTab(Depth).Killer1.too = too%
    Killer2% = KillerTab(Depth).Killer2.from = from%
    Killer2% = Killer2% And KillerTab(Depth).Killer2.too = too%
    MVarMove% = MVar(0, Depth).from = from% And MVar(0, Depth).too = too%
    If MVarMove% Then
        MoveStack(Index).Value = MainVariantBonus%
    ElseIf Killer1% Then
        MoveStack(Index).Value = Killer1Bonus%
    ElseIf Killer2% Then
        MoveStack(Index).Value = Killer2Bonus%
    Else
        MoveStack(Index).Value = Empty%
    End If

    MoveStack(Index).from = from%
    MoveStack(Index).too = too%
    MoveStack(Index).CapturedPiece = Empty%
    MoveStack(Index).PromotedPiece = Empty%
    MoveStack(Index).CastlingNr = NoCastlingMove%
    MoveStack(Index).EpField = Illegal%

    If Index < MoveStackDim% Then ' Prevent MoveStack overflow
        Index = Index + 1
    Else
        Print " ERROR: Move stack overflowed"
        System ' In this case "ease out" to DOS
    End If
End Sub

'--------------------------------------------------------------------
' SavePromotion:
' Produce all possible pawn promotions
' Calls: SaveMove; SaveCaptureMove;
' Calledby:
'--------------------------------------------------------------------
Sub SavePromotion (from%, too%)
    If Board(too%) = Empty% Then
        For i% = WQ% To WR% Step -1 ' Sequence queen,knight,bishop,rook
            Call SaveMove(from%, too%)
            MoveStack(Index - 1).PromotedPiece = i%
        Next i%
    Else ' Promotion with capture
        For i% = WQ% To WR% Step -1
            Call SaveCaptureMove(from%, too%)
            MoveStack(Index - 1).PromotedPiece = i%
        Next i%
    End If
End Sub
'--------------------------------------------------------------------
' TakeBackMove:
' Takes back a move in the tree.
' CurrMove% is the index of the move in MoveStack.
' Calls:
' Calledby:
'--------------------------------------------------------------------
Sub TakeBackMove (CurrMove%)
    MoveCount = MoveCount - 1
    from% = MoveStack(CurrMove%).from
    too% = MoveStack(CurrMove%).too
    ep% = MoveStack(CurrMove%).EpField

    Colour = -Colour ' Other side to move
    Depth = Depth - 1 ' One level higher in tree
    Board(from%) = Board(too%) ' Put back the piece
    Board(too%) = Empty%
    If ep% <> Illegal% And MoveStack(CurrMove%).CapturedPiece = WP% Then
        Board(ep%) = -Colour ' WP%=White%, BP%=Black%
        ' Put back captured piece
    ElseIf MoveStack(CurrMove%).CapturedPiece <> Empty% Then
        Board(too%) = (-Colour) * MoveStack(CurrMove%).CapturedPiece
    End If
    ' Adjust move counter
    MoveControl(from%) = MoveControl(from%) - 1
    MoveControl(too%) = MoveControl(too%) - 1
    ' If castling put back rook
    If MoveStack(CurrMove%).CastlingNr = ShortCastlingMove% Then
        Board(too% + 1) = Colour * WR%
        Board(too% - 1) = Empty%
        Castling(Colour + 1) = False%
    ElseIf MoveStack(CurrMove%).CastlingNr = LongCastlingMove% Then
        Board(too% - 2) = Colour * WR%
        Board(too% + 1) = Empty%
        Castling(Colour + 1) = False%
    End If
    If MoveStack(CurrMove%).PromotedPiece <> Empty% Then
        Board(from%) = Colour ' Take back pawn promotion
    End If
    ' IF the king has moved, update the king's Position
    If Board(from%) = WK% Then
        wKing = from%
    ElseIf Board(from%) = BK% Then
        bKing = from%
    End If
End Sub
'--------------------------------------------------------------------
' WPAssessment: Function
' Assessment of one white Pawn.
' Analogous to the assessment of black pawns.
' Returns the assessment from white's viewpoint.
' Calls:
' Calledby: AssessPosition
'--------------------------------------------------------------------
Function WPAssessment% (Feld%, Column%, row%, developed%)
    If MaterialTotal(Depth) > EndgameMaterial% Then ' Opening of midgame
        Value% = wPFieldValue(Feld%)
        ' If development incomplete, don't push edge pawns forward
        If developed% < 4 Then
            If (row% >= FRow% Or row% <= BRow%) And Column% > Column3% Then
                Value% = Value% - 15
            End If
        End If
    Else ' In then endgame, all lines are equally good.
        Value% = Column% * 4 ' Bring pawns forward.
    End If

    ' Is the pawn isolated?
    ' Edge pawns don't require extra treatment. Pawns(ARow-1) is
    ' the left edge, Pawns(HRow+1) the right edge. No pawn is
    ' placed on these edges.
    If Pawns(row% - 1).White = 0 And Pawns(row% + 1).White = 0 Then
        Value% = Value% - 12 ' Isolated
        ' Isolated double pawn
        If Pawns(row%).White > 1 Then Value% = Value% - 12
    End If

    ' Double pawns
    If Pawns(row%).White > 1 Then Value% = Value% - 15

    ' Duo or guarded pawn gets a bonus
    If PawnControlled(Feld%).White > 0 Or PawnControlled(Feld% + 10).White > 0 Then
        Value% = Value% + Column%
    End If

    If Pawns(row%).Black = 0 Then ' Half-open column
        ' Pawn left behind on half-open column:
        ' Left behind pawn is not guarded by its fellow pawns..
        Condition1% = PawnControlled(Feld%).White = 0
        ' ... and can't advance because of enemy pawns
        ' control the field in front of him.
        Condition2% = PawnControlled(Feld% + 10).Black > PawnControlled(Feld% + 10).White
        If Condition1% And Condition2% Then
            Value% = Value% - 10
            ' Rook impeded by left-behind pawn
            If Rooks(row%).Black > 0 Then Value% = Value% - 8
        Else
            ' Pawn is a free pawn, on a half-open column and the
            ' fields ahead on his column are not controlled by
            ' enemy pawns.
            For j% = Feld% To H6% Step 10 ' Until 6th row
                If PawnControlled(j%).Black > 0 Then
                    WPAssessment% = Value%
                    Exit Function
                End If
            Next j%

            ' Free pawn found. In the endgame, a free pawn is more important
            ' than in midgame.
            If MaterialTotal(Depth) < EndgameMaterial% Then
                Value% = Value% + Column% * 16 ' The more advanced the better
                ' Rook guards free pawn on the same column
                If Rooks(row%).White > 0 Then Value% = Value% + Column% * 2
                ' Enemy rook on the same column.
                If Rooks(row%).Black > 0 Then Value% = Value% - Column% * 2
                ' Pure pawn endgame. Free pawn particularly valuable.
                If MaterialTotal(Depth) = 0 Then Value% = Value% + Column% * 8
                ' Guarded free pawn
                If PawnControlled(Feld%).White > 0 Or PawnControlled(Feld% + 10).White > 0 Then
                    Value% = Value% + Column% * 4
                End If
                ' Free pawn blocked by a black piece. This piece is not
                ' threatened by fellow pawns.
                If Board(Feld% + 10) < 0 And PawnControlled(Feld% + 10).White = 0 Then
                    Value% = Value% - Column% * 4
                End If
            Else ' Free pawn in the midgame
                Value% = Value% + Column% * 8
                ' Guarded free pawn
                If PawnControlled(Feld%).White > 0 Or PawnControlled(Feld% + 10).White > 0 Then
                    Value% = Value% + Column% * 2
                End If
            End If
        End If
    End If
    WPAssessment% = Value%
End Function

' interface for playing against Dodo

'$include: 'tf.bas'
