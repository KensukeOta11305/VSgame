!!
!! じゃんけん（っぽい）ゲームを遊ぶことができるプログラムです
!! Fortran 2018に準拠しています
!!
program main
  use game_character_module
  use output_module
  implicit none

  !! 変数
  type(game_character_type) :: player        ! プレイヤーを表すオブジェクトです
  type(game_character_type) :: com           ! COMを表すオブジェクトです
  integer                   :: turn_count    ! ターン数です
  type(output_type)         :: output        ! コンソール・ログファイルへの出力処理を担当するオブジェクトです

  !! 処理
  call player%constructor(5, 'Qii太郎', .true.)
  call com%constructor(5, 'COM', .false.)
  turn_count = 0
  call output%constructor()
  do while(player%can_game() .and. com%can_game())
    call add_turn_count()
    call output_turn_count_message()
    call player%output_status_message(com%get_name_width(), output)
    call com%output_status_message(player%get_name_width(), output)
    call output%output_empty_line(1)
    call player%choice_action(output)
    call com%choice_action(output)
    call output%output_empty_line(1)
    call output_choiced_action()
    call player%damage_process(com%get_action())
    call com%damage_process(player%get_action())
    call output%output_empty_line(5)
  end do
  call judge_winner()
  call output%output_empty_line(1)
  call pause()
contains

  !!
  !! ターン処理開始に伴い、ターン数を加算するサブルーチンです
  !!
  subroutine add_turn_count()

    !! 処理
    turn_count = turn_count + 1
  end subroutine

  !!
  !! 現在のターン数を知らせるメッセージを出力するサブルーチンです
  !!
  subroutine output_turn_count_message()

    !! 変数
    character(3) :: turn_count_to_string    ! 文字列化したターン数です（長さが3あれば999ターンまで対応できるので十分なはず……）

    !! 処理
    write(turn_count_to_string, '(i0)') turn_count
    call output%output_message('【第' // trim(turn_count_to_string) // 'ターン】')
  end subroutine

  !!
  !! 双方のゲームキャラクターが選択した行動を出力するサブルーチンです
  !!
  subroutine output_choiced_action()
    call output%output_message('> ' // trim(player%get_action()) // ' vs ' // trim(com%get_action()))
  end subroutine

  !!
  !! 勝者を判定し、勝者が誰かを知らせるメッセージを出力するサブルーチンです
  !!
  subroutine judge_winner()

    !! 処理
    if(player%can_game()) then
      if(com%can_game()) then
        error stop 'judge_winner - 1'
      else
        call output%output_message('> ' // trim(player%get_name()) // 'の勝利です！')
      end if
    else
      if(com%can_game()) then
        call output%output_message('> ' // trim(com%get_name()) // 'の勝利です！')
      else
        error stop 'judge_winner - 2'
      end if
    end if
  end subroutine

  !!
  !! Enterキーが押されるまで処理を止めるサブルーチンです
  !!
  subroutine pause()

    !! 処理
    write(*, '(a)', advance='no') 'Enterキーを押してください . . . '
    read *
  end subroutine
end program
