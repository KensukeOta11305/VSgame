# じゃんけんゲーム

色々なリポジトリでは、さまざまなプログラミング言語で作成した「じゃんけんゲーム」のソースコードを置いています。

## 「じゃんけんゲーム」とは

「じゃんけんゲーム」はコンソール上で動作するCUIゲームです。

基本的なルールは既存のじゃんけんそのものです。じゃんけんで勝つごとに1点取得し、対戦相手よりも先に5点先取することで勝者となります。

対戦内容はログファイルに書き出します。

## 取り組みの趣旨

当取り組みは、さまざまなプログラミング言語に触れてみることで知見を広げることを目的に始めました。

プログラムを組むときは、使用するプログラミング言語の背景にある開発思想や各プログラミング言語界隈の文化に従うようにしています。具体的には、識別子の命名傾向、例外処理の組み方、処理を関数やクラスやモジュールやパッケージやファイルにどのように切り出すか、その他当該プログラミング言語らしい書き方などを意識して書くようにしています。

## 各プログラミング言語の所感

以下、使ってみたプログラミング言語の所感を簡単にまとめています。

### Command Prompt

Command PromptはWindows系OSに標準搭載されているシェル「cmd.exe」の名前であり、同シェルで利用できるプログラミング言語の名前でもあります。

当言語独自の機能や仕様などが多く、思わぬところで躓くことがしばしばあります。また、構文エラー時に、どこが、どのように間違っているかを知らせる機能がかなり弱いため、不具合の修正にかなり手間取ります。総合的には、とても書きづらい言語と言わざるをえません。

### Fortran

Fortranは世界初の高級言語です。開発されてから今日に至るまでにいくつものバージョンが作られてきましたが、当じゃんけんゲームはFortran 2018に準拠しています。

60年以上前に開発された言語ということもあって、どんな書き心地なのかとドキドキしていたのですが意外と普通でした。もちろん、個性的な仕様や記述は多いのですが十分理解できる範疇でした。ただ、やはり作られた時期が時期だけあってか書きやすいとは言いがたい文法でした。

### JScript

JScriptはECMAScript3をMicrosoftが拡張したJavaScriptの方言です。

基本的にはJavaScriptそのままなのですが、ES6以降の快適な環境に慣れているとES3時代の仕様に戸惑うことになるでしょう。

### VBScript

VBScriptは（おそらく）VB4.0をベースに、いくつかの機能を省略したVB系のプログラミング言語です。

あまり良い言語設計とは言いがたいVBを、さらに簡略したということもあって評価の難しい言語になっています。Windows 10では標準でVB.NETを使った開発が行えますので、わざわざ当言語を選ぶ意味は薄いでしょう。
