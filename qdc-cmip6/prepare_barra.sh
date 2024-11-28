#
# Bash script for preparing BARRA-R2 data for inclusion in the QDC-CMIP6 dataset
#
# Usage: bash prepare_barra.sh <var>
#   var can be - tasmax tasmin pr rsds hurs hursmin hursmax sfcWind sfcWindmax
# 
# Example input files:
# /g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/pr/v20240809/pr_AUS-11_ERA5_historical_hres_BOM_BARRA-R2_v1_day_198109-198109.nc
# /g/data/ia39/australian-climate-service/test-data/observations/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/hursmax/v20240809/hursmax_AUS-11_ERA5_historical_hres_BOM_BARRA-R2_v1_day_202308-202308.nc
#

var=$1
if [[ "${var}" == "hursmin" ]] || [[ "${var}" == "hursmax" ]] ; then
    barra_path_start=/g/data/ia39/australian-climate-service/test-data/observations
else
    barra_path_start=/g/data/ob53
fi
indir=${barra_path_start}/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/${var}/v20240809

python=/g/data/xv83/quantile-mapping/miniconda3/envs/qq-workflows/bin/python
outdir_start=/g/data/ia39/australian-climate-service/release/QDC-CMIP6/BARRA-R2/raw/historical/v1/day/${var}
for grid in AUS-11 AUS-05i; do
    outdir=${outdir_start}/${grid}/1985-2020/v20241104
    mkdir -p ${outdir}
    for year in {1985..2020}; do
        outpath=${outdir}/${var}_day_BARRA-R2_historical_v1_${grid}_${year}.nc
        command="${python} /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/prepare_barra.py ${indir}/${var}_AUS-11_ERA5_historical_hres_BOM_BARRA-R2_v1_day_${year}??-${year}??.nc ${var} ${grid} ${outpath}"
        echo ${command}
        ${command}
    done
done
