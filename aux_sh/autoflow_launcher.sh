# Sergio Alías, 20230516
# Last modified 20230614

# Generic Autoflow launcher

. ~soft_bio_267/initializes/init_autoflow


if [ "$1" == "count" ] ; then # STAGE 1 OBTAINING COUNTS FROM FASTQ FILES
    export RESULTS_FOLDER=$COUNT_RESULTS_FOLDER
    export TEMPLATE=$COUNT_TEMPLATE
elif [ "$1" == "qc" ] ; then # STAGE 2 QUALITY CONTROL AND TRIMMING
    export RESULTS_FOLDER=$QC_RESULTS_FOLDER
    export TEMPLATE=$QC_TEMPLATE
elif [ "$1" == "preproc" ] ; then # STAGE 3 PREPROCESSING
    export RESULTS_FOLDER=$PREPROC_RESULTS_FOLDER
    export TEMPLATE=$PREPROC_TEMPLATE
fi

mkdir -p $RESULTS_FOLDER

PATH=$LAB_SCRIPTS:$PATH

while IFS= read sample; do
    
    AF_VARS=`echo "
    \\$sample=$sample
    " | tr -d [:space:]`

    AutoFlow -w $TEMPLATE -V "$AF_VARS" -o $RESULTS_FOLDER/$sample #$RESOURCES

done < $SAMPLES_FILE