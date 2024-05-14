#!/bin/bash
#PBS -P xv83
#PBS -q hugemem
#PBS -l walltime=20:00:00
#PBS -l mem=350GB
#PBS -l storage=gdata/xv83+gdata/wp00+gdata/oi10+gdata/fs38+gdata/dk7+gdata/ia39+gdata/ob53
#PBS -l wd
#PBS -v target,var,obs,model,experiment,start,end

command="make ${target} -B -f /home/599/dbi599/qq-workflows/Makefile CONFIG=config_qdc-cmip6.mk VAR=${var} OBS_DATASET=${obs} MODEL=${model} EXPERIMENT=${experiment} REF_START=${start} REF_END=${end}"
echo ${command}
${command}
