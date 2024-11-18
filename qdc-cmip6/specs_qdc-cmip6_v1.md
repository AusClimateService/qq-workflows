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
- CMIP6 models (9):
  - ACCESS-CM2
  - ACCESS-ESM1.5
  - CESM2
  - CMCC-ESM2
  - CNRM-ESM2-1
  - EC-Earth3
  - MPI-ESM1-2-HR
  - NorESM2-MM
  - UKESM1-0-LL
  - Both the ACS ([Grose et al, 2023](https://doi.org/10.1016/j.cliser.2023.100368)) and NARCliM2.0 ([Di Virgilio et al, 2022](https://doi.org/10.1029/2021EF002625)) went through a process of identifying an appropriate sub-sample of CMIP6 models for dynamical downscaling. They collectively settled on nine CMIP6 models that provided the data needed to drive their models, displayed adequate skill in simulating the historical climate over the Australian region and that together spanned a range of different simulated futures with respect to annual mean temperature and precipitation over Australia. Accordingly, those same nine models were used for the QDC-CMIP dataset. 
- Time slice output:
  - Baseline time slice: 1985-2014 ("2000")
    - At least 30 years is preferable for QDC (to reduce the effect of natural variability)
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
- Grid:
  - The AGCD based QDC-CMIP6 data is available on the AGCD 5km grid across Australia ("AUS-05")
  - The BARRA-R2 based QDC_CMIP6 data is available on the ~11km BARRA-R2 grid ("AUS-11") and also interpolated to the AGCD grid ("AUS-05i")  

## Data access

The QDC-CMIP6 data is available from project [ia39](https://my.nci.org.au/mancini/project/ia39) on NCI.

The total size of the QDC-CMIP6 dataset is approximately 31TB.

The data availability tables below can be interpreted according to the following colors:  
:green_circle: = final release data is available  
:yellow_circle: = preliminary data is available    
:white_circle: = hasn't been processed yet  
:no_entry_sign: = the model doesn't reach that GWL under the ssp370 experiment  
blank = CMIP6 data does not exist on NCI or the ESGF  

The first dot in each cell refers to BARRA-R2.
A second dot refers to AGCD.

### Time slice data

An example time slice file path is as follows:
```
/g/data/ia39/australian-climate-service/release/QDC-CMIP6/AGCD/CMCC-ESM2/ssp370/r1i1p1f1/day/tasmin/AUS-05/2035-2064/v20241104/tasmin_day_CMCC-ESM2_ssp370_r1i1p1f1_AUS-05_2040_qdc-additive-monthly-q100-linear_AGCD-baseline-1985-2014_model-baseline-1985-2014.nc
```
That example file contains daily minimum temperature data for the year 2040 on the AUS-05 grid.
It was produced by calculating the quantile changes between the
2035-2064 data from the ssp370 experiment and
1985-2014 data from the historical experiment for the CMCC-ESM2 model
and applying those changes to AGCD data from 1985-2014.

Here's a summary of what preliminary time slice data are currently available
(for both 2035-2064 and 2070-2099).

| model | run | exp | tas max | tas min | pr | hurs | hurs max | hurs min | rsds | sfcWind | sfcWind max |
| ---   | --- | --- | :-:    | :-:    | :-:| :-:  | :-:     | :-:     | :-:  | :-:     | :-:        |
| ACCESS-CM2 | r4i1p1f1 | ssp126 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp245 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-CM2 | r4i1p1f1 | ssp585 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-ESM1-5 | r6i1p1f1 | ssp126 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-ESM1-5 | r6i1p1f1 | ssp245 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-ESM1-5 | r6i1p1f1 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-ESM1-5 | r6i1p1f1 | ssp585 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CESM2 | r11i1p1f1 | ssp126 | | | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| CESM2 | r11i1p1f1 | ssp245 | | | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| CESM2 | r11i1p1f1 | ssp370 | | | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| CESM2 | r11i1p1f1 | ssp585 | | | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| CMCC-ESM2 | r1i1p1f1 | ssp126 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp245 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CMCC-ESM2 | r1i1p1f1 | ssp585 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp126 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |  | :yellow_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp245 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |  | :yellow_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |  | :yellow_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | ssp585 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |  | :yellow_circle: |
| EC-Earth3 | r1i1p1f1 | ssp126 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| EC-Earth3 | r1i1p1f1 | ssp245 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| EC-Earth3 | r1i1p1f1 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| EC-Earth3 | r1i1p1f1 | ssp585 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| MPI-ESM1-2-HR | r1i1p1f1 | ssp126 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| MPI-ESM1-2-HR | r1i1p1f1 | ssp245 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| MPI-ESM1-2-HR | r1i1p1f1 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| MPI-ESM1-2-HR | r1i1p1f1 | ssp585 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| NorESM2-MM | r1i1p1f1 | ssp126 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| NorESM2-MM | r1i1p1f1 | ssp245 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| NorESM2-MM | r1i1p1f1 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| NorESM2-MM | r1i1p1f1 | ssp585 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| UKESM1-0-LL | r1i1p1f2 | ssp126 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp245 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp370 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| UKESM1-0-LL | r1i1p1f2 | ssp585 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |

### Global warming level data

An example global warming level file path is as follows:
```
/g/data/ia39/australian-climate-service/release/QDC-CMIP6/BARRA-R2/ACCESS-CM2/ssp370/r4i1p1f1/day/tasmax/AUS-05i/gwl20/v20241104/tasmax_day_ACCESS-CM2_ssp370_r4i1p1f1_AUS-05i_gwl20-2039_qdc-additive-monthly-q100-linear_BARRA-R2-baseline-gwl10-2001-2020_model-baseline-gwl10-2003-2022.nc
```
That example file contains daily maximum temperature data for the 2.0 degC global warming level interpolated to the AUS-05i grid. 
It wsa produced by calculating the quantile changes between
global warming level 1.0 (corresponding to the years 2003-2022 in the ACCESS-CM2 model for experiment ssp370) and
global warming level 2.0 (corresponding to the years 2029-2048 in the model)
and then applying those changes to BARRA-R2 data for global warming level 1.0
(corresponding to 2001-2020 for the observed global mean temperature).

Here's a summary of what preliminary global warming level data are currently available.

| model | run | GWL | tas max | tas min | pr | hurs | hurs max | hurs min | rsds | sfcWind | sfcWindmax | 
| ---   | --- | --- | :-:     | :-:     | :-:| :-:  | :-:      | :-:      | :-:  | :-:     | :-:        |
| ACCESS-CM2 | r4i1p1f1 | GWL1.5 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-CM2 | r4i1p1f1 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | 
| ACCESS-CM2 | r4i1p1f1 | GWL3.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-CM2 | r4i1p1f1 | GWL4.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-ESM1-5 | r6i1p1f1 | GWL1.5 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-ESM1-5 | r6i1p1f1 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-ESM1-5 | r6i1p1f1 | GWL3.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| ACCESS-ESM1-5 | r6i1p1f1 | GWL4.0 | :no_entry_sign: :no_entry_sign: | :no_entry_sign: :no_entry_sign: | :no_entry_sign: :no_entry_sign: | :no_entry_sign: | :no_entry_sign: | :no_entry_sign: | :no_entry_sign: | :no_entry_sign: | :no_entry_sign: |
| CESM2 | r11i1p1f1 | GWL1.5 | | | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| CESM2 | r11i1p1f1 | GWL2.0 | | | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| CESM2 | r11i1p1f1 | GWL3.0 | | | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| CESM2 | r11i1p1f1 | GWL4.0 | | | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| CMCC-ESM2 | r1i1p1f1 | GWL1.5 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CMCC-ESM2 | r1i1p1f1 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CMCC-ESM2 | r1i1p1f1 | GWL3.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CMCC-ESM2 | r1i1p1f1 | GWL4.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | GWL1.5 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |  | :yellow_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |  | :yellow_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | GWL3.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |  | :yellow_circle: |
| CNRM-ESM2-1 | r1i1p1f2 | GWL4.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |  | :yellow_circle: |
| EC-Earth3 | r1i1p1f1 | GWL1.5 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| EC-Earth3 | r1i1p1f1 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| EC-Earth3 | r1i1p1f1 | GWL3.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| EC-Earth3 | r1i1p1f1 | GWL4.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| MPI-ESM1-2-HR | r1i1p1f1 | GWL1.5 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| MPI-ESM1-2-HR | r1i1p1f1 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| MPI-ESM1-2-HR | r1i1p1f1 | GWL3.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| MPI-ESM1-2-HR | r1i1p1f1 | GWL4.0 | :no_entry_sign: :no_entry_sign: | :no_entry_sign: :no_entry_sign: | :no_entry_sign: :no_entry_sign: | :no_entry_sign: | | | :no_entry_sign: | :no_entry_sign: | :no_entry_sign: |
| NorESM2-MM | r1i1p1f1 | GWL1.5 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| NorESM2-MM | r1i1p1f1 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| NorESM2-MM | r1i1p1f1 | GWL3.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | |
| NorESM2-MM | r1i1p1f1 | GWL4.0 | :no_entry_sign: :no_entry_sign: | :no_entry_sign: :no_entry_sign: | :no_entry_sign: :no_entry_sign: | :no_entry_sign: | | | :no_entry_sign: | :no_entry_sign: | |
| UKESM1-0-LL | r1i1p1f2 | GWL1.5 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| UKESM1-0-LL | r1i1p1f2 | GWL2.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| UKESM1-0-LL | r1i1p1f2 | GWL3.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |
| UKESM1-0-LL | r1i1p1f2 | GWL4.0 | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: :yellow_circle: | :yellow_circle: | | | :yellow_circle: | :yellow_circle: | :yellow_circle: |

## Observational data

The AGCD and BARRA-R2 observational data are available on NCI at the following directories:
```
/g/data/wp00/data/observations/AGCD/
/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/
```
