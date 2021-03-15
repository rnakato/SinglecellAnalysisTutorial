================================
Monocle
================================

Monocle2を用いた疑似時系列解析 (pseudo-time analysis) を行います。Rstudioに "Monocle2"というプロジェクトを新規作成してください。

MonocleはBioconductorを用いてインストール可能です。以下のコマンドでインストールしてください。

.. code-block:: r

   install.packages("BiocManager")
BiocManager::install(c('BiocGenerics', 'DelayedArray', 'DelayedMatrixStats',
                       'limma', 'S4Vectors', 'SingleCellExperiment',
                       'SummarizedExperiment', 'batchelor'))
install.packages("devtools")
devtools::install_github('cole-trapnell-lab/leidenbase')
devtools::install_github('cole-trapnell-lab/monocle3')

既にMonocle2がインストールしてある場合、以下のようなメッセージが出るかもしれません。この場合は "1: All" を選択してください。
> devtools::install_github('cole-trapnell-lab/monocle3')
Downloading GitHub repo cole-trapnell-lab/monocle3@master
These packages have more recent versions available.
Which would you like to update?

1: All                     
2: CRAN packages only      
3: None                    
4: curl (4.1 -> 4.2) [CRAN]

   BiocManager::install(c("monocle", "netbiov"))

.. note::

   Monocleは最近 version3 が公開されましたが、まだ開発版であるため、本実習ではMonocle2を用います。


データのダウンロード
--------------------------------------------
サンプルデータとして、10Xで生産された Peripheral Blood Mononuclear Cells (PBMC) 2,700細胞を用います。以下のURLからダウンロード後、解凍してください。

データは `GitHubサイト <https://github.com/cole-trapnell-lab/monocle2-rge-paper/tree/master/Supplementary_scripts/Jupyter_notebooks>`_ からダウンロード可能ですが、時間の節約のため、`こちらのリンク <https://www.dropbox.com/s/dnkqspct8vjtpii/Olsson_RSEM_SingleCellRNASeq.zip?dl=0>`_ を使ってください。

ダウンロード後圧縮ファイルを解凍し、フォルダ内の "Olsson_RSEM_SingleCellRNASeq.csv" と "fig1b.txt" をProjectのディレクトリに置けば準備完了です。

Monocleの実行
--------------------------------------------

#　http://cole-trapnell-lab.github.io/monocle-release/tutorial_data/Olsson_dataset_analysis_final.html

* Monocle読み込み

.. code-block:: r

   options(warn=-1) # turn off warning message globally 
   suppressMessages(library(monocle))
   suppressMessages(library(stringr))
   suppressMessages(library(plyr))
   suppressMessages(library(netbiov))


hta_exprs <- read.csv("./Olsson_RSEM_SingleCellRNASeq.csv",row.names=1)
sample_sheet <- data.frame(groups = str_split_fixed(colnames(hta_exprs), "\\.+", 3), row.names = colnames(hta_exprs))
gene_ann <- data.frame(gene_short_name = row.names(hta_exprs), row.names = row.names(hta_exprs))
pd <- new("AnnotatedDataFrame",data=sample_sheet)
fd <- new("AnnotatedDataFrame",data=gene_ann)

tpm_mat <- hta_exprs
tpm_mat <- apply(tpm_mat, 2, function(x) x / sum(x) * 1e6)

URMM_all_std <- newCellDataSet(as.matrix(tpm_mat),phenoData = pd,featureData =fd,
                           expressionFamily = negbinomial.size(),
                           lowerDetectionLimit=1)

#set up the experimental type for each cell
pData(URMM_all_std)[, 'Type'] <- as.character(pData(URMM_all_std)[, 'groups.1']) #WT cells
pData(URMM_all_std)[453:593, 'Type'] <- paste(as.character(pData(URMM_all_std)[453:593, 'groups.1']), '_knockout', sep = '') #KO cells
pData(URMM_all_std)[594:640, 'Type'] <- paste(pData(URMM_all_std)[594:640, 'groups.1'], pData(URMM_all_std)[594:640, 'groups.2'], 'knockout', sep = '_') #double KO cells

#run Census to get the transcript counts
URMM_all_abs_list <- relative2abs(URMM_all_std, t_estimate = estimate_t(URMM_all_std), return_all = T, method = 'num_genes')
URMM_all_abs <- newCellDataSet(as(URMM_all_abs_list$norm_cds, 'sparseMatrix'),
                               phenoData = new("AnnotatedDataFrame",data=pData(URMM_all_std)),
                               featureData = new("AnnotatedDataFrame",data=fData(URMM_all_std)),
                               expressionFamily = negbinomial.size(),
                               lowerDetectionLimit=1)
URMM_all_abs <- estimateSizeFactors(URMM_all_abs)
suppressMessages(URMM_all_abs <- estimateDispersions(URMM_all_abs)) # suppress the warning produced from glm fit 

URMM_all_abs <- setOrderingFilter(URMM_all_abs, row.names(fData(URMM_all_abs)))


fig1b <- read.csv("./fig1b.txt",row.names=1, sep = '\t')

#match up the column name in fig1b to the colnames in URMM_all_fig1b
#note that you should not run this mutliple times
URMM_all_fig1b <- URMM_all_abs[, pData(URMM_all_abs)$Type %in% c('Lsk', 'Cmp', 'Gmp', 'LK')]

fig1b_names <- colnames(fig1b)
match_id <- which(str_split_fixed(colnames(fig1b), "\\.+", 2)[, 2] %in% colnames(URMM_all_fig1b) == T)
fig1b_names[match_id] <- str_split_fixed(colnames(fig1b), "\\.+", 2)[match_id, 2]
no_match_id <- which(str_split_fixed(colnames(fig1b), "\\.+", 2)[, 2] %in% colnames(URMM_all_fig1b) == F)
fig1b_names[no_match_id] <- str_split_fixed(colnames(fig1b), "\\.\\.", 2)[no_match_id, 2]
colnames(fig1b)[2:383] <- fig1b_names[2:383]

#set up the color for each experiment
cols <- c("Lsk" = "#edf8fb", "Cmp" = "#ccece6", "Gmp" = "#99d8c9", "GG1" = "#66c2a4", "IG2" = "#41ae76", "Irf8" = "#238b45", "LK" = "#005824",
          "Irf8_knockout" = "#fc8d59", "Gfi1_Irf8_knockout" = "#636363", "Gfi1_knockout" = "#dd1c77")

#########################################################################################################################################################################
#assign clusters to each cell based on the clustering in the original study
pData(URMM_all_fig1b)$cluster <- 0
cluster_assignments <- as.numeric(fig1b[1, 2:383])
cluster_assignments <- revalue(as.factor(cluster_assignments), c("1" = "HSCP-1", "2" = "HSCP-2", "3" = "Meg", "4" = "Eryth",
                                                                 "5" = "Multi-Lin", "6" = "MDP", "7" = "Mono", "8" = "Gran", "9" = "Myelocyte"))

names(cluster_assignments) <- colnames(fig1b[1, 2:383])
pData(URMM_all_fig1b)$cluster <- cluster_assignments[row.names(pData(URMM_all_fig1b))]
#########################################################################################################################################################################
URMM_all_fig1b <- estimateSizeFactors(URMM_all_fig1b)
suppressMessages(URMM_all_fig1b <- estimateDispersions(URMM_all_fig1b))

#1. set ordering genes for the fig1b
URMM_all_fig1b <- setOrderingFilter(URMM_all_fig1b, ordering_genes = row.names(fig1b))
URMM_pc_variance <- plot_pc_variance_explained(URMM_all_fig1b, return_all = T, norm_method = 'log')

#2. run reduceDimension with tSNE as the reduction_method
set.seed(2017)
URMM_all_fig1b <- reduceDimension(URMM_all_fig1b, max_components=2, norm_method = 'log', reduction_method = 'tSNE', num_dim = 12,  verbose = F)

#3. initial run of clusterCells
URMM_all_fig1b <- clusterCells(URMM_all_fig1b, verbose = F, num_clusters = 5)

#4. check the clusters
options(repr.plot.width=4, repr.plot.height=3)
plot_cell_clusters(URMM_all_fig1b, color_by = 'as.factor(Cluster)') + theme (legend.position="left", legend.title=element_blank())# show_density = F,
plot_cell_clusters(URMM_all_fig1b, color_by = 'cluster') + theme (legend.position="left", legend.title=element_blank())
plot_cell_clusters(URMM_all_fig1b, color_by = 'Type') + theme (legend.position="left", legend.title=element_blank())
plot_rho_delta(URMM_all_fig1b) 

URMM_all_fig1b@expressionFamily <- negbinomial.size()
pData(URMM_all_fig1b)$Cluster <- factor(pData(URMM_all_fig1b)$Cluster)
URMM_clustering_DEG_genes <- differentialGeneTest(URMM_all_fig1b, fullModelFormulaStr = '~Cluster', cores = detectCores() - 2)

#use all DEG gene from the clusters
URMM_ordering_genes <- row.names(URMM_clustering_DEG_genes)[order(URMM_clustering_DEG_genes$qval)][1:1000]


# Reconstruct the developmental trajectory for the wild-type data
# use the feature genes selected above to reconstruct the developmental trajectory

URMM_all_fig1b <- setOrderingFilter(URMM_all_fig1b, ordering_genes = c(URMM_ordering_genes))
URMM_all_fig1b <- reduceDimension(URMM_all_fig1b, verbose = F, scaling = T, max_components = 4, maxIter = 100, norm_method = 'log',  lambda = 20 * ncol(URMM_all_fig1b)) 
URMM_all_fig1b <- orderCells(URMM_all_fig1b)
options(repr.plot.width=3, repr.plot.height=3)
plot_cell_trajectory(URMM_all_fig1b, color_by = 'Type')
options(repr.plot.width=8, repr.plot.height=8)
plot_cell_trajectory(URMM_all_fig1b, color_by = 'cluster') + facet_wrap(~cluster)
options(repr.plot.width=8, repr.plot.height=8)
plot_cell_trajectory(URMM_all_fig1b, color_by = 'cluster', x = 1, y = 3) + facet_wrap(~cluster)