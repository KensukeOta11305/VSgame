@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM 実行ログファイルのフルパスを作成します。
SET yymmdd=%DATE%
SET yymmdd=%yymmdd:/=%
SET yymmdd=%yymmdd:~2,6%
SET hhmmss=%TIME%
SET hhmmss=%hhmmss::=%
SET hhmmss=%hhmmss: =0%
SET hhmmss=%hhmmss:~0,6%
SET log_file_full_path="%~DP0log_%yymmdd%%hhmmss%.txt"

REM キャラクター体力を設定します。
SET max_life=5
SET player_life=%max_life%
SET com_life=%max_life%

REM キャラクターの名前を設定します。
SET player_name=Qii太郎
SET com_name=COM

REM コンソールに表示したときに見栄えが良いように、キャラクターの名前の横幅を揃えます。
REM まずは、双方のキャラクターの名前の長さ（バイト数）を取得します。
REM 長さの取得には、名前をファイルに書き出してファイルのサイズから計算する方法を採ります。
REM なお、空ファイルでも2バイト入っているので、その分は名前のサイズから抜いて計算します。
:loop_for_tempory_file_name
SET temporary_file_full_path="%~DP0%RANDOM%.tmp"
IF EXIST %temporary_file_full_path% (
    GOTO get_name_length
)
SET base_file_size=2
ECHO %player_name%>%temporary_file_full_path%
FOR %%I IN (%temporary_file_full_path%) DO (
    SET /A player_name_length=%%~ZI-!base_file_size!
)
ECHO %com_name%>%temporary_file_full_path%
FOR %%I IN (%temporary_file_full_path%) DO (
    SET /A com_name_length=%%~ZI-!base_file_size!
)
DEL %temporary_file_full_path%

REM 名前の長さが取得できたので双方の名前の長さを比較します。
REM 短いほうの名前は半角空白で足りない長さを補います。
SET space=" "
IF %player_name_length% LSS %com_name_length% (
    SET /A difference_name_length=%com_name_length%-%player_name_length%
    FOR /L %%a IN (1,1,!difference_name_length!) DO (
        SET player_name=!player_name!%space:"=%
    )
) ELSE IF %player_name_length% GTR %com_name_length% (
    SET /A difference_name_length=%player_name_length%-%com_name_length%
    FOR /L %%a IN (1,1,!difference_name_length!) DO (
        SET com_name=!com_name!%space:"=%
    )
)
SET player_name="%player_name%"
SET com_name="%com_name%"

REM 以下、無限ループによるターン処理です。
SET turn_count=1
:loop_for_turn_system

REM 現在のゲーム状況を表示します。
CALL :echo_turn_count %log_file_full_path% %turn_count%
CALL :echo_character_status %log_file_full_path% %player_name% %max_life% %player_life%
CALL :echo_character_status %log_file_full_path% %com_name% %max_life% %com_life%
CALL :echo_empty_line %log_file_full_path%  1

REM プレイヤーの行動を選択します。
CALL :choice_player_action %log_file_full_path%
SET player_choice=%ERRORLEVEL%
SET rock=1
SET scissors=2
SET paper=3
IF %player_choice% EQU %rock% (
    SET player_action=グー
) ELSE IF %player_choice% EQU %scissors% (
    SET player_action=チョキ
) ELSE IF %player_choice% EQU %paper% (
    SET player_action=パー
) ELSE (

    REM 閉じ括弧がIFブロックの閉じ記号と解釈されないようエスケープします。
    ECHO [Error] プレイヤーの選択番号が不正です(%player_choice%^)
    PAUSE
    EXIT /B 1
)

REM COMの行動を選択します
CALL :choice_com_action
SET /A com_choice=%ERRORLEVEL%
IF %com_choice% EQU 1 (
    SET com_action=グー
) ELSE IF %com_choice% EQU 2 (
    SET com_action=チョキ
) ELSE IF %com_choice% EQU 3 (
    SET com_action=パー
) ELSE (

    REM 閉じ括弧がIFブロックの閉じ記号と解釈されないようエスケープします。
    ECHO [Error] COMの選択した行動番号が不正です(%com_choice%^)
    PAUSE
    EXIT /B 1
)
CALL :echo_empty_line %log_file_full_path% 1

REM お互いが選択した行動を表示します。
CALL :echo_characters_action %log_file_full_path% %player_action% %com_action%

REM お互いが選択した行動による対決結果を表示します。
CALL :judge_battle %player_action% %com_action%
SET battle_result=%ERRORLEVEL%
SET error=-1
SET draw=0
SET pleyer_win=1
SET player_lose=2
IF %battle_result% EQU %draw% (
    CALL :output_message %log_file_full_path% "> あいこ"
) ELSE IF %battle_result% EQU %pleyer_win% (
    CALL :output_message %log_file_full_path% "> 勝ち"
    SET /A com_life-=1
) ELSE IF %battle_result% EQU %player_lose% (
    CALL :output_message %log_file_full_path% "> 負け"
    SET /A player_life-=1
) ELSE (
    ECHO [Error] じゃんけんの勝敗結果が不正です(%battle_result%^)
    PAUSE
    EXIT /B 1
)
CALL :echo_empty_line %log_file_full_path% 5

REM ゲームの決着がついたか判定します。
IF %player_life% EQU 0 (
    IF %com_life% EQU 0 (
        ECHO [Error] ゲームの勝敗結果が不正です(%player_life%,%com_life%^)
        PAUSE
        EXIT /B 1
    ) ELSE (
        SET winner=%com_name%
    )
) ELSE (
    IF %com_life% EQU 0 (
        SET winner=%player_name%
    )
)

REM 勝者不在の場合は次ターンに進みます。
IF "%winner%" EQU "" (
    SET /A turn_count+=1
    GOTO loop_for_turn_system
)

REM 勝者がいる場合はゲームの勝敗結果を表示します。
CALL :output_message %log_file_full_path% "【決着】"
CALL :echo_character_status %log_file_full_path% %player_name% %max_life% %player_life%
CALL :echo_character_status %log_file_full_path% %com_name% %max_life% %com_life%
CALL :echo_empty_line %log_file_full_path% 1
IF %winner% EQU %player_name% (
    CALL :output_message %log_file_full_path% "> ゲームに勝利しました！"
) ELSE (
    IF %winner% EQU %com_name% (
        CALL :output_message %log_file_full_path% "> ゲームに敗北しました……"
    ) ELSE (
        ECHO [Error] ゲームの勝敗結果が不正です(%winner%^)
        PAUSE
        EXIT /B 1
    )
)
ECHO.
PAUSE
EXIT /B 0

REM ----------------------------------------------------------------
REM COMの行動を乱数で選択させ、選択した行動と対応する数値を返します。
REM
REM ERRORLEVEL 1 グー
REM            2 チョキ
REM            3 パー
REM ----------------------------------------------------------------
:choice_com_action
SET min=1
SET max=3
SET /A lower_limit=32768%%max%
SET generated_random_value=%RANDOM%
IF %generated_random_value% LSS %lower_limit% (
    GOTO choice_com_action
)
SET /A com_choice=%generated_random_value%%%%max%+%min%
EXIT /B %com_choice%

REM ----------------------------------------------------------------
REM プレイヤーの行動を標準入力で選択させ、選択した行動と対応する数値を返します。
REM
REM ARGUMENTS %1 ログファイルのパス
REM
REM ERRORLEVEL 1 グー
REM            2 チョキ
REM            3 パー
REM ----------------------------------------------------------------
:choice_player_action
SETLOCAL ENABLEDELAYEDEXPANSION

REM 標準入力を受け付けます。
SET prompt_message="[1] グー    [2] チョキ    [3] パー    : "
SET /P input=%prompt_message%

REM 何も入力されなかった場合の処理です。
REM 例外として、ログファイルへの書き込みはここで直接行います。
IF "%input%" EQU "" (
    ECHO %prompt_message:"=%>>"%~1"
    GOTO choice_player_action
)

REM 入力された値が想定されたものであれば、対応する値を呼び出し元に返します。
REM 例外として、ログファイルへの書き込みはここで直接行います。
ECHO %prompt_message:"=%^%input%>>"%~1"
IF "%input%" EQU "1" (
    SET rock=1
    EXIT /B !rock!
)
IF "%input%" EQU "2" (
    SET scissors=2
    EXIT /B !scissors!
)
IF "%input%" EQU "3" (
    SET paper=3
    EXIT /B !paper!
)

REM 想定外の値が入力された場合はエラーメッセージを出力して再入力を促します。
REM このとき、大なり記号がファイルへの出力記号と見做されるためエスケープするのを忘れないようにします。
REM 標準入力された値を受け取る変数の初期化を忘れずに行います。
CALL :echo_empty_line "%~1" 1
CALL :output_message %~1 "> 不正な入力です"
CALL :output_message %~1 "> 再入力してください"
CALL :echo_empty_line "%~1" 1
SET input=
GOTO choice_player_action

REM ----------------------------------------------------------------
REM プレイヤーとCOMの選択した行動を出力します。
REM
REM ARGUMENTS %1 ログファイルのパス
REM           %2 プレイヤーの選択した行動
REM           %3 COMの選択した行動
REM ----------------------------------------------------------------
:echo_characters_action
SETLOCAL
CALL :output_message %~1 "> %~2 vs %~3"
EXIT /B

REM ----------------------------------------------------------------
REM キャラクターのステータスを出力します。
REM
REM ARGUMENTS %1 ログファイルのパス
REM           %2 キャラクターの名前
REM           %3 キャラクターの体力上限値
REM           %4 キャラクターの体力
REM ----------------------------------------------------------------
:echo_character_status
SETLOCAL ENABLEDELAYEDEXPANSION

REM 体力の状態を、記号を使って体力ゲージのように表現します。
SET life_gauge=
FOR /L %%I IN (1,1,%~4) DO (
    SET life_sign=■
    SET life_gauge=!life_gauge!!life_sign!
)
SET /A damage=%~3-%~4
FOR /L %%a IN (1,1,%damage%) DO (
    SET damage_sign=□
    SET life_gauge=!life_gauge!!damage_sign!
)

SET character_status="%~2: %life_gauge%"
CALL :output_message %~1 %character_status%
EXIT /B

REM ----------------------------------------------------------------
REM 任意の数の空行を出力します。
REM
REM ARGUMENTS %1 ログファイルのパス
REM           %2 出力する行数
REM ----------------------------------------------------------------
:echo_empty_line
SETLOCAL
FOR /L %%a IN (1,1,%~2) DO (
    CALL :output_message %~1 ""
)
EXIT /B

REM ----------------------------------------------------------------
REM 現在のターン数を出力します。
REM
REM ARGUMENTS %1 ログファイルのパス
REM           %2 ターン数
REM ----------------------------------------------------------------
:echo_turn_count
SETLOCAL
CALL :output_message %~1 "【第%~2ターン】"
EXIT /B

REM ----------------------------------------------------------------
REM お互いの選択した行動をもとに対決処理を行い、その結果を表す数値を返します。
REM
REM ARGUMENTS %1 プレイヤーの行動
REM           %2 COMの行動
REM
REM ERRORLEVEL -1 エラー
REM            0 あいこ
REM            1 プレイヤーの勝ち
REM            2 COMの勝ち
REM ----------------------------------------------------------------
:judge_battle
SETLOCAL
SET error=-1
SET draw=0
SET pleyer_win=1
SET player_lose=2
IF %~1 EQU %~2 (
    EXIT /B %draw%
)
SET rock=グー
SET scissors=チョキ
SET paper=パー
IF %~1 EQU %rock% (
    IF %~2 EQU %scissors% (
        EXIT /B %pleyer_win%
    )
    IF %~2 EQU %paper% (
        EXIT /B %player_lose%
    )
    ECHO [Error] :judge_battleのCOMの行動が不正です(%~2^)
    EXIT /B %error%
) ELSE IF %~1 EQU %scissors% (
    IF %~2 EQU %paper% (
        EXIT /B %pleyer_win%
    )
    IF %~2 EQU %rock% (
        EXIT /B %player_lose%
    )
    ECHO [Error] :judge_battleのCOMの行動が不正です(%~2^)
    EXIT /B %error%
) ELSE IF %~1 EQU %paper% (
    IF %~2 EQU %rock% (
        EXIT /B %pleyer_win%
    )
    IF %~2 EQU %scissors% (
        EXIT /B %player_lose%
    )
    ECHO [Error] :judge_battleのCOMの行動が不正です(%~2^)
    EXIT /B %error%
) ELSE (
    ECHO [Error] :judge_battleのプレイヤーの行動が不正です(%~1^)
    EXIT /B %error%
)

REM ----------------------------------------------------------------
REM 引数で受け取った文字列をコンソールとログファイルに出力します。
REM 空文字を受け取った場合は空行として取り扱います。
REM 原則として、メッセージの出力には当プロシージャを使うようにします。
REM
REM ARGUMENTS %1 ログファイルのパス
REM           %2 出力する文字列
REM ----------------------------------------------------------------
:output_message
SETLOCAL
IF "%~2" EQU "" (
    ECHO.
    ECHO.>>"%~1"
    EXIT /B
)
ECHO ^%~2
ECHO ^%~2>>"%~1"
EXIT /B
