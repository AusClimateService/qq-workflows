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

# The optional user defined variables are:
# - BASE_GWL (baseline global warming level; gwl followed by number with no decimal point, e.g. gwl10, gwl12, gwl15, gwl20, gwl30, gwl40)
# - REF_GWL (reference/future global warming level; gwl15, gwl20, gwl30, gwl40) 

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

## Method options
INTERP=linear
OUTPUT_GRID=input
REF_TIME=--ref_time
OUTPUT_TIME_UNITS=--output_time_units days_since_1850-01-01
PROJECT_ID=qdc-cmip6

## Variable options
$(call check_defined, VAR)

ifeq (${VAR}, pr)
  SCALING=multiplicative
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
#  NQUANTILES=1000
#  METHOD_DESCRIPTION=qdc-${SCALING}-q${NQUANTILES}
  MAX_AF=--max_af 5
  SSR=--ssr
  HIST_VAR=pr
  HIST_UNITS="kg m-2 s-1"
  REF_VAR=pr
  REF_UNITS="kg m-2 s-1"
  ifeq (${OBS_DATASET}, AGCD)
    TARGET_VAR=precip
    TARGET_UNITS="mm day-1"
  else
    TARGET_VAR=pr
    TARGET_UNITS="kg m-2 s-1"
  endif
  OUTPUT_UNITS="mm day-1"
  OUTPUT_VAR=pr
else ifeq (${VAR}, tasmin)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  HIST_VAR=tasmin
  HIST_UNITS=K
  REF_VAR=tasmin
  REF_UNITS=K
  ifeq (${OBS_DATASET}, AGCD)
    TARGET_VAR=tmin
    TARGET_UNITS=C
  else
    TARGET_VAR=tasmin
    TARGET_UNITS=K
  endif
  OUTPUT_UNITS=C
  OUTPUT_VAR=tasmin
else ifeq (${VAR}, tasmax)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  HIST_VAR=tasmax
  HIST_UNITS=K  
  REF_VAR=tasmax
  REF_UNITS=K
  TARGET_VAR=tmax
  ifeq (${OBS_DATASET}, AGCD)
    TARGET_VAR=tmax
    TARGET_UNITS=C
  else
    TARGET_VAR=tasmax
    TARGET_UNITS=K
  endif
  OUTPUT_UNITS=C
  OUTPUT_VAR=tasmax
else ifeq (${VAR}, rsds)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  HIST_VAR=rsds
  HIST_UNITS="W m-2"
  REF_VAR=rsds
  REF_UNITS="W m-2"
  ifeq (${OBS_DATASET}, ERA5)
    TARGET_VAR=ssrd
    TARGET_UNITS="W m-2"
  else
    TARGET_VAR=rsds
    TARGET_UNITS="W m-2"
  endif
  OUTPUT_UNITS="W m-2"
  OUTPUT_VAR=rsds
  VALID_MIN=--valid_min 0
else ifeq (${VAR}, hurs)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  HIST_VAR=hurs
  HIST_UNITS="%"
  REF_VAR=hurs
  REF_UNITS="%"
  TARGET_VAR=hurs
  TARGET_UNITS="%"
  OUTPUT_UNITS="%"
  OUTPUT_VAR=hurs
  VALID_MIN=--valid_min 0
  VALID_MAX=--valid_max 100
else ifeq (${VAR}, hursmax)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  HIST_VAR=hursmax
  HIST_UNITS="%"
  REF_VAR=hursmax
  REF_UNITS="%"
  TARGET_VAR=hursmax
  TARGET_UNITS="%"
  OUTPUT_UNITS="%"
  OUTPUT_VAR=hursmax
  VALID_MIN=--valid_min 0
  VALID_MAX=--valid_max 100
else ifeq (${VAR}, hursmin)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  HIST_VAR=hursmin
  HIST_UNITS="%"
  REF_VAR=hursmin
  REF_UNITS="%"
  TARGET_VAR=hursmin
  TARGET_UNITS="%"
  OUTPUT_UNITS="%"
  OUTPUT_VAR=hursmin
  VALID_MIN=--valid_min 0
  VALID_MAX=--valid_max 100
else ifeq (${VAR}, sfcWind)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  HIST_VAR=sfcWind
  HIST_UNITS="m s-1"
  REF_VAR=sfcWind
  REF_UNITS="m s-1"
  TARGET_VAR=sfcWind
  TARGET_UNITS="m s-1"
  OUTPUT_UNITS="m s-1"
  OUTPUT_VAR=sfcWind
  VALID_MIN=--valid_min 0
else ifeq (${VAR}, sfcWindmax)
  SCALING=additive
  NQUANTILES=100
  GROUPING=--time_grouping monthly
  METHOD_DESCRIPTION=qdc-${SCALING}-monthly-q${NQUANTILES}
  HIST_VAR=sfcWindmax
  HIST_UNITS="m s-1"
  REF_VAR=sfcWindmax
  REF_UNITS="m s-1"
  TARGET_VAR=sfcWindmax
  TARGET_UNITS="m s-1"
  OUTPUT_UNITS="m s-1"
  OUTPUT_VAR=sfcWindmax
  VALID_MIN=--valid_min 0
endif

## Model options
$(call check_defined, MODEL)

ifeq (${MODEL}, ACCESS-CM2)
  NCI_LOC=fs38/publications
else ifeq (${MODEL}, ACCESS-ESM1-5)
  NCI_LOC=fs38/publications
else
  NCI_LOC=oi10/replicas
endif

# Input data files
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
$(call check_defined, NCI_LOC)
$(call check_defined, HIST_VAR)
$(call check_defined, REF_VAR)
$(call check_defined, OBS_DATASET)
$(call check_defined, TARGET_VAR)
$(call check_defined, TARGET_UNITS)

HIST_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/CMIP/*/${MODEL}/historical/${RUN}/day/${HIST_VAR}/*/v*/*.nc) $(wildcard /g/data/${NCI_LOC}/CMIP6/ScenarioMIP/*/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/*/v*/*.nc))
REF_DATA := ${HIST_DATA}
ifeq (${OBS_DATASET}, AGCD)
  TARGET_DIR=/g/data/xv83/agcd-csiro/${TARGET_VAR}/daily
  OUTPUT_GRID_LABEL=AUS-05
else ifeq (${OBS_DATASET}, ERA5)
  TARGET_DIR=/g/data/wp00/data/observations/ERA5/${TARGET_VAR}/daily
  #TODO OUTPUT_GRID_LABEL=
else ifeq (${OBS_DATASET}, BARRA-R2)
  ifeq (${VAR}, hursmax)
    TARGET_BASEDIR=/g/data/ia39/australian-climate-service/test-data/observations
    KEEP_TARGET_HISTORY=--keep_history
  else ifeq (${VAR}, hursmin)
    TARGET_BASEDIR=/g/data/ia39/australian-climate-service/test-data/observations
    KEEP_TARGET_HISTORY=--keep_history
  else
    TARGET_BASEDIR=/g/data/ob53
  endif
  TARGET_DIR=${TARGET_BASEDIR}/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/${TARGET_VAR}/v20240809
  OUTPUT_GRID_LABEL=AUS-11
  TARGET_DROP_VARS=--drop_vars sigma level_height model_level_number crs
endif
TARGET_DATA := $(sort $(wildcard ${TARGET_DIR}/*.nc))

HIST_DROP_VARS=--hist_drop_vars height
REF_DROP_VARS=--ref_drop_vars height

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

ifdef REF_GWL
  REF_TBOUNDS=${REF_GWL}-${REF_START}-${REF_END}
  REF_DIR_LABEL=${REF_GWL}
else
  REF_TBOUNDS=${REF_START}-${REF_END}
  REF_DIR_LABEL=${REF_START}-${REF_END}
endif

ifdef BASE_GWL
  HIST_TBOUNDS=${BASE_GWL}-${HIST_START}-${HIST_END}
  TARGET_TBOUNDS=${BASE_GWL}-${TARGET_START}-${TARGET_END}
else
  HIST_TBOUNDS=${HIST_START}-${HIST_END}
  TARGET_TBOUNDS=${TARGET_START}-${TARGET_END}
endif

OUTPUT_AF_DIR=/g/data/ia39/australian-climate-service/test-data/QDC-CMIP6-v2/${OBS_DATASET}/${MODEL}/${EXPERIMENT}/${RUN}/day/${OUTPUT_VAR}/${REF_DIR_LABEL}
AF_FILE=${OUTPUT_VAR}-${METHOD_DESCRIPTION}-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_gn_${REF_TBOUNDS}_wrt_${HIST_TBOUNDS}.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=${OUTPUT_AF_DIR}
QQ_BASE=${OUTPUT_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_TBOUNDS}_${METHOD_DESCRIPTION}-${INTERP}-maxaf5_${OBS_DATASET}-baseline-${TARGET_TBOUNDS}_model-baseline-${HIST_TBOUNDS}
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc
METADATA_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.yaml
METADATA_OPTIONS=--variable ${TARGET_VAR} --units ${OUTPUT_UNITS} --obs ${OBS_DATASET} --model_name ${MODEL} --model_experiment ${EXPERIMENT} --model_run ${RUN} --hist_tbounds ${HIST_TBOUNDS} --ref_tbounds ${REF_TBOUNDS} --target_tbounds ${TARGET_TBOUNDS}

OUTPUT_VALIDATION_DIR=${OUTPUT_QQ_DIR}
VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb

ifeq (${VAR}, rsds)
  ifeq (${OBS_DATASET}, ERA5)
    MAX_DIR=/g/data/wp00/data/observations/ERA5/ssrdc/daily
    MAX_VAR=ssrdc
  else ifeq (${OBS_DATASET}, BARRA-R2)
    MAX_DIR=/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/rsdscs/v20240516
    MAX_VAR=rsdscs
  endif
  $(call check_defined, MAX_DIR)
  $(call check_defined, MAX_VAR)

  MAX_DATA = $(sort $(wildcard ${MAX_DIR}/*.nc))
  QQCLIPPED_BASE=${OUTPUT_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_TBOUNDS}_${METHOD_DESCRIPTION}-${INTERP}-rsdscs-clipped_${OBS_DATASET}-baseline-${TARGET_TBOUNDS}_model-baseline-${HIST_TBOUNDS}
  QQCLIPPED_PATH=${OUTPUT_QQ_DIR}/${QQCLIPPED_BASE}.nc
  CLIP_VALIDATION=-p qq_clipped_file ${QQCLIPPED_PATH}
  FINAL_QQ_PATH=${QQCLIPPED_PATH}
else ifeq (${VAR}, pr)
  QQCMATCH_BASE=${OUTPUT_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_TBOUNDS}_${METHOD_DESCRIPTION}-${INTERP}-maxaf5-annual-change-matched_${OBS_DATASET}-baseline-${TARGET_TBOUNDS}_model-baseline-${HIST_TBOUNDS}
  QQCMATCH_AF_BASE=${OUTPUT_VAR}-adjustment-factors_day_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_TBOUNDS}_${METHOD_DESCRIPTION}-${INTERP}-maxaf5-annual-change-matched_${OBS_DATASET}-baseline-${TARGET_TBOUNDS}_model-baseline-${HIST_TBOUNDS}
  QQCMATCH_PATH=${OUTPUT_QQ_DIR}/${QQCMATCH_BASE}.nc
  QQCMATCH_AF_PATH=${OUTPUT_QQ_DIR}/${QQCMATCH_AF_BASE}.nc
  CMATCH_VALIDATION=-p qq_cmatch_file ${QQCMATCH_PATH}
  FINAL_QQ_PATH=${QQCMATCH_PATH}
else
  FINAL_QQ_PATH=${QQ_PATH}
endif

