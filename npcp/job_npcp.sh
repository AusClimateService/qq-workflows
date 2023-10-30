#!/bin/bash
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=10:00:00
#PBS -l mem=40GB
#PBS -l storage=gdata/ia39+gdata/xv83+gdata/wp00
#PBS -l wd
#PBS -v method,var,task,rcm,gcm,nquantiles,interp

command="make validation -f /home/599/dbi599/qq-workflows/Makefile CONFIG=config_npcp_${method}.mk VAR=${var} TASK=${task} RCM_NAME=${rcm} GCM_NAME=${gcm} NQUANTILES=${nquantiles} INTERP=${interp}"
echo ${command}
${command}
