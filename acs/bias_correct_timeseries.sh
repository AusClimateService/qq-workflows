#!/bin/bash
#
# Description: Create a full bias corrected timeseries using overlapping periods
#             

function usage {
    echo "USAGE: bash $0 task var obs rcm gcm [-Bn]"
    echo "  task:  task to execute (adjust or clean-up) variable to process"
    echo "  var:   variable to process"
    echo "  obs:   obs dataset to process"
    echo "  rcm:   name of regional climate model"
    echo "  gcm:   name of global climate model"
    echo "  exp:   experiment"
    echo "  [-Bn]: optional flags for make command"
    exit 1
}

task=$1
var=$2
obs=$3
rcm=$4
gcm=$5
exp=$6
flags=$7

if [ "${rcm}" == "BARPA-R" ] ; then
  declare -a target_start=(1960 1970 1980 1990 2000 2010 2020 2030 2040 2050 2060 2070)
  declare -a target_end=(1989 1999 2009 2019 2029 2039 2049 2059 2069 2079 2089 2100)
  declare -a output_start=(1960 1980 1990 2000 2010 2020 2030 2040 2050 2060 2070 2080)
  declare -a output_end=(1979 1989 1999 2009 2019 2029 2039 2049 2059 2069 2079 2100)
elif [ "${rcm}" == "CCAM-v2203-SN" ] ; then
  declare -a target_start=(1951 1960 1970 1980 1990 2000 2010 2020 2030 2040 2050 2060 2070)
  declare -a target_end=(1979 1989 1999 2009 2019 2029 2039 2049 2059 2069 2079 2089 2099)
  declare -a output_start=(1951 1970 1980 1990 2000 2010 2020 2030 2040 2050 2060 2070 2080)
  declare -a output_end=(1969 1979 1989 1999 2009 2019 2029 2039 2049 2059 2069 2079 2099)
fi

nsegments=${#target_start[@]}

for (( i=0; i<${nsegments}; i++ ));
do
  command="make ${flags} ${task} -f /g/data/xv83/quantile-mapping/qq-workflows/Makefile CONFIG=config_acs.mk VAR=${var} OBS_DATASET=${obs} RCM_NAME=${rcm} GCM_NAME=${gcm} TARGET_EXP=${exp} TARGET_START=${target_start[$i]} TARGET_END=${target_end[$i]} OUTPUT_START=${output_start[$i]} OUTPUT_END=${output_end[$i]}"
  echo ${command}
  ${command}
done

