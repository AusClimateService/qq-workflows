## CIH projections data

This directory contains configuration files used to produce CIH climate projections data. 

The complete CIH CMIP6 application ready climate projections dataset will be called CIHP-13.
At the moment an intial subset of data is being produced for the Ag2050 project.

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
  - Surface downwelling solar radiation - rsds (ERA5)
  - Surface relative humidity - hurs, hursmin, hursmax (ERA5)
- CMIP6 models:
  - For a start, the 7 models downscaled by the CSIRO CCAM team for the Australian Climate Service
  - Additional models could be processed later on
  - The complete list of GCMs downscaled by CORDEX-CMIP6 is [here](https://opus.nci.org.au/display/CMIP/CMIP6-CORDEX+datasets)
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
calculating the quantile changes between the 2035-2064 data from the ssp126 experiment
and 1985-2014 data from the historical experiment and applying those changes
to AGCD data from 1985-2014.

Here's a summary of what preliminary data are currently available:

| model | run | experiment | tasmax | tasmin | pr | hurs | hursmin | hursmax | rsds | 
| ---   | --- | ---        | :-:    | :-:    | :-:| :-:  | :-:     | :-:     | :-:  |
| ACCESS-CM2 | r4i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| CESM2 | r11i1p1f1 | ssp126 | | | :green_circle: | :green_circle: |  |  | :green_circle: |
| CESM2 | r11i1p1f1 | ssp245 | | | :green_circle: | :green_circle: |  |  | :green_circle: |
| CESM2 | r11i1p1f1 | ssp370 | | | :green_circle: | :green_circle: |  |  | :green_circle: |
| CESM2 | r11i1p1f1 | ssp585 | | | :green_circle: | :green_circle: |  |  | :green_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| EC-Earth3 | r1i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| EC-Earth3 | r1i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| EC-Earth3 | r1i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| EC-Earth3 | r1i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :white_circle: | :white_circle: | :green_circle: |
| NorESM2-MM | r1i1p1f1 | ssp126 | :green_circle: | :green_circle: | :green_circle: | :green_circle: |  |  | :green_circle: |
| NorESM2-MM | r1i1p1f1 | ssp245 | :green_circle: | :green_circle: | :green_circle: | :green_circle: |  |  | :green_circle: |
| NorESM2-MM | r1i1p1f1 | ssp370 | :green_circle: | :green_circle: | :green_circle: | :green_circle: |  |  | :green_circle: |
| NorESM2-MM | r1i1p1f1 | ssp585 | :green_circle: | :green_circle: | :green_circle: | :green_circle: |  |  | :green_circle: |

:green_circle: = application ready data is available  
:white_circle: = CMIP6 data is available on NCI (or the ESGF) but hasn't been processed yet  
blank = CMIP6 data does not exist on NCI or the ESGF

#### Observational data availability

The AGCD and ERA5 observational data is also available
from project [wp00](https://my.nci.org.au/mancini/project/wp00) on NCI at the following directories:
```
/g/data/wp00/data/observations/AGCD/
/g/data/wp00/data/observations/ERA5/
```
The timespan of those datasets typically ends sometime during 2022,
but they can be updated to the end of 2022 or even to the present day if required.

#### Observational data rationale

###### Solar radiation (ERA5)

The observational data options for downwelling solar radiation are
AGCD,
[SILO](https://www.longpaddock.qld.gov.au/silo/),
ERA5 or
[MSWX](https://www.gloh2o.org/mswx/)
(see [here](https://github.com/AusClimateService/npcp/issues/22) for detailed discussion).

AGCD is only available in the satellite era (1990 onwards).
The early years in the dataset (pre 2007) have missing values, up to 60 days per year in some cases.
It might be possible to replace those missing values with a climatological mean value
(that's what the AWRA modelling team does before feeding the AGCD data into their model;
[Frost & Shokri, 2021](https://awo.bom.gov.au/assets/notes/publications/AWRA-Lv7_Model_Description_Report.pdf))
but it's less than ideal.
The missing value issue coupled with the fact that the data aren't available back to the beginning of our base period (1985)
means we decided against AGCD.

SILO uses an blended data method (that doesn't use satellite data)
to go further back in time to 1959 ([Zajaczkowski et al 2013](https://doi.org/10.1016/j.envsoft.2013.06.013)).
While this fixes the base period issue,
it's likely that products that include satellite data are better quality,
hence we decided against SILO.

The ERA5 data goes back to 1959, assimilates satellite data and has no missing values.
It also provides a clear sky radiation variable which can be used to clip our quantile scaled data
to ensure the projections data doesn't exceed physical solar radiation limits.
For these reasons, we selected ERA5.

The MSWX downward shortwave radiation reference climatology was produced by bilinearly interpolating the ERA5 climatology (1979–2019) on a monthly basis,
and rescaling the long-term mean to match the Global Solar Atlas (GSA) global horizontal insolation climatology.
They find basically no improvement on the ERA5 downward shortwave radiation ([Beck et al 2022](https://doi.org/10.1175/BAMS-D-21-0145.1)).
The lack of improvement is likely attributable to the small influence that the improved climatology has on the day-to-day variability.

###### Relative humidity (ERA5)

The observational data options for relative humidity are AGCD, SILO, ERA5 or MSWX
(see [here](https://github.com/AusClimateService/npcp/issues/2) for a detailed discussion).

The AGCD dataset doesn't provide a relative humidity variable but instead provides vapour pressure.
In general, vapour pressure values can be converted to relative humidity by dividing by the saturation vapour pressure
(which can be calculated directly from temperature).
The complication is that AGCD doesn't provide a daily mean, maximum or minimum vapour pressure value
but instead the 9am and 3pm values. 

In terms of approaches to combining the 9am and 3pm vapour pressure values to get an estimate of the daily mean,
the AWRA modelling group use a weighted average as the input to their model to reflect the average daily value
[Frost & Shokri, 2021](https://awo.bom.gov.au/assets/notes/publications/AWRA-Lv7_Model_Description_Report.pdf)).
The weight is a new parameter for AWRA v7 with an optimum value found to be 0.2 for the 9:00 am and 0.8 for the 3:00 pm values.
In order to estimate the daily average temperature
(which would be needed to calculate the saturation vapour pressure),
the AWRA system takes the weighted mean of the daily maximum and minimum temperatures with the weights 0.85 and 0.15 respectively.
We could follow the lead of the AWRA modelling group and perform these calculations,
but they don't actually calculate relative humidity
(i.e. the daily average vapour pressure and temperature are separate model inputs).
In other words, it's not clear that those vapour pressure and temperature weights
are optimal when combined to generate relative humidity values.
It's also unclear how large the uncertainties are associated with a linear weighting approach to generating daily values
and they also don't provide suggested weights for obtaining the daily minimum or daily maximum vapour pressure
For these reasons we decided against using AGCD.

The SILO dataset includes two relative humidity variables:
"relative humidity at the time of maximum temperature" and
"relative humidity at the time of minimum temperature."
The documentation for the dataset says that these values were calculated using the vapour pressure measured at 9am,
and the saturation vapour pressure computed using either the maximum or minimum daily temperature
([Jeffrey et al 2001](https://doi.org/10.1016/S1364-8152(01)00008-1)).
It's unclear how the relative humidity at the time of the minimum or maximum temperature relates
to the actual minimum and maximum relative humidity for the day,
so we decided against using the SILO data.  

The ERA5 dataset archives hourly dew point temperatures,
which can be converted to hourly relative humidity values
from which the daily mean, maximum or minimum can be calculated.
Given the limitations of the AGCD and SILO datasets,
this was the approach we went with.
According to [Beck et al (2022)]((https://doi.org/10.1175/BAMS-D-21-0145.1)),
the MSWX relative humidity data is essentially just ERA5 data that has been interpolated to a finer grid,
so there was no reason to use MSWX over ERA5.
