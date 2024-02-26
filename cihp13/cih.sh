#!/bin/bash
#
# Description: Process all CIH data
#
# Usage: bash cih.sh {target}
# 

target=$1
#train adjust validation clipmax split-by-year clean-up 

obs=BARRA-R2
#BARRA-R2 AGCD
start=2070
#2035 2070
end=2099
#2064 2099

var_list=(tasmax tasmin pr rsds hurs sfcWind)
#tasmax tasmin pr rsds hurs sfcWind hursmin hursmax
model_list=(ACCESS-CM2)
#ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 CNRM-ESM2-1 EC-Earth3 NorESM2-MM UKESM1-0-LL
exp_list=(ssp126)
# ssp126 ssp245 ssp370 ssp585
for var in "${var_list[@]}"; do
    for model in "${model_list[@]}"; do
        for exp in "${exp_list[@]}"; do
            if [ ${target} == 'split-by-year' ] || [ ${target} == 'clean-up' ]; then 
                make ${target} -f /home/599/dbi599/qq-workflows/Makefile CONFIG=config_cih.mk VAR=${var} OBS_DATASET=${obs} MODEL=${model} EXPERIMENT=${exp} REF_START=${start} REF_END=${end}
            else
                qsub -v target=${target},var=${var},obs=${obs},model=${model},experiment=${exp},start=${start},end=${end} job_cih.sh
            fi
        done
    done
done

