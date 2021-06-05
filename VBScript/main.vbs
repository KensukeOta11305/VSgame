Option Explicit

' �Q�[���L�����N�^�[��\���N���X�ł�
Class Character
    Private mstrName    ' ���O�ł�
    Private mintLife    ' �̗͂ł�
    Private mintMaxLife    ' �̗͂̍ő�l�ł�
    Private mobjActionList    ' �I���ł���s�����܂Ƃ߂�Scripting.Dictionary�I�u�W�F�N�g�ł�
    Private mstrAction    ' �I�������s�����ł�
    Public Property Get Action
        Action = mstrAction
    End Property
    Private mblnIsPlayer    ' �v���C���[�ł��邩�̃t���O�ł�

    ' ****************************************************************
    ' Purpose: �R���X�g���N�^�ł�
    ' Influence: -
    ' Impact: mintMaxLife: �̗͂̍ő�l�ł�
    '         mobjActionList: �I���ł���s�����܂Ƃ߂�Scripting.Dictionary�I�u�W�F�N�g�ł�
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Sub Class_Initialize()
        mintMaxLife = 5
        Set mobjActionList = CreateObject("Scripting.Dictionary")
        Call mobjActionList.Add(1, "�O�[")
        Call mobjActionList.Add(2, "�`���L")
        Call mobjActionList.Add(3, "�p�[")
    End Sub

    ' ****************************************************************
    ' Purpose: �v���C���[�p�̍s���I�������ł�
    '          �z�肳�ꂽ�s�����I�������܂ŕW�����͏������J��Ԃ��܂�
    ' Influence: sobjOutput: �R���\�[���E���O�t�@�C���ւ̏o�͏�����S������Output�I�u�W�F�N�g�ł�
    '            mobjActionList: �I���ł���s�����܂Ƃ߂�Scripting.Dictionary�I�u�W�F�N�g�ł�
    ' Impact: -
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Sub ChoiceActionByStandardInput()
        Dim strInput    ' �W�����͂��ꂽ�l�ł�
        Do While True
            Call WScript.StdOut.Write(CreatePrompt())
            strInput = WScript.StdIn.ReadLine()

            ' ���O�̏����ŃR���\�[���Ƀv�����v�g�Ɠ��͒l���\������Ă���̂Ń��O�t�@�C���ւ̒ǋL�����s���܂�
            Call sobjOutput.WriteLineOnlyLogFile(CreatePrompt() & strInput)

            ' �z�肳�ꂽ�l�Ȃ烋�[�v���甲���܂�
            If IsNumeric(strInput) Then
                If mobjActionList.Exists(CInt(strInput)) Then
                    Exit Do
                End If
            End If

            ' �z�肳�ꂽ�l�łȂ��ꍇ�A�����͂��ǂ����ŏ����𕪂��܂�
            If Trim(strInput) = "" Then
                Call sobjOutput.WriteEmptyLine(1)
            Else
                Call sobjOutput.WriteEmptyLine(1)
                Call sobjOutput.WriteLine("> �s���ȓ��͂ł�")
                Call sobjOutput.WriteLine("> �ē��͂��Ă�������")
                Call sobjOutput.WriteEmptyLine(1)
            End If
        Loop
        mstrAction = mobjActionList.Item(CInt(strInput))
    End Sub

    ' ****************************************************************
    ' Purpose: COM�p�̍s���I�������ł�
    '          ����ׂɍs����I�����܂�
    ' Influence: mobjActionList: �I���ł���s�����܂Ƃ߂�Scripting.Dictionary�I�u�W�F�N�g�ł�
    ' Impact: -
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Sub ChoiceActionByRnd()
        Dim I
        Dim intActionKeys    ' �s����I�����邽�߂̔ԍ��ꗗ���i�[�����z��ł�
        Dim intRndMin    ' �����̍ŏ��l�\�\�I�����ԍ��̍ŏ��l�ł�
        Dim intRndMax    ' �����̍ő�l�\�\�I�����ԍ��̍ő�l�ł�
        intActionKeys = mobjActionList.Keys
        For Each I In intActionKeys
            If IsEmpty(intRndMin) Or I < intRndMin Then
                intRndMin = I
            End If
        Next
        For Each I In intActionKeys
            If IsEmpty(intRndMax) Or I > intRndMax Then
                intRndMax = I
            End If
        Next
        Randomize
        mstrAction = mobjActionList.Item(CInt(Rnd() * (intRndMax - intRndMin) + intRndMin))
    End Sub

    ' ****************************************************************
    ' Purpose: �X�e�[�^�X�����������郁�\�b�h�ł�
    '          �������Ȃ̂�1�x�����Ăяo���悤�ɂ��Ă�������
    ' Influence: mstrName: ���O�ł�
    '            mintLife: �̗͂ł�
    '            mintMaxLife: �̗͂̍ő�l�ł�
    '            mblnIsPlayer: �v���C���[�ł��邩�̃t���O�ł�
    ' Impact: mstrName: ���O�ł�
    '         mintLife: �̗͂ł�
    '         mblnIsPlayer: �v���C���[�ł��邩�̃t���O�ł�
    ' Inputs: strName: ���O�ł�
    '         intInitialLife: �Q�[���J�n���_�̗̑͂ł�
    '         blnIsPlayer: �v���C���[�ł��邩�̃t���O�ł�
    ' Returns: -
    ' ****************************************************************
    Public Sub InitializeStatus(strName, intInitialLife, blnIsPlayer)
        If Not IsEmpty(mstrName) Or Not IsEmpty(mintLife) Or Not IsEmpty(mblnIsPlayer) Then
            Call Err.Raise(1, "Character.InitializeStatus()�͕�����Ăяo���܂���")
        End If
        mstrName = strName
        If intInitialLife > mintMaxLife Then
            Call Err.Raise(1, "�̗͂̏���l���z���ď����̗͂��w�肷�邱�Ƃ͂ł��܂���")
        End If
        mintLife = intInitialLife
        mblnIsPlayer = blnIsPlayer
    End Sub

    ' ****************************************************************
    ' Purpose: �s���I�������ł�
    '          �v���C���[��COM�ł��邩�ŏ������S���قȂ�̂ŁA���ꂼ��̏��������\�b�h�ɐ؂�o���܂���
    ' Influence: mblnIsPlayer: �v���C���[�ł��邩�̃t���O�ł�
    ' Impact: -
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Public Sub ChoiceAction()
        If mblnIsPlayer Then
            Call ChoiceActionByStandardInput()
        Else
            Call ChoiceActionByRnd()
        End If
    End Sub

    ' ****************************************************************
    ' Purpose: �_���[�W���󂯂��Ƃ��ɌĂяo�����\�b�h�ł�
    ' Influence: mintLife: �̗͂ł�
    ' Impact: mintLife: �̗͂ł�
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Public Sub Damage()
        mintLife = mintLife - 1
    End Sub

    ' ****************************************************************
    ' Purpose: �Q�[���̑��s���\���ԓ����郁�\�b�h�ł�
    ' Influence: mintLife: �̗͂ł�
    ' Impact: -
    ' Inputs: -
    ' Returns: �Q�[���̑��s���\�Ȃ�True��Ԃ��܂�
    ' ****************************************************************
    Public Function CanGame()
        If mintLife > 0 Then
            CanGame = True
        End If
    End Function

    ' ****************************************************************
    ' Purpose: ���g�̖��O�̒����i�o�C�g���j�𐔂��ČĂяo�����ɕԂ����\�b�h�ł�
    ' Influence: mstrName: ���O�ł�
    ' Impact: -
    ' Inputs: -
    ' Returns: ���g�̖��O�̒����i�o�C�g���j�𐔒l�ŕԂ��܂�
    ' ****************************************************************
    Public Function CountNameLen()
        Dim I
        Dim intNameLen    ' ���O�̒����i�o�C�g���j��\�����l�ł�
        For I = 1 To Len(mstrName)
            If (Asc(Mid(mstrName, I, 1)) And &HFF00) = 0 Then
                intNameLen = intNameLen + 1
            Else
                intNameLen = intNameLen + 2
            End If
        Next
        CountNameLen = intNameLen
    End Function

    ' ****************************************************************
    ' Purpose: ���g�̃X�e�[�^�X�����L�������b�Z�[�W���쐬���ĕԂ����\�b�h�ł�
    '          ���O�Ƒ̗͂̏�Ԃ����b�Z�[�W�ɂ��܂�
    '          ���O�̒����͑���̖��O�̒����Ƒ�����悤�ɂ��܂�
    '          �̗͂͋L�����g���đ̗̓Q�[�W���ۂ��\�����܂�
    ' Influence: mstrName: ���O�ł�
    '            mintLife: �̗͂ł�
    '            mintMaxLife: �̗͂̍ő�l�ł�
    ' Impact: -
    ' Inputs: intOpponentNameLen: ����L�����N�^�[�̖��O�̒����ł�
    ' Returns: ���g�̃X�e�[�^�X��\�����������Ԃ��܂�
    ' ****************************************************************
    Public Function CreateStatusMessage(intOpponentNameLen)
        Dim I
        Dim strLifeGauge    ' �̗̓Q�[�W���ۂ��\������������ł�
        Dim intDifferenceNameLen    ' ����L�����N�^�[�̖��O���A���g�̖��O�����o�C�g�Z������\�������l�ł�
        Dim strNameSpacer    ' ���g�Ƒ���̖��O�̒����𑵂���X�y�[�T�[�ł�
        For I = 1 To mintLife
            strLifeGauge = strLifeGauge & "��"
        Next
        For I = 1 To mintMaxLife - mintLife
            strLifeGauge = strLifeGauge & "��"
        Next
        intDifferenceNameLen = intOpponentNameLen - CountNameLen()
        If intDifferenceNameLen > 0 Then
            strNameSpacer = Space(intDifferenceNameLen)
        End If
        CreateStatusMessage = mstrName & strNameSpacer & ":" & Space(1) & strLifeGauge
    End Function

    ' ****************************************************************
    ' Purpose: �v���C���[�̍s���I�������ŕ\������v�����v�g���쐬���ĕԂ����\�b�h�ł�
    ' Influence: mobjActionList: �I���ł���s�����܂Ƃ߂�Scripting.Dictionary�I�u�W�F�N�g�ł�
    ' Impact: -
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Function CreatePrompt()
        Dim I
        Dim intActionKeys    ' �s���ƕR�Â����I��ԍ����܂Ƃ߂��z��ł�
        Dim strActionItems    ' �I���ł���s�������܂Ƃ߂��z��ł�
        intActionKeys = mobjActionList.Keys
        strActionItems = mobjActionList.Items
        For I = 0 To mobjActionList.Count - 1
            CreatePrompt = CreatePrompt & "[" & intActionKeys(I) & "]" & Space(1) & strActionItems(I) & Space(4)
        Next
        CreatePrompt = CreatePrompt & ":" & Space(1)
    End Function
End Class

' �R���\�[���E���O�t�@�C���֒l���o�͂���ۂ̏��X�̏�����S���N���X�ł�
Class Output
    Private mstrLogFile    ' ���O�t�@�C���̃t���p�X�ł�

    ' ****************************************************************
    ' Purpose: �R���X�g���N�^�ł�
    '          ���O�t�@�C���̃t���p�X���쐬���A���O�t�@�C����V�K�쐬���܂�
    ' Influence: mstrLogFile: ���O�t�@�C���̃t���p�X�ł�
    ' Impact: mstrLogFile: ���O�t�@�C���̃t���p�X�ł�
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Sub Class_Initialize()
        Dim objFileSystemObject    ' Scripting.FileSystemObject�ł�
        Dim strLogFileName    ' ���O�t�@�C�����ł�
        Set objFileSystemObject = CreateObject("Scripting.FileSystemObject")
        strLogFileName = "log_" & Replace(Mid(Now(), 3, 8), "/", "") & Replace(Mid(Now(), 12, 8), ":", "") & ".txt"
        mstrLogFile = objFileSystemObject.GetParentFolderName(WScript.ScriptFullName) & "\" & strLogFileName
        Call objFileSystemObject.CreateTextFile(mstrLogFile)
    End Sub

    ' ****************************************************************
    ' Purpose: �����Ɏw�肳�ꂽ�l���R���\�[���E���O�t�@�C���ɏo�͂��郁�\�b�h�ł�
    '          �l�͍s�����s���݂ŏo�͂���܂�
    ' Influence: mstrLogFile: ���O�t�@�C���̃t���p�X�ł�
    ' Impact: -
    ' Inputs: strOutput: �o�͂���l�ł�
    ' Returns: -
    ' ****************************************************************
    Public Sub WriteLine(strOutput)
        Dim objFileSystemObject    ' Scripting.FileSystemObject�ł�
        Dim objTextStream    ' �ǋL���[�h��TextStream�I�u�W�F�N�g�ł�
        Call WScript.Echo(strOutput)
        Set objFileSystemObject = CreateObject("Scripting.FileSystemObject")
        Set objTextStream = objFileSystemObject.OpenTextFile(mstrLogFile, 8, False)
        Call objTextStream.WriteLine(strOutput)
    End Sub

    ' ****************************************************************
    ' Purpose: �C�ӂ̐��̋�s���o�͂��郁�\�b�h�ł�
    '          ���v���O�����ł͏������e�����₷�����邽�ߗv���v���ŋ�s��}�����Ă��܂�
    '          ���x���s�������ł��邽�߁A���\�b�h�Ƃ��Đ؂�o���܂���
    ' Influence: -
    ' Impact: -
    ' Inputs: intNumberOfEmptyLine: ��s�̐��ł�
    ' Returns: -
    ' ****************************************************************
    Public Sub WriteEmptyLine(intNumberOfEmptyLine)
        Dim I
        For I = 1 To intNumberOfEmptyLine
            WriteLine("")
        Next
    End Sub

    ' ****************************************************************
    ' Purpose: �����Ɏw�肳�ꂽ�l�����O�t�@�C���ɏo�͂��郁�\�b�h�ł�
    '          WriteLine���\�b�h�Ɩ������قڔ���Ă��܂����ʃ��\�b�h�Ƃ��Đ؂�o���܂���
    ' Influence: mstrLogFile: ���O�t�@�C���̃t���p�X�ł�
    ' Impact: -
    ' Inputs: strOutput: �o�͂���l�ł�
    ' Returns: -
    ' ****************************************************************
    Public Sub WriteLineOnlyLogFile(strOutput)
        Dim objFileSystemObject    ' Scripting.FileSystemObject�ł�
        Dim objTextStream    ' �ǋL���[�h��TextStream�I�u�W�F�N�g�ł�
        Set objFileSystemObject = CreateObject("Scripting.FileSystemObject")
        Set objTextStream = objFileSystemObject.OpenTextFile(mstrLogFile, 8, False)
        Call objTextStream.WriteLine(strOutput)
    End Sub
End Class

' ****************************************************************
' Purpose: �^�[���J�n�ɔ����^�[���������Z����v���V�[�W���[�ł�
' Influence: sintTurnCount: �^�[�����ł�
' Impact: sintTurnCount: �^�[�����ł�
' Inputs: -
' Returns: -
' ****************************************************************
Sub AddTurnCount()
    sintTurnCount = sintTurnCount + 1
End Sub

' ****************************************************************
' Purpose: Enter�L�[���������܂ŏ������~�߂�v���V�[�W���[�ł�
' Influence: -
' Impact: -
' Inputs: -
' Returns: -
' ****************************************************************
Sub Pause()
    Call WScript.StdOut.Write("���s����ɂ͉����L�[�������Ă������� . . . ")
    Call WScript.StdIn.ReadLine()
End Sub

' ****************************************************************
' Purpose: ���݉��^�[���ڂł��邩��\�����b�Z�[�W��Ԃ��v���V�[�W���[�ł�
' Influence: sintTurnCount: �^�[�����ł�
' Impact: -
' Inputs: -
' Returns: -
' ****************************************************************
Function CreateTurnCountMessage()
    CreateTurnCountMessage = "�y��" & sintTurnCount & "�^�[���z"
End Function

' ****************************************************************
' Purpose: �L�����N�^�[���I�������s�����L�������b�Z�[�W��Ԃ��v���V�[�W���[�ł�
' Influence: sobjPlayer: �v���C���[��\��Character�I�u�W�F�N�g�ł�
'            sobjCOM: COM��\��Character�I�u�W�F�N�g�ł�
' Impact: -
' Inputs: -
' Returns: ���b�Z�[�W�ƂȂ镶�����Ԃ��܂�
' ****************************************************************
Function CreateChoicedActionsMessage()
    CreateChoicedActionsMessage = ">" & Space(1) & sobjPlayer.Action & Space(1) & "vs" & Space(1) & sobjCOM.Action
End Function

' ****************************************************************
' Purpose: �L�����N�^�[���I�������s���ɉ����ď��s����E�퓬�������s���v���V�[�W���[�ł�
'          ���������Ő퓬���ʂ�m�点�郁�b�Z�[�W��Ԃ��܂�
' Influence: sobjPlayer: �v���C���[��\��Character�I�u�W�F�N�g�ł�
'            sobjCOM: COM��\��Character�I�u�W�F�N�g�ł�
' Impact: -
' Inputs: -
' Returns: �퓬���ʂ�m�点�镶�����Ԃ��܂�
' ****************************************************************
Function JudgeBattle()
    Dim strPlayerAction    ' �v���C���[�̍s���ł�
    Dim strCOMAction    ' COM�̍s���ł�
    Dim strResult    ' ���s���茋�ʂł�
    strPlayerAction = sobjPlayer.Action
    strCOMAction = sobjCOM.Action
    Select Case strPlayerAction
        Case "�O�["
            Select Case strCOMAction
                Case "�O�["
                    strResult = "������"
                Case "�`���L"
                    strResult = "����"
                Case "�p�["
                    strResult = "����"
                Case Else
                    Call Err.Raise(1, "COM�̑I�������s�����s���ł��i" & strCOMAction & "�j")
            End Select
        Case "�`���L"
            Select Case strCOMAction
                Case "�O�["
                    strResult = "����"
                Case "�`���L"
                    strResult = "������"
                Case "�p�["
                    strResult = "����"
                Case Else
                    Call Err.Raise(1, "COM�̑I�������s�����s���ł��i" & strCOMAction & "�j")
            End Select
        Case "�p�["
            Select Case strCOMAction
                Case "�O�["
                    strResult = "����"
                Case "�`���L"
                    strResult = "����"
                Case "�p�["
                    strResult = "������"
                Case Else
                    Call Err.Raise(1, "COM�̑I�������s�����s���ł��i" & strCOMAction & "�j")
            End Select
        Case Else
            Call Err.Raise(1, "�v���C���[�̑I�������s�����s���ł��i" & strPlayerAction & "�j")
    End Select
    Select Case strResult
        Case "������"
        Case "����"
            sobjCOM.Damage()
        Case "����"
            sobjPlayer.Damage()
        Case Else
            Call Err.Raise(1, "�퓬�������ʂ��s���ł��i" & strResult & "�j")
    End Select
    JudgeBattle = ">" & Space(1) & strResult
End Function

' ****************************************************************
' Purpose: �������t�������Ƃ�\�����b�Z�[�W��Ԃ��v���V�[�W���[�ł�
' Influence: -
' Impact: -
' Inputs: -
' Returns: �������t�������Ƃ�\���������Ԃ��܂�
' ****************************************************************
Function CreateEndTurnMessage()
    CreateEndTurnMessage = "�y�����z"
End Function 

' ****************************************************************
' Purpose: �Q�[���̏��s�𔻒肵�A���̏��s���ʂ�\�����b�Z�[�W��Ԃ��v���V�[�W���[�ł�
' Influence: sobjPlayer: �v���C���[��\��Character�I�u�W�F�N�g�ł�
'            sobjCOM: COM��\��Character�I�u�W�F�N�g�ł�
' Impact: -
' Inputs: -
' Returns: ���s���ʂ�\���������Ԃ��܂�
' ****************************************************************
Function JudgeGame()
    Dim blnPlayerState    ' �v���C���[���Q�[�����s�\�ł��邩�̃t���O�ł�
    Dim blnCOMState    ' COM���Q�[�����s�\�ł��邩�̃t���O�ł�
    blnPlayerState = sobjPlayer.CanGame()
    blnCOMState = sobjCOM.CanGame()
    Select Case blnPlayerState
        Case True
            Select Case blnCOMState
                Case True
                    Call Err.Raise(1, "�����������������܂����i" & blnPlayerState & "," & blnCOMState & "�j")
                Case False
                    JudgeGame = "> �����܂������I"
                Case Else
                    Call Err.Raise(1, "COM���Q�[�����s�\�ł��邩�s���ł��i" & blnCOMState & "�j")
            End Select
        Case False
            Select Case blnCOMState
                Case True
                    JudgeGame = "> �����܂����c�c"
                Case False
                    Call Err.Raise(1, "�����������������܂����i" & blnPlayerState & "," & blnCOMState & "�j")
                Case Else
                    Call Err.Raise(1, "COM���Q�[�����s�\�ł��邩�s���ł��i" & blnCOMState & "�j")
            End Select
        Case Else
            Call Err.Raise(1, "�v���C���[���Q�[�����s�\�ł��邩�s���ł��i" & blnPlayerState & "�j")
    End Select
End Function

' �X�N���v�g���x���ϐ������������܂�
Dim sobjPlayer    ' �v���C���[��\��Character�I�u�W�F�N�g�ł�
Dim sobjCOM    ' COM��\��Character�I�u�W�F�N�g�ł�
Dim sintTurnCount    ' �^�[�����ł�
Dim sobjOutput    ' �R���\�[���E���O�t�@�C���ւ̏o�͏�����S������Output�I�u�W�F�N�g�ł�
Set sobjPlayer = New Character
Call sobjPlayer.InitializeStatus("Qii���Y", 5, True)
Set sobjCOM = New Character
Call sobjCOM.InitializeStatus("COM", 5, False)
sintTurnCount = 0
Set sobjOutput = New Output

' �o���̃L�����N�^�[���Q�[�����s�\�ł���Ԃ̓^�[���������J��Ԃ��܂�
Do While sobjPlayer.CanGame() And sobjCOM.CanGame()
    Call AddTurnCount()
    Call sobjOutput.WriteLine(CreateTurnCountMessage())
    Call sobjOutput.WriteLine(sobjPlayer.CreateStatusMessage(sobjCOM.CountNameLen()))
    Call sobjOutput.WriteLine(sobjCOM.CreateStatusMessage(sobjPlayer.CountNameLen()))
    Call sobjOutput.WriteEmptyLine(1)
    Call sobjPlayer.ChoiceAction()
    Call sobjCOM.ChoiceAction()
    Call sobjOutput.WriteEmptyLine(1)
    Call sobjOutput.WriteLine(CreateChoicedActionsMessage())
    Call sobjOutput.WriteLine(JudgeBattle())
    Call sobjOutput.WriteEmptyLine(5)
Loop

' �Q�[���̌������t�����̂ŏ��s�𔻒肵�A���ʂ�\�����܂�
Call sobjOutput.WriteLine(CreateEndTurnMessage())
Call sobjOutput.WriteLine(sobjPlayer.CreateStatusMessage(sobjCOM.CountNameLen()))
Call sobjOutput.WriteLine(sobjCOM.CreateStatusMessage(sobjPlayer.CountNameLen()))
Call sobjOutput.WriteEmptyLine(1)
Call sobjOutput.WriteLine(JudgeGame())
Call sobjOutput.WriteEmptyLine(1)
Call Pause()
