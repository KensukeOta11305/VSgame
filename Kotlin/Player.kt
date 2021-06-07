/**
 * プレイヤーを表すクラスです
 * 
 * @constructor
 * 
 * @param life プロパティlifeの初期値です
 * @param name プロパティnameの初期値です
 */
class Player(life: Int, name: String): GameCharacter(life, name) {

    /**
     * 行動を選択するメソッドです
     * 標準入力を利用して行動を選択します
     */
    override fun choiceAction() {
        val prompt = this.generatePrompt()
        while (true) {
            StandardIO.print(prompt)
            val input = StandardIO.readLineToIntOrNull()
            if (input != null && (1..this.actionList.size).contains(input)) {
                this.action = this.actionList[input - 1]
                return
            }
            StandardIO.printEmptyLine(1)
            StandardIO.println("> 不正な入力です")
            StandardIO.println("> 再入力してください")
            StandardIO.printEmptyLine(1)
        }
    }

    /**
     * 行動選択処理で必要となるプロンプトを作成して返します
     * 
     * @return プロンプトとなる文字列です
     */
    private fun generatePrompt(): String {
        var prompt = ""
        for ((i, v) in this.actionList.withIndex()) {
            prompt += "[${i + 1}] $v    "
        }
        prompt += ": "
        return prompt
    }
}