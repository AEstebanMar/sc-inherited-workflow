#! /usr/bin/env bash


source ~soft_bio_267/initializes/init_autoflow
project_dir=`pwd`
autoflow_dir=$project_dir/AutoFlow
results_dir=$project_dir/results
config_file=$project_dir/config_daemon
ref_dir=`grep refDir $config_file | cut -f 2 -d " "`
aux_opt="none" ### Will be handled by daemon flags in the future
constraint="cal" ### Will be handled by daemon flags in the future

if [ "$1" == "count" ] ; then # STAGE 1 OBTAINING COUNTS FROM FASTQ FILES
    TEMPLATE=$autoflow_dir/count_template.af
    RESULTS_FOLDER=$results_dir/counts
elif [ "$1" == "qc" ] ; then # STAGE 2 QUALITY CONTROL AND TRIMMING
    TEMPLATE=$autoflow_dir/QC_template.af
    RESULTS_FOLDER=$results_dir/QC
elif [ "$1" == "preproc" ] ; then # STAGE 3a PREPROCESSING  
    TEMPLATE=$autoflow_dir/preprocessing_template.af
    RESULTS_FOLDER=$results_dir/preprocessing
fi

mkdir -p $RESULTS_FOLDER

if [ "$1" == "preproc" ] && [ "$integrative_analysis" == "TRUE" ] ; then
    Rscript prior_integration.R --exp_design $exp_design \
                                --output $RESULTS_FOLDER \
                                --condition $subset_column \
                                --integration_file $integration_file \
                                --experiment_name $experiment_name
    export SAMPLES_FILE=$integration_file
fi

export PATH=$LAB_SCRIPTS:$PATH

experiment_name=`grep experiment_name $config_file | cut -f 2 -d " "`
preproc_filter=`grep preproc_filter $config_file | cut -f 2 -d " "`
preproc_init_min_cells=`grep preproc_init_min_cells $config_file | cut -f 2 -d " "`
preproc_init_min_feats=`grep preproc_init_min_feats $config_file | cut -f 2 -d " "`
preproc_qc_min_feats=`grep preproc_qc_min_feats $config_file | cut -f 2 -d " "`
preproc_max_percent_mt=`grep preproc_max_percent_mt $config_file | cut -f 2 -d " "`
preproc_norm_method=`grep preproc_norm_method $config_file | cut -f 2 -d " "`
preproc_scale_factor=`grep preproc_scale_factor $config_file | cut -f 2 -d " "`
preproc_select_hvgs=`grep preproc_select_hvgs $config_file | cut -f 2 -d " "`
preproc_pca_n_dims=`grep preproc_pca_n_dims $config_file | cut -f 2 -d " "`
preproc_resolution=`grep preproc_resolution $config_file | cut -f 2 -d " "`
preproc_pca_n_cells=`grep preproc_pca_n_cells $config_file | cut -f 2 -d " "`
integrative_analysis=`grep integrative_analysis $config_file | cut -f 2 -d " "`
subset_column=`grep subset_column $config_file | cut -f 2 -d " "`
integration_file=$project_dir/results/`grep integration_file $config_file | cut -f 2 -d " "`

while IFS= read sample; do
    total_fastq_files=$(ls $project_dir/raw_data -1 | grep -c $sample)
    number_of_lanes=$((total_fastq_files / 2))
    for (( i=1; i <= $number_of_lanes; i++ )) ; do
        variables=`echo "
        \\$sample=$sample,
        \\$lane_num=$i,
        \\$count_transcriptome=$ref_dir,
        \\$read_path=$project_dir/raw_data,
        \\$project_dir=$project_dir,
        \\$preproc_filter=$preproc_filter,
        \\$preproc_init_min_cells=$preproc_init_min_cells,
        \\$preproc_init_min_feats=$preproc_init_min_feats,
        \\$preproc_qc_min_feats=$preproc_qc_min_feats,
        \\$preproc_max_percent_mt=$preproc_max_percent_mt,
        \\$preproc_norm_method=$preproc_norm_method,
        \\$preproc_scale_factor=$preproc_scale_factor,
        \\$preproc_select_hvgs=$preproc_select_hvgs,
        \\$preproc_pca_n_dims=$preproc_pca_n_dims,
        \\$preproc_resolution=$preproc_resolution,
        \\$preproc_pca_n_cells=$preproc_pca_n_cells,
        \\$integrative_analysis=$integrative_analysis,
        \\$subset_column=$subset_column,
        \\$integration_file=$integration_file,
        \\$experiment_name=$experiment_name
        " | tr -d [:space:]`
        AutoFlow -w $TEMPLATE -V $variables -o $RESULTS_FOLDER/$sample -L $aux_opt -e -n $constraint -t 00-00:59:59
    done
    S_NUMBER=$(( S_NUMBER + 1 ))
done < $project_dir/samples_to_process