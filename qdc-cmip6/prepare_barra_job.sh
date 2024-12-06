#!/bin/bash
#PBS -P xv83
#PBS -q normal
#PBS -l walltime=05:00:00
#PBS -l mem=50GB
#PBS -l storage=gdata/xv83+gdata/ia39+gdata/ob53
#PBS -l wd
#PBS -v var

# Example: qsub -v var=sfcWind prepare_barra_job.sh 

bash /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/prepare_barra.sh ${var}



