# Quantile Delta Change configuration
#
# The required user defined variables are:
# - VAR (options: tasmin tasmax pr rsds hurs hursmin hursmax sfcWind)
# - OBS_DATASET (options: AGCD BARRA-R2)
# - MODEL (options: ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 EC-Earth3 NorESM2-MM UKESM1-0-LL)
# - EXPERIMENT (options: any ScenarioMIP e.g. ssp370)
# - RUN (e.g. r1i1p1f1)
# - REF_START (start of reference/future model time period)
# - REF_END (end of reference/future model time period)
# - HIST_START (start of historical/baseline model time period)
# - HIST_END (end of historical/baseline model time period)
# - TARGET_START (start of target/observations time period)
# - TARGET_END (end of target/observations time period)

# Example usage:
#   make [target] [-Bn] CONFIG=cih/config_cih.mk VAR=pr OBS_DATASET=AGCD MODEL=ACCESS-ESM1-5
#                       EXPERIMENT=ssp370 REF_START=2035 REF_END=2064 HIST_START=1985 HIST_END=2014 
#                       TARGET_START=1985 TARGET_END=2014

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

PYTHON=/g/data/xv83/quantile-mapping/miniconda3/envs/qq-workflows/bin/python

## Method options
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

## Model options
$(call check_defined, MODEL)

# Input data files
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
$(call check_defined, NCI_LOC)
$(call check_defined, HIST_VAR)
$(call check_defined, REF_VAR)
$(call check_defined, OBS_DATASET)
$(call check_defined, TARGET_VAR)
$(call check_defined, TARGET_UNITS)

HIST_FILES := /g/data/${NCI_LOC}/CMIP6/CMIP/*/${MODEL}/historical/${RUN}/day/${HIST_VAR}/*/v*/*.nc
REF_FILES := /g/data/${NCI_LOC}/CMIP6/ScenarioMIP/*/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/*/${REF_VERSION_PREFIX}*/*.nc
HIST_DATA := ${HIST_FILES} ${REF_FILES}
REF_DATA := ${HIST_DATA}

ifeq (${OBS_DATASET}, BARRA-R2)
  TARGET_BASEDIR=/g/data/ob53
endif
TARGET_DIR=${TARGET_BASEDIR}/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/${TARGET_VAR}/v20240809
OUTPUT_GRID_LABEL=AUS-11
TARGET_DATA := ${TARGET_DIR}/*.nc

## Output data files
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
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

OUTPUT_AF_DIR=/g/data/ia39/australian-climate-service/test-data/QDC-hourly/${OBS_DATASET}/${MODEL}/${EXPERIMENT}/${RUN}/1hr/${OUTPUT_VAR}/${REF_DIR_LABEL}
AF_FILE=${OUTPUT_VAR}-${METHOD_DESCRIPTION}-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_gn_${REF_TBOUNDS}_wrt_${HIST_TBOUNDS}.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=${OUTPUT_AF_DIR}
QQ_BASE=${OUTPUT_VAR}_1hr_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_TBOUNDS}_${METHOD_DESCRIPTION}-${AF_SMOOTHING}_${OBS_DATASET}-baseline-${TARGET_TBOUNDS}_model-baseline-${HIST_TBOUNDS}
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc
METADATA_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.yaml
METADATA_OPTIONS=--variable ${TARGET_VAR} --units ${OUTPUT_UNITS} --obs ${OBS_DATASET} --model_name ${MODEL} --model_experiment ${EXPERIMENT} --model_run ${RUN} --hist_tbounds ${HIST_TBOUNDS} --ref_tbounds ${REF_TBOUNDS} --target_tbounds ${TARGET_TBOUNDS}

OUTPUT_VALIDATION_DIR=${OUTPUT_QQ_DIR}
VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb

FINAL_QQ_PATH=${QQ_PATH}

