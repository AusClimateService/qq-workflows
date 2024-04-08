# CIHP-13

The Climate Innovation Hub CMIP6 application ready climate projections dataset is called CIHP-13.
This directory contains the configuration files used to produce that dataset.

## Methodology

The CIHP-13 dataset has been produced using the
[Quantile Delta Change](https://github.com/climate-innovation-hub/qqscale/blob/master/docs/method_qdc.md) (QDC) approach.
The QDC method involves calculating quantile changes between an historical and future climate model simulation
and applying those quantile changes to observations in order to produce timeseries data for a future time period
(i.e. "application ready climate projections").
For information on how the QDC method compares against other alteratives,
refer to the [NPCP bias correction intercomparison](https://github.com/AusClimateService/npcp) project.

## Execution

1. Edit `cih.sh` for the desired models, variables, experiments, time period etc.  
1. Run `bash cih.sh adjust` to produce the data files.  
1. Run `bash cih.sh validation` to produce the corresponding validation notebook.  
1. Run `bash cih.sh split-by-year` to split and compress the data files.  
1. Run `bash cih.sh clean-up` to delete the original (not split or compressed) data files. 

## Versions

- [Version 0](cihp13_v0.md): Test data for the Ag2050 project.
- [Version 1](cihp13_v1.md): All CMIP6 GCMs selected for downscaling by the Australian Climate Service.
- Version 1.1 (still to come): Add a broader selection of CMIP6 GCMs.
- Version 1.2 (still to come): Add CORDEX-Australisia downscaled data (see details [here](https://opus.nci.org.au/display/CMIP/CMIP6-CORDEX+datasets)). 
- Version 2.0 (still to come): Replacement of BARRA-R2 (~12km resolution) with BARRA-C2 (~4.4km)

Additional variables and timescales may also be added along the way as identified by users.
