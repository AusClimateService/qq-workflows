#!/bin/bash
#PBS -P wp00
#PBS -q normal
#PBS -l walltime=2:00:00
#PBS -l mem=10GB
#PBS -l storage=gdata/xv83+gdata/ia39
#PBS -l wd
#PBS -l ncpus=5
#PBS -v year,infile,outfile

module load cdo
command="cdo seldate,${year}-01-01,${year}-12-31 ${infile} ${outfile}"
echo ${command}
${command}
