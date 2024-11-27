#
# Bash script for preparing AGCD data for inclusion in the QDC-CMIP6 dataset
#
# Usage: bash prepare_agcd.sh <var>
#   var - can be tasmax tasmin or pr
# 

var=$1
if [[ "${var}" == "tasmax" ]] ; then
    agcd_path_start=/g/data/xv83/agcd-csiro/tmax/daily/tmax
elif [[ "${var}" == "tasmin" ]] ; then
    agcd_path_start=/g/data/xv83/agcd-csiro/tmax/daily/tmin
elif [[ "${var}" == "pr" ]] ; then
    agcd_path_start=/g/data/xv83/agcd-csiro/precip/daily/precip-total
fi

python=/g/data/xv83/quantile-mapping/miniconda3/envs/qq-workflows/bin/python
outdir=/g/data/ia39/australian-climate-service/release/QDC-CMIP6/AGCD/raw/historical/v-csiro/day/tasmax/AUS-05/1985-2020/v20241104
#mkdir -p ${outdir}
for year in {1985..2020}; do
    inpath=${agcd_path_start}_AGCD-CSIRO_r005_${year}0101-${year}1231_daily.nc
#    echo ${inpath}
    outpath=${outdir}/tasmax_day_AGCD_historical_v-csiro_AUS-05_${year}.nc
    echo ${python} /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/prepare_agcd.py ${inpath} ${var} ${outpath} 
#    echo ${outpath}
done
