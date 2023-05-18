## CIH paper

This directory contains configuration files and other information
relating to the journal paper assessing the quantile delta mapping technique
used to produce CIH climate projections data. 

### Study design

- Observations: AGCD
- Variables: tasmax, tasmin and pr (daily)
- Spatial domain - Australian land surface
- CMIP6 models:
  - ACCESS-CM2 (r4)
  - ACCESS-ESM1.5 (r6)
  - CESM2 (r1)
  - CMCC-ESM2 (r1)
  - CNRM-ESM2-1 (r1)
  - EC-Earth3 (r1)
  - NorESM2-MM (r1)
- AGCD baseline: 1990-2019
- CMIP6 historical baseline: 1995-2014
- CMIP6 future experiment: ssp370
- CMIP6 future period: 2056-2085 (i.e. 2070)
  - The other time periods used for the CMIP5 projections were 2016-2045 (2030) and 2036-2065 (2050)
- Methods:
  - mdc: mean delta change 
  - qdc: quantile delta change
    - with no adjustment to match the model mean change
    - adjusted to match the model monthly mean change
    - adjusted to match the model annual mean change

