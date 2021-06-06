/**
 * じゃんけん（っぽい）ゲームを実行するファイルです
 * WSHのcscript.exeで実行してください
 * @author AGadget
 */

/**
 * ゲーム中で使用できる行動を定義するためのクラスです
 * @constructor
 * @param {String} name 定義する行動の名前です
 */
var GameAction = function (name) {

  /**
   * 行動名です
   * @type {String}
   */
  this.name = name;

  /**
   * 当オブジェクトで定義した行動と紐づける関係をまとめた配列です
   * @type {Array}
   */
  this.relationship = [];
};

/**
 * インスタンス化時に設定した行動と、別の行動との間に関係を設けるメソッドです
 * @param {GameAction} action 新たに関係を構築する行動を表すGameActionオブジェクトです
 * @param {String} effect インスタンス化時に指定した行動との間で生ずる結果です
 */
GameAction.prototype.addRelationship = function (action, effect) {
  this.relationship.push({
    name: action.name,
    effect: effect
  });
};

/**
 * ゲームキャラクターを表すクラスです
 * @constructor
 * @param {String} name ゲームキャラクターの名前です
 * @param {String} damageEffect ダメージ受ける判定結果を表す文字列です
 * @param {Boolean} isPlayable プレイアブルであるかのフラグです
 */
var GameCharacter = function (name, damageEffect, isPlayable) {

  /**
   * ゲームキャラクターの名前です
   * @constant
   * @type {String}
   */
  this.NAME = name;

  /**
   * 体力の最大値です
   * @constant
   * @type {Number}
   */
  this.MAX_LIFE = 5;

  /**
   * ゲームキャラクターの体力です
   * 体力最大値でゲームは開始されます
   * @type {Number}
   */
  this.life = this.MAX_LIFE;

  /**
   * このゲームキャラクターがプレイアブルであるかのフラグです
   * @constant
   * @type {Boolean}
   */
  this.IS_PLAYABLE = isPlayable;

  /**
   * プレイヤーが選択した行動です
   * @type {Object}
   */
  this.action;

  /**
   * ダメージ受ける判定結果です
   * @type {String}
   */
  this.damageEffect = damageEffect;
};

/**
 * ゲームの続行が可能か返答するメソッドです
 * @returns {Boolean} 続行可能ならtrueを返します
 */
GameCharacter.prototype.canGame = function () {
  return this.life > 0 ? true : false;
};

/**
 * 行動選択を行うメソッドです
 * 選択した行動はフィールドで保持します
 * プレイアブルなキャラクターか、そうでないかで処理が大きく変わるので、それぞれ関数に切り出しています
 * @param {Output} output 処理内容を出力するのに必要となるOutputオブジェクトです
 * @param {GameAction} actions ゲームで使用する行動についてまとめたGameActionオブジェクトです
 */
GameCharacter.prototype.choiceAction = function (output, actions) {

  /**
   * プレイアブルなキャラクター用の行動選択処理を行う関数です
   * 標準入力を受け付け、ユーザーが任意の行動を選択できるようにします
   * → 未入力の場合は再度プロンプトを表示します
   * → 不正な入力の場合は、その旨を通知したうえで再度プロンプトを表示します
   * @param {Output} output 処理内容を出力するのに必要となるOutputオブジェクトです
   * @param {GameAction} actions ゲームで使用する行動についてまとめたGameActionオブジェクトです
   * @returns {String} 選択された行動名です
   */
  var choiceActionForPlayable = function (output, actions) {
    var prompt = '';
    for (var i = 0; i < actions.length; i += 1) {
      prompt += '[' + (i + 1) + '] ' + actions[i].name + '    ';
    }
    prompt += ': ';
    while (true) {
      var input = '';

      /* プロンプトを表示させたいのでWScript.Echo()ではなく、改行の発生しないWriteメソッドを使用しています */
      WScript.StdOut.Write(prompt);
      input = WScript.StdIn.ReadLine();

      /* 標準入力処理ではコンソールの表示と同時にログファイルへの書き込みができないので書き込みだけ行います */
      output.echoOnlyLogFile(prompt + input);

      /* 入力された値が正しいか確認し、正常なら入力された値に応じた行動名を返します */
      if (typeof actions[Number(input) - 1] !== 'undefined') {
        return actions[Number(input) - 1];
      }
      if (input.replace(' ', '') === '') {
        output.echoBlankLine(1);
      } else {
        output.echoBlankLine(1);
        output.echo('> 不正な入力です');
        output.echo('> 再入力してください');
        output.echoBlankLine(1);
      }
    }
  };

  /**
   * プレイアブルでないキャラクター用の行動選択処理を行う関数です
   * 乱数を使って無作為に行動を選択します
   * @param {GameAction} actions ゲームで使用する行動についてまとめたGameActionオブジェクトです
   * @returns {Object} 選択された行動です
   */
  var choiceActionForNonPlayable = function (actions) {
    return actions[Math.floor(Math.random() * actions.length)];
  };

  this.action = this.IS_PLAYABLE ? choiceActionForPlayable(output, actions) : choiceActionForNonPlayable(actions);
};

/**
 * ダメージを受けるか判定するメソッドです
 * ダメージを受ける場合は体力を減らします
 * @param {Output} output 処理内容を出力するのに必要となるOutputオブジェクトです
 * @param {String} opponentAction 対戦相手の行動です
 */
GameCharacter.prototype.damageProcess = function (output, opponentAction) {
  try {
    for (var i = 0; i < this.action.relationship.length; i += 1) {
      if (this.action.relationship[i].name === opponentAction) {
        if (this.action.relationship[i].effect === this.damageEffect) {
          this.life -= 1;
          return;
        }
        return;
      }
    }
    throw '[Error] ダメージ判定処理でエラーが発生しました\n' +
      '        キャラクターの選択した行動が不正です（' + this.action.name + ',' + opponentAction + '）';
  } catch (error) {
    output.echo(error);
    WScript.Quit();
  }
};

/**
 * コンソール・ログファイルへ処理内容を出力するときの諸々の処理を引き受けるクラスです
 * 原則として、何らかの値を出力するときは当クラスを利用してください
 * @constructor
 */
var Output = function () {

  /**
   * ログファイルのフルパスを保持するフィールドです
   * ログファイル名は当ファイル実行日時をyymmddhhmmss形式にした文字列を組み込みます
   * → 2020年1月23日4時56分00秒なら「log_200123045600.txt」となります
   * @constant
   * @type {String}
   */
  this.LOG_FILE_PASS = (function () {
    var date = new Date();
    var logFileNameComponents = [date.getFullYear(), date.getMonth() + 1, date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds()];
    var yymmddhhmmss = '';
    for (var i = 0; i < logFileNameComponents.length; i += 1) {
      yymmddhhmmss += ('0' + String(logFileNameComponents[i])).slice(-2);
    }
    var fileSystemObject = WScript.CreateObject('Scripting.FileSystemObject');
    return fileSystemObject.GetParentFolderName(WScript.ScriptFullName) + '\\log_' + yymmddhhmmss + '.txt';
  })();
};

/**
 * 引数に指定された値をコンソール・ログファイルに出力するメソッドです
 * → 出力時は最後に改行が入りますので注意してください
 * ログファイルが存在しているなら追記だけ、存在していないなら新規作成したうえで書き込みを行います
 * ファイルの文字コードはShift JISです
 * @param {String} message 出力する値です（String型に変換できる値なら何でも――数値や配列でもOKです）
 */
Output.prototype.echo = function (message) {
  WScript.Echo(message);
  var fileSystemObject = WScript.CreateObject('Scripting.FileSystemObject');
  var logFile = fileSystemObject.OpenTextFile(this.LOG_FILE_PASS, 8, true);
  logFile.WriteLine(message);
  logFile.Close();
};

/**
 * 引数に指定された値をログファイルに「だけ」出力するメソッドです
 * → 出力時は最後に改行が入りますので注意してください
 * 標準入力処理などではログファイルへの書き込みだけが必要になりますので当メソッドを利用します
 * @param {String} message 出力する値です（String型に変換できる値なら何でも――数値や配列でもOKです）
 */
Output.prototype.echoOnlyLogFile = function (message) {
  var fileSystemObject = WScript.CreateObject('Scripting.FileSystemObject');
  var logFile = fileSystemObject.OpenTextFile(this.LOG_FILE_PASS, 8, true);
  logFile.WriteLine(message);
  logFile.Close();
};

/**
 * 任意の数の空行を表示するメソッドです
 * 当プログラムでは処理内容を読みやすくするため要所要所で空行を挿入しています
 * → 同オブジェクトの出力用メソッドに空文字を渡すことでも実現できますが用途が異なるので別メソッドに切り出しました
 *     → 空文字を出力するのが目的ではなく、空行を挿入して処理内容を読みやすくするのが目的であるためです
 *     → まぁ、処理自体は出力用メソッドを繰り返し呼び出しているんですけどね……
 * @param {Number} numberOfEmptyLine 表示する空行の行数です
 */
Output.prototype.echoBlankLine = function (numberOfEmptyLine) {
  for (var i = 0; i < numberOfEmptyLine; i += 1) {
    this.echo('');
  }
};

/**
 * 現在のターン数を表すメッセージを表示する関数です
 * @param {Output} output 出力処理を担当するOutputオブジェクトです
 * @param {Number} turnCount 現在のターン数です
 * @returns {String} ターン数を知らせる文字列です
 */
var echoTurnCountMessage = function (output, turnCount) {
  output.echo('【第' + turnCount + 'ターン】');
};

/**
 * ゲームキャラクターのステータスを表すメッセージを表示する関数です
 * ゲームキャラクターの名前と体力を記載した文字列を返します
 * → 名前は対戦相手の名前と横幅を揃えます（差は半角空白で埋めます）
 * → 体力は記号を使って体力ゲージっぽく表現します
 * @param {Output} output 出力処理を担当するOutputオブジェクトです
 * @param {String} name 対象となるゲームキャラクターの名前です
 * @param {String} opponentName 対戦相手のゲームキャラクターの名前です
 * @param {Number} life 対象となるゲームキャラクターの体力です
 * @param {Number} maxLife 対象となるゲームキャラクターの最大体力です
 * @returns {String} ステータスを表すメッセージです
 */
var echoStatusMessage = function (output, name, opponentName, life, maxLife) {

  /**
   * 名前の長さを返す関数です
   * 半角は1、全角は2で計算し、その合計値を返します
   * encodeURI()では半角空白は「%20」という値になるので条件分岐処理で判定を掛けています
   * @param {String} name 計算対象となる名前です
   * @return {Number} 名前の長さです
   */
  var countNameLength = function (name) {
    var nameLength = 0;
    for (var i = 0; i < name.length; i += 1) {
      if (encodeURI(name.charAt(i)).length === 1) {
        nameLength += 1;
      } else {
        nameLength += encodeURI(name.charAt(i)) === '%20' ? 1 : 2;
      }
    }
    return nameLength;
  };

  /* メッセージの名前部分を作成します */
  var messagePartOfName = name;
  var nameLength = countNameLength(name);
  var opponentNameLength = countNameLength(opponentName);
  if (nameLength < opponentNameLength) {
    for (var i = 0; i < opponentNameLength - nameLength; i += 1) {
      messagePartOfName += ' ';
    }
  }

  /* メッセージの体力部分を作成します */
  var messagePartOfLife = '';
  for (var i = 0; i < life; i += 1) {
    messagePartOfLife += '■';
  }
  for (var i = 0; i < maxLife - life; i += 1) {
    messagePartOfLife += '□';
  }

  /* メッセージを構成する各部分を合体させて表示します */
  output.echo(messagePartOfName + ': ' + messagePartOfLife);
};

/**
 * キャラクターが選択した行動と、その結果を表すメッセージを表示する関数です
 * @param {Output} output 出力処理を担当するOutputオブジェクトです
 * @param {GameCharacter} character1 キャラクター1です
 * @param {GameCharacter} character2 キャラクター2です
 */
var echoActionResult = function (output, character1, character2) {

  /**
   * メッセージを作成して返す関数です
   * @param {Output} output 出力処理を担当するOutputオブジェクトです
   * @param {GameCharacter} myself メッセージ作成の対象となるキャラクターです
   * @param {String} opponentAction 対戦相手の選択した行動です
   */
  var createMessage = function (output, myself, opponentAction) {
    var message = myself.action.name;
    try {
      for (var i = 0; i < myself.action.relationship.length; i += 1) {
        if (myself.action.relationship[i].name === opponentAction) {
          return message += '（' + myself.action.relationship[i].effect + '）';
        }
      }
      throw '[Error] 行動結果出力処理でエラーが発生しました\n' +
        '        キャラクターの選択した行動が不正です（' + myself.action.name + ',' + opponentAction + '）';
    } catch (error) {
      output.echo(error);
      WScript.Quit();
    }
  };

  var messageOfCharacter1 = createMessage(output, character1, character2.action.name);
  var messageOfCharacter2 = createMessage(output, character2, character1.action.name);
  output.echo('> ' + messageOfCharacter1 + ' vs ' + messageOfCharacter2);
};

/**
 * 勝者の判定を行い、判定結果を表示する関数です
 * @param {Output} output 出力処理を担当するOutputオブジェクトです
 * @param {GameCharacter} character1 キャラクター1です
 * @param {GameCharacter} character2 キャラクター2です
 */
var echoWinner = function (output, character1, character2) {
  try {
    if (character1.canGame()) {
      if (character2.canGame()) {
        throw '[Error] 勝者判定処理でエラーが発生しました\n' +
          '    決着が付きません（' + (character1.canGame() ? '勝ち' : '負け') + ',' + (character2.canGame() ? '勝ち' : '負け') + '）';
      } else {
        output.echo('> ' + character1.NAME + 'の勝ちです')
      }
    } else {
      if (character2.canGame()) {
        output.echo('> ' + character2.NAME + 'の勝ちです')
      } else {
        throw '[Error] 勝者判定処理でエラーが発生しました\n' +
          '    勝者不在です（' + (character1.canGame() ? '勝ち' : '負け') + ',' + (character2.canGame() ? '勝ち' : '負け') + '）';
      }
    }
  } catch (error) {
    output.echo(error);
    WScript.Quit();
  }
};

/**
 * 一時停止する関数です
 */
var pause = function () {
  WScript.StdOut.Write('Enterキーを押してください . . . ');
  WScript.StdIn.ReadLine();
};

/* 当プログラムにおける主要な変数を初期化します */
var effect = {
  draw: 'あいこ',
  lose: '負け',
  win: '勝ち'
};
var actionRock = new GameAction('グー');
var actionScissors = new GameAction('チョキ');
var actionPaper = new GameAction('パー');
actionRock.addRelationship(actionRock, effect.draw);
actionRock.addRelationship(actionScissors, effect.win);
actionRock.addRelationship(actionPaper, effect.lose);
actionScissors.addRelationship(actionRock, effect.lose);
actionScissors.addRelationship(actionScissors, effect.draw);
actionScissors.addRelationship(actionPaper, effect.win);
actionPaper.addRelationship(actionRock, effect.win);
actionPaper.addRelationship(actionScissors, effect.lose);
actionPaper.addRelationship(actionPaper, effect.draw);
var actions = [actionRock, actionScissors, actionPaper]; // 行動は配列でまとめて管理することで取り回しやすくします
var player = new GameCharacter('Qii太郎', effect.lose, true);
var enemy = new GameCharacter('COM', effect.lose, false);
var turnCount = 0;
var output = new Output();

/* ゲームの続行が可能である間はターン処理を繰り返します */
while (player.canGame() && enemy.canGame()) {
  echoTurnCountMessage(output, turnCount += 1);
  echoStatusMessage(output, player.NAME, enemy.NAME, player.life, player.MAX_LIFE);
  echoStatusMessage(output, enemy.NAME, player.NAME, enemy.life, enemy.MAX_LIFE);
  output.echoBlankLine(1);
  player.choiceAction(output, actions);
  enemy.choiceAction(output, actions);
  output.echoBlankLine(1);
  player.damageProcess(output, enemy.action.name);
  enemy.damageProcess(output, player.action.name);
  echoActionResult(output, player, enemy);
  output.echoBlankLine(5);
}

/* ゲームの続行が可能でなくなった――決着が付いたので、勝ち負けの判定を行います */
echoStatusMessage(output, player.NAME, enemy.NAME, player.life, player.MAX_LIFE);
echoStatusMessage(output, enemy.NAME, player.NAME, enemy.life, enemy.MAX_LIFE);
output.echoBlankLine(1);
echoWinner(output, player, enemy);
output.echoBlankLine(1);
pause();