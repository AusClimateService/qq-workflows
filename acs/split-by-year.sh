#
# Bash script for separating bias corrected data into single years
#
# Usage: bash split-by-year.sh {full/path/to/file1.nc ... full/path/to/fileN.nc }
#

for infile in "$@"; do
    experiment=`basename ${infile} | cut -d _ -f 4`
    dates=`basename ${infile} | cut -d _ -f 9`
    start=`echo ${dates:0:4}`
    end=`echo ${dates:9:4}`
    years=($(seq ${start} 1 ${end}))
    for year in "${years[@]}"; do
        outfile=`echo ${infile} | sed s:xv83/dbi599:ia39:g | sed s:${start}:${year}:g | sed s:${end}:${year}:g`
        if [ ${year} -lt 2015 ]; then
           outfile=`echo ${outfile} | sed s:${experiment}:historical:g`
        fi
        outdir=`dirname ${outfile}`
        mkdir -p ${outdir}
        qsub -v year=${year},infile=${infile},outfile=${outfile} split-by-year-job.sh
    done
done

