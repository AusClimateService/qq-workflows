#
# Bash script for separating bias corrected data into single years
#
# Usage: bash split-by-year.sh {full/path/to/file1.nc ... full/path/to/fileN.nc }
#

#module load cdo
#module load nco

for infile in "$@"; do
    echo ${infile}
    experiment=`basename ${infile} | cut -d _ -f 4`
    var_adjust=`basename ${infile} | cut -d _ -f 1`
    var=`echo ${var_adjust:0:-6}`
    dates=`basename ${infile} | cut -d _ -f 9`
    start=`echo ${dates:0:4}`
    end=`echo ${dates:9:4}`
    years=($(seq ${start} 1 ${end}))
    for year in "${years[@]}"; do
        #outfile=`echo ${infile} | sed s:xv83/dbi599:ia39:g | sed s:${start}:${year}:g | sed s:${end}:${year}:g`
        outfile=`echo ${infile} | sed s:${start}0101:${year}0101:g | sed s:${end}1231:${year}1231:g`
#        if [ ${year} -lt 2015 ]; then
#           outfile=`echo ${outfile} | sed s:${experiment}:historical:g`
#        fi
        outdir=`dirname ${outfile}`
        mkdir -p ${outdir}
        qsub -v year=${year},var=${var},infile=${infile},outfile=${outfile} split-by-year-job.sh
        #cdo -z zip_5 -seldate,${year}-01-01,${year}-12-31 ${infile} ${outfile}
        #ncatted -O -a missing_value,${var},d,, ${outfile}
        #ncatted -O -a _FillValue,${var},d,, ${outfile}
    done
done

