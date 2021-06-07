/**
 * プレイヤーを表すクラスです。
 * @param initialLife ゲーム開始時点の体力です
 * @param name ゲームキャラクターの名前です
 */
class Player extends GameCharacter {
  Player(int initialLife, String name) {
    super(initialLife, name);
  }

  /**
   * 行動を選択するメソッドです。 
   * プレイヤー用の処理なので標準入力を使った処理を実装しました。
   */
  @Override
  void choiceAction() {
    String prompt = this.generatePrompt();
    while (true) {
      standardIO.print(prompt);
      String input = standardIO.readLine();
      try {
        this.action = this.ACTIONS[Integer.parseInt(input) - 1];
        return;
      } catch (Exception error) {
        standardIO.printlnEmptyLine(1);
        standardIO.println("> 不正な入力です");
        standardIO.println("> 再入力してください");
        standardIO.printlnEmptyLine(1);
      }
    }
  }

  /**
   * 行動選択処理で必要になるプロンプトを作成して返すメソッドです。
   * @return プロンプト
   */
  private String generatePrompt() {
    StringBuilder prompt = new StringBuilder();
    for (int i = 0; i < this.ACTIONS.length; i += 1) {
      prompt.append("[" + (i + 1) + "] " + this.ACTIONS[i] + "    ");
    }
    prompt.append(": ");
    return prompt.toString();
  }
}
