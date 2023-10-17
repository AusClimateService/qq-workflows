# qq-workflows

This repository contains code used to coordinate workflows
that use the qq-scaling command line programs at:  
https://github.com/climate-innovation-hub/qqscale

Generic makefiles and template notebooks can be found in the top directory.
Each subdirectory then contains configuration makefiles and
executed notebooks relating to specific projects.

The steps involved in using the `Makefile` to build an execute a workflow
for a particular project (`project/`) are:
1. Create a configuration makefile (e.g. `project/my_config.mk`) 
1. Run `make [target] [-nB] CONFIG=project/my_config.mk` to implement either QDM or ECDFm.

The targets are `train`, `adjust` or `validation` (run `make help` for details),
while `-n` is a dry run (i.e. just print the commands to the screen without running them)
and `-B` forces all steps to be run
(i.e. even if make thinks the output files already exist and are up-to-date).

Other useful scripts include:
- `make_qdm_post-processing.mk`: Makefile for applying standard CIH file metadata to QDM data.
- `bias_correct_timeseries.sh`: Bias correct a long timeseries via sliding window.
- `npcp_ecdfm.sh` calls `job_npcp.sh` multiple times to process the entire NPCP ECDFm dataset
