#!/bin/bash
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=10:00:00
#PBS -l mem=40GB
#PBS -l storage=gdata/ia39+gdata/xv83+gdata/wp00
#PBS -l wd
#PBS -v method,var,task,rcm,gcm

command="make validation -f /g/data/xv83/quantile-mapping/qq-workflows/Makefile CONFIG=config_npcp_${method}.mk VAR=${var} TASK=${task} RCM_NAME=${rcm} GCM_NAME=${gcm}"
echo ${command}
${command}
