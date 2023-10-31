## ACS bias correction

This directory contains files used to coordinate the production of bias corrected CORDEX data for ACS.

#### Step 1: Bias correct the full timeseries

The CORDEX runs span the period 1960-2100.
The training period for the bias correction is 1985-2014 (the last 30 years of the historical experiment).
The CORDEX data is then corrected in 30-year sliding windows from 1960-2100.
The central 10 years of each window (or 20 years for the first and last window)
is retained and then the window is incremented 10 years.
This sliding window approach prevents strong trends in the data impacting the results.
e.g.

```
qsub -v var=tasmax,rcm=BOM-BARPA-R,gcm=CSIRO-ACCESS-ESM1-5 bias_correct_timeseries-job.sh
```

#### Step 2: Split data into single years

The bias correction process produces data files containing 10 (or 20) years of data.
There's a bash script to split them into single years (like the CORDEX collection does).
e.g.

```
bash split_by_year.sh /g/data/xv83/dbi599/australian-climate-service/test-data/CORDEX-CMIP6/bias-adjusted-output/AUS-05i/BOM/CSIRO-ACCESS-ESM1-5/ssp370/r6i1p1f1/BOM-BARPA-R/v1-ecdfm-AGCD-1985-2014/day/tasmaxAdjust/tasmaxAdjust_AUS-05i_CSIRO-ACCESS-ESM1-5_ssp370_r6i1p1f1_BOM-BARPA-R_v1-ecdfm-AGCD-1985-2014_day_*.nc
```

#### Step 3: Fix file metadata

The process of splitting the data into individual years
will cause some data files to have incorrect metadata relating to the corresponding CMIP6 experiment.
There's a bash script to fix that.
e.g.

```
bash fix_experiment.sh  /g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6/bias-adjusted-output/AUS-05i/BOM/CSIRO-ACCESS-ESM1-5/{historical,ssp370}/r6i1p1f1/BOM-BARPA-R/v1-ecdfm-AGCD-1985-2014/day/tasmaxAdjust/*.nc
``` 



