/**
 * ターン数を表すクラスです。
 */
class TurnCount {
  private StandardIO standardIO = StandardIO.getInstance(); // 出力処理を担当するオブジェクトです。
  private int turnCount; // ターン数です。
  TurnCount() {
    turnCount = 0;
  }

  /**
   * ターン数のカウントを進めるメソッドです。
   */
  void countUp() {
    this.turnCount += 1;
  }

  /**
   * 現在のターン数をメッセージとして出力するメソッドです。
   */
  void printTurnCountMessage() {
    standardIO.println("【第" + this.turnCount + "ターン】");
  }
}
