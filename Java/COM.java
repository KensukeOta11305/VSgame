import java.util.Random;

/**
 * COMを表すクラスです。
 * @param initialLife ゲーム開始時点の体力
 * @param name ゲームキャラクターの名前
 */
class COM extends GameCharacter {
  COM(int initialLife, String name) {
    super(initialLife, name);
  }

  /**
   * 行動を選択するメソッドです。
   * COM用の処理なので乱数を使った処理を実装しました。
   */
  @Override
  void choiceAction() {
    Random random = new Random();
    this.action = ACTIONS[random.nextInt(ACTIONS.length)];
  }
}
