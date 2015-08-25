### OpenDolphin Docker

下記はOpenDolphinサーバーを構築する最も簡単な方法です。コンテナイメージは Docker Hub に公開しています。


#### サーバーとなるマシンに docker をインストール
* CentOS7/Ubuntuの場合　Docker の公式サイトに手順があります。
* Windows/Macの場合　Docker Toolbox を使用します。（インストールパッケージがあります。）


#### Dolphin 用の Postgres と WildFly イメージをインストール

    docker pull dolphindev/postgres
    docker pull dolphindev/wildfly

インストールには時間がかかります。ネットワーク速度の関係でタイムアウトが起きた場合、再度実行してください。


#### 起動

    docker run --name dolphin-db -d dolphindev/postgres
    docker run --name dolphin-server --link dolphin-db:ds -p 8080:8080 -d dolphindev/wildfly

コマンドは正確に入力してください（コピーペーストが確実です）。上記コマンドが成功するとサーバーがバックグラウンドで動いています。


#### サーバーのIPアドレスを調査
クライアントと接続するため、サーバのIPアドレスを調べます。

* Linuxの場合　　インストールしたマシンのIPアドレス
* Windows/Macの場合　ターミナルで下記コマンドを実行し、その戻り値を使用します。

````
docker-machine ip default　（defaultは使用中のマシン名です）
````

以下、サーバーのIPアドレスを host_ip とし次の節で使用します。


#### クライアントから接続
* クライアントマシン(Windows/Mac)に最新の Java8 実行環境をインストールしてください。
* [ここから](http://www.digital-globe.co.jp/openDolphin/sys-guide/26/client/OpenDolphin.zip) クライアントプログラムをダウンロードします。
* クライアントプログラムは ZIP 形式になっています。下記 Tips を参照し、OpenDolphinを起動してください。
* ログイン画面が現れたら設定ボタンを押してください。
* 接続設定に下記の値を入力します。
  - 医療機関ID　　1.3.6.1.4.1.9414.70.1
  - ユーザーID　　admin
  - ベースURI　　 http&#58;//host_ip:8080（サーバーのIPアドレス:8080）
* 設定を保存するとログイン画面に戻ります。
* パスワードに admin を入力し、ログインボタンを押します。

これによりOpenDolphinサーバーにログインした状態と成ります。
しかしデータベースにまだ何も登録されていないため、これ以上の操作はできません。カルテを作成するには
ORCAと接続し、患者受付を行う必要があります。ファイルメニューの終了を選択しアプルケーションを終了してください。


#### Tips 解凍とクライアント起動
* Windows
  - ダウンロードしたファイルを右クリック、メニューの全て展開(T)...を選択
  - 参照ボタンを押し、展開先にデスクトップを選択
  - デスクトップに展開されたOpenDolphinフォルダ内の OpenDolphin.jar をダブルクリック
* Mac
  - ダウンロードしたファイルをダブルクリック
  - 解凍されたOpenDolphinフォルダ内の OpenDolphin.jarを右クリック
  - メニューの、このアプリケーションで開く、Jar Launcher.app を選択


#### サーバーの停止
WildFlyを停止 ->  Postgresを停止

    docker stop dolphin-server
    docker stop dolphin-db


#### ２回目からのサーバー起動
Postgresを起動 -> WildFlyを起動  

    docker start dolphin-db
    docker start dolphin-server


#### WildFlyをフォアグラウンドで実行する
上記はWildFlyをバックグラウンドで実行するため、起動の失敗や接続トラブルがあった場合、コンテナに接続しログを見る
必要があります。次のコマンドで実行すると起動状態がターミナルに流れます。  

    docker run --rm --link dolphin-db:ds -p 8080:8080 -it dolphindev/wildfly

停止は

    コントロールキーと英語のcキーを同時に押します。


#### 既存の Postgres サーバーと接続する
既にOpenDolphinを運用していてPostgresサーバーにデータがある場合、WildFly
コンテナとPostgresを直接接続することができます。

* データのバックアップをとってください。
* Postgresのバージョンを最新にしてください。（pg_dump, pg_restore等の決められた手順を実行してください。）
* PostgresサーバーのIPアドレスを pg_server_ip とします。またポートはデフォルトの5432とします。
* postgresql.conf に上記IPアドレスでのリッスンを許可してください。
* pg_hba.conf にクライアントマシンからの接続を許可してください。

WildFly コンテナを下記のように起動します。
（環境変数でPostgresサーバーのIPアドレスとポート番号を与えます。）

    docker rm dolphin-server  
    docker run --name dolphin-server -e DB_HOST=pg_server_ip -e DB_PORT=5432 -p 8080:8080 -d dolphindev/wildfly


#### 次のステップ
* ORCAを導入し、OpenDolphinと接続してください。カルテの作成、診療行為の送信ができるようになります。
* Postgres（dolphin-db）をデータコンテナ化してください。
* Nginx 等のリバースプロキシーを立てると安全性が向上します。
* このリポジトリのDockerfileを解析し、独自のイメージを作成すると良いかも知れません。
* もし Windows/Mac をサーバーとする場合は（全く推奨されていませんが）メモリーやディスクサイズを十分に確保したMachineを作成してください。

またDocker ToolBoxが動いているマシン以外からアクセスできるようにするため、VirtualBox にポートフォーワードの設定を行ってください。


#### 参考情報
 * [ORCAとの接続](https://gist.github.com/dolphin-dev/c75e4ca63689779bfdf7)
 * [ソースコード](https://github.com/dolphin-dev/OpenDolphin)


#### 免責事項
********************************************************************************
このドキュメントはOpenDolphinの構成を理解していただき、導入を進めていただくための参考になるこを目的としています。ご利用は自己責任の原則に基づきます。したがってこのドキュメントとコンテナを使用し、何らかの障害、損害、訴訟等が発生してもその責任は一切負わないものとします。実際に運用するためには、ここに述べた以外の知識、特にPostgresとJavaEEに関する理解と経験が必要です。できるだけ商用サービスをご利用ください。
