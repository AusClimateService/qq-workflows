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
  - Surface downwelling solar radiation - rsds (ERA5 - see [here](https://github.com/AusClimateService/npcp/issues/22) for discussion)
  - Surface relative humidity - hurs (ERA5 - see [here](https://github.com/AusClimateService/npcp/issues/2) for discussion)
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
    - ??? (the complex list of GCMs downscaled by CORDEX-CMIP6 is [here](https://opus.nci.org.au/display/CMIP/CMIP6-CORDEX+datasets))
- Baseline: 1985-2014 ("2000")
  - At least 30 years is preferable for quantile detla mapping (to reduce the effect of natural variability)
  - The CMIP6 historical experiment ends in 2014
  - 1985-2014 is currently the preferred 30 year base period of the National Partnership for Climate Projections (NPCP)
- Future period: 2035-2064 ("2050")
- Experiments: ssp126, ssp245, ssp370, ssp585 (maybe)

