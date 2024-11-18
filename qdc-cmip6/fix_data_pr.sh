#
# Bash script for fixing the metadata
#
# Usage: bash fix_data.sh {files to fix}
#
# Example input file: /g/data/ia39/australian-climate-service/release/QDC-CMIP6/BARRA-R2/ACCESS-CM2/ssp370/r4i1p1f1/day/pr/AUS-11/gwl15/v20241104/pr_day_ACCESS-CM2_ssp370_r4i1p1f1_AUS-11_gwl15-2037_qdc-multiplicative-monthly-q100-linear-maxaf5-annual-change-matched_BARRA-R2-baseline-gwl10-2001-2020_model-baseline-gwl10-2003-2022.nc
#

module load nco

python=/g/data/xv83/quantile-mapping/miniconda3/envs/qq-workflows/bin/python

for inpath in "$@"; do
    echo ${inpath}
    obs=`echo ${inpath} | cut -d '/' -f 8`
    model=`echo ${inpath} | cut -d '/' -f 9`
    tbounds=`echo ${inpath} | cut -d '/' -f 15`
    if [[ "${tbounds:0:3}" == "gwl" ]] ; then
        summary=`${python} /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/trim_summary.py ${inpath}`
    else
        summary="The data have been created by applying climate changes simulated between 1985-2014 and ${tbounds} by the ${model} CMIP6 global climate model to ${obs} data for 1985-2014 using the Quantile Delta Change (QDC) scaling method."
    fi
    ncatted -O -h -a summary,global,o,c,"${summary}" ${inpath}
done
