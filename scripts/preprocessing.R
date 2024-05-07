#! /usr/bin/env Rscript


library(optparse)
library(Seurat)
library(scCustomize)

option_list <- list(
  optparse::make_option(c("-i", "--input"), type = "character",
              help="Input folder with 10X data"),
  optparse::make_option(c("-o", "--output"), type = "character",
              help="Output folder"),
  optparse::make_option(c("-n", "--name"), type = "character",
              help="Sample name"),
  optparse::make_option(c("--filter"), type = "character",
              help="TRUE for using only detected cell-associated barcodes, FALSE for using all detected barcodes"),
  optparse::make_option(c("--mincells"), type = "integer",
              help="Min number of cells for which a feature was recorded"),
  optparse::make_option(c("--minfeats"), type = "integer",
              help="Min number of features for which a cell was recorded"),
  optparse::make_option(c("--minqcfeats"), type = "integer",
              help="Min number of features for which a cell was selected in QC"),
  optparse::make_option(c("--percentmt"), type = "integer",
              help="Max percentage of reads mapped to mitochondrial genes for which a cell is recorded"),
  optparse::make_option(c("--normalmethod"), type = "character",
              help="Method for normalization. LogNormalize, CLR or RC"),
  optparse::make_option(c("--scalefactor"), type = "integer",
              help="Scale factor for cell-level normalization"),
  optparse::make_option(c("--hvgs"), type = "integer",
              help="Number of HVG to be selected"),
  optparse::make_option(c("--ndims"), type = "integer",
              help="Number of PC to be used for clustering / UMAP / tSNE"),
  optparse::make_option(c("--dimheatmapcells"), type = "integer",
              help="Heatmap plots the 'extreme' cells on both ends of the spectrum"),
  optparse::make_option(c("--report_folder"), type = "character",
              help="Folder where the report is written"),
  optparse::make_option(c("--experiment_name"), type = "character",
              help="Experiment name"),
  optparse::make_option(c("--resolution"), type = "double",
              help="Granularity of the clustering"),
  optparse::make_option(c("--integrate"), type = "character",
              help="TRUE if integrative analysis, FALSE otherwise"),
  optparse::make_option(c("-l", "--preprocessing_library"), type = "character",
              help="Path to preprocessing library")
)  


opt <- optparse::parse_args(optparse::OptionParser(option_list = option_list))

source(opt$preprocessing_library)


############
### Main ###
############

main_preprocessing_analysis(name = opt$name,
                            experiment = opt$experiment_name,
                            input = opt$input,
                            output = opt$output,
                            filter = opt$filter,
                            mincells = opt$mincells,
                            minfeats = opt$minfeats,
                            minqcfeats = opt$minqcfeats,
                            percentmt = opt$percentmt,
                            normalmethod = opt$normalmethod,
                            scalefactor = opt$scalefactor,
                            hvgs = opt$hvgs,
                            ndims = opt$ndims,
                            resolution = opt$resolution,
                            integrate = as.logical(opt$integrate))

write_preprocessing_report(name = opt$name,
                           experiment = opt$experiment_name,
                           template = file.path(root_path, 
                                                "templates",
                                                "preprocessing_report.Rmd"),
                           outdir = opt$report_folder,
                           intermediate_files = "int_files",
                           minqcfeats = opt$minqcfeats,
                           percentmt = opt$percentmt,
                           hvgs = opt$hvgs,
                           resolution = opt$resolution)