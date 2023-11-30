## CIH projections data

This directory contains configuration files used to produce CIH climate projections data. 

### Ag2050 project

Ag2050 is a multi-year program of work funded by CSIRO that will target non-incremental change of Australia’s farming systems
and provide an evidence-based picture of what Australia’s farming systems could,
should and need to look like in 2050 to be productive, resilient and sustainable
(see details [here](https://confluence.csiro.au/pages/viewpage.action?pageId=1706583873)).

The Climate Innovation Hub will provide application-ready climate projections data
for the Ag2050 project using the [Quantile Delta Mapping](https://github.com/climate-innovation-hub/qqscale/blob/master/docs/method_qdm.md) method.

#### Dataset details

The details of the application ready dataset that will be produced are as follows:
- Timescale: Daily
- Variables (observational dataset):
  - Daily maximum surface air temperature - tasmax (AGCD)
  - Daily minimum surface air temperature - tasmin (AGCD)
  - Precipitation - pr (AGCD)
  - Surface downwelling solar radiation - rsds (ERA5 - see [here](https://github.com/AusClimateService/npcp/issues/22) for discussion)
  - Surface relative humidity - hurs (ERA5 - see [here](https://github.com/AusClimateService/npcp/issues/2) for discussion)
- CMIP6 models:
  - For a start, the 7 models downscaled by the CSIRO CCAM team for the Australian Climate Service
  - Additional models could be processed later on
  - The complete list of GCMs downscaled by CORDEX-CMIP6 is [here](https://opus.nci.org.au/display/CMIP/CMIP6-CORDEX+datasets))
- Baseline: 1985-2014 ("2000")
  - At least 30 years is preferable for quantile detla mapping (to reduce the effect of natural variability)
  - The CMIP6 historical experiment ends in 2014
  - 1985-2014 is currently the preferred 30 year base period of the National Partnership for Climate Projections
- Future period: 2035-2064 ("2050")
- Experiments: ssp126, ssp245, ssp370, ssp585

#### Model data availability

Preliminary data that have not yet undergone
the Climate Innovation Hub quality checking and metadata standardisation process
are available from project [wp00](https://my.nci.org.au/mancini/project/wp00) on NCI.
An example file path is as follows:
```
/g/data/wp00/data/QQ-CMIP6/ACCESS-CM2/ssp126/r4i1p1f1/day/tasmax/tasmax_day_ACCESS-CM2_ssp126_r4i1p1f1_AUS-r005_20350101-20641231_qdm-additive-monthly-q100-nearest_AGCD-19850101-20141231_historical-19850101-20141231.nc
```
That example file contains data for the 2035-2064 period that was produced by
calcating the quantile changes between the 2035-2064 data from the ssp126 experiment
and 1985-2014 data from the historical experiment and applying those changes
to AGCD data from 1985-2014.

Here's a summary of what preliminary data is currently available:

| model | run | experiment | tasmax | tasmin | pr | hurs | rsds | 
| ---   | --- | ---        | :-:    | :-:    | :-:| :-:  | :-:  |
| ACCESS-CM2 | r4i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp126 | | | :green_circle: | :green_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp245 | | | :green_circle: | :green_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp370 | | | :green_circle: | :green_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp585 | | | :green_circle: | :green_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: |

:green_circle: = application ready data is available  
:white_circle: = CMIP6 data is available on NCI but hasn't been processed yet  
blank = CMIP6 data does not exist on NCI

#### Observational data availability

The AGCD and ERA5 observational data is also available
from project [wp00](https://my.nci.org.au/mancini/project/wp00) on NCI at the following directories:
```
/g/data/wp00/data/observations/AGCD/
/g/data/wp00/data/observations/ERA5/
```
Those datasets typically end sometime during 2022,
but can be updated to the end of 2022 or even to the present day if required.
