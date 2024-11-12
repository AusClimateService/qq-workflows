#
# Bash script for fixing the metadata
#
# Usage: bash fix_data.sh {files to fix}
#
# Example input file: /g/data/ia39/australian-climate-service/release/QDC-CMIP6/BARRA-R2/CESM2/ssp245/r11i1p1f1/day/rsds/AUS-11/2070-2099/v20241025/rsds_day_CESM2_ssp245_r11i1p1f1_AUS-11_2099_qdc-multiplicative-monthly-q100-linear-rsdscs-clipped_BARRA-R2-baseline-1985-2014_model-baseline-1985-2014.nc
#

module load nco

for inpath in "$@"; do
    echo ${inpath}
    obs=`echo ${inpath} | cut -d '/' -f 8`
    model=`echo ${inpath} | cut -d '/' -f 9`
    var=`echo ${inpath} | cut -d '/' -f 13`
    tbounds=`echo ${inpath} | cut -d '/' -f 15`
    ncatted -O -h -a coordinates,${var},d,, ${inpath}
    ncks -O -h -x -v height ${inpath} ${inpath}
    #ncatted -O -h -a summary,global,o,c,"The data have been created by applying climate changes simulated between 1985-2014 and ${tbounds} by the ${model} CMIP6 global climate model to ${obs} data for 1985-2014 using the Quantile Delta Change (QDC) scaling method." ${inpath}
done
