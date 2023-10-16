#!/bin/bash
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=5:00:00
#PBS -l mem=20GB
#PBS -l storage=gdata/ia39+gdata/xv83+gdata/wp00
#PBS -l wd
#PBS -v var,task,rcm,gcm

command="make validation CONFIG=npcp/config_npcp.mk VAR=${var} TASK=${task} RCM_NAME=${rcm} GCM_NAME=${gcm}"
echo ${command}
${command}
