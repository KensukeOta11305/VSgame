import Data.Time.Format
import Data.Time.LocalTime
import System.IO

{-
    じゃんけん（っぽい）ゲームを遊ぶことができるプログラムです
    main関数では主要な変数の束縛だけ行い、処理のほとんどは別関数に任せています
    → 当プログラムの主要な処理はターン処理（繰り返し処理）であるため、再帰しやすいよう別関数に処理をまとめています
-}
main :: IO()
main = do
    let maxLife = 5
    let player = (maxLife, "Qii太郎")
    let com = (maxLife, "COM")
    let turnCount = 1
    logFileName <- generateLogFileName
    judgeGameState maxLife player com turnCount logFileName

{-
    ログファイル名を作成して返すアクションを返します
-}
generateLogFileName :: IO [Char]
generateLogFileName = do
    yymmddhhmmss <- formatTime defaultTimeLocale "%y%m%d%H%M%S" <$> getZonedTime
    return ("log_" ++ yymmddhhmmss ++ ".txt")

{-
    ゲームの状況を確認し、状況に応じた処理に分岐させます
    具体的にはゲームキャラクター双方がゲーム続行可能であるかを確認して、ターン処理を継続するか、決着させるかを判断します
-}
judgeGameState :: Int -> (Int, String) -> (Int, String) -> Int -> String -> IO()
judgeGameState maxLife (playerLife, playerName) (comLife, comName) turnCount logFileName
    | canGame playerLife && not (canGame comLife) = putStr "プレイヤーの勝利\n"
    | not (canGame playerLife) && canGame comLife = putStr "COMの勝利\n"
    | canGame playerLife && canGame comLife = do
        putTurnCountMessage logFileName turnCount
        putGameCharacterStatusMessage logFileName playerName playerLife maxLife
        putGameCharacterStatusMessage logFileName comName comLife maxLife
        putEmptyLine logFileName 1
        let actionList = ("グー", "チョキ", "パー") -- 行動名は自由ですが、グー・チョキ・パーの順に格納してください
        playerAction <- choiceAction logFileName actionList True
        comAction <- choiceAction logFileName actionList False
        putEmptyLine logFileName 1
        putChoicedActions playerAction comAction logFileName
        let playerDamage = calculationDamage actionList playerAction comAction
        let comDamage = calculationDamage actionList comAction playerAction
        putEmptyLine logFileName 5
        judgeGameState maxLife ((playerLife + playerDamage), playerName) ((comLife + comDamage), comName) (turnCount + 1) logFileName

{-
    引数に指定された体力値でゲームの続行が可能か返答します
    続行可能ならTrueを返します
-}
canGame :: Int -> Bool
canGame life = if life > 0
    then True
    else False

{-
    現在のターン数を表すメッセージを作成して、コンソールとログファイルに出力します
-}
putTurnCountMessage :: String -> Int -> IO ()
putTurnCountMessage logFileName turnCount = do
    let message = "【第" ++ show(turnCount) ++ "ターン】\n"
    putStr message
    appendFile logFileName message

{-
    ゲームキャラクターのステータスを表すメッセージを作成して、コンソールとログファイルに出力します
-}
putGameCharacterStatusMessage :: String -> String -> Int -> Int -> IO()
putGameCharacterStatusMessage logFileName gameCharacterName gameCharacterLife maxLife = do
    let message = gameCharacterName ++ ": " ++ show(gameCharacterLife) ++ "/" ++ show(maxLife) ++ "\n"
    putStr message
    appendFile logFileName message

{-
    任意の数の空行をコンソールとログファイルに出力します
    空行の数は引数で制御します
-}
putEmptyLine :: String -> Int -> IO()
putEmptyLine logFileName numberOfEmptyLine
    | numberOfEmptyLine == 1 = do
        let message = "\n"
        putStr message
        appendFile logFileName message
    | numberOfEmptyLine > 1 = do
        let message = "\n"
        putStr message
        appendFile logFileName message
        putEmptyLine logFileName (numberOfEmptyLine - 1)

{-
    行動選択処理です
    → 選択した行動は文字列にして呼び出し元に返します
    第3引数に指定された真偽値でプレイヤー用処理・COM用処理を切り替えます
-}
choiceAction :: String -> (String, String, String) -> Bool -> IO String
choiceAction logFileName (rock, scissors, paper) isPlayable = if isPlayable
    then do
        let prompt = "[1] " ++ rock ++ "    [2] " ++ scissors ++ "    [3] " ++ paper ++ "    : "
        putStr prompt
        appendFile logFileName prompt
        hFlush stdout
        input <- getLine
        appendFile logFileName input
        case input of
            "1" -> return rock
            "2" -> return scissors
            "3" -> return paper
            input -> do
                putEmptyLine logFileName 1
                let message = "> 再入力してください\n"
                putStr message
                appendFile logFileName message
                putEmptyLine logFileName 1
                choiceAction logFileName (rock, scissors, paper) True
    else do
        random <- getRandomInt 1 3
        case random of
            1 -> return rock
            2 -> return scissors
            3 -> return paper

{-
    自作の乱数発生器です
    引数で指定した範囲内にある数値を無作為に返すアクションを返します
-}
getRandomInt :: Int -> Int -> IO Int
getRandomInt min max = do
    seed <- formatTime defaultTimeLocale "%Q" <$> getZonedTime
    return ((mod (read (tail(seed)) :: Int) (max - min + 1)) + min)

{-
    双方のゲームキャラクターが選択した行動を表すメッセージを作成して、コンソールとログファイルに出力します
-}
putChoicedActions :: String -> String -> String -> IO()
putChoicedActions playerAction comAction logFileName = do
    let message = "> " ++ playerAction ++ " vs " ++ comAction ++ "\n"
    putStr message
    appendFile logFileName message

{-
    ダメージ処理です
    自身と相手――双方が選択した行動の組み合わせからダメージ量を計算します
-}
calculationDamage :: (String, String, String) -> String -> String -> Int
calculationDamage (rock, scissors, paper) action opponentAction
    | action == rock && opponentAction == paper = -1
    | action == scissors && opponentAction == rock = -1
    | action == paper && opponentAction == scissors = -1
    | otherwise = 0
