#!/bin/bash
#
# Description: Process all CIH data
#             

var_list=(tasmax tasmin pr)
#tasmax tasmin pr rsds hurs
gcm_list=(ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 EC-Earth3 NorESM2-MM)
exp_list=(ssp126 ssp245 ssp370 ssp585)
# ssp126 ssp245 ssp370 ssp585
for var in "${var_list[@]}"; do
    for gcm in "${gcm_list[@]}"; do
        for exp in "${exp_list[@]}"; do
            qsub -v var=${var},gcm=${gcm},experiment=${exp},start=2035,end=2064 job_cih.sh
        done
    done
done

