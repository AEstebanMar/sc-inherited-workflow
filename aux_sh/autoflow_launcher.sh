#! /usr/bin/env bash


source ~soft_bio_267/initializes/init_autoflow
project_dir=`pwd`
autoflow_dir=$project_dir/AutoFlow
results_dir=$project_dir/results

if [ "$1" == "count" ] ; then # STAGE 1 OBTAINING COUNTS FROM FASTQ FILES
    TEMPLATE=$autoflow_dir/count_template.af
    RESULTS_FOLDER=$results_dir/counts
elif [ "$1" == "qc" ] ; then # STAGE 2 QUALITY CONTROL AND TRIMMING
    TEMPLATE=$autoflow_dir/QC_template.txt
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

PATH=$LAB_SCRIPTS:$PATH

while IFS= read sample; do
    total_fastq_files=$(ls $project_dir/raw_data -1 | grep -c $sample)
    number_of_lanes=$((total_fastq_files / 2))
    for (( i = 1; i <= $number_of_lanes; i++ )) ; do
        AF_VARS=`echo "
        \\$sample=$sample,
        \\$lane_num=$i
        " | tr -d [:space:]`
        AutoFlow -w $TEMPLATE -V "$AF_VARS" -o $RESULTS_FOLDER/$sample #$RESOURCES
    done
    S_NUMBER=$(( S_NUMBER + 1 ))
done < $project_dir/samples_to_process