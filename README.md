# qq-workflows

This repository contains code used to coordinate workflows
that use the qq-scaling command line programs at:  
https://github.com/AusClimateService/qqscale

Generic makefiles and template notebooks can be found in the top directory.
Each subdirectory then contains configuration makefiles and
executed notebooks relating to specific projects.

The steps involved in using the `Makefile` to build an execute a workflow
for a particular project (`project/`) are:
1. Create a configuration makefile (e.g. `project/my_config.mk`) 
1. Run `make [target] [-nB] CONFIG=project/my_config.mk` to implement either QDC or ECDFm.

`-n` is a dry run (i.e. just print the commands to the screen without running them)
and `-B` forces all steps to be run
(i.e. even if make thinks the output files already exist and are up-to-date).

The `Makefile` runs python programs in the
`/g/data/xv83/quantile-mapping/miniconda3/envs/qq-workflows` conda environment,
which is described by `environment.yml`.

