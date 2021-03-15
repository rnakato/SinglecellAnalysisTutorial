================================
Docker / Jupyter notebook
================================

このページではDockerを用いるための環境構築方法について説明します。Dockerの詳細については以下のような資料も参考にしてください。

* `Docker入門（第一回）～Dockerとは何か、何が良いのか～ <https://knowledge.sakura.ad.jp/13265/>`_
* `https://qiita.com/kotaro-dr/items/b1024c7d200a75b992fc <https://qiita.com/kotaro-dr/items/b1024c7d200a75b992fc>`_
* `Dockerのインストール（中戸ブログ） <http://rnakato.hatenablog.jp/entry/2019/07/19/115538>`_

Dockerのインストール
--------------------------------

Mac, Windows10 Pro, Windows10 Homeでそれぞれインストール・設定方法が異なります。詳細は以下の林さん作成の資料を参照してください。

`技術講習会 docker環境の構築 改訂版 <../file/hayashi.pdf>`_ 

Dockerイメージのダウンロード
==============================

**rnakato/singlecell_jupyter** というのが、中戸作成の1細胞解析用Dockerイメージの名前になります。
以下のコマンドでダウンロードします。(新しいバージョンのイメージに更新したい場合も同様にpullします)

::

    docker pull rnakato/singlecell_jupyter  # イメージのダウンロード

DockerからJupyterの起動
==========================
| 本資料ではDockerイメージからJupyterを起動し、Jupyter上で作業します。
| **Docker起動 -> Dockerイメージの起動 -> イメージ内でJupyter (R or Python) 起動 -> Jupyter上でツールを利用** という流れになります。

ここでは notebook というコンテナ名でイメージを起動し、Jupyterを起動します。 **-v** オプションをつけることで、コンテナ内のディレクトリをホストPCのフォルダと同期させることができます。こうしておかないと、Docker内で作成したjupyterファイルがDocker終了後消えてしまいますので注意してください。

Mac terminalの場合
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh

    docker run -it --rm -p 8888:8888 -v $(pwd):/home/jovyan/work \
        rnakato/singlecell_jupyter \
        start-notebook.sh

| その後、以下のように表示されますので、**http://127.0.0.1:8888/?token=~** の部分(URL)をコピーし、ブラウザで起動。

.. code-block:: sh

    To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-6-open.html
    Or copy and paste one of these URLs:
        http://f6251475ae06:8888/?token=0b07988ac7e4cf803c53d07f4de0366cc20ed4568343d
     or http://127.0.0.1:8888/?token=0b07988ac7e4cf803c53d07f4de0366cc20ed4568343d

Windows10 Pro の場合
^^^^^^^^^^^^^^^^^^^^^^

あらかじめ Docker の "Setting" でCドライブをマウントしておいてください。
その後、(Windows Powershellなどで) 以下のコマンドを実行します。

.. code-block:: sh

    docker run -it --rm -p 8888:8888 -v c:/Users:/home/jovyan/work rnakato/singlecell_jupyter start-notebook.sh

参考：https://qiita.com/kikako/items/7b6301a140cf37a5b7ac

| その後、以下のように表示されますので、**http://127.0.0.1:8888/?token=~** の部分(URL)をコピーし、ブラウザで起動。

.. code-block:: sh

    To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-6-open.html
    Or copy and paste one of these URLs:
        http://f6251475ae06:8888/?token=0b07988ac7e4cf803c53d07f4de0366cc20ed4568343d
     or http://127.0.0.1:8888/?token=0b07988ac7e4cf803c53d07f4de0366cc20ed4568343d


Windows10 Home (Windows7) の場合
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh

    docker run -it --rm -p 8888:8888 -v /Users:/home/jovyan/work rnakato/singlecell_jupyter start-notebook.sh

| その後、以下のように表示されますので、**http://127.0.0.1:8888/?token=~** の部分(URL)をコピーし、ブラウザで起動。
| （注：アクセスにlocalhost (127.0.0.1)ではなく 192.168.99.100 を指定する必要があるかもしれません。参考：https://qiita.com/hidao/items/cf4a3ed0d2a753a405a4）

.. code-block:: sh

    To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-6-open.html
    Or copy and paste one of these URLs:
        http://f6251475ae06:8888/?token=0b07988ac7e4cf803c53d07f4de0366cc20ed4568343d
     or http://127.0.0.1:8888/?token=0b07988ac7e4cf803c53d07f4de0366cc20ed4568343d

Dockerについての補足
==========================

Tokenが要求される場合
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Jupyterが開いた時に "password or token" を入力する画面になった時は、上記URLの "taken=" 以降の文字列をコピペして入力してください。


Dockerコンテナの確認
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh

    docker ps    # アクティブなコンテナの一覧表示
    docker ps -a # 非アクティブなコンテナを含めた一覧表示
    docker stop <コンテナ名>  # 実行中のコンテナを停止
    docker start <コンテナ名> # 停止中のコンテナを起動
    docker rm <コンテナ名>   # コンテナの削除
    
    docker exec -it <コンテナ名> <コマンド> # 実行中のコンテナでコマンドを実行
    docker run -it --rm <コンテナ名> <コマンド> # コンテナを新規起動してコマンドを実行
    
    docker images  # ダウンロードしたイメージの一覧表示
    docker rmi <image名>   # ダウンロード済イメージの削除
    
    docker container prune -f  # 停止中のコンテナをすべて削除
    docker image prune    # タグが<none>のイメージを削除 


Dockerコンテナの再起動
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| 過去にJupyter notebookを起動したコンテナが残ったままで再び上のコマンドを実行すると、 "コンテナが既に存在するため作成できません"とエラーになる場合があります。
| その場合は "docker stop <コンテナ名>" 既存の既存のコンテナを停止（削除）してから、あらためて作成してください。

Jupyterの使い方
==========================

.. image:: img/Jupyter.jpg
   :scale: 35
   :align: center

上がJupyterを起動した状態です。赤枠の "New" を選択し、 "R" または "Python3" の適切な方を選択すると notebook が新規作成されます。

セル内にコマンドを書き込み、上部の ">Run" をクリックするとセル内のコマンドが実行されます。
左のカッコ内が "\*" になっている間はコマンド実行中で、完了すると数字に変わります。

"+" ボタンを押すとセル追加、ハサミマークを押すと現在のセルが削除されます。
一番左のフロッピーマークが保存です。
実行中のセルで "■" ボタンを押すと実行を中止します。

参考： `jupyter notebookの基本的な使い方。起動と終了 <https://code-graffiti.com/how-to-use-jupyter-notebook/>`_


データの保存
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Docker内で作成したファイルは、Docker終了時に消えてしまいます。
ファイルを永続化するために、上のコマンドでは "-v" オプションを付加し、ホスト（PC）側のフォルダとDockerコンテナのworkフォルダを同期しています。

Jupyter起動後、workフォルダに移動し、その中でファイルを作成すると、同期したホスト側フォルダの中にファイルが残り、Docker終了後も消えることはありませんので、繰り返し用いることができます。

.. Note::

    | "-v" オプションで同期するホスト側のフォルダのパスに2バイト文字（ひらがな・カタカナ・漢字など）が含まれていると、同期に失敗するようです。
    | また、同期したフォルダの中に2バイト文字のファイル or フォルダが存在すると、workディレクトリ側からはフォルダが空に見えるようです。
    | ですので、cドライブ直下など、2バイト文字が存在しない場所を同期するようにしてください。


Dead Kernel について
^^^^^^^^^^^^^^^^^^^^^^^^^^
| 使用しているPCのスペックを超える作業をJupyter上で行った場合、Jupyterが強制終了してしまう場合があります。
| その場合、ページ上部のKernelが "Dead Kernel" という表示になり、作業が続けられません。
| この場合は一旦Jupyterのホーム画面に戻り、Jupyterファイルをshutdownしてから再起動する必要があります。
| (特にWin10 HomeでVirtual boxを起動している場合は、スペック制限が厳しいです。) 
| 毎回終了してしまう場合は、Virtual boxの設定から許容するCPU/メモリ数を多くするか、より高スペックのPCを使う必要があります。