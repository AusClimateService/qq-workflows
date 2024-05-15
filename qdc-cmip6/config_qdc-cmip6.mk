# Quantile Delta Change configuration
#
# The required user defined variables are:
# - METHOD (options: qdm ecdfm)
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
METHOD=qdc
INTERP=linear
OUTPUT_GRID=input
REF_TIME=--ref_time
OUTPUT_TIME_UNITS=--output_time_units days_since_1850-01-01
SPLIT_SCRIPT=/home/599/dbi599/qq-workflows/cihp13/split-by-year.sh

## Variable options
$(call check_defined, VAR)

ifeq (${VAR}, pr)
  SCALING=multiplicative
  NQUANTILES=1000
  METHOD_DESCRIPTION=qdc-${SCALING}-q${NQUANTILES}
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
  TARGET_DIR=/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/${TARGET_VAR}/v20231001
  OUTPUT_GRID_LABEL=AUS-11
endif
TARGET_DATA = $(sort $(wildcard ${TARGET_DIR}/*.nc))

## Output data files
$(call check_defined, EXPERIMENT)
$(call check_defined, RUN)
$(call check_defined, REF_VAR)
$(call check_defined, SCALING)
$(call check_defined, NQUANTILES)
$(call check_defined, REF_START)
$(call check_defined, REF_END)
$(call check_defined, HIST_START)
$(call check_defined, HIST_END)

ifdef REF_GWL
  REF_TBOUNDS=${REF_GWL}-${REF_START}0101-${REF_END}1231
  REF_DIR_LABEL=${REF_GWL}
else
  REF_TBOUNDS=${REF_START}0101-${REF_END}1231
  REF_DIR_LABEL=${REF_START}-${REF_END}
endif

ifdef BASE_GWL
  HIST_TBOUNDS=${BASE_GWL}-${HIST_START}0101-${HIST_END}1231
  TARGET_TBOUNDS=${BASE_GWL}-${TARGET_START}0101-${TARGET_END}1231
else
  HIST_TBOUNDS=${HIST_START}0101-${HIST_END}1231
  TARGET_TBOUNDS=${TARGET_START}0101-${TARGET_END}1231
endif

OUTPUT_AF_DIR=/g/data/ia39/australian-climate-service/test-data/QDC-CMIP6/${OBS_DATASET}/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${REF_DIR_LABEL}
AF_FILE=${REF_VAR}-${METHOD_DESCRIPTION}-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_gn_${REF_TBOUNDS}_wrt_${HIST_TBOUNDS}.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=${OUTPUT_AF_DIR}
QQ_BASE=${REF_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_TBOUNDS}_${METHOD_DESCRIPTION}-${INTERP}_${OBS_DATASET}-baseline-${TARGET_TBOUNDS}_model-baseline-${HIST_TBOUNDS}
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc
METADATA_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.yaml

OUTPUT_VALIDATION_DIR=${OUTPUT_QQ_DIR}
VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb

ifeq (${VAR}, rsds)
  ifeq (${OBS_DATASET}, ERA5)
    MAX_DIR=/g/data/wp00/data/observations/ERA5/ssrdc/daily
    MAX_VAR=ssrdc
  else ifeq (${OBS_DATASET}, BARRA-R2)
    MAX_DIR=/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/rsdscs/v20231001
    MAX_VAR=rsdscs
  endif
  $(call check_defined, MAX_DIR)
  $(call check_defined, MAX_VAR)

  MAX_DATA = $(sort $(wildcard ${MAX_DIR}/*.nc))
  QQCLIPPED_BASE=${REF_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_TBOUNDS}_${METHOD_DESCRIPTION}-${INTERP}-rsdscs-clipped_${OBS_DATASET}-baseline-${TARGET_TBOUNDS}1231_model-baseline-${HIST_TBOUNDS}
  QQCLIPPED_PATH=${OUTPUT_QQ_DIR}/${QQCLIPPED_BASE}.nc
  CLIP_VALIDATION=-p qq_clipped_file ${QQCLIPPED_PATH}
  FINAL_QQ_PATH=${QQCLIPPED_PATH}
else
  FINAL_QQ_PATH=${QQ_PATH}
endif

