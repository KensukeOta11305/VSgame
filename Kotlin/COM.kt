/**
 * COMを表すクラスです
 * 
 * @constructor
 * 
 * @param life プロパティlifeの初期値です
 * @param name プロパティnameの初期値です
 */
class COM(life: Int, name: String): GameCharacter(life, name) {

    /**
     * 行動を選択するメソッドです
     * 乱数を利用して行動を選択します
     */
    override fun choiceAction() {
        this.action = this.actionList[(0..this.actionList.size - 1).random()]
    }
}