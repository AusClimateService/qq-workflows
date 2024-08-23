#!/bin/bash
#PBS -P xv83
#PBS -q hugemem
#PBS -l walltime=5:00:00
#PBS -l mem=400GB
#PBS -l storage=gdata/xv83+gdata/ob53+gdata/fs38+gdata/ia39+gdata/oi10
#PBS -l wd
#PBS -v model

# To run: qsub -v model=ACCESS-CM2 job_model_bias.sh

/g/data/xv83/dbi599/miniconda3/envs/qqscale/bin/papermill model_bias.ipynb model_bias_${model}.ipynb -p model ${model}
