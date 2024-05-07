#! /usr/bin/env bash

# Sergio Alias, 20230711
# Last modified 20230717

# STAGE 2 QUALIMAP

#SBATCH -J qualimap.sh
#SBATCH --cpus-per-task=10
#SBATCH --mem='60gb'
#SBATCH --constraint=cal
#SBATCH --time=3-00:00:00
#SBATCH --error=job.qmap.%J.err
#SBATCH --output=job.qmap.%J.out

# Setup

hostname

source ~soft_bio_267/initializes/init_qualimap
project_dir=`pwd`
mkdir -p $project_dir/report
mkdir -p $project_dir/QMAP_RESULTS

cd $project_dir/QMAP_RESULTS

rm $project_dir/QMAP_RESULTS"/qualimap_input_data"
touch $project_dir/QMAP_RESULTS"/qualimap_input_data"

while IFS= read -r name; do
  if [ -d "$project_dir/results/counts/$name" ]; then
    echo -e "$name\t$project_dir/results/counts/$name/cellranger_0000/$name/outs/possorted_genome_bam.bam" >> $project_dir/QMAP_RESULTS"/qualimap_input_data"
  fi
done < $project_dir/samples_to_process

unset DISPLAY

# Main

/usr/bin/time qualimap multi-bamqc --run-bamqc \
                                   -d $project_dir/QMAP_RESULTS/qualimap_input_data \
                                   -outdir $project_dir/QMAP_RESULTS
 
