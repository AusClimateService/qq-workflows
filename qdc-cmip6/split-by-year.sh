#
# Bash script for separating bias corrected data into single years
#
# Usage: bash split-by-year.sh {full/path/to/file1.nc ... full/path/to/fileN.nc }
#
# Example path:
# /g/data/wp00/data/QQ-CMIP6/ACCESS-ESM1-5/ssp245/r6i1p1f1/day/rsds/rsds_day_ACCESS-ESM1-5_ssp245_r6i1p1f1_AUS-r005_2035-2064_qdm-additive-monthly-q100-nearest_ERA5-1985-2014_historical-1985-2014.nc


for infile in "$@"; do
    echo ${infile}
    date_label=`basename ${infile} | cut -d _ -f 7`
    start_year=`echo ${date_label} | rev | cut -d - -f 2 | rev`
    end_year=`echo ${date_label} | rev | cut -d - -f 1 | rev`
    years=($(seq ${start_year} 1 ${end_year}))
    for year in "${years[@]}"; do
        outfile=`echo ${infile} | sed s:${start_year}-${end_year}:${year}:g`
        outdir=`dirname ${outfile}`
        mkdir -p ${outdir}
        qsub -v year=${year},infile=${infile},outfile=${outfile} /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/split-by-year-job.sh
    done
done


