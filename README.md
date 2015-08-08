# OpenDolphin Docker

このリポジトリで作成したイメージは Docker Hub に公開しています。下記手順でインストールと起動を行うことができます。

### サーバーとなるマシンに docker をインストール
* CentOS7/Ubntuの場合　yum install 等のパッケージコマンドが利用できます。
* Windows/Macの場合　Boot2Docker を使用します。（インストールパーッケージがあります。）

### データベースの Postgres をインストール
docker run --name dolphin-db -d dolphindev/postgres

### アプリケーションサーバーの WildFly をインストール
docker run --name dolphin-server --link dolphin-db:ds -p 8080:8080 -d dolphindev/wildfly

コマンドは１行です。正確に入力してください（コピーペーストが確実です）。
最初のインストールと起動には少し時間がかかります。
上記コマンドが成功するとサーバーがバックグランドで動いています。

### サーバーのIPアドレスを調査
* クライアントと接続するため、サーバのIPアドレスを調べます。
* Linuxの場合　　インストールしたマシンのIPアドレス
* Windows/Macの場合  boot2docker ip コマンドが返す値
  （左のコマンドを今実行しているターミナルに打ち込みます。一般に 192.168.5９.xxxになります。）
* 以下、サーバーのIPアドレスを HOST_IP とし次の節で使用します。

********************

### クライアントから接続
* クライアントマシン(Windows/Mac)に最新の Java8 実行環境をインストールしてください。
* [ここから](http://www.digital-globe.co.jp/openDolphin/sys-guide/26/client/OpenDolphin.zip) クライアントプログラムをダウンロードします。
* クライアントプログラムは ZIP 形式になっています。下記 Tips を参照し、OpenDolphinを起動してください。
* ログイン画面が現れたら設定ボタンを押してください。
* 接続設定に下記の値を入力します。
  - 医療機関ID　　1.3.6.1.4.1.9414.70.1
  - ユーザーID　　admin
  - ベースURI　　 http&#58;//HOST_IP:8080（サーバーのIPアドレス:8080）
* 設定を保存するとログイン画面に戻ります。
* パスワードに admin を入力し、ログインボタンを押します。

### Tips 解凍とクライアント起動
* Windows
  - ダウンロードしたファイルを右クリック、メニューの全て展開(T)...を選択
  - 参照ボタンを押し、展開先にデスクトップを選択
  - デスクトップに展開されたOpenDolphinフォルダ内の OpenDolphin.jar をダブルクリック
* Mac
  - ダウンロードしたファイルをダブルクリック
  - 解凍されたOpenDolphinフォルダ内の OpenDolphin.jarを右クリック
  - メニューの、このアプリケーションで開く、Jar Launcher.app を選択

これによりOpenDolphinサーバーにログインした状態と成ります。
しかしデータベースにまだ何も登録されていないため、これ以上の操作はできません。カルテを作成するには
ORCAと接続し、患者受付を行う必要があります。ファイルメニューの終了を選択しアプルケーションを終了してください。

***********************

### サーバーの停止
* WildFlyを停止
 	- コントロールキーと英語のcキーを同時に押します 。
* Postgresを停止
 	- docker stop dolphin-db


### ２回目からのサーバー起動
* Postgresを起動
 	- docker start dolphin-db
* WildFlyを起動
 	- docker start dolphin-server

***********************

### WildFlyをフォアグランドで実行する
上記はWildFlyをバックグランドで実行するため、起動の失敗や接続トラブルがあった場合、コンテナに接続しログを見る
必要があります。次のコマンドで実行すると起動状態がターミナルに流れます。
 * docker run --rm --link dolphin-db:ds -p 8080:8080 -it dolphindev/wildfly

停止は
 * コントロールキーと英語のcキーを同時に押します。

***********************

### 既存Postgresサーバーと接続する
既にOpenDolphinを運用していて、Postgresサーバーにデータがある場合、WildFly
コンテナとPostgresデータベースを直接接続することができます。
* データのバックアップをとってください。
* Postgresのバージョンを 9.x 以降に更新してください。（pg_dump, pg_restore等の決められた手順を実行してください。）
* PostgresサーバーのIPアドレスを pg_server_ip とします。またポートはデフォルトの5432とします。
* postgresql.conf に上記IPアドレスでのリッスンを許可してください。
* pg_hba.conf にクライアントマシンからの接続を許可してください。

* WildFly コンテナを下記のように起動します。（環境変数でPostgresサーバーのIPアドレスとポート番号を与えます。）
  - docker rm dolphin-serve
  - docker run --name dolphin-server -e DB_HOST=pg_server_ip -e DB_PORT=5432 -p 8080:8080 -d dolphindev/wildfly

***********************
### 次のステップ
* ORCAを導入し、OpenDolphinと接続してください。カルテの作成、診療行為の送信ができるようになります。
* Postgres（dolphin-db）をデータコンテナ化してください。
* Nginx 等のリバースプロキシーを立てると安全性が向上します。
* このリポジトリのDockerfileを解析し、独自のイメージを作成すると良いかも知れません。
* もし Windows/Mac をサーバーとする場合は（推奨しませんが）Boot2Docker のメモリーやディスクサイズの
拡張を行ってください。またBoot2Dockerが動いているマシン以外からアクセスできるようにするため、
VirtualBox にポートフォーワードの設定を行ってください。

### 免責事項
このドキュメントはOpenDolphinの構成を理解していただき、導入を進めていただくための参考になるこを目的として
います。実際に運用するためには、ここに述べた内容以外にも、特にPostgresと
JavaEEに関する深い知識と経験が必要です。したがってこのドキュメントとコンテナを使用した場合に、何らかの
障害、損害、訴訟等が発生してもその責任は一切負わないものとします。できるだけ商用サポートをご検討ください。
