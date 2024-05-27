# QDC-CMIP6, Version 1

## Specifications

- Timescale: Daily
- Variables (observational dataset/s):
  - Daily maximum surface air temperature - tasmax (AGCD, BARRA-R2)
  - Daily minimum surface air temperature - tasmin (AGCD, BARRA-R2)
  - Precipitation - pr (AGCD, BARRA-R2)
  - Surface downwelling solar radiation - rsds (BARRA-R2)
  - Daily mean surface relative humidity - hurs (BARRA-R2)
  - Daily maximum surface relative humidity - hursmax (BARRA-R2)
  - Daily minimum surface relative humidity - hursmin (BARRA-R2)
  - Daily mean surface wind speed - sfcWind (BARRA-R2)
  - Daily maximum surface wind speed - sfcWindmax (BARRA-R2)
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
  - These global climate models were selected for dynamical downscaling over Australia by the Australian Climate Service (i.e. the [BARPA](https://dx.doi.org/10.25914/z1x6-dq28) and
[CCAM](https://dx.doi.org/10.25914/rd73-4m38) data) using a 'sparse matrix' framework ([Grose et al, 2023](https://doi.org/10.1016/j.cliser.2023.100368))
- Time slice output:
  - Baseline time slice: 1985-2014 ("2000")
    - At least 30 years is preferable for QDM (to reduce the effect of natural variability)
    - The CMIP6 historical experiment ends in 2014
    - 1985-2014 is currently the preferred 30 year base period of the National Partnership for Climate Projections
  - Future time slices: 2035-2064 ("2050" or "mid century") and 2070-2099 ("2085" or "end century")
    - For all future scenarios (ssp126, ssp245, ssp370, ssp585)
- Global Warming Level (GWL) output:
  - Baseline GWL: 1.0  
  - Future GWLs: 1.5, 2.0, 3.0 and 4.0 degC
  - Source for 20 year period defining each GWL:
    - Observations: The GWL 1.0 level corresponds to 2001-2020 (Table 2.4 of the [latest IPCC report](https://www.ipcc.ch/report/ar6/wg1/chapter/chapter-2/#2.3.1.1#2.3.1.1.3))
    - Models: [Mathias Hauser](https://github.com/mathause/cmip_warming_levels/blob/main/warming_levels/cmip6_all_ens/cmip6_warming_levels_all_ens_1850_1900.yml)
  - ssp370 scenario for all GWLs 

## Model data availability

Preliminary data that have not yet undergone final quality checking
are available from project [ia39](https://my.nci.org.au/mancini/project/ia39) on NCI.

### Time slice data

An example time slice file path is as follows:
```
/g/data/ia39/australian-climate-service/test-data/QDC-CMIP6/AGCD/CMCC-ESM2/ssp370/r1i1p1f1/day/tasmin/2035-2064/tasmin_day_CMCC-ESM2_ssp370_r1i1p1f1_AUS-05_20350101-20641231_qdc-additive-monthly-q100-linear_AGCD-baseline-19850101-20141231_model-baseline-19850101-20141231.nc
```
That example file contains data for the years 2035-2064.
It was produced by calculating the quantile changes between the
2035-2064 data from the ssp370 experiment and
1985-2014 data from the historical experiment for the CMCC-ESM2 model
and applying those changes to AGCD data from 1985-2014.

Here's a summary of what preliminary time slice data are currently available
(for both 2035-2064 and 2070-2099).
The first dot in each cell refers to BARRA-R2.
A second dot refers to AGCD.

| model | run | exp | tas max | tas min | pr | hurs | hurs max | hurs min | rsds | sfcWind | sfcWind max |
| ---   | --- | --- | :-:    | :-:    | :-:| :-:  | :-:     | :-:     | :-:  | :-:     | :-:        |
| ACCESS-CM2 | r4i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :white_circle: | :white_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | ssp126 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| CESM2 | r11i1p1f1 | ssp245 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | | 
| CESM2 | r11i1p1f1 | ssp370 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| CESM2 | r11i1p1f1 | ssp585 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| CMCC-ESM2 | r1i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: |  | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: |  | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: |  |  :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: |  | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| NorESM2-MM | r1i1p1f1 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| NorESM2-MM | r1i1p1f1 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| NorESM2-MM | r1i1p1f1 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| UKESM1-0-LL | r1i1p1f2 | ssp126 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp245 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp370 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp585 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | :white_circle: |
| Size (TB) | | | 2.1 | 2.1 | 3.5 | 1.7 | | | 1.8 | 1.4 | 1.2 |

Estimated total size of time slice dataset = 13.8 TB

### Global warming level data

An example global warming level file path is as follows:
```
/g/data/ia39/australian-climate-service/test-data/QDC-CMIP6/AGCD/CMCC-ESM2/ssp370/r1i1p1f1/day/tasmin/gwl20/tasmin_day_CMCC-ESM2_ssp370_r1i1p1f1_AUS-05_gwl20-20320101-20511231_qdc-additive-monthly-q100-linear_AGCD-baseline-gwl10-20010101-20201231_model-baseline-gwl10-19940101-20131231.nc
```
That example file contains data for the 2.0 degC global warming level. 
It wsa produced by calculating the quantile changes between
global warming level 1.0 (corresponding to the years 1994-2013 in the CMCC-ESM2 model for experiment ssp370) and
global warming level 2.0 (corresponding to the years 2032-2051 in the model)
and then applying those changes to AGCD data for global warming level 1.0
(corresponding to 2001-2020 for the observed global mean temperature).

Here's a summary of what preliminary global warming level data are currently available.
The first dot in each cell refers to BARRA-R2.
A second dot refers to AGCD.

| model | run | GWL | tas max | tas min | pr | hurs | hurs max | hurs min | rsds | sfcWind | sfcWindmax | 
| ---   | --- | --- | :-:     | :-:     | :-:| :-:  | :-:      | :-:      | :-:  | :-:     | :-:        |
| ACCESS-CM2 | r4i1p1f1 | GWL1.5 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-CM2 | r4i1p1f1 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :white_circle: | :white_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | 
| ACCESS-CM2 | r4i1p1f1 | GWL3.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-CM2 | r4i1p1f1 | GWL4.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | GWL1.5 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | GWL2.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | GWL3.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| ACCESS-ESM1.5 | r6i1p1f1 | GWL4.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: | :white_circle: |
| CESM2 | r11i1p1f1 | GWL1.5 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| CESM2 | r11i1p1f1 | GWL2.0 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| CESM2 | r11i1p1f1 | GWL3.0 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| CESM2 | r11i1p1f1 | GWL4.0 | | | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| CMCC-ESM2 | r1i1p1f1 | GWL1.5 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | GWL2.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | GWL3.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| CMCC-ESM2 | r1i1p1f1 | GWL4.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | GWL1.5 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: |  | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | GWL2.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: |  | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | GWL3.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: |  | :white_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | GWL4.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: |  | :white_circle: |
| EC-Earth3 | r1i1p1f1 | GWL1.5 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | GWL2.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | GWL3.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| EC-Earth3 | r1i1p1f1 | GWL4.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | :white_circle: |
| NorESM2-MM | r1i1p1f1 | GWL1.5 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | :red_circle: | :red_circle: | :white_circle: | :white_circle: | |
| NorESM2-MM | r1i1p1f1 | GWL2.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| NorESM2-MM | r1i1p1f1 | GWL3.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| NorESM2-MM | r1i1p1f1 | GWL4.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | |
| UKESM1-0-LL | r1i1p1f2 | GWL1.5 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | GWL2.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | GWL3.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | :white_circle: |
| UKESM1-0-LL | r1i1p1f2 | GWL4.0 | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: :white_circle: | :white_circle: | | | :white_circle: | :white_circle: | :white_circle: |
| Size (TB) | | | 0.7 | 0.7 | 1.2 | 0.6 | | | 0.6 | 0.5 | 0.4 |

Estimated total size of GWL dataset = 4.6 TB

:green_circle: = data is available  
:yellow_circle: = preliminary data is available  
:white_circle: = CMIP6 data is available on NCI (or the ESGF) but hasn't been processed yet  
blank = CMIP6 data does not exist on NCI or the ESGF   

## Observational data availability 

The AGCD and BARRA-R2 observational data are available on NCI at the following directories:
```
/g/data/wp00/data/observations/AGCD/
/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/
```
