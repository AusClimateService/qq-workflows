#!/bin/bash
#PBS -P xv83
#PBS -q normal
#PBS -l walltime=40:00:00
#PBS -l mem=60GB
#PBS -l storage=gdata/xv83+gdata/ia39
#PBS -l wd
#PBS -v var

# Example: qsub -v var=sfcWind regrid_to_agcd_job.sh 

bash /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/regrid_to_agcd.sh /g/data/ia39/australian-climate-service/release/QDC-CMIP6/BARRA-R2/*/ssp*/*/day/${var}/AUS-11/*/v20241104/*.nc



