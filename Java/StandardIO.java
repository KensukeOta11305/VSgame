import java.util.Calendar;
import java.text.SimpleDateFormat;
import java.io.IOException;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.PrintWriter;
import java.util.Scanner;

/**
 * コンソール・ログファイルへの入出力を一手に担うクラスです。
 * Singletonデザインパターンを採用しています。
 */
class StandardIO {
  private static StandardIO instanceStandardIO = new StandardIO(); // 当オブジェクトのインスタンスです。
  private String logFilePath; // ログファイルのパスです。
  private StandardIO() {
    Calendar calendar = Calendar.getInstance();
    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyMMddHHmmss");
    this.logFilePath = "log_" + simpleDateFormat.format(calendar.getTime()) + ".txt"; // 現在日時から作成されたログファイル名です。
  }

  /**
   * 当オブジェクトのインスタンスを返すメソッドです。
   * Singletonデザインパターンを採用しているため必要となるメソッドです。
   * @return 当オブジェクトのインスタンス
   */
  public static StandardIO getInstance() {
    return instanceStandardIO;
  }

  /**
   * 引数に指定された文字列をコンソールとログファイルに出力するメソッドです。
   * 出力する値の末尾に改行文字が付きます。
   * @param message 出力する文字列
   */
  void println(String message) {
    System.out.println(message);
    try {
      FileWriter fileWriter = new FileWriter(this.logFilePath, true);
      PrintWriter printWriter = new PrintWriter(new BufferedWriter(fileWriter));
      printWriter.println(message);
      printWriter.close();
    } catch (IOException ex) {
      ex.printStackTrace();
    }
  }

  /**
   * 任意の数の空行をコンソールとログファイルに出力するメソッドです。
   * 行数は引数で指定することができます。
   * @param numberOfEmptyLine 出力する空行の数
   */
  void printlnEmptyLine(int numberOfEmptyLine) {
    for (int i = 0; i < numberOfEmptyLine; i += 1) {
      this.println("");
    }
  }

  /**
   * 引数に指定された文字列をコンソールとログファイルに出力するメソッドです。
   * 出力する価の末尾に改行文字は付きません。
   * @param message 出力する文字列
   */
  void print(String message) {
    System.out.print(message);
    try {
      FileWriter fileWriter = new FileWriter(this.logFilePath, true);
      PrintWriter printWriter = new PrintWriter(new BufferedWriter(fileWriter));
      printWriter.print(message);
      printWriter.close();
    } catch (IOException ex) {
      ex.printStackTrace();
    }
  }

  /**
   * 標準入力を受け付け、入力された値をログファイルに出力するとともに呼び出し元に返すメソッドです。
   * @return 標準入力された値
   */
  String readLine() {
    Scanner scanner = new Scanner(System.in);
    String input = scanner.nextLine();
    this.printlnOnlyToLogFile(input);
    return input;
  }

  /**
   * 引数に指定された文字列をログファイルに「だけ」出力するメソッドです。
   * 標準入力処理を担当するメソッドとセットで使うことを想定しています。
   * 出力する値の末尾に改行文字が付きます。
   * @param message 出力する文字列
   */
  private void printlnOnlyToLogFile(String message) {
    try {
      FileWriter fileWriter = new FileWriter(this.logFilePath, true);
      PrintWriter printWriter = new PrintWriter(new BufferedWriter(fileWriter));
      printWriter.println(message);
      printWriter.close();
    } catch (IOException ex) {
      ex.printStackTrace();
    }
  }
}
