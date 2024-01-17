#
# Bash script for separating bias corrected data into single years
#
# Usage: bash split-by-year.sh {full/path/to/file1.nc ... full/path/to/fileN.nc }
#
# Example path:
# /g/data/wp00/data/QQ-CMIP6/ACCESS-ESM1-5/ssp245/r6i1p1f1/day/rsds/rsds_day_ACCESS-ESM1-5_ssp245_r6i1p1f1_AUS-r005_20350101-20641231_qdm-additive-monthly-q100-nearest_ERA5-19850101-20141231_historical-19850101-20141231.nc


for infile in "$@"; do
    echo ${infile}
    dates=`basename ${infile} | cut -d _ -f 7`
    start=`echo ${dates:0:4}`
    end=`echo ${dates:9:4}`
    years=($(seq ${start} 1 ${end}))
    for year in "${years[@]}"; do
        outfile=`echo ${infile} | sed s:_${start}:_${year}:g | sed s:${end}:${year}:g`
        outdir=`dirname ${outfile}`
        mkdir -p ${outdir}
        qsub -v year=${year},infile=${infile},outfile=${outfile} /home/599/dbi599/qq-workflows/cihp13/split-by-year-job.sh
    done
done


