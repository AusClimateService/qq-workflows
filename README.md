# qq-workflows

When processing large datasets,
quantile-quantile scaling is a multi-step workflow:  
https://github.com/climate-innovation-hub/qqscale#data-processing

This repository contains Makefiles and template notebooks used to coordinate qq-scaling workflows.
Generic makefiles, template configuation files and template notebooks can be found in the top directory.
Each subdirectory then contains configuration files and notebooks relating to specific projects.

## Generic makefiles

The steps involved in using the `Makefile` for a particular project (`project/`) are:
1. Create a configuration file (e.g. `project/my_config.mk`) based on `config_qdm.mk` or `config_cdfm.mk`
1. Run `make all -f make_ssr.mk CONFIG=project/my_config.mk` if SSR is required.
1. Run `make apply-adjustment CONFIG=project/my_config.mk` to implement either QDM or CDFm

Additional processing steps for QDM
(e.g. applying standard CIH file metadata or matching the mean change)
can be applied using `make_qdm_post-processing.mk`.
Help information can be viewed by running `make help -f make_qdm_post-processing.mk`.
