/**
 * ゲームキャラクターを表す抽象クラスです
 * 
 * @constructor
 * 
 * @param life プロパティlifeの初期値です
 * @param name プロパティnameの初期値です
 * 
 * @property maxLife 全ゲームキャラクター共通となる体力の上限値です
 * @property actionList ゲームキャラクターが選択できる行動のリストです
 * @property action 選択した行動です
 * @property life 体力です
 * @property name 名前です
 */
abstract class GameCharacter(private var life: Int, private val name: String) {
    private val maxLife = 5
    internal val actionList = listOf("グー", "チョキ", "パー")
    internal var action: String = ""    // Kotlinの文法上、メンバ変数は初期化が必要なので空文字を突っ込んでいます
    init {
        if (!(this.life in 0..this.maxLife)) throw Exception("[Error] ゲーム開始時点の体力が不正です（ $this.life ）")
    }

    /**
     * 行動を選択する抽象メソッドです
     */
    abstract fun choiceAction()

    /**
     * ゲームの続行が可能か返答するメソッドです
     * 
     * @return 続行可能ならtrueを返します
     */
    fun canGame(): Boolean = if (this.life > 0) true else false

    /**
     * 自身のステータスを表すメッセージを作成・出力するメソッドです
     * メッセージは名前部分と体力部分から成ります
     * → 名前部分は自身と相手の名前の「横幅」を揃えるようにします
     * → 体力部分は体力を記号を使って体力ゲージっぽく表現します
     * 
     * @param opponentNameWidth 対戦相手の名前の「横幅」です
     */
    fun printStatus(opponentNameWidth: Int) {
        var namePart = this.name
        repeat(opponentNameWidth - this.countNameWidth()) {
            namePart += " "
        }
        var lifePart = ""
        repeat(this.life) {
            lifePart += "■"
        }
        repeat(this.maxLife - this.life) {
            lifePart += "□"
        }
        StandardIO.println("$namePart : $lifePart")
    }

    /**
     * 自身の名前の「横幅」を返すメソッドです
     * ここでいう「横幅」とは半角文字を1、全角文字を2として数えた整数です
     * 
     * @return 名前の横幅を表す数値です
     */
    fun countNameWidth(): Int {
        var nameWidth = 0
        for (i in this.name.toCharArray()) nameWidth += if (i.toString().toByteArray().size == 1) 1 else 2
        return nameWidth
    }

    /**
     * 選択した行動を返すメソッドです
     * 
     * @return 選択した行動です
     */
    fun getAction(): String = this.action

    /**
     * ダメージ処理を実行するメソッドです
     * 自身と相手の行動を照らし合わせ、ダメージが発生するか確認します
     * ダメージが発生する状況であれば体力を減らします
     * 
     * @param opponentAction 対戦相手が選択した行動です
     */
    fun damageProcess(opponentAction: String) {
        if (!(this.actionList.contains(opponentAction))) throw Exception("[Error] 対戦相手の選択した行動が不正です（ $opponentAction ）")
        if ((this.action == this.actionList[0] && opponentAction == this.actionList[2])
            || (this.action == this.actionList[1] && opponentAction == this.actionList[0])
            || (this.action == this.actionList[2] && opponentAction == this.actionList[1])
        ) this.life -= 1
    }

    /**
     * 自身の名前を返すメソッドです
     * 
     * @return 自身の名前です
     */
    fun getName(): String = this.name
}