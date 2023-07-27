# CIH quantile delta mapping configuration
#
# The user defined variables are:
# - VAR (options: tasmin tasmax pr)
# - MODEL (options: ACCESS-ESM1-5 ACCESS-CM2)
# - EXPERIMENT (options: any ScenarioMIP e.g. ssp370)
# - RUN (e.g. r1i1p1f1)
# - REF_START (start of reference/future time period)
# - REF_END (end of reference/future time period)
#
# Example usage:
#   make [target] [-Bn] CONFIG=cih/config_cih.mk VAR=pr MODEL=ACCESS-ESM1-5
#                       EXPERIMENT=ssp370 RUN=r1i1p1f1 REF_START=2056 REF_END=2085
#

## User provided variables

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

$(call check_defined, VAR)
$(call check_defined, MODEL)
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
$(call check_defined, REF_START)
$(call check_defined, REF_END)

## Preset/automatic variables

METHOD=qdm
NQUANTILES=100
INTERP=nearest
OUTPUT_GRID=input
TARGET_START=1990
TARGET_END=2019
HIST_START=1995
HIST_END=2014
REF_TIME=--ref_time

ifeq (${VAR}, pr)
SCALING=multiplicative
SSR=--ssr
HIST_VAR=pr
REF_VAR=pr
TARGET_VAR=precip
OUTPUT_UNITS="mm day-1"
HIST_UNITS="kg m-2 s-1"
REF_UNITS="kg m-2 s-1"
TARGET_UNITS="mm day-1"
else ifeq (${VAR}, tasmin)
SCALING=additive
GROUPING=--time_grouping monthly
HIST_VAR=tasmin
REF_VAR=tasmin
TARGET_VAR=tmin
OUTPUT_UNITS=C
HIST_UNITS=K
REF_UNITS=K
TARGET_UNITS=C
else ifeq (${VAR}, tasmax)
SCALING=additive
GROUPING=--time_grouping monthly
HIST_VAR=tasmax
REF_VAR=tasmax
TARGET_VAR=tmax
OUTPUT_UNITS=C
HIST_UNITS=K
REF_UNITS=K
TARGET_UNITS=C
endif

ifeq (${MODEL}, ACCESS-ESM1-5)
HIST_VERSION=v20191115
REF_VERSION=v20191115
MODEL_GRID=gn
NCI_LOC=fs38/publications
else ifeq (${MODEL}, ACCESS-CM2)
HIST_VERSION=v20210607
REF_VERSION=v20210712
MODEL_GRID=gn
NCI_LOC=fs38/publications
endif

OBS_DATASET=AGCD

HIST_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/CMIP/*/${MODEL}/historical/${RUN}/day/${HIST_VAR}/${MODEL_GRID}/${HIST_VERSION}/*.nc))
REF_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/ScenarioMIP/*/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${MODEL_GRID}/${REF_VERSION}/*.nc))
TARGET_DATA := $(wildcard /g/data/xv83/agcd-csiro/${TARGET_VAR}/daily/*_AGCD-CSIRO_r005_*_daily_space-chunked.zarr)

OUTPUT_AF_DIR=/g/data/wp00/data/QQ-CMIP6/${MODEL}/historical/${RUN}/day/${HIST_VAR}/${HIST_VERSION}
OUTPUT_QQ_DIR=/g/data/wp00/data/QQ-CMIP6/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${REF_VERSION}
OUTPUT_VALIDATION_DIR=/g/data/wp00/data/QQ-CMIP6/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${REF_VERSION}

AF_FILE=${REF_VAR}-${METHOD}-${SCALING}-monthly-q${NQUANTILES}-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_${MODEL_GRID}_${REF_START}0101-${REF_END}1231_wrt_${HIST_START}0101-${HIST_END}1231.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

QQ_BASE=${REF_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_AUS-r005_${REF_START}0101-${REF_END}1231_${METHOD}-${SCALING}-monthly-q${NQUANTILES}-${INTERP}_${OBS_DATASET}-${TARGET_START}0101-${TARGET_END}1231_historical-${HIST_START}0101-${HIST_END}1231
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc

VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb


