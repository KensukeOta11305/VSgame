!!
!! ゲームキャラクターに関する値や操作をまとめたモジュールです
!! → クラスのように使用してください
!!     → 当モジュールで宣言されている構造型の変数を宣言後、コンストラクタの代替となる手続きを呼び出して初期化してください
!! Fortran 2018に準拠しています
!!
module game_character_module
  use output_module
  implicit none
  type game_character_type
    private
    integer       :: max_life          ! 体力の上限値です
    integer       :: life              ! 体力です
    character(64) :: name              ! 名前です（長さは64もあれば足りるやろ……）
    integer       :: name_width        ! 名前の横幅（バイト数ではない）です
    logical       :: is_playable       ! プレイヤーキャラクターであるかを表すフラグです
    character(9)  :: action_list(3)    ! 行動の一覧です
    character(9)  :: action            ! 選択した行動です
  contains
    procedure          :: constructor              => game_character_constructor                 ! 構造型を初期化します
    procedure, private :: set_name_width           => game_character_set_name_width              ! 名前の横幅を数えてモジュール変数に代入します
    procedure          :: can_game                 => game_character_can_game                    ! ゲームの続行が可能か返答します
    procedure          :: get_name_width           => game_character_get_name_width              ! 名前の横幅を返します
    procedure          :: output_status_message    => game_character_output_status_message       ! ステータスを表すメッセージを返します
    procedure          :: choice_action            => game_character_choice_action               ! 行動選択処理です
    procedure, private :: count_prompt_len         => game_character_count_prompt_len            ! プロンプトの長さをカウントします
    procedure, private :: generate_prompt          => game_character_generate_prompt             ! プロンプトを作成します
    procedure, private :: choice_action_for_player => game_character_choice_action_for_player    ! プレイヤー用の行動選択処理です
    procedure, private :: choice_action_for_com    => game_character_choice_action_for_com       ! COM用の行動選択処理です
    procedure          :: get_action               => game_character_get_action                  ! 選択した行動名を返します
    procedure          :: damage_process           => game_character_damage_process              ! ダメージ処理です
    procedure          :: get_name                 => game_character_get_name                    ! 名前を返します
  end type
contains

  !!
  !! コンストラクタの代替となるサブルーチンです
  !! → 初期化処理を行っているため、当サブルーチンを呼び出すのは1回だけにしてください
  !!
  subroutine game_character_constructor(self, initial_life, name, is_playable)
    class(game_character_type) :: self            ! 自オブジェクトです
    integer                    :: initial_life    ! ゲーム開始時点の体力です
    character(*)               :: name            ! 名前です
    logical                    :: is_playable     ! プレイヤーキャラクターであるかを表すフラグです

    !! 処理
    self%max_life = 5
    if (initial_life < 0) then
      error stop 'game_character_module%constructor - 1'
    end if
    if (initial_life > self%max_life) then
      error stop 'game_character_module%constructor - 2'
    end if
    self%life = initial_life
    self%name = name
    call self%set_name_width()
    self%is_playable = is_playable
    self%action_list(1) = 'グー'
    self%action_list(2) = 'チョキ'
    self%action_list(3) = 'パー'
  end subroutine

  !!
  !! 自身の名前の横幅（バイト数ではない）を数えて返す関数です
  !! 半角文字を1、全角文字を2としてカウントします
  !! → iachar()を使って名前をアスキーコードに変換したとき、全角文字を構成する3バイトの1つ目の数値が128以上である特性を利用して判別しています
  !!
  subroutine game_character_set_name_width(self)
    class(game_character_type) :: self    ! 自オブジェクトです

    !! 変数
    integer :: cycle_stock    ! 下記do文中でcycle文を実行するか判断するフラグ兼cycle文の実行回数です
    integer :: i              ! 名前を1文字ずつ参照するためのカウンタ変数です

    !! 処理
    self%name_width = 0
    cycle_stock = 0
    do i = 1, len_trim(self%name)
      if (cycle_stock > 0) then
        cycle_stock = cycle_stock - 1
        cycle
      end if
      if (iachar(self%name(i:i)) < 128) then
        self%name_width = self%name_width + 1
      else
        self%name_width = self%name_width + 2
        cycle_stock = 2
      end if
    end do
  end subroutine

  !!
  !! ゲームの続行が可能であるか返答する関数です
  !!
  function game_character_can_game(self) result(can_game)
    class(game_character_type) :: self        ! 自オブジェクトです
    logical                    :: can_game    ! ゲームの続行が可能であるかを表す戻り値です

    !! 処理
    if (self%life > 0) then
      can_game = .true.
    else
      can_game = .false.
    end if
  end function

  !!
  !! 名前の横幅を返す関数です
  !!
  function game_character_get_name_width(self) result(name_width)
    class(game_character_type) :: self          ! 自オブジェクトです
    integer                    :: name_width    ! 名前の横幅です

    !! 処理
    name_width = self%name_width
  end function

  !!
  !! ステータスを表すメッセージを作成して返すサブルーチンです
  !! メッセージは名前部分と体力部分からなります
  !! → 名前部分では双方のゲームキャラクターの名前の横幅を揃えて見映えを良くしています
  !!     → 横幅を揃えるために、バイト数ではなく、半角文字を1、全角文字を2としてカウントした特殊な値を使用しています
  !! → 体力部分では記号を使って体力ゲージっぽく見える文字列を使用しています
  !!
  subroutine game_character_output_status_message(self, opponent_name_width, output_object)
    class(game_character_type) :: self                   ! 自オブジェクトです
    integer                    :: opponent_name_width    ! 当サブルーチンにおいて主体となるゲームキャラクターの対戦相手の名前の横幅です
    type(output_type)          :: output_object          ! コンソール・ログファイルへの出力を担当するオブジェクトです

    !! 変数
    character(len_trim(self%name) + max(0, opponent_name_width - self%name_width)) :: name_part    ! メッセージを構成する名前部分です
    character(self%max_life * 3)                                                   :: life_part    ! メッセージを構成する体力部分です
    integer                                                                        :: i            ! 体力ゲージを作成するのに必要なカウンタ変数です

    !! 処理
    name_part = self%name
    life_part = ''
    do i = 1, self%life
      life_part = trim(life_part) // '■'
    end do
    do i = 1, self%max_life - self%life
      life_part = trim(life_part) // '□'
    end do
    call output_object%output_message(name_part // ': ' // life_part)
  end subroutine

  !!
  !! 行動を選択するサブルーチンです
  !! プレイアブルなキャラクターであるかどうかに応じて処理を切り替えます
  !!
  subroutine game_character_choice_action(self, output_object)
    class(game_character_type) :: self             ! 自オブジェクトです
    type(output_type)          :: output_object    ! コンソール・ログファイルへの出力を担当するオブジェクトです

    !! 処理
    if(self%is_playable) then
      call self%choice_action_for_player(self%generate_prompt(self%count_prompt_len()), output_object)
    else
      call self%choice_action_for_com()
    end if
  end subroutine

  !!
  !! 行動選択処理で必要となるプロンプトの長さを返す関数です
  !!
  function game_character_count_prompt_len(self) result(prompt_len)
    class(game_character_type) :: self          ! 自オブジェクトです
    integer                    :: prompt_len    ! プロンプトの長さです

    !! 変数
    integer :: i                    ! プロンプトの長さを測るのに必要なカウンタ変数です
    integer :: option_number_len    ! プロンプトを構成する選択肢番号部分の長さですです
    integer :: option_spacer_len    ! プロンプトを構成する選択肢間を区切る半角空白群の長さです
    integer :: prompt_end_len       ! プロンプトの末尾を表す文字列の長さです

    !! 処理
    option_number_len = 4
    option_spacer_len = 4
    prompt_end_len = 2
    prompt_len = 0
    do i = 1, size(self%action_list)
      prompt_len = prompt_len + option_number_len + len_trim(self%action_list(i)) + option_spacer_len
    end do
    prompt_len = prompt_len + prompt_end_len
  end function

  !!
  !! 行動選択処理で必要となるプロンプトを作成して返す関数です
  !!
  function game_character_generate_prompt(self, prompt_len) result(prompt)
    class(game_character_type) :: self          ! 自オブジェクトです
    integer                    :: prompt_len    ! プロンプトの長さです
    character(prompt_len)      :: prompt        ! プロンプトです

    !! 変数
    integer      :: i                ! カウンタ変数です
    character(1) :: option_number    ! カウンタ変数を文字列化したもの――選択肢番号です
    integer      :: option_len       ! 選択肢番号・選択肢名・選択肢間の区切りからなる文字列の長さです
    integer      :: prompt_head      ! プロンプトとなる文字列のうち、未入力のインデックスのなかで最も若い番号です

    !! 処理
    prompt = ''
    prompt_head = 1
    do i = 1, size(self%action_list)
      write(option_number, '(i0)') i
      option_len = len('[' // option_number // '] ' // trim(self%action_list(i)) // '    ')
      prompt(prompt_head: prompt_head + option_len - 1) = '[' // option_number // '] ' // self%action_list(i) // '    '
      prompt_head = prompt_head + option_len
    end do
    prompt(prompt_head:prompt_head + 2) = ': '
  end function

  !!
  !! プレイヤー用の行動選択処理を実行するサブルーチンです
  !!
  subroutine game_character_choice_action_for_player(self, prompt, output_object)
    class(game_character_type) :: self             ! 自オブジェクトです
    character(*)               :: prompt           ! プロンプトです
    type(output_type)          :: output_object    ! コンソール・ログファイルへの出力を担当するオブジェクトです

    !! 変数
    character(1) :: input          ! 標準入力された値を受け取る変数です
    integer      :: i              ! カウンタ変数です
    character(1) :: i_to_string    ! カウンタ変数を文字列化したものです

    !! 処理
    do
      write(*, '(a)', advance='no') prompt
      read *, input
      call output_object%output_message_only_to_log_file(prompt // input)
      do i = 1, size(self%action_list)
        write(i_to_string, '(i0)') i
        if(input == i_to_string) then
          self%action = self%action_list(i)
          return
        end if
      end do
      call output_object%output_empty_line(1)
      call output_object%output_message('> 再入力してください')
      call output_object%output_empty_line(1)
    end do
  end subroutine

  !!
  !! COM用の行動選択処理を実行するサブルーチンです
  !!
  subroutine game_character_choice_action_for_com(self)
    class(game_character_type) :: self    ! 自オブジェクトです

    !! 変数
    real :: random    ! 行動選択処理で用いる乱数です

    !! 処理
    call random_number(random)
    self%action = self%action_list(int(random * size(self%action_list)) + 1)
  end subroutine

  !!
  !! 選択した行動を返す関数です
  !!
  function game_character_get_action(self) result(action)
    class(game_character_type)  :: self      ! 自オブジェクトです
    character(len(self%action)) :: action    ! 選択した行動です

    !! 処理
    action = self%action
  end function

  !!
  !! ダメージが発生するかを確認し、必要であればダメージを発生――体力を減少させるサブルーチンです
  !!
  subroutine game_character_damage_process(self, opponent_action)
    class(game_character_type)     :: self               ! 自オブジェクトです
    character(len(self%action))    :: opponent_action    ! 対戦相手が選択した行動です

    !! 処理
    if( &
      & (self%action == self%action_list(1) .and. opponent_action == self%action_list(3)) &
      & .or. &
      & (self%action == self%action_list(2) .and. opponent_action == self%action_list(1)) &
      & .or. &
      & (self%action == self%action_list(3) .and. opponent_action == self%action_list(2)) &
      & ) then
      self%life = self%life - 1
    end if
  end subroutine

  !!
  !! 名前を呼び出し元に返す関数です
  !!
  function game_character_get_name(self) result(name)
    class(game_character_type) :: self    ! 自オブジェクトです
    character(len(self%name))  :: name    ! 自身の名前です

    !! 処理
    name = self%name
  end function
end module
