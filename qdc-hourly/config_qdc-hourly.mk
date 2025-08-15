# Quantile Delta Change configuration
#
# The required user defined variables are:
# - VAR (options: tasmin tasmax pr rsds hurs hursmin hursmax sfcWind)
# - EXPERIMENT (options: any ScenarioMIP e.g. ssp370)
# - GCM (options: ACCESS-CM2)
# - RCM (options: CCAM-v2203-SN)
# - RUN (e.g. r4i1p1f1)
# - OBS (options: BARRA-R2)
# - HOUR (e.g. 01)
# - REF_START (start of reference/future model time period)
# - REF_END (end of reference/future model time period)
# - HIST_START (start of historical/baseline model time period)
# - HIST_END (end of historical/baseline model time period)
# - TARGET_START (start of target/observations time period)
# - TARGET_END (end of target/observations time period)

# Example usage:
#   make [target] [-Bn] CONFIG=qdc-hourly/config_qdc-hourly.mk VAR=tas EXPERIMENT=ssp370
#                       GCM=ACCESS-CM2 RCM=CCAM-v2203-SN RUN=r4i1p1f1 OBS=BARRA-R2 HOUR=02
#                       REF_START=2070 REF_END=2099 HIST_START=1985 HIST_END=2014 
#                       TARGET_START=1985 TARGET_END=2014

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

PYTHON=/g/data/xv83/quantile-mapping/miniconda3/envs/qq-workflows/bin/python

## Method options
HOUR_SELECTION=--isel_hour ${HOUR}
INTERP=linear
OUTPUT_GRID=input
REF_TIME=--ref_time
OUTPUT_TIME_UNITS=--output_time_units days_since_1850-01-01
PROJECT_ID=qdc-hourly
#TODO: Add hour selection (and to output file names below)

## Variable options
$(call check_defined, VAR)

ifeq (${VAR}, tas)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  AF_SMOOTHING=${INTERP}
  HIST_VAR=tas
  HIST_UNITS=K
  REF_VAR=tas
  REF_UNITS=K
  TARGET_VAR=tas
  TARGET_UNITS=K
  OUTPUT_UNITS=C
  OUTPUT_VAR=tas
endif

# Input data files
$(call check_defined, EXPERIMENT)
$(call check_defined, GCM)
$(call check_defined, RCM)
$(call check_defined, RUN)
$(call check_defined, OBS)
$(call check_defined, HIST_VAR)
$(call check_defined, REF_VAR)
$(call check_defined, TARGET_VAR)
$(call check_defined, TARGET_UNITS)

HIST_FILES := /g/data/hq89/CCAM/output/CMIP6/DD/AUS-10i/CSIRO/${GCM}/historical/${RUN}/${RCM}/v1-r1/1hr/${HIST_VAR}/v20231206/*.nc
REF_FILES := /g/data/hq89/CCAM/output/CMIP6/DD/AUS-10i/CSIRO/${GCM}/${EXPERIMENT}/${RUN}/${RCM}/v1-r1/1hr/${REF_VAR}/v20231206/*.nc
HIST_DATA := ${HIST_FILES} ${REF_FILES}
REF_DATA := ${HIST_DATA}

OUTPUT_GRID_LABEL=AUS-11
TARGET_DATA := /g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/1hr/tas/v20250528/*.nc

## Output data files
$(call check_defined, REF_VAR)
$(call check_defined, OUTPUT_VAR)
$(call check_defined, SCALING)
$(call check_defined, NQUANTILES)
$(call check_defined, REF_START)
$(call check_defined, REF_END)
$(call check_defined, HIST_START)
$(call check_defined, HIST_END)

REF_TBOUNDS=${REF_START}-${REF_END}
REF_DIR_LABEL=${REF_START}-${REF_END}

HIST_TBOUNDS=${HIST_START}-${HIST_END}
TARGET_TBOUNDS=${TARGET_START}-${TARGET_END}

OUTPUT_AF_DIR=/g/data/ia39/australian-climate-service/test-data/QDC-hourly/${OBS}/${GCM}/${EXPERIMENT}/${RUN}/${RCM}/v1-r1/1hr/${OUTPUT_VAR}/v20250805
AF_FILE=${OUTPUT_VAR}-${METHOD_DESCRIPTION}-adjustment-factors_AUS-10i_${GCM}_${EXPERIMENT}_${RUN}_${RCM}_v1-r1_1hr-${HOUR}_${REF_TBOUNDS}_wrt_${HIST_TBOUNDS}.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=${OUTPUT_AF_DIR}
QQ_BASE=${OUTPUT_VAR}_${OUTPUT_GRID_LABEL}_${GCM}_${EXPERIMENT}_${RUN}_${RCM}_v1-r1_1hr-${HOUR}_${REF_TBOUNDS}_${METHOD_DESCRIPTION}-${AF_SMOOTHING}_${OBS}-baseline-${TARGET_TBOUNDS}_model-baseline-${HIST_TBOUNDS}
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc
METADATA_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.yaml
METADATA_OPTIONS=--variable ${TARGET_VAR} --units ${OUTPUT_UNITS} --obs ${OBS} --gcm_name ${GCM} --rcm_name ${RCM} --model_experiment ${EXPERIMENT} --model_run ${RUN} --hist_tbounds ${HIST_TBOUNDS} --ref_tbounds ${REF_TBOUNDS} --target_tbounds ${TARGET_TBOUNDS}

OUTPUT_VALIDATION_DIR=${OUTPUT_QQ_DIR}
VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb

FINAL_QQ_PATH=${QQ_PATH}

