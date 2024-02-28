#!/bin/bash
#PBS -P wp00
#PBS -q hugemem
#PBS -l walltime=30:00:00
#PBS -l mem=350GB
#PBS -l storage=gdata/xv83+gdata/ia39+gdata/ob53
#PBS -l wd
#PBS -v var,obs,rcm,gcm

command="bash bias_correct_timeseries.sh ${var} ${obs} ${rcm} ${gcm}"
echo ${command}
${command}
