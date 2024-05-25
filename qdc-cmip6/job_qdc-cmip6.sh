#!/bin/bash
#PBS -P xv83
#PBS -q hugemem
#PBS -l walltime=20:00:00
#PBS -l mem=400GB
#PBS -l storage=gdata/xv83+gdata/wp00+gdata/oi10+gdata/fs38+gdata/dk7+gdata/ia39+gdata/ob53+gdata/hd50+scratch/hd50
#PBS -l wd
#PBS -v target,var,obs,model,experiment,run,hist_start,hist_end,ref_start,ref_end,target_start,target_end,base_gwl,ref_gwl

command="make ${target} -f /g/data/xv83/quantile-mapping/qq-workflows/Makefile CONFIG=config_qdc-cmip6.mk VAR=${var} OBS_DATASET=${obs} MODEL=${model} EXPERIMENT=${experiment} RUN=${run} HIST_START=${hist_start} HIST_END=${hist_end} REF_START=${ref_start} REF_END=${ref_end} TARGET_START=${target_start} TARGET_END=${target_end} BASE_GWL=${base_gwl} REF_GWL=${ref_gwl}"
echo ${command}
${command}
