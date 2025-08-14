#
# Bash script for pre-processing BARRA-R2 1hr hurs to daily hursmin and hursmax
#
# Usage: bash preprocess.sh {var} [flags]
#
#   var:    variable to process (hursmin, hursmax)
#   flags:  optional flags (e.g. -n for dry run)
#

var=$1
flags=$2
python=/g/data/xv83/quantile-mapping/miniconda3/envs/qq-workflows/bin/python

infiles=(`ls /g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/1hr/hurs/latest/hurs_AUS-11_ERA5_historical_hres_BOM_BARRA-R2_v1_1hr_2024??-2024??.nc`)
for infile in "${infiles[@]}"; do
    outfile=`echo ${infile} | sed s:/g/data/ob53:/g/data/ia39/australian-climate-service/test-data/observations:`
    outfile=`echo ${outfile} | sed s:1hr:day:g`
    outfile=`echo ${outfile} | sed s:hurs:${var}:g`
    outdir=`dirname ${outfile}`
  
    python_command="${python} /g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/preprocess_hurs.py ${infile} ${var} ${outfile}"
    if [[ "${flags}" == "-n" ]] ; then
        echo ${python_command}
    else
        echo ${infile}
        mkdir -p ${outdir}
        ${python_command}
        echo ${outfile}
    fi
done

