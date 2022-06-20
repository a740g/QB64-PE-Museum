'#######################
' aKFrameWork v1.012
'  A Qb64 Framework
'      library
'#######################
'Copyright © 2016-17 by Ashish Kushwaha
'Last Update on 12:47 PM 8/25/2016
'Any suggestion or bug about this library are always welcome
'find me at http://www.qb64.net/forum

' Changes by a740g to work with QBPE

$If AKFRAMEWORK_GLOBAL_BAS = UNDEFINED Then
    $Let AKFRAMEWORK_GLOBAL_BAS = TRUE

    Declare Library
        Sub glutSetCursor (ByVal style&)
    End Declare

    Type akFrameWorkType
        version As String * 5
    End Type

    Type mousetype
        x As Integer
        y As Integer
        Lclick As Integer
        Rclick As Integer
        movement As Integer
        icon As String * 10
    End Type

    Type aKdialogType
        caption As String * 256
        h As Integer
        w As Integer
        background As Long
        shown As Integer
        closed As Integer
        Wx As Single
        Wy As Single
        Cx As Single
        Cy As Single
        Cx2 As Single
        Cy2 As Single
        content As Long
        hasAnimation As Long
        transition As String * 128
        noShadow As Integer
        save As Integer
    End Type

    Type aKlabelType
        x As Integer
        y As Integer
        text As String * 256
        tooltip As Integer
        id As Integer
        tId As Integer
        hidden As Integer
    End Type

    Type aKButtonType
        x As Integer
        y As Integer
        value As String * 256
        tooltip As Integer
        react As Integer
        tId As Integer
        id As Integer
        hidden As Integer
    End Type

    Type akCheckBoxType
        x As Integer
        y As Integer
        text As String * 256
        tooltip As Integer
        checked As Integer
        tId As Integer
        react As Integer
        id As Integer
        hidden As Integer
    End Type

    Type akRadioButtonType
        x As Integer
        y As Integer
        text As String * 256
        tooltip As Integer
        checked As Integer
        groupId As Integer
        react As Integer
        id As Integer
        hidden As Integer
    End Type

    Type aKLinklabelType
        x As Integer
        y As Integer
        text As String * 256
        tooltip As Integer
        tId As Integer
        id As Integer
        hidden As Integer
    End Type

    Type aKComboBoxType
        x As Integer
        y As Integer
        value As String * 256
        options As String * 512
        react As Integer
        active As Integer
        id As Integer
        hidden As Integer
    End Type

    Type aKTextboxType
        x As Integer
        y As Integer
        w As Integer
        value As String * 256
        placeholder As String * 256
        active As Integer
        react As Integer
        id As Integer
        hidden As Integer
        typ As Integer
    End Type

    Type aKNumericUpDownType
        x As Integer
        y As Integer
        value As Long
        w As Integer
        react As Integer
        react1 As Integer
        react2 As Integer
        id As Integer
        hidden As Integer
    End Type

    Type aKProgressBarType
        x As Integer
        y As Integer
        w As Integer
        active As Integer
        value As Integer
        oldValue As Integer
        bar As Long
        id As Integer
        hidden As Integer
    End Type

    Type aKTooltipType
        text As String * 512
        shown As Integer
        content As Long
        id As Integer
    End Type

    Type aKPictureType
        x As Integer
        y As Integer
        w As Integer
        h As Integer
        img As Long
        hidden As Integer
        id As Integer
        tooltip As Integer
        tid As Integer
    End Type

    Type aKDividerType
        x As Integer
        y As Integer
        size As Integer
        typ As Integer
        hidden As Integer
        id As Integer
    End Type

    Type aKPanelType
        x As Integer
        y As Integer
        w As Integer
        h As Integer
        hidden As Integer
        title As String * 256
        id As Integer
    End Type

    Const False = 0, True = Not False
    Const aKLabel = 0, aKButton = 1, aKCheckBox = 2, aKRadioButton = 4, aKLinkLabel = 5, aKComboBox = 6, aKTextBox = 7, aKNumericUpDown = 8, aKProgressBar = 9
    Const aKPicture = 10, aKDivider = 11, aKPanel = 12, aKVertical = 13, aKHorizontal = 14, aKPassword = 15, aKTooltip = 16

    Dim Shared aKFrameWork As akFrameWorkType
    ReDim Shared aKDialog(1) As aKdialogType, aKDialogLength
    ReDim Shared aKLabel(1) As aKlabelType, aKlabelLength As Integer
    ReDim Shared aKButton(1) As aKButtonType, aKButtonLength As Integer
    ReDim Shared aKCheckBox(1) As akCheckBoxType, aKCheckBoxLength As Integer
    ReDim Shared aKRadioButton(1) As akRadioButtonType, aKRadioLength As Integer
    ReDim Shared aKLinkLabel(1) As aKLinklabelType, aKLinklabelLength As Integer
    ReDim Shared aKComboBox(1) As aKComboBoxType, aKComboBoxLength As Integer
    ReDim Shared aKTextBox(1) As aKTextboxType, aKTextBoxLength As Integer
    ReDim Shared aKNumericUpDown(1) As aKNumericUpDownType, aKNumericUDLength As Integer
    ReDim Shared aKProgressBar(1) As aKProgressBarType, aKProgressBarLength As Integer
    ReDim Shared aKTooltip(1) As aKTooltipType, aKTooltipLength As Integer
    ReDim Shared aKDivider(1) As aKDividerType, aKDividerLength As Integer
    ReDim Shared aKPicture(1) As aKPictureType, aKPictureLength As Integer
    ReDim Shared aKPanel(1) As aKPanelType, aKPanelLength As Integer
    Dim Shared aKMouse As mousetype, tooltipBg As Long, optionsBg As Long

    aKDialogLength = 1
    aKlabelLength = 1
    aKButtonLength = 1
    aKCheckBoxLength = 1
    aKRadioLength = 1
    aKLinklabelLength = 1
    aKComboBoxLength = 1
    aKTextBoxLength = 1
    aKNumericUDLength = 1
    aKProgressBarLength = 1
    aKTooltipLength = 1
    aKDividerLength = 1
    aKPictureLength = 1
    aKPanelLength = 1

    aKFrameWork.version = "1.012"
$End If

