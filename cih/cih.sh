#!/bin/bash
#
# Description: Process all CIH data
#             

var_list=(tasmax tasmin pr hurs)
#tasmax tasmin pr rsds hurs
model_list=(ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 CNRM-ESM2-1 EC-Earth3 NorESM2-MM)
#ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 CNRM-ESM2-1 EC-Earth3 NorESM2-MM
exp_list=(ssp126 ssp245 ssp370 ssp585)
# ssp126 ssp245 ssp370 ssp585
for var in "${var_list[@]}"; do
    for model in "${model_list[@]}"; do
        for exp in "${exp_list[@]}"; do
            qsub -v var=${var},model=${model},experiment=${exp},start=2035,end=2064 job_cih.sh
        done
    done
done

