#!/bin/bash
#PBS -P xv83
#PBS -q normal
#PBS -l walltime=30:00:00
#PBS -l mem=40GB
#PBS -l storage=gdata/xv83+gdata/ob53+gdata/ia39
#PBS -l wd
#PBS -v var

# usage: qsub -v var=hursmin job_preprocess_hurs.sh

bash preprocess_hurs.sh ${var}
