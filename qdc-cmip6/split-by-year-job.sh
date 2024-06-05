#!/bin/bash
#PBS -P xv83
#PBS -q normal
#PBS -l walltime=2:00:00
#PBS -l mem=10GB
#PBS -l storage=gdata/ia39+gdata/xv83
#PBS -l wd
#PBS -l ncpus=5
#PBS -v infile

command="bash /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/split-by-year.sh ${infile}"
echo ${command}
${command}
