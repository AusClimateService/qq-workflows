#!/bin/bash
#
# Description: Create a full bias corrected timeseries using overlapping periods
#             

function usage {
    echo "USAGE: bash $0"
    exit 1
}

declare -a target_start=(1960 1970 1980 1990 2000 2010 2020 2030 2040 2050 2060 2070)
declare -a target_end=(1989 1999 2009 2019 2029 2039 2049 2059 2069 2079 2089 2100)
declare -a output_start=(1960 1980 1990 2000 2010 2020 2030 2040 2050 2060 2070 2080)
declare -a output_end=(1979 1989 1999 2009 2019 2029 2039 2049 2059 2069 2079 2100)

nsegments=${#target_start[@]}

for (( i=0; i<${nsegments}; i++ ));
do
  make adjust CONFIG=acs/config_ecdfm_acs.mk TARGET_START=${target_start[$i]} TARGET_END=${target_end[$i]} OUTPUT_START=${output_start[$i]} OUTPUT_END=${output_end[$i]}
done

