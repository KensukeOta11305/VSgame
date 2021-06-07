/**
 * じゃんけん（っぽい）ゲームのエントリポイントです
 * 
 * @author AGadget
 */
fun main() {
    val player = Player(5, "Qii太郎")
    val com = COM(5, "COM")
    val turnCount = TurnCount()
    while (player.canGame() && com.canGame()) {
        turnCount.countUp()
        turnCount.printTurnCount()
        player.printStatus(com.countNameWidth())
        com.printStatus(player.countNameWidth())
        StandardIO.printEmptyLine(1)
        player.choiceAction()
        com.choiceAction()
        StandardIO.printEmptyLine(1)
        printChoicedAction(player.getAction(), com.getAction())
        player.damageProcess(com.getAction())
        com.damageProcess(player.getAction())
        StandardIO.printEmptyLine(5)
    }
    judgeGameResult(player.canGame(), com.canGame(), player.getName(), com.getName())
    StandardIO.printEmptyLine(1)
    pause()
}

/**
 * 双方のゲームキャラクターが選択した行動を表すメッセージを出力する関数です
 * 
 * @param action1 ゲームキャラクター1が選択した行動です
 * @param action2 ゲームキャラクター2が選択した行動です
 */
private fun printChoicedAction(action1: String, action2: String) {
    StandardIO.println("> $action1 vs $action2")
}

/**
 * ゲームの勝敗を判定・出力する関数です
 * @param canGame1 ゲームキャラクター1がゲーム続行可能であるかのフラグです
 * @param canGame2 ゲームキャラクター1がゲーム続行可能であるかのフラグです
 * @param name1 ゲームキャラクター1の名前です
 * @param name2 ゲームキャラクター2の名前です
 */
private fun judgeGameResult(canGame1: Boolean, canGame2: Boolean, name1: String, name2: String) {
    when {
        canGame1 && !canGame2 -> StandardIO.println("> $name1 の勝利です！")
        !canGame1 && canGame2 -> StandardIO.println("> $name2 の勝利です！")
        else -> throw Exception("[Error] ゲームの勝敗が不正です（ $name1 : $canGame1 , $name2 : $canGame2 ）")
    }
}

/**
 * Enterキーが押されるまで処理を停止する関数です
 */
private fun pause() {
    print("Enterキーを押してください . . . ")
    readLine()
}