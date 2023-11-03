#!/bin/bash
#PBS -P wp00
#PBS -q hugemem
#PBS -l walltime=30:00:00
#PBS -l mem=220GB
#PBS -l storage=gdata/xv83+gdata/ia39
#PBS -l wd
#PBS -v var,rcm,gcm

command="bash bias_correct_timeseries.sh ${var} ${rcm} ${gcm}"
echo ${command}
${command}
