#!/bin/bash
#PBS -P xv83
#PBS -q normal
#PBS -l walltime=2:00:00
#PBS -l mem=10GB
#PBS -l storage=gdata/wp00
#PBS -l wd
#PBS -l ncpus=5
#PBS -v year,infile,outfile

module load cdo
command="cdo -z zip_5 -seldate,${year}-01-01,${year}-12-31 ${infile} ${outfile}"
echo ${command}
${command}
