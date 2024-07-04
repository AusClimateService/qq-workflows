#!/bin/bash
#PBS -P wp00
#PBS -q hugemem
#PBS -l walltime=40:00:00
#PBS -l mem=450GB
#PBS -l storage=gdata/xv83+gdata/ia39+gdata/ob53+gdata/hq89
#PBS -l wd
#PBS -v var,obs,rcm,gcm,exp

command="bash bias_correct_timeseries.sh adjust ${var} ${obs} ${rcm} ${gcm} ${exp}"
echo ${command}
${command}
