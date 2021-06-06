/**
 * ����񂯂�i���ۂ��j�Q�[�������s����t�@�C���ł�
 * WSH��cscript.exe�Ŏ��s���Ă�������
 * @author AGadget
 */

/**
 * �Q�[�����Ŏg�p�ł���s�����`���邽�߂̃N���X�ł�
 * @constructor
 * @param {String} name ��`����s���̖��O�ł�
 */
var GameAction = function (name) {

  /**
   * �s�����ł�
   * @type {String}
   */
  this.name = name;

  /**
   * ���I�u�W�F�N�g�Œ�`�����s���ƕR�Â���֌W���܂Ƃ߂��z��ł�
   * @type {Array}
   */
  this.relationship = [];
};

/**
 * �C���X�^���X�����ɐݒ肵���s���ƁA�ʂ̍s���Ƃ̊ԂɊ֌W��݂��郁�\�b�h�ł�
 * @param {GameAction} action �V���Ɋ֌W���\�z����s����\��GameAction�I�u�W�F�N�g�ł�
 * @param {String} effect �C���X�^���X�����Ɏw�肵���s���Ƃ̊ԂŐ����錋�ʂł�
 */
GameAction.prototype.addRelationship = function (action, effect) {
  this.relationship.push({
    name: action.name,
    effect: effect
  });
};

/**
 * �Q�[���L�����N�^�[��\���N���X�ł�
 * @constructor
 * @param {String} name �Q�[���L�����N�^�[�̖��O�ł�
 * @param {String} damageEffect �_���[�W�󂯂锻�茋�ʂ�\��������ł�
 * @param {Boolean} isPlayable �v���C�A�u���ł��邩�̃t���O�ł�
 */
var GameCharacter = function (name, damageEffect, isPlayable) {

  /**
   * �Q�[���L�����N�^�[�̖��O�ł�
   * @constant
   * @type {String}
   */
  this.NAME = name;

  /**
   * �̗͂̍ő�l�ł�
   * @constant
   * @type {Number}
   */
  this.MAX_LIFE = 5;

  /**
   * �Q�[���L�����N�^�[�̗̑͂ł�
   * �̗͍ő�l�ŃQ�[���͊J�n����܂�
   * @type {Number}
   */
  this.life = this.MAX_LIFE;

  /**
   * ���̃Q�[���L�����N�^�[���v���C�A�u���ł��邩�̃t���O�ł�
   * @constant
   * @type {Boolean}
   */
  this.IS_PLAYABLE = isPlayable;

  /**
   * �v���C���[���I�������s���ł�
   * @type {Object}
   */
  this.action;

  /**
   * �_���[�W�󂯂锻�茋�ʂł�
   * @type {String}
   */
  this.damageEffect = damageEffect;
};

/**
 * �Q�[���̑��s���\���ԓ����郁�\�b�h�ł�
 * @returns {Boolean} ���s�\�Ȃ�true��Ԃ��܂�
 */
GameCharacter.prototype.canGame = function () {
  return this.life > 0 ? true : false;
};

/**
 * �s���I�����s�����\�b�h�ł�
 * �I�������s���̓t�B�[���h�ŕێ����܂�
 * �v���C�A�u���ȃL�����N�^�[���A�����łȂ����ŏ������傫���ς��̂ŁA���ꂼ��֐��ɐ؂�o���Ă��܂�
 * @param {Output} output �������e���o�͂���̂ɕK�v�ƂȂ�Output�I�u�W�F�N�g�ł�
 * @param {GameAction} actions �Q�[���Ŏg�p����s���ɂ��Ă܂Ƃ߂�GameAction�I�u�W�F�N�g�ł�
 */
GameCharacter.prototype.choiceAction = function (output, actions) {

  /**
   * �v���C�A�u���ȃL�����N�^�[�p�̍s���I���������s���֐��ł�
   * �W�����͂��󂯕t���A���[�U�[���C�ӂ̍s����I���ł���悤�ɂ��܂�
   * �� �����͂̏ꍇ�͍ēx�v�����v�g��\�����܂�
   * �� �s���ȓ��͂̏ꍇ�́A���̎|��ʒm���������ōēx�v�����v�g��\�����܂�
   * @param {Output} output �������e���o�͂���̂ɕK�v�ƂȂ�Output�I�u�W�F�N�g�ł�
   * @param {GameAction} actions �Q�[���Ŏg�p����s���ɂ��Ă܂Ƃ߂�GameAction�I�u�W�F�N�g�ł�
   * @returns {String} �I�����ꂽ�s�����ł�
   */
  var choiceActionForPlayable = function (output, actions) {
    var prompt = '';
    for (var i = 0; i < actions.length; i += 1) {
      prompt += '[' + (i + 1) + '] ' + actions[i].name + '    ';
    }
    prompt += ': ';
    while (true) {
      var input = '';

      /* �v�����v�g��\�����������̂�WScript.Echo()�ł͂Ȃ��A���s�̔������Ȃ�Write���\�b�h���g�p���Ă��܂� */
      WScript.StdOut.Write(prompt);
      input = WScript.StdIn.ReadLine();

      /* �W�����͏����ł̓R���\�[���̕\���Ɠ����Ƀ��O�t�@�C���ւ̏������݂��ł��Ȃ��̂ŏ������݂����s���܂� */
      output.echoOnlyLogFile(prompt + input);

      /* ���͂��ꂽ�l�����������m�F���A����Ȃ���͂��ꂽ�l�ɉ������s������Ԃ��܂� */
      if (typeof actions[Number(input) - 1] !== 'undefined') {
        return actions[Number(input) - 1];
      }
      if (input.replace(' ', '') === '') {
        output.echoBlankLine(1);
      } else {
        output.echoBlankLine(1);
        output.echo('> �s���ȓ��͂ł�');
        output.echo('> �ē��͂��Ă�������');
        output.echoBlankLine(1);
      }
    }
  };

  /**
   * �v���C�A�u���łȂ��L�����N�^�[�p�̍s���I���������s���֐��ł�
   * �������g���Ė���ׂɍs����I�����܂�
   * @param {GameAction} actions �Q�[���Ŏg�p����s���ɂ��Ă܂Ƃ߂�GameAction�I�u�W�F�N�g�ł�
   * @returns {Object} �I�����ꂽ�s���ł�
   */
  var choiceActionForNonPlayable = function (actions) {
    return actions[Math.floor(Math.random() * actions.length)];
  };

  this.action = this.IS_PLAYABLE ? choiceActionForPlayable(output, actions) : choiceActionForNonPlayable(actions);
};

/**
 * �_���[�W���󂯂邩���肷�郁�\�b�h�ł�
 * �_���[�W���󂯂�ꍇ�̗͑͂����炵�܂�
 * @param {Output} output �������e���o�͂���̂ɕK�v�ƂȂ�Output�I�u�W�F�N�g�ł�
 * @param {String} opponentAction �ΐ푊��̍s���ł�
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
    throw '[Error] �_���[�W���菈���ŃG���[���������܂���\n' +
      '        �L�����N�^�[�̑I�������s�����s���ł��i' + this.action.name + ',' + opponentAction + '�j';
  } catch (error) {
    output.echo(error);
    WScript.Quit();
  }
};

/**
 * �R���\�[���E���O�t�@�C���֏������e���o�͂���Ƃ��̏��X�̏����������󂯂�N���X�ł�
 * �����Ƃ��āA���炩�̒l���o�͂���Ƃ��͓��N���X�𗘗p���Ă�������
 * @constructor
 */
var Output = function () {

  /**
   * ���O�t�@�C���̃t���p�X��ێ�����t�B�[���h�ł�
   * ���O�t�@�C�����͓��t�@�C�����s������yymmddhhmmss�`���ɂ����������g�ݍ��݂܂�
   * �� 2020�N1��23��4��56��00�b�Ȃ�ulog_200123045600.txt�v�ƂȂ�܂�
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
 * �����Ɏw�肳�ꂽ�l���R���\�[���E���O�t�@�C���ɏo�͂��郁�\�b�h�ł�
 * �� �o�͎��͍Ō�ɉ��s������܂��̂Œ��ӂ��Ă�������
 * ���O�t�@�C�������݂��Ă���Ȃ�ǋL�����A���݂��Ă��Ȃ��Ȃ�V�K�쐬���������ŏ������݂��s���܂�
 * �t�@�C���̕����R�[�h��Shift JIS�ł�
 * @param {String} message �o�͂���l�ł��iString�^�ɕϊ��ł���l�Ȃ牽�ł��\�\���l��z��ł�OK�ł��j
 */
Output.prototype.echo = function (message) {
  WScript.Echo(message);
  var fileSystemObject = WScript.CreateObject('Scripting.FileSystemObject');
  var logFile = fileSystemObject.OpenTextFile(this.LOG_FILE_PASS, 8, true);
  logFile.WriteLine(message);
  logFile.Close();
};

/**
 * �����Ɏw�肳�ꂽ�l�����O�t�@�C���Ɂu�����v�o�͂��郁�\�b�h�ł�
 * �� �o�͎��͍Ō�ɉ��s������܂��̂Œ��ӂ��Ă�������
 * �W�����͏����Ȃǂł̓��O�t�@�C���ւ̏������݂������K�v�ɂȂ�܂��̂œ����\�b�h�𗘗p���܂�
 * @param {String} message �o�͂���l�ł��iString�^�ɕϊ��ł���l�Ȃ牽�ł��\�\���l��z��ł�OK�ł��j
 */
Output.prototype.echoOnlyLogFile = function (message) {
  var fileSystemObject = WScript.CreateObject('Scripting.FileSystemObject');
  var logFile = fileSystemObject.OpenTextFile(this.LOG_FILE_PASS, 8, true);
  logFile.WriteLine(message);
  logFile.Close();
};

/**
 * �C�ӂ̐��̋�s��\�����郁�\�b�h�ł�
 * ���v���O�����ł͏������e��ǂ݂₷�����邽�ߗv���v���ŋ�s��}�����Ă��܂�
 * �� ���I�u�W�F�N�g�̏o�͗p���\�b�h�ɋ󕶎���n�����Ƃł������ł��܂����p�r���قȂ�̂ŕʃ��\�b�h�ɐ؂�o���܂���
 *     �� �󕶎����o�͂���̂��ړI�ł͂Ȃ��A��s��}�����ď������e��ǂ݂₷������̂��ړI�ł��邽�߂ł�
 *     �� �܂��A�������̂͏o�͗p���\�b�h���J��Ԃ��Ăяo���Ă����ł����ǂˁc�c
 * @param {Number} numberOfEmptyLine �\�������s�̍s���ł�
 */
Output.prototype.echoBlankLine = function (numberOfEmptyLine) {
  for (var i = 0; i < numberOfEmptyLine; i += 1) {
    this.echo('');
  }
};

/**
 * ���݂̃^�[������\�����b�Z�[�W��\������֐��ł�
 * @param {Output} output �o�͏�����S������Output�I�u�W�F�N�g�ł�
 * @param {Number} turnCount ���݂̃^�[�����ł�
 * @returns {String} �^�[������m�点�镶����ł�
 */
var echoTurnCountMessage = function (output, turnCount) {
  output.echo('�y��' + turnCount + '�^�[���z');
};

/**
 * �Q�[���L�����N�^�[�̃X�e�[�^�X��\�����b�Z�[�W��\������֐��ł�
 * �Q�[���L�����N�^�[�̖��O�Ƒ̗͂��L�ڂ����������Ԃ��܂�
 * �� ���O�͑ΐ푊��̖��O�Ɖ����𑵂��܂��i���͔��p�󔒂Ŗ��߂܂��j
 * �� �̗͂͋L�����g���đ̗̓Q�[�W���ۂ��\�����܂�
 * @param {Output} output �o�͏�����S������Output�I�u�W�F�N�g�ł�
 * @param {String} name �ΏۂƂȂ�Q�[���L�����N�^�[�̖��O�ł�
 * @param {String} opponentName �ΐ푊��̃Q�[���L�����N�^�[�̖��O�ł�
 * @param {Number} life �ΏۂƂȂ�Q�[���L�����N�^�[�̗̑͂ł�
 * @param {Number} maxLife �ΏۂƂȂ�Q�[���L�����N�^�[�̍ő�̗͂ł�
 * @returns {String} �X�e�[�^�X��\�����b�Z�[�W�ł�
 */
var echoStatusMessage = function (output, name, opponentName, life, maxLife) {

  /**
   * ���O�̒�����Ԃ��֐��ł�
   * ���p��1�A�S�p��2�Ōv�Z���A���̍��v�l��Ԃ��܂�
   * encodeURI()�ł͔��p�󔒂́u%20�v�Ƃ����l�ɂȂ�̂ŏ������򏈗��Ŕ�����|���Ă��܂�
   * @param {String} name �v�Z�ΏۂƂȂ閼�O�ł�
   * @return {Number} ���O�̒����ł�
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

  /* ���b�Z�[�W�̖��O�������쐬���܂� */
  var messagePartOfName = name;
  var nameLength = countNameLength(name);
  var opponentNameLength = countNameLength(opponentName);
  if (nameLength < opponentNameLength) {
    for (var i = 0; i < opponentNameLength - nameLength; i += 1) {
      messagePartOfName += ' ';
    }
  }

  /* ���b�Z�[�W�̗͕̑������쐬���܂� */
  var messagePartOfLife = '';
  for (var i = 0; i < life; i += 1) {
    messagePartOfLife += '��';
  }
  for (var i = 0; i < maxLife - life; i += 1) {
    messagePartOfLife += '��';
  }

  /* ���b�Z�[�W���\������e���������̂����ĕ\�����܂� */
  output.echo(messagePartOfName + ': ' + messagePartOfLife);
};

/**
 * �L�����N�^�[���I�������s���ƁA���̌��ʂ�\�����b�Z�[�W��\������֐��ł�
 * @param {Output} output �o�͏�����S������Output�I�u�W�F�N�g�ł�
 * @param {GameCharacter} character1 �L�����N�^�[1�ł�
 * @param {GameCharacter} character2 �L�����N�^�[2�ł�
 */
var echoActionResult = function (output, character1, character2) {

  /**
   * ���b�Z�[�W���쐬���ĕԂ��֐��ł�
   * @param {Output} output �o�͏�����S������Output�I�u�W�F�N�g�ł�
   * @param {GameCharacter} myself ���b�Z�[�W�쐬�̑ΏۂƂȂ�L�����N�^�[�ł�
   * @param {String} opponentAction �ΐ푊��̑I�������s���ł�
   */
  var createMessage = function (output, myself, opponentAction) {
    var message = myself.action.name;
    try {
      for (var i = 0; i < myself.action.relationship.length; i += 1) {
        if (myself.action.relationship[i].name === opponentAction) {
          return message += '�i' + myself.action.relationship[i].effect + '�j';
        }
      }
      throw '[Error] �s�����ʏo�͏����ŃG���[���������܂���\n' +
        '        �L�����N�^�[�̑I�������s�����s���ł��i' + myself.action.name + ',' + opponentAction + '�j';
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
 * ���҂̔�����s���A���茋�ʂ�\������֐��ł�
 * @param {Output} output �o�͏�����S������Output�I�u�W�F�N�g�ł�
 * @param {GameCharacter} character1 �L�����N�^�[1�ł�
 * @param {GameCharacter} character2 �L�����N�^�[2�ł�
 */
var echoWinner = function (output, character1, character2) {
  try {
    if (character1.canGame()) {
      if (character2.canGame()) {
        throw '[Error] ���Ҕ��菈���ŃG���[���������܂���\n' +
          '    �������t���܂���i' + (character1.canGame() ? '����' : '����') + ',' + (character2.canGame() ? '����' : '����') + '�j';
      } else {
        output.echo('> ' + character1.NAME + '�̏����ł�')
      }
    } else {
      if (character2.canGame()) {
        output.echo('> ' + character2.NAME + '�̏����ł�')
      } else {
        throw '[Error] ���Ҕ��菈���ŃG���[���������܂���\n' +
          '    ���ҕs�݂ł��i' + (character1.canGame() ? '����' : '����') + ',' + (character2.canGame() ? '����' : '����') + '�j';
      }
    }
  } catch (error) {
    output.echo(error);
    WScript.Quit();
  }
};

/**
 * �ꎞ��~����֐��ł�
 */
var pause = function () {
  WScript.StdOut.Write('Enter�L�[�������Ă������� . . . ');
  WScript.StdIn.ReadLine();
};

/* ���v���O�����ɂ������v�ȕϐ������������܂� */
var effect = {
  draw: '������',
  lose: '����',
  win: '����'
};
var actionRock = new GameAction('�O�[');
var actionScissors = new GameAction('�`���L');
var actionPaper = new GameAction('�p�[');
actionRock.addRelationship(actionRock, effect.draw);
actionRock.addRelationship(actionScissors, effect.win);
actionRock.addRelationship(actionPaper, effect.lose);
actionScissors.addRelationship(actionRock, effect.lose);
actionScissors.addRelationship(actionScissors, effect.draw);
actionScissors.addRelationship(actionPaper, effect.win);
actionPaper.addRelationship(actionRock, effect.win);
actionPaper.addRelationship(actionScissors, effect.lose);
actionPaper.addRelationship(actionPaper, effect.draw);
var actions = [actionRock, actionScissors, actionPaper]; // �s���͔z��ł܂Ƃ߂ĊǗ����邱�ƂŎ��񂵂₷�����܂�
var player = new GameCharacter('Qii���Y', effect.lose, true);
var enemy = new GameCharacter('COM', effect.lose, false);
var turnCount = 0;
var output = new Output();

/* �Q�[���̑��s���\�ł���Ԃ̓^�[���������J��Ԃ��܂� */
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

/* �Q�[���̑��s���\�łȂ��Ȃ����\�\�������t�����̂ŁA���������̔�����s���܂� */
echoStatusMessage(output, player.NAME, enemy.NAME, player.life, player.MAX_LIFE);
echoStatusMessage(output, enemy.NAME, player.NAME, enemy.life, enemy.MAX_LIFE);
output.echoBlankLine(1);
echoWinner(output, player, enemy);
output.echoBlankLine(1);
pause();