## CIH projections data

This directory contains configuration files used to produce CIH climate projections data. 

### Ag2050 project

Ag2050 is a multi-year program of work funded by CSIRO that will target non-incremental change of Australia’s farming systems
and provide an evidence-based picture of what Australia’s farming systems could,
should and need to look like in 2050 to be productive, resilient and sustainable
(see details [here](https://confluence.csiro.au/pages/viewpage.action?pageId=1706583873)).

The Climate Innovation Hub will provide application-ready climate projections data
for the Ag2050 project using the [Quantile Delta Mapping](https://github.com/climate-innovation-hub/qqscale/blob/master/docs/method_qdm.md) method.
The details of the dataset that will be produced are as follows:
- Timescale: Daily
- Variables (observational dataset):
  - Daily maximum surface air temperature - tasmax (AGCD)
  - Daily minimum surface air temperature - tasmin (AGCD)
  - Precipitation - pr (AGCD)
  - Surface downwelling solar radiation - rsds (SILO - see [here](https://github.com/AusClimateService/npcp/issues/22) for discussion)
  - Surface relative humidity - hurs (TBC - see [here](https://github.com/AusClimateService/npcp/issues/2) for discussion)
- CMIP6 models:
  - Models/runs that were downscaled by ACS: 
    - ACCESS-CM2 (r4)
    - ACCESS-ESM1.5 (r6)
    - CESM2 (r1)
    - CMCC-ESM2 (r1)
    - CNRM-ESM2-1 (r1)
    - EC-Earth3 (r1)
    - NorESM2-MM (r1)
  - Additional models:
    - ???
- Baseline: 1990-2019 ("2005")
  - At least 30 years is preferable for quantile detla mapping (to reduce the effect of natural variability)
  - The limiting factor for the start year is the AGCD solar radiation data (if we go with AGCD as the rsds dataset), which doesn't begin until 1990 (the beginning of the satellite era for solar radiation data)
  - The CMIP6 historical experiment ends in 2014 so we use the ssp245 experiment for 2015-2019, noting that all SSPs are practically [indistinguishable](https://en.wikipedia.org/wiki/Shared_Socioeconomic_Pathways#/media/File:Atmospheric_CO%E2%82%82_concentrations_by_SSP_across_the_21st_century.svg) prior to the mid 2020s so it doesn't really matter which one we pick  
- Future period: 2035-2064 ("2050")
- Experiments: ssp126, ssp245, ssp370, ssp585 (maybe)

