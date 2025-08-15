#!/bin/bash
#PBS -P xv83
#PBS -q normal
#PBS -l walltime=10:00:00
#PBS -l mem=100GB
#PBS -l storage=gdata/xv83+gdata/hq89+gdata/ia39+gdata/ob53
#PBS -l wd
#PBS -v target,hour,var,experiment,gcm,rcm,run,obs,hist_start,hist_end,ref_start,ref_end,target_start,target_end

# Example:
# qsub -v target=train,hour=02,var=tas,experiment=ssp370,gcm=ACCESS-CM2,rcm=CCAM-v2203-SN,run=r4i1p1f1,obs=BARRA-R2,hist_start=1985,hist_end=2014,ref_start=2070,ref_end=2099,target_start=1985,target_end=2014 job_qdc-hourly.sh

command="make ${target} -f /g/data/xv83/quantile-mapping/qq-workflows/Makefile CONFIG=config_qdc-hourly.mk HOUR=${hour} VAR=${var} EXPERIMENT=${experiment} GCM=${gcm} RCM=${rcm} RUN=${run} OBS=${obs} HIST_START=${hist_start} HIST_END=${hist_end} REF_START=${ref_start} REF_END=${ref_end} TARGET_START=${target_start} TARGET_END=${target_end}"
echo ${command}
${command}

