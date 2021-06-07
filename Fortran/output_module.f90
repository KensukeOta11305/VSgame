!!
!! コンソール・ログファイルへの出力処理に関する値や操作をまとめたモジュールです
!! → クラスのように使用してください
!!     → 当モジュールで宣言されている構造型の変数を宣言後、コンストラクタの代替となる手続きを呼び出して初期化してください
!! Fortran 2018に準拠しています
!!
module output_module
  implicit none
  type output_type
    private
    character(20) :: log_file_name    ! ログファイル名です
  contains
    procedure          :: constructor                     => output_constructor                        ! 構造型を初期化します
    procedure, private :: set_log_file_name               => output_set_log_file_name                  ! ログファイル名を作成します
    procedure          :: output_message                  => output_output_message                     ! コンソールとログファイルに値を出力します
    procedure          :: output_empty_line               => output_output_empty_line                  ! 任意の数の空行を出力します
    procedure          :: output_message_only_to_log_file => output_output_message_only_to_log_file    ! ログファイルに値を出力します
  end type
contains

  !!
  !! コンストラクタの代替となるサブルーチンです
  !! → 初期化処理を行っているため、当サブルーチンを呼び出すのは1回だけにしてください
  !!
  subroutine output_constructor(self)
    class(output_type) :: self    ! 自オブジェクトです

    !! 処理
    call self%set_log_file_name()
  end subroutine

  !!
  !! ログファイル名を作成するサブルーチンです
  !!
  subroutine output_set_log_file_name(self)
    class(output_type) :: self    ! 自オブジェクトです

    !! 変数
    character(8)  :: current_date          ! ccyymmdd形式の現在日付です
    character(10) :: current_time          ! hhmmss.sss形式の現在時刻です
    character(5)  :: time_difference       ! 現地時刻と世界標準時との時差です    date_and_time()を呼び出すためだけに宣言しています
    integer       :: dates_and_times(8)    ! 現在日時をまとめた配列です    date_and_time()を呼び出すためだけに宣言しています

    !! 処理
    call date_and_time(current_date, current_time, time_difference, dates_and_times)
    self%log_file_name = 'log_' &
      & // current_date(3:4) // current_date(5:6) // current_date(7:8) &
      & // current_time(1:2) // current_time(3:4) // current_time(5:6) &
      & // '.txt'
  end subroutine

  !!
  !! 引数に指定された文字列をコンソールとログファイルに出力するサブルーチンです
  !! 出力される値の末尾には改行が付きます
  !! ログファイルへの書き込みは追記モードで実行します
  !!
  subroutine output_output_message(self, message)
    class(output_type) :: self       ! 自オブジェクトです
    character(*)       :: message    ! 出力する値です

    !! 変数
    integer :: unit    ! ログファイルへの追記時に使用する装置番号です

    !! 処理
    print '(a)', message
    open(newunit = unit, file = self%log_file_name, position = 'append')
    write(unit, '(a)') message
    close(unit)
  end subroutine

  !!
  !! 空行をコンソールとログファイルに出力するサブルーチンです
  !! 出力する空行の数は引数で指定します
  !!
  subroutine output_output_empty_line(self, number_of_line)
    class(output_type) :: self              ! 自オブジェクトです
    integer            :: number_of_line    ! 空行の数です

    !! 変数
    integer :: i    ! 空行出力処理を繰り返し実行するためのカウンタ変数です

    !! 処理
    do i = 1, number_of_line
      call self%output_message('')
    end do
  end subroutine

  !!
  !! 引数に指定された文字列をログファイルにだけ出力するサブルーチンです
  !! → プレイヤー用の行動選択処理などではログファイルへの出力だけが必要になるので当処理を用意しました
  !! 出力される値の末尾には改行が付きます
  !! ログファイルへの書き込みは追記モードで実行します
  !!
  subroutine output_output_message_only_to_log_file(self, message)
    class(output_type) :: self       ! 自オブジェクトです
    character(*)       :: message    ! 出力する値です

    !! 変数
    integer :: unit    ! ログファイルへの追記時に使用する装置番号です

    !! 処理
    open(newunit = unit, file = self%log_file_name, position = 'append')
    write(unit, '(a)') message
    close(unit)
  end subroutine
end module
