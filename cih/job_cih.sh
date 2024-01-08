#!/bin/bash
#PBS -P xv83
#PBS -q hugemem
#PBS -l walltime=10:00:00
#PBS -l mem=250GB
#PBS -l storage=gdata/xv83+gdata/wp00+gdata/oi10+gdata/fs38+gdata/dk7+gdata/ia39
#PBS -l wd
#PBS -v var,model,experiment,start,end

command="make validation -f /home/599/dbi599/qq-workflows/Makefile CONFIG=config_cih.mk VAR=${var} MODEL=${model} EXPERIMENT=${experiment} REF_START=${start} REF_END=${end}"
echo ${command}
${command}
