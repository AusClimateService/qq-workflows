# CIH quantile delta mapping configuration
#
# The required user defined variables are:
# - VAR (options: tasmin tasmax pr rsds)
# - MODEL (options: ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 EC-Earth3 NorESM2-MM)
# - EXPERIMENT (options: any ScenarioMIP e.g. ssp370)
# - REF_START (start of reference/future time period)
# - REF_END (end of reference/future time period)
#
# Example usage:
#   make [target] [-Bn] CONFIG=cih/config_cih.mk VAR=pr MODEL=ACCESS-ESM1-5
#                       EXPERIMENT=ssp370 REF_START=2056 REF_END=2085
#

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

## Method options
METHOD=qdm
INTERP=nearest
OUTPUT_GRID=input
TARGET_START=1985
TARGET_END=2014
HIST_START=1985
HIST_END=2014
REF_TIME=--ref_time
SPLIT_SCRIPT=/home/599/dbi599/qq-workflows/cihp13/split-by-year.sh

## Variable options
$(call check_defined, VAR)

ifeq (${VAR}, pr)
SCALING=multiplicative
NQUANTILES=1000
METHOD_DESCRIPTION=${METHOD}-${SCALING}-q${NQUANTILES}
SSR=--ssr
HIST_VAR=pr
REF_VAR=pr
TARGET_VAR=precip
OUTPUT_UNITS="mm day-1"
HIST_UNITS="kg m-2 s-1"
REF_UNITS="kg m-2 s-1"
TARGET_UNITS="mm day-1"
OBS_DATASET=AGCD
else ifeq (${VAR}, tasmin)
SCALING=additive
NQUANTILES=100
GROUPING=--time_grouping monthly
METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
HIST_VAR=tasmin
REF_VAR=tasmin
TARGET_VAR=tmin
OUTPUT_UNITS=C
HIST_UNITS=K
REF_UNITS=K
TARGET_UNITS=C
OBS_DATASET=AGCD
else ifeq (${VAR}, tasmax)
SCALING=additive
NQUANTILES=100
GROUPING=--time_grouping monthly
METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
HIST_VAR=tasmax
REF_VAR=tasmax
TARGET_VAR=tmax
OUTPUT_UNITS=C
HIST_UNITS=K
REF_UNITS=K
TARGET_UNITS=C
OBS_DATASET=AGCD
else ifeq (${VAR}, rsds)
SCALING=additive
NQUANTILES=100
GROUPING=--time_grouping monthly
METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
HIST_VAR=rsds
REF_VAR=rsds
TARGET_VAR=ssrd
OUTPUT_UNITS="W m-2"
HIST_UNITS="W m-2"
REF_UNITS="W m-2"
TARGET_UNITS="W m-2"
OBS_DATASET=ERA5
else ifeq (${VAR}, hurs)
SCALING=additive
NQUANTILES=100
GROUPING=--time_grouping monthly
METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
HIST_VAR=hurs
REF_VAR=hurs
TARGET_VAR=hurs
OUTPUT_UNITS="%"
HIST_UNITS="%"
REF_UNITS="%"
TARGET_UNITS="%"
OBS_DATASET=ERA5
VALID_MIN=--valid_min 0
VALID_MAX=--valid_max 100
else ifeq (${VAR}, hursmin)
SCALING=additive
NQUANTILES=100
GROUPING=--time_grouping monthly
METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
HIST_VAR=hursmin
REF_VAR=hursmin
TARGET_VAR=hursmin
OUTPUT_UNITS="%"
HIST_UNITS="%"
REF_UNITS="%"
TARGET_UNITS="%"
OBS_DATASET=ERA5
VALID_MIN=--valid_min 0
VALID_MAX=--valid_max 100
else ifeq (${VAR}, hursmax)
SCALING=additive
NQUANTILES=100
GROUPING=--time_grouping monthly
METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
HIST_VAR=hursmax
REF_VAR=hursmax
TARGET_VAR=hursmax
OUTPUT_UNITS="%"
HIST_UNITS="%"
REF_UNITS="%"
TARGET_UNITS="%"
OBS_DATASET=ERA5
VALID_MIN=--valid_min 0
VALID_MAX=--valid_max 100
endif

## Model options
$(call check_defined, MODEL)

ifeq (${MODEL}, ACCESS-CM2)
NCI_LOC=fs38/publications
RUN=r4i1p1f1
else ifeq (${MODEL}, ACCESS-ESM1-5)
NCI_LOC=fs38/publications
RUN=r6i1p1f1
else ifeq (${MODEL}, CESM2)
NCI_LOC=oi10/replicas
RUN=r11i1p1f1
## FIXME: No tasmin or tasmax on NCI
else ifeq (${MODEL}, CMCC-ESM2)
NCI_LOC=oi10/replicas
RUN=r1i1p1f1
else ifeq (${MODEL}, CNRM-ESM2-1)
NCI_LOC=oi10/replicas
RUN=r1i1p1f2
else ifeq (${MODEL}, EC-Earth3)
NCI_LOC=oi10/replicas
RUN=r1i1p1f1
else ifeq (${MODEL}, NorESM2-MM)
NCI_LOC=oi10/replicas
RUN=r1i1p1f1
endif

# Input data files
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
$(call check_defined, NCI_LOC)
$(call check_defined, HIST_VAR)
$(call check_defined, REF_VAR)
$(call check_defined, TARGET_VAR)
$(call check_defined, OBS_DATASET)

HIST_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/CMIP/*/${MODEL}/historical/${RUN}/day/${HIST_VAR}/*/v*/*.nc))
REF_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/ScenarioMIP/*/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/*/v*/*.nc))
ifeq (${OBS_DATASET}, AGCD)
TARGET_DATA := $(sort $(wildcard /g/data/xv83/agcd-csiro/${TARGET_VAR}/daily/*_${OBS_DATASET}-CSIRO_r005_198[5,6,7,8,9]*_daily.nc) $(wildcard /g/data/xv83/agcd-csiro/${TARGET_VAR}/daily/*_${OBS_DATASET}-CSIRO_r005_199*_daily.nc) $(wildcard /g/data/xv83/agcd-csiro/${TARGET_VAR}/daily/*_${OBS_DATASET}-CSIRO_r005_200*_daily.nc) $(wildcard /g/data/xv83/agcd-csiro/${TARGET_VAR}/daily/*_${OBS_DATASET}-CSIRO_r005_201[0,1,2,3,4]*_daily.nc))
else ifeq (${OBS_DATASET}, ERA5)
TARGET_DATA := $(sort $(wildcard /g/data/wp00/data/observations/ERA5/${TARGET_VAR}/daily/${TARGET_VAR}_ERA-5_day_aus0.05_198[5,6,7,8,9].nc) $(wildcard /g/data/wp00/data/observations/ERA5/${TARGET_VAR}/daily/${TARGET_VAR}_ERA-5_day_aus0.05_199[0,1,2,3,4,5,6,7,8,9].nc) $(wildcard /g/data/wp00/data/observations/ERA5/${TARGET_VAR}/daily/${TARGET_VAR}_ERA-5_day_aus0.05_200[0,1,2,3,4,5,6,7,8,9].nc) $(wildcard /g/data/wp00/data/observations/ERA5/${TARGET_VAR}/daily/${TARGET_VAR}_ERA-5_day_aus0.05_201[0,1,2,3,4].nc))
endif

## Output data files
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
$(call check_defined, REF_VAR)
$(call check_defined, METHOD)
$(call check_defined, SCALING)
$(call check_defined, NQUANTILES)
$(call check_defined, REF_START)
$(call check_defined, REF_END)
$(call check_defined, HIST_START)
$(call check_defined, HIST_END)

OUTPUT_AF_DIR=/g/data/wp00/data/QQ-CMIP6/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}
AF_FILE=${REF_VAR}-${METHOD_DESCRIPTION}-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_gn_${REF_START}0101-${REF_END}1231_wrt_${HIST_START}0101-${HIST_END}1231.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=/g/data/wp00/data/QQ-CMIP6/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}
QQ_BASE=${REF_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_AUS-r005_${REF_START}0101-${REF_END}1231_${METHOD_DESCRIPTION}-${INTERP}_${OBS_DATASET}-${TARGET_START}0101-${TARGET_END}1231_historical-${HIST_START}0101-${HIST_END}1231
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc

OUTPUT_VALIDATION_DIR=${OUTPUT_QQ_DIR}
VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb

ifeq (${VAR}, rsds)
MAX_DIR=/g/data/wp00/data/observations/ERA5/ssrdc/daily
MAX_DATA := $(sort $(wildcard ${MAX_DIR}/ssrdc_ERA-5_day_aus0.05_198[5,6,7,8,9].nc) $(wildcard ${MAX_DIR}/ssrdc_ERA-5_day_aus0.05_199*.nc) $(wildcard ${MAX_DIR}/ssrdc_ERA-5_day_aus0.05_200*.nc) $(wildcard ${MAX_DIR}/ssrdc_ERA-5_day_aus0.05_201[0,1,2,3,4].nc))
MAX_VAR=ssrdc
QQCLIPPED_BASE=${REF_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_AUS-r005_${REF_START}0101-${REF_END}1231_${METHOD_DESCRIPTION}-${INTERP}-ssrdc-clipped_${OBS_DATASET}-${TARGET_START}0101-${TARGET_END}1231_historical-${HIST_START}0101-${HIST_END}1231
QQCLIPPED_PATH=${OUTPUT_QQ_DIR}/${QQCLIPPED_BASE}.nc
CLIP_VALIDATION=-p qq_clipped_file ${QQCLIPPED_PATH}
FINAL_QQ_PATH=${QQCLIPPED_PATH}
else
FINAL_QQ_PATH=${QQ_PATH}
endif

