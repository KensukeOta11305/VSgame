import java.util.Scanner;

/**
 * じゃんけんゲームのメインクラスです。
 */
class Main {
  public static void main(String[] args) {
    StandardIO standardIO = StandardIO.getInstance();
    Player player = new Player(5, "Qii太郎");
    COM com = new COM(5, "COM");
    TurnCount turnCount = new TurnCount();
    while (player.canGame() && com.canGame()) {
      turnCount.countUp();
      turnCount.printTurnCountMessage();
      player.printStatusMessage(com.getNameWidth());
      com.printStatusMessage(player.getNameWidth());
      standardIO.printlnEmptyLine(1);
      player.choiceAction();
      com.choiceAction();
      standardIO.printlnEmptyLine(1);
      standardIO.println(generateChoicedActionMessage(player.getAction(), com.getAction()));
      player.damageProcess(com.getAction());
      com.damageProcess(player.getAction());
      standardIO.printlnEmptyLine(5);
    }
    standardIO.println(generateGameResultMessage(player.canGame(), com.canGame(), player.getName(), com.getName()));
    standardIO.printlnEmptyLine(1);
    pause();
  }

  /**
   * 双方のゲームキャラクターが選択した行動を表すメッセージを作成して返すメソッドです。
   * @param action1 ゲームキャラクター1が選択した行動
   * @param action2 ゲームキャラクター2が選択した行動
   * @return 選択した行動を表すメッセージ
   */
  private static String generateChoicedActionMessage(String action1, String action2) {
    return "> " + action1 + " vs " + action2;
  }

  /**
   * ゲームの結果を表すメッセージを作成して返すメソッドです。
   * @param canGame1 ゲームキャラクター1がゲーム続行可能であるかのフラグ
   * @param canGame2 ゲームキャラクター2がゲーム続行可能であるかのフラグ
   * @param name1 ゲームキャラクター1の名前
   * @param name2 ゲームキャラクター2の名前
   * @return ゲームの結果を表すメッセージ
   */
  private static String generateGameResultMessage(boolean canGame1, boolean canGame2, String name1, String name2) {
    if (canGame1 && !canGame2) {
      return "> " + name1 + "の勝利ですっ！";
    }
    if (!canGame1 && canGame2) {
      return "> " + name2 + "の勝利ですっ！";
    }
    System.out.println("[Error] 引き分けが発生しました");
    System.exit(0);
    return ""; // 文法上のエラーになるため、処理上では不要なreturn文を書いています。
  }

  /**
   * Enterキーが押されるまで処理を止めるメソッドです。
   */
  private static void pause() {
    System.out.print("Enterキーを押してください . . . ");
    Scanner scanner = new Scanner(System.in);
    scanner.nextLine();
  }
}
