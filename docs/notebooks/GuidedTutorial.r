
# ライブラリ読み込み
library(dplyr)
library(Seurat)

sessionInfo()

# Load the PBMC dataset (cellrangerのraw dataを読み込み、UMIの行列に変換)
pbmc.data <- Read10X(data.dir = "./filtered_gene_bc_matrices/hg19/")
# Initialize the Seurat object with the raw (non-normalized data).
# min.cells, min.features はそれぞれ最低発現細胞数、遺伝子数
pbmc <- CreateSeuratObject(counts = pbmc.data, project = "pbmc3k", min.cells = 3, min.features = 200)
pbmc

# 最初の20細胞中の冒頭10遺伝子についてUMI値を表示
pbmc[["RNA"]]@counts[1:10,1:20]
# pbmc.data[1:10,1:20]  でも同じ（並び順は異なる）

# 最初の30細胞における特定の遺伝子を表示
pbmc.data["CD3D", 1:30]  # 1遺伝子の場合
pbmc.data[c("CD3D", "TCL1A", "MS4A1"), 1:30]  # 複数遺伝子を指定する場合

pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")

# Show QC metrics for the first 5 cells
head(pbmc@meta.data, 5)

# Visualize QC metrics as a violin plot
VlnPlot(pbmc, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)

# CombinePlots関数で２つの図を同時に表示
plot1 <- FeatureScatter(pbmc, feature1 = "nCount_RNA", feature2 = "percent.mt")
plot2 <- FeatureScatter(pbmc, feature1 = "nCount_RNA", feature2 = "nFeature_RNA")
CombinePlots(plots = list(plot1, plot2))

### We filter cells that have unique feature counts over 2,500 or less than 200
### and cells that have >5% mitochondrial counts
pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)

pbmc <- NormalizeData(pbmc, normalization.method = "LogNormalize", scale.factor = 10000)

### Seurat3 directly models the mean-variance relationship inherent in single-cell data,
### By default, we return 2,000 features per dataset.
pbmc <- FindVariableFeatures(pbmc, selection.method = "vst", nfeatures = 2000)

# 上位10個のHVGをtop10に格納
top10 <- head(VariableFeatures(pbmc), 10)

# HVGを赤色として「発現量ー分散」の散布図をプロット
plot1 <- VariableFeaturePlot(pbmc)  # top10ラベルなし
plot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE)  # top10ラベルあり
CombinePlots(plots = list(plot1, plot2))

all.genes <- rownames(pbmc)
#pbmc <- ScaleData(pbmc, features = all.genes)  # scaled by all genes
pbmc <- ScaleData(pbmc)   # scaled by highly variable (2,000) genes
### The results of this are stored in pbmc[["RNA"]]@scale.data

pbmc <- RunPCA(pbmc, features = VariableFeatures(object = pbmc))

# PC1からPC5までの上位・下位トップランク遺伝子を表示
print(pbmc[["pca"]], dims = 1:5, nfeatures = 5)

# PC1, PC2について同様に図で表示
VizDimLoadings(pbmc, dims = 1:2, reduction = "pca")

# PC1, PC2の散布図表示
DimPlot(pbmc, reduction = "pca")

# PC1方向で正負トップランクの遺伝子について、ランダムに選ばれたそれぞれ500細胞での値を可視化
DimHeatmap(pbmc, dims = 1, cells = 500, balanced = TRUE)

# PC15までを一度に可視化 (目で見る主観的な方法だが有用性が高い)
#（２分されているように見えなければ、その主成分にはもう情報がないと言える）
DimHeatmap(pbmc, dims = 1:15, cells = 500, balanced = TRUE)

# Jack-Straw plotによる主成分の可視化
# 黒点線で示されたランダム状態より上に振れているほど情報量が多い
# 実際には主観的であるうえに計算量が非常に多いので個人的にはスキップ推奨
pbmc <- JackStraw(pbmc, num.replicate = 100)
pbmc <- ScoreJackStraw(pbmc, dims = 1:20)
JackStrawPlot(pbmc, dims = 1:15)

# Elbow plotによる可視化
# 横軸が主成分の次元を表し、降下曲線から水平になる点（Elbow）が最適な主成分の次元数
ElbowPlot(pbmc)

# This step is performed using the FindNeighbors function, and takes as input the previously defined dimensionality of the dataset (first 10 PCs).

# 第10主成分までの値を元にKNNグラフ作成
pbmc <- FindNeighbors(pbmc, dims = 1:10)
# グラフを元にクラスタリング (resolutionを変えるとクラスタ数が変わる)
pbmc <- FindClusters(pbmc, resolution = 0.5)

# 第10主成分までの値を元にKNNグラフ作成
pbmc <- FindNeighbors(pbmc, dims = 1:10)
# グラフを元にクラスタリング
pbmc <- FindClusters(pbmc, resolution = 0.5)

# Look at cluster IDs of the first 5 cells
head(Idents(pbmc), 5)

pbmc <- RunTSNE(pbmc, dims = 1:10)
DimPlot(pbmc, reduction = "tsne")

# "label = TRUE" をつけると細胞ラベルありになる
DimPlot(pbmc, reduction = "tsne", label = TRUE)

pbmc <- RunUMAP(pbmc, dims = 1:10)
DimPlot(pbmc, reduction = "umap", label = TRUE)

# データ保存
saveRDS(pbmc, file = "pbmc_tutorial.rds")
# 保存したデータを後から読み込む場合
# pbmc <- readRDS("pbmc_tutorial.rds")

# ライブラリ読み込み
library(sleepwalk)

# 以下のコマンドを実行し、生成された"sleepwalk.html"をブラウザで開いてください。
sleepwalk(list(pbmc@reductions$pca@cell.embeddings[,1:2],
               pbmc@reductions$tsne@cell.embeddings,
               pbmc@reductions$umap@cell.embeddings),
          pbmc@reductions$pca@cell.embeddings,
          saveToFile="sleepwalk.html")

# クラスタ1に特異的な遺伝子の抽出
# min.pct: 2群のいずれかで、この割合以上の細胞数が発現している遺伝子のみを対象とする
cluster1.markers <- FindMarkers(pbmc, ident.1 = 1, min.pct = 0.25)
head(cluster1.markers, n = 5)

# 利用できる発現変動解析法は複数ある。詳細：https://satijalab.org/seurat/v3.0/de_vignette.html
# cluster1.markers <- FindMarkers(pbmc, ident.1 = 0, logfc.threshold = 0.25, test.use = "roc", only.pos = TRUE)

# find all markers distinguishing cluster 5 from clusters 0 and 3
cluster5.markers <- FindMarkers(pbmc, ident.1 = 5, ident.2 = c(0, 3), min.pct = 0.25)
head(cluster5.markers, n = 5)

pbmc.markers <- FindAllMarkers(pbmc, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
pbmc.markers %>% group_by(cluster) %>% top_n(n = 2, wt = avg_logFC)

# violin plot (正規化後発現量)
VlnPlot(pbmc, features = c("MS4A1", "CD79A"))

# raw counts (正規化前UMI数)
VlnPlot(pbmc, features = c("NKG7", "PF4"), slot = "counts", log = TRUE)

# UMAP (tSNE) プロット上で発現量を可視化
FeaturePlot(pbmc, features = c("MS4A1", "GNLY", "CD3E", "CD14", "FCER1A", "FCGR3A", "LYZ", "PPBP", "CD8A"))

# Heatmap形式での可視化
top10 <- pbmc.markers %>% group_by(cluster) %>% top_n(n = 10, wt = avg_logFC)
DoHeatmap(pbmc, features = top10$gene) + NoLegend()

new.cluster.ids <- c("Naive CD4 T", "Memory CD4 T", "CD14+ Mono", "B", "CD8 T", "FCGR3A+ Mono", "NK", "DC", "Platelet")
names(new.cluster.ids) <- levels(pbmc)
pbmc <- RenameIdents(pbmc, new.cluster.ids)
DimPlot(pbmc, reduction = "umap", label = TRUE, pt.size = 0.5) + NoLegend()

# データ保存
saveRDS(pbmc, file = "pbmc3k_final.rds")
