# Quantile delta mapping configuration
#
# The required user defined variables are:
# - GROUPBY (options: month none)
# - MODEL_TYPE (options: GCM, RCM)
#
# Example usage:
#   make [target] [-Bn] CONFIG=cih/config_qdm.mk

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

## Method options
VAR=pr
MODEL=ACCESS-ESM1-5
EXPERIMENT=ssp370
RUN=r6i1p1f1
REF_START=2070
REF_END=2099
METHOD=qdm
NQUANTILES=100
INTERP=nearest
OUTPUT_GRID=input
TARGET_START=1985
TARGET_END=2014
HIST_START=1985
HIST_END=2014
REF_TIME=--ref_time

## Variable options
$(call check_defined, VAR)

SCALING=multiplicative
SSR=--ssr
HIST_VAR=pr
REF_VAR=pr
TARGET_VAR=precip
OUTPUT_UNITS="mm day-1"
HIST_UNITS="kg m-2 s-1"
REF_UNITS="kg m-2 s-1"
TARGET_UNITS="mm day-1"

## Model options
$(call check_defined, MODEL)

ifeq (${MODEL}, ACCESS-ESM1-5)
HIST_VERSION=v20191115
REF_VERSION=v20191115
MODEL_GRID=gn
NCI_LOC=fs38/publications
endif
OBS_DATASET=AGCD

# Input data files
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
$(call check_defined, NCI_LOC)
$(call check_defined, HIST_VAR)
$(call check_defined, REF_VAR)
$(call check_defined, TARGET_VAR)
$(call check_defined, MODEL_GRID)
$(call check_defined, HIST_VERSION)
$(call check_defined, REF_VERSION)

HIST_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/CMIP/*/${MODEL}/historical/${RUN}/day/${HIST_VAR}/${MODEL_GRID}/${HIST_VERSION}/*.nc))
REF_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/ScenarioMIP/*/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${MODEL_GRID}/${REF_VERSION}/*.nc))
TARGET_DATA := $(wildcard /g/data/xv83/agcd-csiro/${TARGET_VAR}/daily/*_AGCD-CSIRO_r005_*_daily_space-chunked.zarr)

## Output data files
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
$(call check_defined, REF_VAR)
$(call check_defined, MODEL_GRID)
$(call check_defined, METHOD)
$(call check_defined, SCALING)
$(call check_defined, NQUANTILES)
$(call check_defined, REF_START)
$(call check_defined, REF_END)
$(call check_defined, HIST_START)
$(call check_defined, HIST_END)

ifeq (${GROUPBY}, month)
GROUPING=--time_grouping monthly
METHOD_INSERT=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
else
METHOD_INSERT=${METHOD}-${SCALING}-q${NQUANTILES}
endif

OUTPUT_DIR=/g/data/wp00/users/dbi599/QQ-comparison/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${METHOD}

OUTPUT_AF_DIR=${OUTPUT_DIR}
AF_FILE=${REF_VAR}-${METHOD_INSERT}-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_${MODEL_GRID}_${REF_START}0101-${REF_END}1231_wrt_${HIST_START}0101-${HIST_END}1231.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=${OUTPUT_DIR}
QQ_BASE=${REF_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_AUS-r005_${REF_START}0101-${REF_END}1231_${METHOD_INSERT}-${INTERP}_${OBS_DATASET}-${TARGET_START}0101-${TARGET_END}1231_historical-${HIST_START}0101-${HIST_END}1231
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc
QQ_PATH_CIH=${OUTPUT_QQ_DIR}/${QQ_BASE}_cih.nc

OUTPUT_VALIDATION_DIR=${OUTPUT_DIR}
VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb


