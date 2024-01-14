#!/bin/bash
#
# Description: Process all NPCP data
#             

method_list=(ecdfm qdm)
# ecdfm qdm
var_list=(pr)
# tasmax tasmin pr
rcm_list=(BOM-BARPA-R CSIRO-CCAM-2203 GCM)
# BOM-BARPA-R UQ-DES-CCAM-2105 CSIRO-CCAM-2203 GCM
gcm_list=(EC-Earth-Consortium-EC-Earth3)
# ECMWF-ERA5 CSIRO-ACCESS-ESM1-5 EC-Earth-Consortium-EC-Earth3

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
                    if [ "${var}" == "pr" ] && [ "${method}" == "ecdfm" ] ; then
                        interp=linear
                    else
                        interp=nearest
                    fi
                    if [ "${var}" == "pr" ] && [ "${method}" == "qdm" ] ; then
                        if [ "${task}" == "xvalidation" ] && [ "${gcm}" == "ECMWF-ERA5" ] ; then
                            nquantiles=500
                        else
                            nquantiles=1000
                        fi
                    else
                        nquantiles=100
                    fi
                    qsub -v method=${method},var=${var},task=${task},rcm=${rcm},gcm=${gcm},nquantiles=${nquantiles},interp=${interp} job_npcp.sh
                done
            done
        done
    done
done
