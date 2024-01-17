#!/bin/bash
#
# Description: Process all CIH data
#
# Usage: bash cih.sh {target}
# 

target=$1
#train adjust validation clipmax split-by-year clean-up 

var_list=(hurs)
#tasmax tasmin pr rsds hurs hursmin hursmax 
model_list=(ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 CNRM-ESM2-1 EC-Earth3 NorESM2-MM)
#ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 CNRM-ESM2-1 EC-Earth3 NorESM2-MM
exp_list=(ssp126 ssp245 ssp370 ssp585)
# ssp126 ssp245 ssp370 ssp585
for var in "${var_list[@]}"; do
    for model in "${model_list[@]}"; do
        for exp in "${exp_list[@]}"; do
            if [ ${target} == 'split-by-year' ] || [ ${target} == 'clean-up' ]; then 
                make ${target} -f /home/599/dbi599/qq-workflows/Makefile CONFIG=config_cih.mk VAR=${var} MODEL=${model} EXPERIMENT=${exp} REF_START=2035 REF_END=2064
            else
                qsub -v target=${target},var=${var},model=${model},experiment=${exp},start=2035,end=2064 job_cih.sh
            fi
        done
    done
done

