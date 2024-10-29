#!/bin/bash
#
# Description: Process all NPCP data
#             

method_list=(ecdfm)
# ecdfm qdc
var_list=(pr)
# tasmax tasmin pr
rcm_list=(BOM-BARPA-R UQ-DES-CCAM-2105 CSIRO-CCAM-2203 GCM)
# BOM-BARPA-R UQ-DES-CCAM-2105 CSIRO-CCAM-2203 GCM
gcm_list=(ECMWF-ERA5 CSIRO-ACCESS-ESM1-5 EC-Earth-Consortium-EC-Earth3 NCAR-CESM2)
# ECMWF-ERA5 CSIRO-ACCESS-ESM1-5 EC-Earth-Consortium-EC-Earth3 NCAR-CESM2

for var in "${var_list[@]}"; do
    for rcm in "${rcm_list[@]}"; do 
        for gcm in "${gcm_list[@]}"; do
            for method in "${method_list[@]}"; do
                task_list=(xvalidation)
                if ! [[ "${gcm}" == "ECMWF-ERA5" ]] ; then
                    task_list+=(projection)
                fi
                if [[ "${method}" == "ecdfm" ]] ; then
                    task_list+=(historical)
                fi
                for task in "${task_list[@]}"; do
                    qsub -v method=${method},var=${var},task=${task},rcm=${rcm},gcm=${gcm} job_npcp.sh
                done
            done
        done
    done
done
