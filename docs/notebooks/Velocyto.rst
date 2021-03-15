================================
Velocyto Introduction
================================

RNA velocity を利用して細胞の遷移方向を直接推定可能な **Velocyto** のチュートリアルです。

元論文: `RNA velocity of single cells <https://www.nature.com/articles/s41586-018-0414-6>`_


Velocytoのインストール
--------------------------------------------

Velocyto は内部で boost library を使っており、Windows の R ではインストールすることは難しいため、
本チュートリアルでは私が作成したインストール済の Docker イメージを使います。

Linux や Mac terminal などで boost library をインストール済の状態であれば以下のコマンドでインストールすることができます。

- Pythonの場合

.. code-block:: python

    pip install velocyto

- Rの場合

.. code-block:: r

    install.packages("devtools")
    devtools::install_github("velocyto-team/velocyto.R")


Dockerを用いたVelocytoの起動
-------------------------------
自分のPCでDockerが起動している状態であることを確認してください。
Dockerイメージ から Jupyter を起動し、その上で Velocyto を読み込みます。

**Docker起動 -> Dockerイメージの起動 -> イメージ内でJupyter (R or Python) 起動 -> Jupyter上でVelocytoを利用** という流れになります。


入力データについて
--------------------------------------------
Velocytoは .loom 形式のファイルを入力として読み込みます。
10Xなどで生成されたシングルセルデータから .loom ファイルを生成するステップは下記を参考にしてください（本講習では実行しません）。

- `Velocyto CLI Usage Guide <http://velocyto.org/velocyto.py/tutorial/cli.html>`_

VelocytoはRとPython両方に対応しており、以後のチュートリアルではR版とPython版の両方を紹介しています。

参考
--------------------------------------------

- `velocyto homepage <http://velocyto.org/>`_
- `velocyto.py <http://velocyto.org/velocyto.py/index.html>`_
- `velocyto.R <https://github.com/velocyto-team/velocyto.R>`_
