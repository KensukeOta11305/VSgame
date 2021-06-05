Option Explicit

' ゲームキャラクターを表すクラスです
Class Character
    Private mstrName    ' 名前です
    Private mintLife    ' 体力です
    Private mintMaxLife    ' 体力の最大値です
    Private mobjActionList    ' 選択できる行動をまとめたScripting.Dictionaryオブジェクトです
    Private mstrAction    ' 選択した行動名です
    Public Property Get Action
        Action = mstrAction
    End Property
    Private mblnIsPlayer    ' プレイヤーであるかのフラグです

    ' ****************************************************************
    ' Purpose: コンストラクタです
    ' Influence: -
    ' Impact: mintMaxLife: 体力の最大値です
    '         mobjActionList: 選択できる行動をまとめたScripting.Dictionaryオブジェクトです
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Sub Class_Initialize()
        mintMaxLife = 5
        Set mobjActionList = CreateObject("Scripting.Dictionary")
        Call mobjActionList.Add(1, "グー")
        Call mobjActionList.Add(2, "チョキ")
        Call mobjActionList.Add(3, "パー")
    End Sub

    ' ****************************************************************
    ' Purpose: プレイヤー用の行動選択処理です
    '          想定された行動が選択されるまで標準入力処理を繰り返します
    ' Influence: sobjOutput: コンソール・ログファイルへの出力処理を担当するOutputオブジェクトです
    '            mobjActionList: 選択できる行動をまとめたScripting.Dictionaryオブジェクトです
    ' Impact: -
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Sub ChoiceActionByStandardInput()
        Dim strInput    ' 標準入力された値です
        Do While True
            Call WScript.StdOut.Write(CreatePrompt())
            strInput = WScript.StdIn.ReadLine()

            ' 直前の処理でコンソールにプロンプトと入力値が表示されているのでログファイルへの追記だけ行います
            Call sobjOutput.WriteLineOnlyLogFile(CreatePrompt() & strInput)

            ' 想定された値ならループから抜けます
            If IsNumeric(strInput) Then
                If mobjActionList.Exists(CInt(strInput)) Then
                    Exit Do
                End If
            End If

            ' 想定された値でない場合、未入力かどうかで処理を分けます
            If Trim(strInput) = "" Then
                Call sobjOutput.WriteEmptyLine(1)
            Else
                Call sobjOutput.WriteEmptyLine(1)
                Call sobjOutput.WriteLine("> 不正な入力です")
                Call sobjOutput.WriteLine("> 再入力してください")
                Call sobjOutput.WriteEmptyLine(1)
            End If
        Loop
        mstrAction = mobjActionList.Item(CInt(strInput))
    End Sub

    ' ****************************************************************
    ' Purpose: COM用の行動選択処理です
    '          無作為に行動を選択します
    ' Influence: mobjActionList: 選択できる行動をまとめたScripting.Dictionaryオブジェクトです
    ' Impact: -
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Sub ChoiceActionByRnd()
        Dim I
        Dim intActionKeys    ' 行動を選択するための番号一覧を格納した配列です
        Dim intRndMin    ' 乱数の最小値――選択肢番号の最小値です
        Dim intRndMax    ' 乱数の最大値――選択肢番号の最大値です
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
    ' Purpose: ステータスを初期化するメソッドです
    '          初期化なので1度だけ呼び出すようにしてください
    ' Influence: mstrName: 名前です
    '            mintLife: 体力です
    '            mintMaxLife: 体力の最大値です
    '            mblnIsPlayer: プレイヤーであるかのフラグです
    ' Impact: mstrName: 名前です
    '         mintLife: 体力です
    '         mblnIsPlayer: プレイヤーであるかのフラグです
    ' Inputs: strName: 名前です
    '         intInitialLife: ゲーム開始時点の体力です
    '         blnIsPlayer: プレイヤーであるかのフラグです
    ' Returns: -
    ' ****************************************************************
    Public Sub InitializeStatus(strName, intInitialLife, blnIsPlayer)
        If Not IsEmpty(mstrName) Or Not IsEmpty(mintLife) Or Not IsEmpty(mblnIsPlayer) Then
            Call Err.Raise(1, "Character.InitializeStatus()は複数回呼び出せません")
        End If
        mstrName = strName
        If intInitialLife > mintMaxLife Then
            Call Err.Raise(1, "体力の上限値を越えて初期体力を指定することはできません")
        End If
        mintLife = intInitialLife
        mblnIsPlayer = blnIsPlayer
    End Sub

    ' ****************************************************************
    ' Purpose: 行動選択処理です
    '          プレイヤーかCOMであるかで処理が全く異なるので、それぞれの処理をメソッドに切り出しました
    ' Influence: mblnIsPlayer: プレイヤーであるかのフラグです
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
    ' Purpose: ダメージを受けたときに呼び出すメソッドです
    ' Influence: mintLife: 体力です
    ' Impact: mintLife: 体力です
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Public Sub Damage()
        mintLife = mintLife - 1
    End Sub

    ' ****************************************************************
    ' Purpose: ゲームの続行が可能か返答するメソッドです
    ' Influence: mintLife: 体力です
    ' Impact: -
    ' Inputs: -
    ' Returns: ゲームの続行が可能ならTrueを返します
    ' ****************************************************************
    Public Function CanGame()
        If mintLife > 0 Then
            CanGame = True
        End If
    End Function

    ' ****************************************************************
    ' Purpose: 自身の名前の長さ（バイト数）を数えて呼び出し元に返すメソッドです
    ' Influence: mstrName: 名前です
    ' Impact: -
    ' Inputs: -
    ' Returns: 自身の名前の長さ（バイト数）を数値で返します
    ' ****************************************************************
    Public Function CountNameLen()
        Dim I
        Dim intNameLen    ' 名前の長さ（バイト数）を表す数値です
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
    ' Purpose: 自身のステータス情報を記したメッセージを作成して返すメソッドです
    '          名前と体力の状態をメッセージにします
    '          名前の長さは相手の名前の長さと揃えるようにします
    '          体力は記号を使って体力ゲージっぽく表現します
    ' Influence: mstrName: 名前です
    '            mintLife: 体力です
    '            mintMaxLife: 体力の最大値です
    ' Impact: -
    ' Inputs: intOpponentNameLen: 相手キャラクターの名前の長さです
    ' Returns: 自身のステータスを表した文字列を返します
    ' ****************************************************************
    Public Function CreateStatusMessage(intOpponentNameLen)
        Dim I
        Dim strLifeGauge    ' 体力ゲージっぽく表現した文字列です
        Dim intDifferenceNameLen    ' 相手キャラクターの名前より、自身の名前が何バイト短いかを表した数値です
        Dim strNameSpacer    ' 自身と相手の名前の長さを揃えるスペーサーです
        For I = 1 To mintLife
            strLifeGauge = strLifeGauge & "■"
        Next
        For I = 1 To mintMaxLife - mintLife
            strLifeGauge = strLifeGauge & "□"
        Next
        intDifferenceNameLen = intOpponentNameLen - CountNameLen()
        If intDifferenceNameLen > 0 Then
            strNameSpacer = Space(intDifferenceNameLen)
        End If
        CreateStatusMessage = mstrName & strNameSpacer & ":" & Space(1) & strLifeGauge
    End Function

    ' ****************************************************************
    ' Purpose: プレイヤーの行動選択処理で表示するプロンプトを作成して返すメソッドです
    ' Influence: mobjActionList: 選択できる行動をまとめたScripting.Dictionaryオブジェクトです
    ' Impact: -
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Function CreatePrompt()
        Dim I
        Dim intActionKeys    ' 行動と紐づいた選択番号をまとめた配列です
        Dim strActionItems    ' 選択できる行動名をまとめた配列です
        intActionKeys = mobjActionList.Keys
        strActionItems = mobjActionList.Items
        For I = 0 To mobjActionList.Count - 1
            CreatePrompt = CreatePrompt & "[" & intActionKeys(I) & "]" & Space(1) & strActionItems(I) & Space(4)
        Next
        CreatePrompt = CreatePrompt & ":" & Space(1)
    End Function
End Class

' コンソール・ログファイルへ値を出力する際の諸々の処理を担うクラスです
Class Output
    Private mstrLogFile    ' ログファイルのフルパスです

    ' ****************************************************************
    ' Purpose: コンストラクタです
    '          ログファイルのフルパスを作成し、ログファイルを新規作成します
    ' Influence: mstrLogFile: ログファイルのフルパスです
    ' Impact: mstrLogFile: ログファイルのフルパスです
    ' Inputs: -
    ' Returns: -
    ' ****************************************************************
    Private Sub Class_Initialize()
        Dim objFileSystemObject    ' Scripting.FileSystemObjectです
        Dim strLogFileName    ' ログファイル名です
        Set objFileSystemObject = CreateObject("Scripting.FileSystemObject")
        strLogFileName = "log_" & Replace(Mid(Now(), 3, 8), "/", "") & Replace(Mid(Now(), 12, 8), ":", "") & ".txt"
        mstrLogFile = objFileSystemObject.GetParentFolderName(WScript.ScriptFullName) & "\" & strLogFileName
        Call objFileSystemObject.CreateTextFile(mstrLogFile)
    End Sub

    ' ****************************************************************
    ' Purpose: 引数に指定された値をコンソール・ログファイルに出力するメソッドです
    '          値は行末改行込みで出力されます
    ' Influence: mstrLogFile: ログファイルのフルパスです
    ' Impact: -
    ' Inputs: strOutput: 出力する値です
    ' Returns: -
    ' ****************************************************************
    Public Sub WriteLine(strOutput)
        Dim objFileSystemObject    ' Scripting.FileSystemObjectです
        Dim objTextStream    ' 追記モードのTextStreamオブジェクトです
        Call WScript.Echo(strOutput)
        Set objFileSystemObject = CreateObject("Scripting.FileSystemObject")
        Set objTextStream = objFileSystemObject.OpenTextFile(mstrLogFile, 8, False)
        Call objTextStream.WriteLine(strOutput)
    End Sub

    ' ****************************************************************
    ' Purpose: 任意の数の空行を出力するメソッドです
    '          当プログラムでは処理内容を見やすくするため要所要所で空行を挿入しています
    '          何度も行う処理であるため、メソッドとして切り出しました
    ' Influence: -
    ' Impact: -
    ' Inputs: intNumberOfEmptyLine: 空行の数です
    ' Returns: -
    ' ****************************************************************
    Public Sub WriteEmptyLine(intNumberOfEmptyLine)
        Dim I
        For I = 1 To intNumberOfEmptyLine
            WriteLine("")
        Next
    End Sub

    ' ****************************************************************
    ' Purpose: 引数に指定された値をログファイルに出力するメソッドです
    '          WriteLineメソッドと役割がほぼ被っていますが別メソッドとして切り出しました
    ' Influence: mstrLogFile: ログファイルのフルパスです
    ' Impact: -
    ' Inputs: strOutput: 出力する値です
    ' Returns: -
    ' ****************************************************************
    Public Sub WriteLineOnlyLogFile(strOutput)
        Dim objFileSystemObject    ' Scripting.FileSystemObjectです
        Dim objTextStream    ' 追記モードのTextStreamオブジェクトです
        Set objFileSystemObject = CreateObject("Scripting.FileSystemObject")
        Set objTextStream = objFileSystemObject.OpenTextFile(mstrLogFile, 8, False)
        Call objTextStream.WriteLine(strOutput)
    End Sub
End Class

' ****************************************************************
' Purpose: ターン開始に伴いターン数を加算するプロシージャーです
' Influence: sintTurnCount: ターン数です
' Impact: sintTurnCount: ターン数です
' Inputs: -
' Returns: -
' ****************************************************************
Sub AddTurnCount()
    sintTurnCount = sintTurnCount + 1
End Sub

' ****************************************************************
' Purpose: Enterキーが押されるまで処理を止めるプロシージャーです
' Influence: -
' Impact: -
' Inputs: -
' Returns: -
' ****************************************************************
Sub Pause()
    Call WScript.StdOut.Write("続行するには何かキーを押してください . . . ")
    Call WScript.StdIn.ReadLine()
End Sub

' ****************************************************************
' Purpose: 現在何ターン目であるかを表すメッセージを返すプロシージャーです
' Influence: sintTurnCount: ターン数です
' Impact: -
' Inputs: -
' Returns: -
' ****************************************************************
Function CreateTurnCountMessage()
    CreateTurnCountMessage = "【第" & sintTurnCount & "ターン】"
End Function

' ****************************************************************
' Purpose: キャラクターが選択した行動を記したメッセージを返すプロシージャーです
' Influence: sobjPlayer: プレイヤーを表すCharacterオブジェクトです
'            sobjCOM: COMを表すCharacterオブジェクトです
' Impact: -
' Inputs: -
' Returns: メッセージとなる文字列を返します
' ****************************************************************
Function CreateChoicedActionsMessage()
    CreateChoicedActionsMessage = ">" & Space(1) & sobjPlayer.Action & Space(1) & "vs" & Space(1) & sobjCOM.Action
End Function

' ****************************************************************
' Purpose: キャラクターが選択した行動に応じて勝敗判定・戦闘処理を行うプロシージャーです
'          処理末尾で戦闘結果を知らせるメッセージを返します
' Influence: sobjPlayer: プレイヤーを表すCharacterオブジェクトです
'            sobjCOM: COMを表すCharacterオブジェクトです
' Impact: -
' Inputs: -
' Returns: 戦闘結果を知らせる文字列を返します
' ****************************************************************
Function JudgeBattle()
    Dim strPlayerAction    ' プレイヤーの行動です
    Dim strCOMAction    ' COMの行動です
    Dim strResult    ' 勝敗判定結果です
    strPlayerAction = sobjPlayer.Action
    strCOMAction = sobjCOM.Action
    Select Case strPlayerAction
        Case "グー"
            Select Case strCOMAction
                Case "グー"
                    strResult = "あいこ"
                Case "チョキ"
                    strResult = "勝ち"
                Case "パー"
                    strResult = "負け"
                Case Else
                    Call Err.Raise(1, "COMの選択した行動が不正です（" & strCOMAction & "）")
            End Select
        Case "チョキ"
            Select Case strCOMAction
                Case "グー"
                    strResult = "負け"
                Case "チョキ"
                    strResult = "あいこ"
                Case "パー"
                    strResult = "勝ち"
                Case Else
                    Call Err.Raise(1, "COMの選択した行動が不正です（" & strCOMAction & "）")
            End Select
        Case "パー"
            Select Case strCOMAction
                Case "グー"
                    strResult = "勝ち"
                Case "チョキ"
                    strResult = "負け"
                Case "パー"
                    strResult = "あいこ"
                Case Else
                    Call Err.Raise(1, "COMの選択した行動が不正です（" & strCOMAction & "）")
            End Select
        Case Else
            Call Err.Raise(1, "プレイヤーの選択した行動が不正です（" & strPlayerAction & "）")
    End Select
    Select Case strResult
        Case "あいこ"
        Case "勝ち"
            sobjCOM.Damage()
        Case "負け"
            sobjPlayer.Damage()
        Case Else
            Call Err.Raise(1, "戦闘処理結果が不正です（" & strResult & "）")
    End Select
    JudgeBattle = ">" & Space(1) & strResult
End Function

' ****************************************************************
' Purpose: 決着が付いたことを表すメッセージを返すプロシージャーです
' Influence: -
' Impact: -
' Inputs: -
' Returns: 決着が付いたことを表す文字列を返します
' ****************************************************************
Function CreateEndTurnMessage()
    CreateEndTurnMessage = "【決着】"
End Function 

' ****************************************************************
' Purpose: ゲームの勝敗を判定し、その勝敗結果を表すメッセージを返すプロシージャーです
' Influence: sobjPlayer: プレイヤーを表すCharacterオブジェクトです
'            sobjCOM: COMを表すCharacterオブジェクトです
' Impact: -
' Inputs: -
' Returns: 勝敗結果を表す文字列を返します
' ****************************************************************
Function JudgeGame()
    Dim blnPlayerState    ' プレイヤーがゲーム続行可能であるかのフラグです
    Dim blnCOMState    ' COMがゲーム続行可能であるかのフラグです
    blnPlayerState = sobjPlayer.CanGame()
    blnCOMState = sobjCOM.CanGame()
    Select Case blnPlayerState
        Case True
            Select Case blnCOMState
                Case True
                    Call Err.Raise(1, "引き分けが発生しました（" & blnPlayerState & "," & blnCOMState & "）")
                Case False
                    JudgeGame = "> 勝ちましたっ！"
                Case Else
                    Call Err.Raise(1, "COMがゲーム続行可能であるか不明です（" & blnCOMState & "）")
            End Select
        Case False
            Select Case blnCOMState
                Case True
                    JudgeGame = "> 負けました……"
                Case False
                    Call Err.Raise(1, "引き分けが発生しました（" & blnPlayerState & "," & blnCOMState & "）")
                Case Else
                    Call Err.Raise(1, "COMがゲーム続行可能であるか不明です（" & blnCOMState & "）")
            End Select
        Case Else
            Call Err.Raise(1, "プレイヤーがゲーム続行可能であるか不明です（" & blnPlayerState & "）")
    End Select
End Function

' スクリプトレベル変数を初期化します
Dim sobjPlayer    ' プレイヤーを表すCharacterオブジェクトです
Dim sobjCOM    ' COMを表すCharacterオブジェクトです
Dim sintTurnCount    ' ターン数です
Dim sobjOutput    ' コンソール・ログファイルへの出力処理を担当するOutputオブジェクトです
Set sobjPlayer = New Character
Call sobjPlayer.InitializeStatus("Qii太郎", 5, True)
Set sobjCOM = New Character
Call sobjCOM.InitializeStatus("COM", 5, False)
sintTurnCount = 0
Set sobjOutput = New Output

' 双方のキャラクターがゲーム続行可能である間はターン処理を繰り返します
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

' ゲームの決着が付いたので勝敗を判定し、結果を表示します
Call sobjOutput.WriteLine(CreateEndTurnMessage())
Call sobjOutput.WriteLine(sobjPlayer.CreateStatusMessage(sobjCOM.CountNameLen()))
Call sobjOutput.WriteLine(sobjCOM.CreateStatusMessage(sobjPlayer.CountNameLen()))
Call sobjOutput.WriteEmptyLine(1)
Call sobjOutput.WriteLine(JudgeGame())
Call sobjOutput.WriteEmptyLine(1)
Call Pause()
