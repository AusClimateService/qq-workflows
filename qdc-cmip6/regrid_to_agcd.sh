#
# Bash script for regridding to the AGCD grid
#
# Usage: bash regrid_to_agcd.sh {files to regrid}
#
# Example input file: /g/data/ia39/australian-climate-service/release/QDC-CMIP6/BARRA-R2/ACCESS-CM2/ssp370/r4i1p1f1/day/pr/AUS-11/gwl15/v20241104/pr_day_ACCESS-CM2_ssp370_r4i1p1f1_AUS-11_gwl15-2037_qdc-multiplicative-monthly-q100-linear-maxaf5-annual-change-matched_BARRA-R2-baseline-gwl10-2001-2020_model-baseline-gwl10-2003-2022.nc
#

python=/g/data/xv83/quantile-mapping/miniconda3/envs/qq-workflows/bin/python

for inpath in "$@"; do
    echo ${inpath}
    base=`basename ${inpath}`
    var=`echo ${base} | cut -d '_' -f 1`
    outpath=`echo ${inpath} | sed s:AUS-11:AUS-05i:g`
    outdir=`dirname ${outpath}`
    mkdir -p ${outdir}
    ${python} /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/regrid_to_agcd.py ${inpath} ${var} ${outpath} 
    echo ${outpath}
done
