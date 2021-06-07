import java.util.Calendar
import java.text.SimpleDateFormat
import java.io.File

/**
 * コンソール・ログファイルへの入出力を一手に担うオブジェクトです
 * 
 * @constructor 当オブジェクトが生成されるタイミングでの現在日時から、ログファイル名を作成してプロパティで保持します
 * 
 * @property logFileName ログファイル名です
 */
object StandardIO {
    private val logFileName: String
    init {
        this.logFileName = "log_${SimpleDateFormat("yyMMddHHmmss").format(Calendar.getInstance().getTime())}.txt"
    }

    /**
     * 引数に指定された値をコンソールとログファイルに出力するメソッドです
     * 出力される文字列の末尾には改行が付きます
     * 
     * @param message 出力対象となる値です
     */
    fun println(message: Any) {
        kotlin.io.println(message)    // 当メソッド名と衝突するためパッケージ名込みで呼び出しています
        File(this.logFileName).appendText(message.toString() + "\n")
    }

    /**
     * 任意の数の空行をコンソールとログファイルに出力するメソッドです
     * 空行の数は引数で操作します
     * 
     * @param numberOfEmptyLine 空行の数です
     */
    fun printEmptyLine(numberOfEmptyLine: Int) {
        repeat(numberOfEmptyLine) {
            this.println("")
            File(this.logFileName).appendText("")
        }
    }

    /**
     * 引数に指定された値をコンソールとログファイルに出力するメソッドです
     * 
     * @param message 出力対象となる値です
     */
    fun print(message: Any) {
        kotlin.io.print(message)    // 当メソッド名と衝突するためパッケージ名込みで呼び出しています
        File(this.logFileName).appendText(message.toString())
    }

    /**
     * 標準入力処理を実行するメソッドです
     * 入力された値はInt型への変換が行われ、数値に変換できない場合はnullを返します
     * また、入力された値をログファイルに書き出します
     * → 末尾に改行が入ります
     * 
     * @return 標準入力された数値かnullです
     */
    fun readLineToIntOrNull(): Int? {
        val input = readLine()
        if (input == null) this.println("") else this.println(input.toString())
        return input?.toIntOrNull()
    }
}
