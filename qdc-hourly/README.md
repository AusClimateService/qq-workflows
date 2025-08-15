## QDC-hourly

Test case:

```
make train -n CONFIG=qdc-hourly/config_qdc-hourly.mk VAR=tas EXPERIMENT=ssp370 GCM=ACCESS-CM2 RCM=CCAM-v2203-SN RUN=r4i1p1f1 OBS=BARRA-R2 HOUR=02 REF_START=2070 REF_END=2099 HIST_START=1985 HIST_END=2014 TARGET_START=1985 TARGET_END=2014
```
or
```
qsub -v target=train,hour=02,var=tas,experiment=ssp370,gcm=ACCESS-CM2,rcm=CCAM-v2203-SN,run=r4i1p1f1,obs=BARRA-R2,hist_start=1985,hist_end=2014,ref_start=2070,ref_end=2099,target_start=1985,target_end=2014 job_qdc-hourly.sh
```
