# CIH quantile delta mapping configuration
#
# The required user defined variables are:
# - VAR (options: tasmin tasmax pr rsds hurs hursmin hursmax sfcWind)
# - OBS_DATASET (options: AGCD BARRA-R2)
# - MODEL (options: ACCESS-CM2 ACCESS-ESM1-5 CMCC-ESM2 CESM2 EC-Earth3 NorESM2-MM UKESM1-0-LL)
# - EXPERIMENT (options: any ScenarioMIP e.g. ssp370)
# - REF_START (start of reference/future time period)
# - REF_END (end of reference/future time period)
#
# Example usage:
#   make [target] [-Bn] CONFIG=cih/config_cih.mk VAR=pr OBS_DATASET=AGCD MODEL=ACCESS-ESM1-5
#                       EXPERIMENT=ssp370 REF_START=2035 REF_END=2064
#

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
  METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
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
  METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
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
  METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
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
  METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
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
  METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
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
  METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
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
  METHOD_DESCRIPTION=${METHOD}-${SCALING}-monthly-q${NQUANTILES}
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
  RUN=r4i1p1f1
else ifeq (${MODEL}, ACCESS-ESM1-5)
  NCI_LOC=fs38/publications
  RUN=r6i1p1f1
else ifeq (${MODEL}, CESM2)
  NCI_LOC=oi10/replicas
  RUN=r11i1p1f1
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
else ifeq (${MODEL}, UKESM1-0-LL)
  NCI_LOC=oi10/replicas
  RUN=r1i1p1f2
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

HIST_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/CMIP/*/${MODEL}/historical/${RUN}/day/${HIST_VAR}/*/v*/*.nc))
REF_DATA := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/ScenarioMIP/*/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/*/v*/*.nc))
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
TARGET_DATA = $(sort $(wildcard ${TARGET_DIR}/*_198[5,6,7,8,9]*.nc) $(wildcard ${TARGET_DIR}/*_199*.nc) $(wildcard ${TARGET_DIR}/*_200*.nc) $(wildcard ${TARGET_DIR}/*_201[0,1,2,3,4]*.nc))

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

OUTPUT_AF_DIR=/g/data/wp00/data/QDC-CMIP6/${OBS_DATASET}/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${REF_START}-${REF_END}
AF_FILE=${REF_VAR}-${METHOD_DESCRIPTION}-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_gn_${REF_START}0101-${REF_END}1231_wrt_${HIST_START}0101-${HIST_END}1231.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=${OUTPUT_AF_DIR}
QQ_BASE=${REF_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_START}0101-${REF_END}1231_${METHOD_DESCRIPTION}-${INTERP}_${OBS_DATASET}-${TARGET_START}0101-${TARGET_END}1231_historical-${HIST_START}0101-${HIST_END}1231
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc

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

  MAX_DATA = $(sort $(wildcard ${MAX_DIR}/*_198[5,6,7,8,9]*.nc) $(wildcard ${MAX_DIR}/*_199*.nc) $(wildcard ${MAX_DIR}/*_200*.nc) $(wildcard ${MAX_DIR}/*_201[0,1,2,3,4]*.nc))
  QQCLIPPED_BASE=${REF_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_${OUTPUT_GRID_LABEL}_${REF_START}0101-${REF_END}1231_${METHOD_DESCRIPTION}-${INTERP}-rsdscs-clipped_${OBS_DATASET}-${TARGET_START}0101-${TARGET_END}1231_historical-${HIST_START}0101-${HIST_END}1231
  QQCLIPPED_PATH=${OUTPUT_QQ_DIR}/${QQCLIPPED_BASE}.nc
  CLIP_VALIDATION=-p qq_clipped_file ${QQCLIPPED_PATH}
  FINAL_QQ_PATH=${QQCLIPPED_PATH}
else
  FINAL_QQ_PATH=${QQ_PATH}
endif

