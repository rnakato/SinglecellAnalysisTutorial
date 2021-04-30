================================
Velocyto Introduction
================================

従来の軌道解析では得られた軌道の遷移方向やroot cell を自動推定できないため、マーカー遺伝子などを用いて自力で推測する必要がありました。
ここで、mature/premature mRNAの比率を元に推定される "RNA velocity" を用いると、細胞の遷移方向をデータから直接推定可能になります。
ここでは最も代表的なツールである **Velocyto** を実行する方法を紹介します。

元論文: `RNA velocity of single cells, La Manno et al., Nature, 2018 <https://www.nature.com/articles/s41586-018-0414-6>`_

- 参考:

     - `velocyto homepage <http://velocyto.org/>`_
     - `velocyto.py <http://velocyto.org/velocyto.py/index.html>`_
     - `velocyto.R <https://github.com/velocyto-team/velocyto.R>`_


VelocytoはRとPython両方に対応しており、以後のチュートリアルではR版とPython版の両方を紹介しています。


Velocytoのインストール（optional）
--------------------------------------------

本チュートリアルでは私の ``singlecell_jupyter Docker`` イメージを使いますが、自分のPCにインストールする場合は以下のようにしてください。

Velocyto は内部で boost library を使っており、Windows の R ではインストールすることは難しいです。
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

**Docker起動 -> Dockerイメージからコンテナ起動 -> コンテナ内でJupyter (R or Python) 起動 -> Jupyter上でVelocytoを利用** という流れになります。

入力データ（.loomファイル）の生成（optional）
------------------------------------------------------------
Velocytoは .loom 形式のファイルを入力として読み込みます。
本チュートリアルでは既に生成されたファイルを使いますので必要ありませんが、自分のデータでvelocytoを使う場合は以下の手続きが必要になります。

ここでは例として、10X CellRanger で生成されたディレクトリ（ここでは `10Xdir` ）から.loomファイルを生成する `run10x` コマンドを紹介します。

.. code-block:: sh

    gtf="refdata-cellranger-mm10-3.0.0/genes/genes.gtf"
    # -@ 12 は利用するCPU数
    velocyto run10x -m repeat_msk.gtf -@ 12 10Xdir $gtf

    # singularityを用いる場合のコマンド
    singularity exec rnakato_singlecell_jupyter.img velocyto run10x -m repeat_msk.gtf -@ 12 10Xdir $gtf

``repeat_msk.gtf`` は `UCSC genome browser <https://genome.ucsc.edu/cgi-bin/hgTables?hgsid=611454127_NtvlaW6xBSIRYJEBI0iRDEWisITa&clade=mammal&org=Mouse&db=mm10&hgta_group=allTracks&hgta_track=rmsk&hgta_table=0&hgta_regionType=genome&position=chr12%3A56694976-56714605&hgta_outputType=primaryTable&hgta_outputType=gff&hgta_outFileName=mm10_rmsk.gtf>`_ からダウンロードするリピート情報のファイルです。
より詳細は以下のページを参考にしてください。

- `Velocyto CLI Usage Guide <http://velocyto.org/velocyto.py/tutorial/cli.html>`_
- `Download expressed repeats annotation <http://velocyto.org/velocyto.py/tutorial/cli.html#preparation>`_
