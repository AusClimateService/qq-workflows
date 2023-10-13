#!/bin/bash
#
# Description: Process all ECDFm data
#             

var_list=(tasmin tasmax pr)
rcm_list=(BOM-BARPA-R UQ-DES-CCAM-2105 CSIRO-CCAM-2203)
gcm_list=(ECMWF-ERA5 CSIRO-ACCESS-ESM1-5)
for gcm in "${gcm_list[@]}"; do
    if [[ "${gcm}" == "ECMWF-ERA5" ]] ; then
        task_list=(historical xvalidation)
    else
        task_list=(historical xvalidation projection)
    fi
    for var in "${var_list[@]}"; do
        for task in "${task_list[@]}"; do
            for rcm in "${rcm_list[@]}"; do

                echo qsub -v var=${var},task=${task},rcm=${rcm},gcm=${gcm} job_npcp.sh

            done
        done
    done
done
