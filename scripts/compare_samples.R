#! /usr/bin/env Rscript


source("~aestebanm/projects/sc-inherited-workflow/R/qc_library.R")

option_list <- list(
  optparse::make_option(c("-m", "--metrics"), type = "character",
    help="Metrics file in wide format"),
  optparse::make_option(c("-l", "--long_metrics"), type = "character",
    help="Metrics file in long format"),
  optparse::make_option(c("--cellranger_metrics"), type = "character",
    help="Cell Ranger metrics file in wide format"),
  optparse::make_option(c("--cellranger_long_metrics"), type = "character",
    help="Cell Ranger Metrics file in long format"),
  optparse::make_option(c("-o", "--output"), type = "character",
    help="Output folder"),
  optparse::make_option(c("-e", "--experiment_name"), type = "character",
    help="Experiment name"),
  optparse::make_option(c("-t", "--template"), type = "character",
    help="Template for report")
)  

opt <- optparse::parse_args(optparse::OptionParser(option_list = option_list))

write_qc_report(name = "All samples",
                experiment = opt$experiment_name,
                template = opt$template,
                outdir = opt$output,
                intermediate_files = "int_files",
                metrics = opt$metrics,
                long_metrics = opt$long_metrics,
                cellranger_metrics = opt$cellranger_metrics,
                cellranger_long_metrics = opt$cellranger_long_metrics)