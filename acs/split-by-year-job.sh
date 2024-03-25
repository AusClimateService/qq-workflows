#!/bin/bash
#PBS -P xv83
#PBS -q normal
#PBS -l walltime=2:00:00
#PBS -l mem=10GB
#PBS -l storage=gdata/xv83+gdata/ia39
#PBS -l wd
#PBS -l ncpus=5
#PBS -v year,var,infile,outfile

module load cdo
module load nco
command="cdo -z zip_5 -seldate,${year}-01-01,${year}-12-31 ${infile} ${outfile}"
echo ${command}
${command}
ncatted -O -a missing_value,${var},d,, ${outfile}
ncatted -O -a _FillValue,${var},d,, ${outfile}
