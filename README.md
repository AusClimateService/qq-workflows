# qq-workflows

This repository contains code used to coordinate workflows
that use the qq-scaling command line programs at:  
https://github.com/climate-innovation-hub/qqscale

Generic makefiles and template notebooks can be found in the top directory.
Each subdirectory then contains configuration makefiles and
executed notebooks relating to specific projects.

The steps involved in using the `Makefile` for a particular project (`project/`) are:
1. Create a configuration makefile (e.g. `project/my_config.mk`) 
1. Run `make validation CONFIG=project/my_config.mk` to implement either QDM or ECDFm

Other useful scripts include:
- `make_qdm_post-processing.mk`: Makefile for applying standard CIH file metadata to QDM data.
-  `bias_correct_timeseries.sh`: Bias correct a long timeseries via sliding window.
