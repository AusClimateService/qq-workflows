# QDC-CMIP6

This directory contains the configuration files used to produce the QDC-CMIP6 dataset.

## Methodology

The QDC-CMIP6 dataset has been produced by applying the
[Quantile Delta Change](https://github.com/AusClimateService/qqscale/blob/master/docs/method_qdc.md) (QDC) method
to data from the [Coupled Model Intercomparison Project Phase 6](https://pcmdi.llnl.gov/CMIP6/) (CMIP6).
The QDC method involves calculating quantile changes between an historical and future climate model simulation
and applying those quantile changes to observations in order to produce timeseries data for a future time period.
For information on how the QDC method compares against other alteratives,
refer to the [NPCP bias correction intercomparison](https://github.com/AusClimateService/npcp) project.

## Workflow Execution

Run the following at the command line:

1. `python run_qdc-cmip6.py adjust {options}` to produce the data files.  
1. `python run_qdc-cmip6.py validation {options}` to produce the corresponding validation notebook.  
1. `python run_qdc-cmip6.py split-by-year` to split and compress the data files.  
1. `python run_qdc-cmip6.py clean-up` to delete the original (not split or compressed) data files. 

The various `{options}` (i.e. the variables, models, experiments etc that you want to process)
can be viewed by running `python run_qdc-cmip6.py -h`.

## Versions

- [Version 0.0](specs_qdc-cmip6_v0.md): Test data for the Ag2050 project.
- [Version 1.0](specs_qdc-cmip6_v1.md): All CMIP6 GCMs selected for downscaling by the Australian Climate Service.
- Version 1.1 (still to come): Add a broader selection of CMIP6 GCMs.
- Version 1.2 (still to come): Add CORDEX-Australisia downscaled data (see details [here](https://opus.nci.org.au/display/CMIP/CMIP6-CORDEX+datasets)). 
- Version 2.0 (still to come): Replacement of BARRA-R2 (~12km resolution) with BARRA-C2 (~4.4km)

Additional variables and timescales may also be added along the way as identified by users
(see https://github.com/AusClimateService/qq-workflows/issues/3 for suggested additions).
