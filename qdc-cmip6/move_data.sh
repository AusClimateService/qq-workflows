

for inpath in "$@"; do
    echo ${inpath}
    grid=`echo ${inpath} | cut -d '_' -f 6`
    time=`echo ${inpath} | cut -d '/' -f 14`

    outpath=`echo ${inpath} | sed s:test-data:release:g`
    outpath=`echo ${outpath} | sed s:QDC-CMIP6-v2:QDC-CMIP6:g`
    outpath=`echo ${outpath} | sed s:${time}:${grid}/${time}/v20241025:g`
    echo ${outpath}
#    outdir=`dirname ${outpath}`
#    mkdir -p ${outdir}
#    mv ${inpath} ${outpath}
done


#/g/data/ia39/australian-climate-service/test-data/QDC-CMIP6-v2/BARRA-R2/CESM2/ssp245/r11i1p1f1/day/rsds/2070-2099/
#rsds_day_CESM2_ssp245_r11i1p1f1_AUS-11_2099_qdc-multiplicative-monthly-q100-linear-rsdscs-clipped_BARRA-R2-baseline-1985-2014_model-baseline-1985-2014.nc

#/g/data/ia39/australian-climate-service/release/QDC-CMIP6/BARRA-R2/CESM2/ssp245/r11i1p1f1/day/rsds/AUS-11/2070-2099/v20241025/
#rsds_day_CESM2_ssp245_r11i1p1f1_AUS-11_2099_qdc-multiplicative-monthly-q100-linear-rsdscs-clipped_BARRA-R2-baseline-1985-2014_model-baseline-1985-2014.nc
