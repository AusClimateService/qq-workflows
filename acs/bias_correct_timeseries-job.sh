#!/bin/bash
#PBS -P xv83
#PBS -q hugemem
#PBS -l walltime=40:00:00
#PBS -l mem=200GB
#PBS -l storage=gdata/xv83+gdata/ia39
#PBS -l wd
#PBS -v var,rcm,gcm

command="bash bias_correct_timeseries.sh ${var} ${rcm} ${gcm}"
echo ${command}
${command}
