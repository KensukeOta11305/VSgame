/**
 * ターン数を表すクラスです
 * 
 * @constructor 何も行いません
 * 
 * @property turnCount ターン数です
 */
class TurnCount() {
    private var turnCount = 0

    /**
     * ターン数のカウントを進めるメソッドです
     */
    fun countUp() {
        this.turnCount += 1
    }

    /**
     * 現在のターン数を表すメッセージを作成・出力するメソッドです
     */
    fun printTurnCount() {
        StandardIO.println("【第 $turnCount ターン】")
    }
}