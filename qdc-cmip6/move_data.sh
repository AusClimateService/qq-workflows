#
# Bash script for moving QDC-CMIP6 data to the release directory
# after quality checking
#
# Usage: bash move_data.sh {files to move}
#
# Example input files: 
#  /g/data/ia39/australian-climate-service/test-data/QDC-CMIP6-v2/BARRA-R2/CESM2/ssp245/r11i1p1f1/day/rsds/2070-2099/
#rsds_day_CESM2_ssp245_r11i1p1f1_AUS-11_2099_qdc-multiplicative-monthly-q100-linear-rsdscs-clipped_BARRA-R2-baseline-1985-2014_model-baseline-1985-2014.nc
#  /g/data/ia39/australian-climate-service/release/QDC-CMIP6/BARRA-R2/CESM2/ssp245/r11i1p1f1/day/rsds/AUS-11/2070-2099/v20241025/
#rsds_day_CESM2_ssp245_r11i1p1f1_AUS-11_2099_qdc-multiplicative-monthly-q100-linear-rsdscs-clipped_BARRA-R2-baseline-1985-2014_model-baseline-1985-2014.nc
#

module load nco

for inpath in "$@"; do
    echo ${inpath}
    # Define variables
    base=`basename ${inpath}`
    var=`echo ${base} | cut -d '_' -f 1`
    grid=`echo ${base} | cut -d '_' -f 6`
    year=`echo ${base} | cut -d '_' -f 7`
    time=`echo ${inpath} | cut -d '/' -f 14`
    if [[ "${year}" == "2064" ]] && [[ "${time}" == "2035-2064" ]] ; then
        end_day=30
    else
        end_day=31
    fi
    outpath=`echo ${inpath} | sed s:test-data:release:g`
    outpath=`echo ${outpath} | sed s:QDC-CMIP6-v2:QDC-CMIP6:g`
    outpath=`echo ${outpath} | sed s:${time}:${grid}/${time}/v20241025:g`
    outdir=`dirname ${outpath}`
    # Update file attributes
    ncatted -O -h -a creator_url,global,c,c,"https://www.acs.gov.au/" ${inpath}
    ncatted -O -h -a project,global,c,c,"QDC-CMIP6" ${inpath}
    ncatted -O -h -a time_coverage_start,c,c,"${year}0101T0000Z" ${inpath}
    ncatted -O -h -a time_coverage_end,c,c,"${year}12${end_day}T0000Z" ${inpath}
    ncatted -O -h -a time_coverage_duration,c,c,"P1Y0M0DT0H0M0S" ${inpath}
    ncatted -O -h -a processing_level,global,o,c,"Level 2: Quality assurance and quality control undertaken." ${inpath}
    if [[ "${var}" == "pr" ]] ; then
        ncatted -O -h -a standard_name,pr,o,c,"lwe_precipitation_rate" ${inpath}
        ncatted -O -h -a summary,global,a,c," The AGCD precipitation for the previous 24 hours is recorded at 9am local clock time and then recorded against the observed day's date." ${inpath}
    elif [[ "${var}" == "tasmin" ]] ; then
        ncatted -O -h -a summary,global,a,c," The AGCD minimum temperature for the previous 24 hours is recorded at 9am local clock time and then recorded against the observed day's date." ${inpath}
    elif [[ "${var}" == "tasmax" ]] ; then
        ncatted -O -h -a summary,global,a,c," The AGCD maximum temperature for the previous 24 hours is recorded at 9am local clock time and then recorded against the previous day's date." ${inpath}
    fi
    # Move file
    mkdir -p ${outdir}
    mv ${inpath} ${outpath}
done
