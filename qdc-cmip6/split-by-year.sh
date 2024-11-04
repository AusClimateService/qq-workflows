#
# Bash script for separating bias corrected data into single years
#
# Usage: bash split-by-year.sh {full/path/to/file1.nc ... full/path/to/fileN.nc }
#
# Example path:
# /g/data/wp00/data/QQ-CMIP6/ACCESS-ESM1-5/ssp245/r6i1p1f1/day/rsds/2035-2064/rsds_day_ACCESS-ESM1-5_ssp245_r6i1p1f1_AUS-r005_2035-2064_qdm-additive-monthly-q100-nearest_ERA5-1985-2014_historical-1985-2014.nc


module load cdo
module load nco

for infile in "$@"; do
    echo ${infile}
    date_label=`basename ${infile} | cut -d _ -f 7`
    start_year=`echo ${date_label} | rev | cut -d - -f 2 | rev`
    end_year=`echo ${date_label} | rev | cut -d - -f 1 | rev`
    years=($(seq ${start_year} 1 ${end_year}))
    for year in "${years[@]}"; do
        outfile=`echo ${infile} | sed s:${start_year}-${end_year}_:${year}_:g`
        command="cdo -z zip_5 -seldate,${year}-01-01,${year}-12-31 ${infile} ${outfile}"
        echo ${command}
        ${command}
        ncatted -O -h -a time_coverage_start,c,c,"${year}0101T0000Z" ${outfile}
        if [[ "${year}" == "2064" ]] && [[ "${start_year}-${end_year}" == "2035-2064" ]] ; then
            end_day=30
        else
            end_day=31
        fi
        ncatted -O -h -a time_coverage_end,c,c,"${year}12${end_day}T0000Z" ${outfile}
        ncatted -O -h -a time_coverage_duration,c,c,"P1Y0M0DT0H0M0S" ${outfile}
    done
done

