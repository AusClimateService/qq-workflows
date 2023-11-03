#
# Bash script for fixing the experiment metadata in bias corrected data
# that has been separated into single years
#
# Usage: bash fix_experiment.sh {full/path/to/file1.nc ... full/path/to/fileN.nc }
#

module load nco
for infile in "$@"; do
    experiment=`basename ${infile} | cut -d _ -f 4`
    echo ${infile}
    echo ${experiment} 
    ncatted -O -a experiment_id,global,m,c,${experiment} ${infile}
    ncatted -O -a driving_experiment_name,global,m,c,${experiment} ${infile}
done

