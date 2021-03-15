================================
Monocle3: trajectory analysis
================================

Monocle3を用いた疑似時系列解析 (pseudo-time analysis) を行います。Rstudioに "Monocle3"というプロジェクトを新規作成し、その中で作業します。

Monocle3のインストール
--------------------------------------------

Monocle2はBioconductorを用いてインストール可能ですが、Monocle3は今のところGithub上で公開されている開発版であり、インストール方法がやや複雑です。以下のコマンドでインストールしてください。Rのバージョンは3.6以上が必要です。

.. code-block:: r

   install.packages("BiocManager")
   BiocManager::install(c('BiocGenerics', 'DelayedArray', 'DelayedMatrixStats',
                       'limma', 'S4Vectors', 'SingleCellExperiment',
                       'SummarizedExperiment', 'batchelor'))
   install.packages("devtools")
   devtools::install_github('cole-trapnell-lab/leidenbase')
   devtools::install_github('cole-trapnell-lab/monocle3')

.. note::

   既にMonocle2がインストールしてある場合、以下のようなメッセージが出るかもしれません。この場合は "1: All" を選択してください。

.. code-block:: r

   > devtools::install_github('cole-trapnell-lab/monocle3')
   Downloading GitHub repo cole-trapnell-lab/monocle3@master
   These packages have more recent versions available.
   Which would you like to update?
   
   1: All                     
   2: CRAN packages only      
   3: None                    
   4: curl (4.1 -> 4.2) [CRAN]

データのダウンロード
--------------------------------------------
今回はMonocle3の `軌道解析チュートリアル <https://cole-trapnell-lab.github.io/monocle3/docs/trajectories/>`_ をもとに進めます。用いるデータは `Packer & Zhu et al. <https://science.sciencemag.org/content/365/6459/eaax1971>`_ による線虫のembryoからの細胞分化データです。

Monocle3は軌道解析以外にもクラスタリングなどの機能も備えています。それらの操作については `Getting started with Monocle 3 <https://cole-trapnell-lab.github.io/monocle3/docs/starting/>`_ を参照してください。

データ読み込み、前処理、正規化
--------------------------------------------

.. code-block:: r

   install.packages("stringi")   # <- これを先に実行してください
   library(monocle3)
   library(dplyr)

データ読み込み


.. code-block:: r

   expression_matrix <- readRDS(url("http://staff.washington.edu/hpliner/data/packer_embryo_expression.rds"))
   cell_metadata <- readRDS(url("http://staff.washington.edu/hpliner/data/packer_embryo_colData.rds"))
   gene_annotation <- readRDS(url("http://staff.washington.edu/hpliner/data/packer_embryo_rowData.rds"))
   
   cds <- new_cell_data_set(expression_matrix,
                         cell_metadata = cell_metadata,
                         gene_metadata = gene_annotation)
.. code-block:: r

   # 参考: 10Xディレクトリを指定する場合
   cds <- load_cellranger_data("./10x_data")

* 前処理、バッチエフェクトの処理

.. code-block:: r

   cds <- preprocess_cds(cds, num_dim = 50)
   cds <- align_cds(cds, alignment_group = "batch", 
          residual_model_formula_str = "~ bg.300.loading + bg.400.loading + bg.500.1.loading + bg.500.2.loading 
          + bg.r17.loading + bg.b01.loading + bg.b02.loading")
   
   cds@colData

次元削減、クラスタリング
--------------------------------------------

Monocle3はデフォルトでUMAPを次元削減に使います。

.. code-block:: r

   cds <- reduce_dimension(cds)

* 可視化

.. code-block:: r

   plot_cells(cds, label_groups_by_cluster=FALSE,  color_cells_by = "cell.type")
* 指定した遺伝子の発現量を可視化

.. code-block:: r

   ciliated_genes <- c("che-1", "hlh-17", "nhr-6", "dmd-6", "ceh-36", "ham-1")
   plot_cells(cds, genes=ciliated_genes, label_cell_groups=FALSE, show_trajectory_graph=FALSE)

* クラスタリング

ひとつのサンプル内に複数の軌道が含まれる（複数の「祖先」細胞がある）可能性を考慮するため、クラスタリングによって得られたクラスタそれぞれで軌道解析を行います。

.. code-block:: r

   cds <- cluster_cells(cds)
   plot_cells(cds, color_cells_by = "partition")


軌道推定
--------------------------------------------
各クラスタについて軌道推定します。

.. code-block:: r

   cds <- learn_graph(cds)
   plot_cells(cds,
           color_cells_by = "cell.type",
           label_groups_by_cluster=FALSE,
           label_leaves=FALSE,
           label_branch_points=FALSE)

* 細胞を軌道（疑似時間軸）に沿ってソート

.. code-block:: r

   plot_cells(cds, color_cells_by = "embryo.time.bin",
           label_cell_groups=FALSE,
           label_leaves=TRUE,
           label_branch_points=TRUE,
           graph_label_size=1.5)

全ての細胞が軌道に含まれるわけではないことに注意。灰色の丸は各軌道の終点（cell fate）を、黒色の丸は分岐点（branch point）を示します。

* rootをマニュアルで指定（GUI）

order_cellsコマンドでソート画面を起動し、rootをどこにするかを指定します。
複数のrootを指定することも可能です。

.. code-block:: r

   cds <- order_cells(cds)

その後、以下のコマンドで軌道の方向性が決定されます。

.. code-block:: r

   plot_cells(cds, color_cells_by = "pseudotime",
           label_cell_groups=FALSE,
           label_leaves=FALSE,
           label_branch_points=FALSE,
           graph_label_size=1.5)

軌道に含まれていない細胞（rootと接続されていない細胞）は灰色で表示されます。

* rootを自動推定

以下のコマンドを実行すると、rootを自動で推定します。
細胞を最近傍の軌道ノードに割り当て、early stageの細胞が最も多く割り当てられているノードをrootとして同定します。

.. code-block:: r

   get_earliest_principal_node <- function(cds, time_bin="130-170"){
     cell_ids <- which(colData(cds)[, "embryo.time.bin"] == time_bin)
   
   closest_vertex <- cds@principal_graph_aux[["UMAP"]]$pr_graph_cell_proj_closest_vertex
   closest_vertex <- as.matrix(closest_vertex[colnames(cds), ])
   root_pr_nodes <- igraph::V(principal_graph(cds)[["UMAP"]])$name[as.numeric(names(which.max(table(closest_vertex[cell_ids,]))))]
  
   root_pr_nodes
   }
   cds <- order_cells(cds, root_pr_nodes=get_earliest_principal_node(cds))
   
- 可視化
.. code-block:: r

   plot_cells(cds, color_cells_by = "pseudotime",
           label_cell_groups=FALSE,
           label_leaves=FALSE,
           label_branch_points=FALSE,
           graph_label_size=1.5)

軌道に沿って発現変化する遺伝子の同定
--------------------------------------------

.. code-block:: r

   # 細胞種ごとに色分けして可視化
   plot_cells(cds, color_cells_by = "cell.type",
           label_groups_by_cluster=FALSE,
           label_leaves=FALSE,
           label_branch_points=FALSE)

graph_test (発現変動解析のためのコマンド) に neighbor_graph="principal_graph" オプションを追加することで、軌道上で近い細胞ごとに分けて発現変動解析をするようになります。以下はかなり時間がかかります。
 
.. code-block:: r

   # cores=4 で4CPUを使う
   ciliated_cds_pr_test_res <- graph_test(cds, neighbor_graph="principal_graph", cores=4)
   pr_deg_ids <- row.names(subset(ciliated_cds_pr_test_res, q_value < 0.05))

得られた遺伝子の可視化

.. code-block:: r

   plot_cells(cds, genes=c("hlh-4", "gcy-8", "dac-1", "oig-8"),
           show_trajectory_graph=FALSE,
           label_cell_groups=FALSE,
           label_leaves=FALSE)

遺伝子モジュールの可視化
--------------------------------------------

軌道ごとのtrajectory-variable genesを遺伝子モジュールとして定義

.. code-block:: r

   gene_module_df <- find_gene_modules(cds[pr_deg_ids,], resolution=c(10^seq(-6,-1)))

(注：公式Tutorialでは resolution=c(0,10^seq(-6,-1)) となっているのですが、手元の環境ではそれだとinput parameter error(s): -> resolution_parameter <= 0　とエラーなるため、ここでは c(10^seq(-6,-1)) を指定しています)

モジュール単位での発現量をヒートマップで可視化

.. code-block:: r

   cell_group_df <- tibble::tibble(cell=row.names(colData(cds)), cell_group=colData(cds)$cell.type)
   agg_mat <- aggregate_gene_expression(cds, gene_module_df, cell_group_df)
   row.names(agg_mat) <- stringr::str_c("Module ", row.names(agg_mat))
   pheatmap::pheatmap(agg_mat, scale="column", clustering_method="ward.D2")

モジュール単位での発現量を2次元マップ上で可視化

.. code-block:: r

   plot_cells(cds,
           genes=gene_module_df %>% filter(module %in% c(27, 10, 7, 30)),
           label_cell_groups=FALSE,
           show_trajectory_graph=FALSE)

その他の可視化
--------------------------------------------

指定した軌道上の発現ダイナミクスの可視化

.. code-block:: r

   AFD_genes <- c("gcy-8", "dac-1", "oig-8")
   AFD_lineage_cds <- cds[rowData(cds)$gene_short_name %in% AFD_genes,
                       colData(cds)$cell.type %in% c("AFD")]
   plot_genes_in_pseudotime(AFD_lineage_cds,
                         color_cells_by="embryo.time.bin",
                         min_expr=0.5)

特定のブランチ（部分細胞群）の抽出・可視化

.. code-block:: r

   # GUIを起動し、部分細胞群を矩形で指定
   cds_subset <- choose_cells(cds)
   # 選択したブランチに対して変動解析を実行
   subset_pr_test_res <- graph_test(cds_subset, neighbor_graph="principal_graph", cores=4)
   pr_deg_ids <- row.names(subset(subset_pr_test_res, q_value < 0.05))
   # 遺伝子モジュールを抽出
   gene_module_df <- find_gene_modules(cds_subset[pr_deg_ids,], resolution=0.001)
   # 可視化
   agg_mat <- aggregate_gene_expression(cds_subset, gene_module_df)
   module_dendro <- hclust(dist(agg_mat))
   gene_module_df$module <- factor(gene_module_df$module, 
                            levels = row.names(agg_mat)[module_dendro$order])
   
   plot_cells(cds_subset, genes=gene_module_df,
           label_cell_groups=FALSE,
           show_trajectory_graph=FALSE)