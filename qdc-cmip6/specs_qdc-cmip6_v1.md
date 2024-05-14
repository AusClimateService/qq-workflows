# CIHP-13, Version 1

## Specifications

- Timescale: Daily
- Variables (observational dataset/s):
  - Daily maximum surface air temperature - tasmax (AGCD, BARRA-R2)
  - Daily minimum surface air temperature - tasmin (AGCD, BARRA-R2)
  - Precipitation - pr (AGCD, BARRA-R2)
  - Surface downwelling solar radiation - rsds (BARRA-R2)
  - Surface relative humidity - hurs, hursmin, hursmax (BARRA-R2; see [known issues](https://opus.nci.org.au/pages/viewpage.action?pageId=264241304))
  - Surface wind speed - sfcWind (BARRA-R2)
  - The rationale for processing two observational datasets is that BARRA-R2 (~12km) provides a consistent product across all variables,
while having AGCD (~5km) available for temperature and precipitation caters to users who don't require consistency across many variables
and just want the (arguably) superior observational underpinning.
- CMIP6 models (8):
  - ACCESS-CM2
  - ACCESS-ESM1.5
  - CESM2
  - CMCC-ESM2
  - CNRM-ESM2-1
  - EC-Earth3
  - MPI-ESM1-2-HR
  - NorESM2-MM
  - These global climate models were selected for dynamical downscaling over Australia by the Australian Climate Service (i.e. the [BARPA-R](https://dx.doi.org/10.25914/z1x6-dq28) and
[CCAM-v2203-SN](https://dx.doi.org/10.25914/rd73-4m38) data) using a 'sparse matrix' framework ([Grose et al, 2023](https://doi.org/10.1016/j.cliser.2023.100368))
- Time slice output:
  - Baseline time slice: 1985-2014 ("2000")
    - At least 30 years is preferable for QDM (to reduce the effect of natural variability)
    - The CMIP6 historical experiment ends in 2014
    - 1985-2014 is currently the preferred 30 year base period of the National Partnership for Climate Projections
  - Future time slices: 2035-2064 ("2050" or "mid century") and 2070-2099 ("2085" or "end century")
    - For all future scenarios (ssp126, ssp245, ssp370, ssp585)
- Global Warming Level (GWL) output:
  - Baseline GWL: 1.0
    - In observations this corresponds to 2001-2020 (Table 2.4 of the [latest IPCC report](https://www.ipcc.ch/report/ar6/wg1/chapter/chapter-2/#2.3.1.1#2.3.1.1.3))  
  - Future GWLs: 1.5, 2.0, 3.0 and 4.0 degC
  - ssp370 scenario for all GWLs 
  - See Issue https://github.com/climate-innovation-hub/qq-workflows/issues/2 for methodological considerations

## Model data availability

Preliminary data that have not yet undergone
the Climate Innovation Hub quality checking and metadata standardisation process
are available from project [wp00](https://my.nci.org.au/mancini/project/wp00) on NCI.
An example file path is as follows:
```
/g/data/wp00/data/QDC-CMIP6/AGCD/ACCESS-CM2/ssp126/r4i1p1f1/day/tasmax/2035-2064/tasmax_day_ACCESS-CM2_ssp126_r4i1p1f1_AUS-r005_20440101-20441231_qdc-additive-monthly-q100-nearest_AGCD-19850101-20141231_historical-19850101-20141231.nc
```
That example file contains data for the year 2044 that was produced by
calculating the quantile changes between the 2035-2064 data from the ssp126 experiment
and 1985-2014 data from the historical experiment and applying those changes
to AGCD data from 1985-2014.

Here's a summary of what preliminary data are currently available.
The first dot in each cell refers to BARRA-R2.
A second dot refers to AGCD.

| model | run | experiment | tasmax | tasmin | pr | hurs | hursmax | hursmin | rsds | sfcWind | 
| ---   | --- | ---        | :-:    | :-:    | :-:| :-:  | :-:     | :-:     | :-:  | :-:     |
| ACCESS-CM2 | r4i1p1f1 | ssp126 | :green_circle: :white_circle: | :green_circle: :white_circle: | :green_circle: :white_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: | :green_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | 
| ACCESS-CM2 | r4i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp126 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp245 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp370 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp585 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |

:green_circle: = application ready data is available  
:white_circle: = CMIP6 data is available on NCI (or the ESGF) but hasn't been processed yet  
blank = CMIP6 data does not exist on NCI or the ESGF   

## Observational data availability 

The AGCD and BARRA-R2 observational data are available on NCI at the following directories:
```
/g/data/wp00/data/observations/AGCD/
/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/
```