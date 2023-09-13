#
# Bash script for separating bias corrected data into single years
#
# Usage: bash fix_experiment.sh {full/path/to/file1.nc ... full/path/to/fileN.nc }
#

for infile in "$@"; do
    experiment=`basename ${infile} | cut -d _ -f 4`
    ncatted -O -a experiment_id,global,m,c,${experiment} ${infile}
    ncatted -O -a driving_experiment_name,global,m,c,${experiment} ${infile}
done

