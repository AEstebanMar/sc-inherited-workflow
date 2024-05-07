#! /usr/bin/env bash

# Sergio Alias, 20230530
# Last modified 20230721

# STAGE 2 SAMPLES COMPARISON

#SBATCH -J compare_samples.sh
#SBATCH --cpus-per-task=3
#SBATCH --mem='5gb'
#SBATCH --constraint=cal
#SBATCH --time=0-01:00:00
#SBATCH --error=job.comp.%J.err
#SBATCH --output=job.comp.%J.out

# Setup

hostname

project_dir=`pwd`
experiment_name=`grep experiment_name $project_dir/config_daemon | cut -f 2 -d " "`
report_folder=$project_dir/report
mkdir -p $report_folder

## TODO fix code below

while IFS= read -r name; do
  if [ -d "$project_dir/results/counts/$name" ]; then
    input_file="$project_dir/results/counts/$name/cellranger_0000/$name/outs/metrics_summary.csv"
    cat $input_file | perl -pe 's/(\d),(\d)/$1$2/g'| sed '1 s/ /_/g' | sed 's/%//g' | sed 's/"//g' | sed 's/ /\n/g' | sed 's/,/\t/g' | awk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' | awk -v var="$name" 'BEGIN {FS=OFS="\t"} {print var, $0}' | sed 's/ /\t/g' >> $project_dir'/cellranger_metrics'
  fi
done < $project_dir/samples_to_process


. ~soft_bio_267/initializes/init_ruby
. ~soft_bio_267/initializes/init_R
create_metric_table.rb $project_dir'/metrics' sample $project_dir'/metric_table'
create_metric_table.rb $project_dir'/cellranger_metrics' sample $project_dir'/cellranger_metric_table'

# Main

/usr/bin/time $project_dir/scripts/compare_samples.R -o $report_folder \
                                                   -m $project_dir'/metric_table' \
                                                   -l $project_dir'/metrics' \
                                                   -e $experiment_name \
                                                   --cellranger_metrics $project_dir'/cellranger_metric_table' \
                                                   --cellranger_long_metrics $project_dir'/cellranger_metrics' \
                                                   --template $project_dir/templates/fastqc_report.Rmd