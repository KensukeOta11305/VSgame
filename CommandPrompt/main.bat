@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM ���s���O�t�@�C���̃t���p�X���쐬���܂��B
SET yymmdd=%DATE%
SET yymmdd=%yymmdd:/=%
SET yymmdd=%yymmdd:~2,6%
SET hhmmss=%TIME%
SET hhmmss=%hhmmss::=%
SET hhmmss=%hhmmss: =0%
SET hhmmss=%hhmmss:~0,6%
SET log_file_full_path="%~DP0log_%yymmdd%%hhmmss%.txt"

REM �L�����N�^�[�̗͂�ݒ肵�܂��B
SET max_life=5
SET player_life=%max_life%
SET com_life=%max_life%

REM �L�����N�^�[�̖��O��ݒ肵�܂��B
SET player_name=Qii���Y
SET com_name=COM

REM �R���\�[���ɕ\�������Ƃ��Ɍ��h�����ǂ��悤�ɁA�L�����N�^�[�̖��O�̉����𑵂��܂��B
REM �܂��́A�o���̃L�����N�^�[�̖��O�̒����i�o�C�g���j���擾���܂��B
REM �����̎擾�ɂ́A���O���t�@�C���ɏ����o���ăt�@�C���̃T�C�Y����v�Z������@���̂�܂��B
REM �Ȃ��A��t�@�C���ł�2�o�C�g�����Ă���̂ŁA���̕��͖��O�̃T�C�Y���甲���Čv�Z���܂��B
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

REM ���O�̒������擾�ł����̂őo���̖��O�̒������r���܂��B
REM �Z���ق��̖��O�͔��p�󔒂ő���Ȃ�������₢�܂��B
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

REM �ȉ��A�������[�v�ɂ��^�[�������ł��B
SET turn_count=1
:loop_for_turn_system

REM ���݂̃Q�[���󋵂�\�����܂��B
CALL :echo_turn_count %log_file_full_path% %turn_count%
CALL :echo_character_status %log_file_full_path% %player_name% %max_life% %player_life%
CALL :echo_character_status %log_file_full_path% %com_name% %max_life% %com_life%
CALL :echo_empty_line %log_file_full_path%  1

REM �v���C���[�̍s����I�����܂��B
CALL :choice_player_action %log_file_full_path%
SET player_choice=%ERRORLEVEL%
SET rock=1
SET scissors=2
SET paper=3
IF %player_choice% EQU %rock% (
    SET player_action=�O�[
) ELSE IF %player_choice% EQU %scissors% (
    SET player_action=�`���L
) ELSE IF %player_choice% EQU %paper% (
    SET player_action=�p�[
) ELSE (

    REM �����ʂ�IF�u���b�N�̕��L���Ɖ��߂���Ȃ��悤�G�X�P�[�v���܂��B
    ECHO [Error] �v���C���[�̑I��ԍ����s���ł�(%player_choice%^)
    PAUSE
    EXIT /B 1
)

REM COM�̍s����I�����܂�
CALL :choice_com_action
SET /A com_choice=%ERRORLEVEL%
IF %com_choice% EQU 1 (
    SET com_action=�O�[
) ELSE IF %com_choice% EQU 2 (
    SET com_action=�`���L
) ELSE IF %com_choice% EQU 3 (
    SET com_action=�p�[
) ELSE (

    REM �����ʂ�IF�u���b�N�̕��L���Ɖ��߂���Ȃ��悤�G�X�P�[�v���܂��B
    ECHO [Error] COM�̑I�������s���ԍ����s���ł�(%com_choice%^)
    PAUSE
    EXIT /B 1
)
CALL :echo_empty_line %log_file_full_path% 1

REM ���݂����I�������s����\�����܂��B
CALL :echo_characters_action %log_file_full_path% %player_action% %com_action%

REM ���݂����I�������s���ɂ��Ό����ʂ�\�����܂��B
CALL :judge_battle %player_action% %com_action%
SET battle_result=%ERRORLEVEL%
SET error=-1
SET draw=0
SET pleyer_win=1
SET player_lose=2
IF %battle_result% EQU %draw% (
    CALL :output_message %log_file_full_path% "> ������"
) ELSE IF %battle_result% EQU %pleyer_win% (
    CALL :output_message %log_file_full_path% "> ����"
    SET /A com_life-=1
) ELSE IF %battle_result% EQU %player_lose% (
    CALL :output_message %log_file_full_path% "> ����"
    SET /A player_life-=1
) ELSE (
    ECHO [Error] ����񂯂�̏��s���ʂ��s���ł�(%battle_result%^)
    PAUSE
    EXIT /B 1
)
CALL :echo_empty_line %log_file_full_path% 5

REM �Q�[���̌��������������肵�܂��B
IF %player_life% EQU 0 (
    IF %com_life% EQU 0 (
        ECHO [Error] �Q�[���̏��s���ʂ��s���ł�(%player_life%,%com_life%^)
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

REM ���ҕs�݂̏ꍇ�͎��^�[���ɐi�݂܂��B
IF "%winner%" EQU "" (
    SET /A turn_count+=1
    GOTO loop_for_turn_system
)

REM ���҂�����ꍇ�̓Q�[���̏��s���ʂ�\�����܂��B
CALL :output_message %log_file_full_path% "�y�����z"
CALL :echo_character_status %log_file_full_path% %player_name% %max_life% %player_life%
CALL :echo_character_status %log_file_full_path% %com_name% %max_life% %com_life%
CALL :echo_empty_line %log_file_full_path% 1
IF %winner% EQU %player_name% (
    CALL :output_message %log_file_full_path% "> �Q�[���ɏ������܂����I"
) ELSE (
    IF %winner% EQU %com_name% (
        CALL :output_message %log_file_full_path% "> �Q�[���ɔs�k���܂����c�c"
    ) ELSE (
        ECHO [Error] �Q�[���̏��s���ʂ��s���ł�(%winner%^)
        PAUSE
        EXIT /B 1
    )
)
ECHO.
PAUSE
EXIT /B 0

REM ----------------------------------------------------------------
REM COM�̍s���𗐐��őI�������A�I�������s���ƑΉ����鐔�l��Ԃ��܂��B
REM
REM ERRORLEVEL 1 �O�[
REM            2 �`���L
REM            3 �p�[
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
REM �v���C���[�̍s����W�����͂őI�������A�I�������s���ƑΉ����鐔�l��Ԃ��܂��B
REM
REM ARGUMENTS %1 ���O�t�@�C���̃p�X
REM
REM ERRORLEVEL 1 �O�[
REM            2 �`���L
REM            3 �p�[
REM ----------------------------------------------------------------
:choice_player_action
SETLOCAL ENABLEDELAYEDEXPANSION

REM �W�����͂��󂯕t���܂��B
SET prompt_message="[1] �O�[    [2] �`���L    [3] �p�[    : "
SET /P input=%prompt_message%

REM �������͂���Ȃ������ꍇ�̏����ł��B
REM ��O�Ƃ��āA���O�t�@�C���ւ̏������݂͂����Œ��ڍs���܂��B
IF "%input%" EQU "" (
    ECHO %prompt_message:"=%>>"%~1"
    GOTO choice_player_action
)

REM ���͂��ꂽ�l���z�肳�ꂽ���̂ł���΁A�Ή�����l���Ăяo�����ɕԂ��܂��B
REM ��O�Ƃ��āA���O�t�@�C���ւ̏������݂͂����Œ��ڍs���܂��B
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

REM �z��O�̒l�����͂��ꂽ�ꍇ�̓G���[���b�Z�[�W���o�͂��čē��͂𑣂��܂��B
REM ���̂Ƃ��A��Ȃ�L�����t�@�C���ւ̏o�͋L���ƌ��􂳂�邽�߃G�X�P�[�v����̂�Y��Ȃ��悤�ɂ��܂��B
REM �W�����͂��ꂽ�l���󂯎��ϐ��̏�������Y�ꂸ�ɍs���܂��B
CALL :echo_empty_line "%~1" 1
CALL :output_message %~1 "> �s���ȓ��͂ł�"
CALL :output_message %~1 "> �ē��͂��Ă�������"
CALL :echo_empty_line "%~1" 1
SET input=
GOTO choice_player_action

REM ----------------------------------------------------------------
REM �v���C���[��COM�̑I�������s�����o�͂��܂��B
REM
REM ARGUMENTS %1 ���O�t�@�C���̃p�X
REM           %2 �v���C���[�̑I�������s��
REM           %3 COM�̑I�������s��
REM ----------------------------------------------------------------
:echo_characters_action
SETLOCAL
CALL :output_message %~1 "> %~2 vs %~3"
EXIT /B

REM ----------------------------------------------------------------
REM �L�����N�^�[�̃X�e�[�^�X���o�͂��܂��B
REM
REM ARGUMENTS %1 ���O�t�@�C���̃p�X
REM           %2 �L�����N�^�[�̖��O
REM           %3 �L�����N�^�[�̗̑͏���l
REM           %4 �L�����N�^�[�̗̑�
REM ----------------------------------------------------------------
:echo_character_status
SETLOCAL ENABLEDELAYEDEXPANSION

REM �̗͂̏�Ԃ��A�L�����g���đ̗̓Q�[�W�̂悤�ɕ\�����܂��B
SET life_gauge=
FOR /L %%I IN (1,1,%~4) DO (
    SET life_sign=��
    SET life_gauge=!life_gauge!!life_sign!
)
SET /A damage=%~3-%~4
FOR /L %%a IN (1,1,%damage%) DO (
    SET damage_sign=��
    SET life_gauge=!life_gauge!!damage_sign!
)

SET character_status="%~2: %life_gauge%"
CALL :output_message %~1 %character_status%
EXIT /B

REM ----------------------------------------------------------------
REM �C�ӂ̐��̋�s���o�͂��܂��B
REM
REM ARGUMENTS %1 ���O�t�@�C���̃p�X
REM           %2 �o�͂���s��
REM ----------------------------------------------------------------
:echo_empty_line
SETLOCAL
FOR /L %%a IN (1,1,%~2) DO (
    CALL :output_message %~1 ""
)
EXIT /B

REM ----------------------------------------------------------------
REM ���݂̃^�[�������o�͂��܂��B
REM
REM ARGUMENTS %1 ���O�t�@�C���̃p�X
REM           %2 �^�[����
REM ----------------------------------------------------------------
:echo_turn_count
SETLOCAL
CALL :output_message %~1 "�y��%~2�^�[���z"
EXIT /B

REM ----------------------------------------------------------------
REM ���݂��̑I�������s�������ƂɑΌ��������s���A���̌��ʂ�\�����l��Ԃ��܂��B
REM
REM ARGUMENTS %1 �v���C���[�̍s��
REM           %2 COM�̍s��
REM
REM ERRORLEVEL -1 �G���[
REM            0 ������
REM            1 �v���C���[�̏���
REM            2 COM�̏���
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
SET rock=�O�[
SET scissors=�`���L
SET paper=�p�[
IF %~1 EQU %rock% (
    IF %~2 EQU %scissors% (
        EXIT /B %pleyer_win%
    )
    IF %~2 EQU %paper% (
        EXIT /B %player_lose%
    )
    ECHO [Error] :judge_battle��COM�̍s�����s���ł�(%~2^)
    EXIT /B %error%
) ELSE IF %~1 EQU %scissors% (
    IF %~2 EQU %paper% (
        EXIT /B %pleyer_win%
    )
    IF %~2 EQU %rock% (
        EXIT /B %player_lose%
    )
    ECHO [Error] :judge_battle��COM�̍s�����s���ł�(%~2^)
    EXIT /B %error%
) ELSE IF %~1 EQU %paper% (
    IF %~2 EQU %rock% (
        EXIT /B %pleyer_win%
    )
    IF %~2 EQU %scissors% (
        EXIT /B %player_lose%
    )
    ECHO [Error] :judge_battle��COM�̍s�����s���ł�(%~2^)
    EXIT /B %error%
) ELSE (
    ECHO [Error] :judge_battle�̃v���C���[�̍s�����s���ł�(%~1^)
    EXIT /B %error%
)

REM ----------------------------------------------------------------
REM �����Ŏ󂯎������������R���\�[���ƃ��O�t�@�C���ɏo�͂��܂��B
REM �󕶎����󂯎�����ꍇ�͋�s�Ƃ��Ď�舵���܂��B
REM �����Ƃ��āA���b�Z�[�W�̏o�͂ɂ͓��v���V�[�W�����g���悤�ɂ��܂��B
REM
REM ARGUMENTS %1 ���O�t�@�C���̃p�X
REM           %2 �o�͂��镶����
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
