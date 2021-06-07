/**
 * ゲームキャラクターを表す抽象クラスです。
 * @param initialLife ゲーム開始時点の体力
 * @param name ゲームキャラクターの名前
 */
abstract class GameCharacter {
  protected StandardIO standardIO = StandardIO.getInstance(); // 出力処理を担当するオブジェクトです。
  private final int MAX_LIFE = 5; // 全ゲームキャラクター共通となる体力の上限値です。
  private int life; // 体力です。
  private String name; // 名前です。
  protected final String[] ACTIONS = {"グー", "チョキ", "パー"}; // 選択できる行動の一覧です。
  protected String action; // 選択した行動です。
  GameCharacter(int initialLife, String name) {
    if (initialLife < 0 && initialLife > this.MAX_LIFE ? true : false) {
      System.out.println("[Error] ゲーム開始時点の初期値力値が不正です（" + initialLife + "）");
      System.exit(0);
    }
    this.life = initialLife;
    this.name = name;
  }

  /**
   * 行動を選択する抽象メソッドです。
   * 何らかの方法で行動を選択し、選択した行動を保持するフィールドに選択した行動を代入する処理を実装してください。
   */
  abstract void choiceAction();

  /**
   * ゲームの続行が可能か返答するメソッドです。
   * @return 続行可能ならtrue
   */
  boolean canGame() {
    return this.life > 0 ? true : false;
  }

  /**
   * 名前の横幅を返すメソッドです。
   * String.length()などで取得できる値とは異なり、半角文字を1、全角文字を2としてカウントした値を返します。
   */
  int getNameWidth() {
    char[] nameToCharArray = this.name.toCharArray();
    int nameWidth = 0;
    for (int i = 0; i < nameToCharArray.length; i += 1) {
      nameWidth += String.valueOf(nameToCharArray[i]).getBytes().length == 1 ? 1 : 2;
    }
    return nameWidth;
  }

  /**
   * 自身の状態をメッセージにして返すメソッドです。
   * メッセージは名前部分と体力部分から成ります。
   * 名前部分は相手の名前の長さと横幅を揃えるようにします。
   * 体力部分は記号を使って体力ゲージっぽく表現します。
   * @param opponentNameWidth 対戦相手の名前の横幅（半角文字を1、全角文字を2としてカウント）
   */
  void printStatusMessage(int opponentNameWidth) {
    StringBuilder namePart = new StringBuilder(this.name);
    for (int i = 0; i < opponentNameWidth - this.getNameWidth(); i += 1) {
      namePart.append(" ");
    }
    StringBuilder lifePart = new StringBuilder();
    for (int i = 0; i < this.life; i += 1) {
      lifePart.append("■");
    }
    for (int i = 0; i < this.MAX_LIFE - this.life; i += 1) {
      lifePart.append("□");
    }
    standardIO.println(namePart.toString() + ": " + lifePart.toString());
  }

  /**
   * 選択した行動を返すメソッドです。
   * @return 選択した行動
   */
  String getAction() {
    return this.action;
  }

  /**
   * ダメージ処理となるメソッドです。
   * 自身と相手の行動の組み合わせから、ダメージが発生するか確認し、ダメージが発生するならば体力を減らします。
   * @param opponentAction 対戦相手の行動
   */
  void damageProcess(String opponentAction) {
    if (this.action.equals(this.ACTIONS[0]) && opponentAction.equals(this.ACTIONS[2])
      || this.action.equals(this.ACTIONS[1]) && opponentAction.equals(this.ACTIONS[0])
      || this.action.equals(this.ACTIONS[2]) && opponentAction.equals(this.ACTIONS[1])
    ) {
      this.life -= 1;
      return;
    }
  }

  /**
   * 名前を返すメソッドです。
   * @return 名前
   */
  String getName() {
      return this.name;
  }
}
