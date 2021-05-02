１細胞解析技術講習会資料（中戸研究室）
====================================================

本資料について
^^^^^^^^^^^^^^^^^^

- 本資料は **新学術「細胞ダイバース」１細胞解析技術講習会（2019年10月開催）** 用資料として作成したものを改良したものです。本資料を読むことで、1細胞（RNA-seq）解析に必要な知識や基本的な実践方法を学ぶことができます。
- 受講者として、シングルセル解析初心者・初級者である生命系の学生および研究者を想定しています。
- 著作権の問題により、公開しているものは資料の一部のみとなります。完全版はパスワード付き公開となっていますので、閲覧希望の方は中戸までご連絡ください。
- 本資料は Rstudio, Jupyter notebook, Google Colaboratory というサービスを用いて執筆されています。
- 使用するプログラミング言語はR, Pythonです。まれにLinuxシェル上での作業が含まれることもあります。



News
^^^^
| **2021/4/28: 資料Ver 1.5:** Scanpy, Velocytoを修正,追加。scVeloを追加。Monocle3を非公開ページに移動。
| **2021/3/15: 資料Ver 1.4:** 更に改定。 一般公開しました。
| **2020/5/26: 資料Ver 1.3:** 全面的に改定。 Rを使った解析の一部を Rmarkdownに移行しました。
| **2019/12/28: 資料Ver 1.2:** Dockerコンテナをnotebookと名付けて起動する方法で説明していましたが、「次に起動したらエラーになるのですが」という質問が大変多かったので、"--rm" オプションでコンテナを毎回削除するやり方に変更しました。
| **2019/10/23: 資料Ver 1.1:** 技術講習会でのフィードバックを元にアップデートしました。
| **2019/9/25: 資料Ver 1.0** 公開

資料もくじ
^^^^^^^^^^

はじめに
++++++++++++++

.. toctree::
    :maxdepth: 1
    :numbered:

    notebooks/Docker
    notebooks/GoogleColab

Seurat (Rstudio)
++++++++++++++++++++

ここではSeuratを題材に、Rstudioの使い方と基本的なscRNA-seq解析のワークフロー、注意点について解説します。

.. toctree::
    :maxdepth: 1
    :numbered:

    notebooks/Seurat
    notebooks/GuidedTutorial

Scanpy (Google Colab, Jupyter)
++++++++++++++++++++++++++++++++++++++

こちらの項目は `Scanpy Tutorial <https://scanpy.readthedocs.io/en/stable/index.html>`_ 及び 
`scVelo Tutorial <https://scvelo.readthedocs.io/>`_ の内容を原著者の許諾のもとに翻訳・公開したものです。

.. toctree::
    :maxdepth: 1
    :numbered:

    notebooks/Scanpy_PBMC
    notebooks/Scanpy_PAGA
    notebooks/Scanpy_CorePlottingFunctions
    notebooks/ingest_and_BBKNN
    notebooks/VisiumSpatialTranscriptomics
    notebooks/scVelo

Velocyto (Jupyter)
++++++++++++++++++++++++++++++++++++++

こちらの項目は `velocyto.py <http://velocyto.org/velocyto.py/index.html>`_ で公開されているnotebookを原著者の許諾のもとに翻訳・公開したものです。

.. toctree::
    :maxdepth: 1
    :numbered:

    notebooks/Velocyto
    notebooks/Velocyto.R
    notebooks/Velocyto_Pagoda2.ipynb
    notebooks/Velocyto.python.DentateGyrus


利用について
^^^^^^^^^^^^^^
- 本資料の著作権は中戸に帰属します。
- 本資料にはクリエイティブコモンズの「`CC BY-NC（表示 - 非営利） <https://creativecommons.org/licenses/by-nc/4.0/deed.ja>`_」ライセンスが適用されます。
- 本資料は個人で学習する目的で自由に利用可能です。企業内での講習など、商用利用は認められていません。
- 本資料を用いた講義・講習会を実施されたい場合は、個別に許諾を得ていただく必要があります。

問い合わせ先
^^^^^^^^^^^^^^
- 本資料に記載されている内容や、Dockerイメージについての質問、不具合の報告については中戸 <rnakato AT iqb.u-tokyo.ac.jp> までお知らせください。
- 本資料に掲載されているツールの利用法の詳細、チュートリアルの記載内容、起きたエラーについての質問は、それぞれの開発元に問い合わせてください。
