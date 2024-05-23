#
# Bash script for separating bias corrected data into single years
#
# Usage: bash split-by-year.sh {full/path/to/file1.nc ... full/path/to/fileN.nc }
#
# Example path:
# /g/data/wp00/data/QQ-CMIP6/ACCESS-ESM1-5/ssp245/r6i1p1f1/day/rsds/rsds_day_ACCESS-ESM1-5_ssp245_r6i1p1f1_AUS-r005_20350101-20641231_qdm-additive-monthly-q100-nearest_ERA5-19850101-20141231_historical-19850101-20141231.nc


for infile in "$@"; do
    echo ${infile}
    date_label=`basename ${infile} | cut -d _ -f 7`
    start_date=`echo ${date_label} | rev | cut -d - -f 2 | rev`
    end_date=`echo ${date_label} | rev | cut -d - -f 1 | rev`
    start=`echo ${start_date:0:4}`
    end=`echo ${end_date:0:4}`
    years=($(seq ${start} 1 ${end}))
    for year in "${years[@]}"; do
        outfile=`echo ${infile} | sed s:${start}0101-${end}1231:${year}0101-${year}1231:g`
        outdir=`dirname ${outfile}`
        mkdir -p ${outdir}
        qsub -v year=${year},infile=${infile},outfile=${outfile} /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/split-by-year-job.sh
    done
done


