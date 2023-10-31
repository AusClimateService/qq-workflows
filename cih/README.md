## CIH projections data

This directory contains configuration files used to produce CIH climate projections data. 

### Ag2050 project

- Timescale: Daily
- Variables (obs):
  - tasmax (AGCD)
  - tasmin (AGCD)
  - pr (AGCD)
  - rsds (AGCD)
  - hurs ([TBC](https://github.com/AusClimateService/npcp/issues/2))
- CMIP6 models:
  - ACCESS-CM2 (r4)
  - ACCESS-ESM1.5 (r6)
  - CESM2 (r1)
  - CMCC-ESM2 (r1)
  - CNRM-ESM2-1 (r1)
  - EC-Earth3 (r1)
  - NorESM2-MM (r1)
- Baseline: 1990-2019 ("2005")
  - (Uses ssp245 for 2015-2019, although all SSPs are [indistinguishable](https://en.wikipedia.org/wiki/Shared_Socioeconomic_Pathways#/media/File:Atmospheric_CO%E2%82%82_concentrations_by_SSP_across_the_21st_century.svg) prior to the mid 2020s)  
- Future period: 2035-2064 ("2050")
- Experiments: ssp126, ssp245, ssp370, ssp585 (maybe)

