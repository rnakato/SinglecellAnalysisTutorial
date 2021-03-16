================================
Velocyto Introduction
================================

従来の軌道解析では得られた軌道の遷移方向やroot cell を自動推定できないため、マーカー遺伝子などを用いて自力で推定する必要がありました。
ここでpre-mRNAの比率を元に推定される "RNA velocity" を用いると、細胞の遷移方向をデータから直接推定可能になります。 
ここでは代表的なツールである **Velocyto** を実行します。

元論文: `RNA velocity of single cells, La Manno et al., Nature, 2018 <https://www.nature.com/articles/s41586-018-0414-6>`_


Velocytoのインストール
--------------------------------------------

Velocyto は内部で boost library を使っており、Windows の R ではインストールすることは難しいです。
本チュートリアルでは私が作成したインストール済の Docker イメージを使います。

Linux や Mac terminal 上では boost library をインストールしたうえで以下のコマンドでインストール可能です。

- Pythonの場合 (velocyto.py)

.. code-block:: python

    pip install velocyto

- Rの場合 (velocyto.R)

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
