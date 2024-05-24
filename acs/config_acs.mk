# ACS bias correction configuration
#
# The user defined variables are:
# - VAR (required; options: tasmin tasmax pr)
# - OBS_DATASET (required; options: AGCD BARRA-R2 AGCA-AGCD)
# - RCM_NAME (required; options: BARPA-R CCAM-v2203-SN)
# - GCM_NAME (required; options:
#               CMCC-ESM2
#               CNRM-ESM2-1
#               ACCESS-ESM1-5
#               ARCCSS-ACCESS-CM2
#               EC-Earth3
#               ERA5
#               MPI-ESM1-2-HR
#               CESM2
#               NorESM2-MM
#             )
# - TARGET_START (required; start year for target period)
# - TARGET_END (required; end year for target period)
# - OUTPUT_START (optional; start year for output data; default=TARGET_START)
# - OUTPUT_END (optional; end year for output data; default=TARGET_END)
#
# Example usage:
#   make [target] [-Bn] CONFIG=acs/config_acs.mk VAR=pr OBS_DATASET=AGCD RCM_NAME=BARPA-R
#                       GCM_NAME=ACCESS-ESM1-5 TARGET_START=2040 TARGET_END=2069
#                       OUTPUT_START=2050 OUTPUT_END=2059
#

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

## Method options
METHOD=ecdfm
NQUANTILES=100
GROUPING=--time_grouping monthly
INTERP=nearest
HIST_START=1985
HIST_END=2014
REF_START=1985
REF_END=2014
OUTPUT_GRID=input
OUTPUT_START=${TARGET_START}
OUTPUT_END=${TARGET_END}
OUTPUT_TSLICE=--output_tslice ${OUTPUT_START}-01-01 ${OUTPUT_END}-12-31
SPLIT_SCRIPT=/g/data/xv83/quantile-mapping/qq-workflows/acs/split-by-year.sh

## Variable options
$(call check_defined, VAR)

ifeq (${VAR}, pr)
  SCALING=multiplicative
  SSR=--ssr
  HIST_VAR=pr
  HIST_UNITS="kg m-2 s-1"
  ifeq (${OBS_DATASET}, AGCD)
    REF_VAR=precip
    REF_UNITS="mm day-1"
  else ifeq (${OBS_DATASET}, AGCA-AGCD)
    REF_VAR=rain
    REF_UNITS="mm day-1"
  else
    REF_VAR=pr
    REF_UNITS="kg m-2 s-1"
  endif
  TARGET_VAR=pr
  TARGET_UNITS="kg m-2 s-1"
  OUTPUT_UNITS="mm day-1"
else ifeq (${VAR}, tasmin)
  SCALING=additive
  HIST_VAR=tasmin
  HIST_UNITS=K
  ifeq (${OBS_DATASET}, AGCD)
    REF_VAR=tmin
    REF_UNITS=C
  else ifeq (${OBS_DATASET}, AGCA-AGCD)
    REF_VAR=tmin
    REF_UNITS=C  
  else
    REF_VAR=tasmin
    REF_UNITS=K
  endif
  TARGET_VAR=tasmin
  TARGET_UNITS=K
  OUTPUT_UNITS=C
else ifeq (${VAR}, tasmax)
  SCALING=additive
  HIST_VAR=tasmax
  HIST_UNITS=K
  ifeq (${OBS_DATASET}, AGCD)
    REF_VAR=tmax
    REF_UNITS=C
  else ifeq (${OBS_DATASET}, AGCA-AGCD)
    REF_VAR=tmax
    REF_UNITS=C    
  else
    REF_VAR=tasmax
    REF_UNITS=K
  endif
  TARGET_VAR=tasmax
  TARGET_UNITS=K
  OUTPUT_UNITS=C
else ifeq (${VAR}, tasmax)
  SCALING=additive
  HIST_VAR=tasmax
  HIST_UNITS=K
  ifeq (${OBS_DATASET}, AGCD)
    REF_VAR=tmax
    REF_UNITS=C
  else
    REF_VAR=tasmax
    REF_UNITS=K
  endif
  TARGET_VAR=tasmax
  TARGET_UNITS=K
  OUTPUT_UNITS=C
else ifeq (${VAR}, rsds)
  SCALING=additive
  HIST_VAR=rsds
  HIST_UNITS="W m-2"
  ifeq (${OBS_DATASET}, AGCA-AGCD)
    REF_VAR=rad
    REF_UNITS="megajoule/meter2"
  else
    REF_VAR=rsds
    REF_UNITS="W m-2"
  endif
  TARGET_VAR=rsds
  TARGET_UNITS="W m-2"
  OUTPUT_UNITS="W m-2"
else ifeq (${VAR}, vph09)
  SCALING=additive
  HIST_VAR=vph09
  HIST_UNITS=hPa
  REF_VAR=vph09
  REF_UNITS=hPa
  TARGET_VAR=vph09
  TARGET_UNITS=hPa
  OUTPUT_UNITS=hPa
else ifeq (${VAR}, vph15)
  SCALING=additive
  HIST_VAR=vph15
  HIST_UNITS=hPa
  REF_VAR=vph15
  REF_UNITS=hPa
  TARGET_VAR=vph15
  TARGET_UNITS=hPa
  OUTPUT_UNITS=hPa
else ifeq (${VAR}, hurs)
  SCALING=additive
  HIST_VAR=hurs
  HIST_UNITS="%"
  REF_VAR=hurs
  REF_UNITS="%"
  TARGET_VAR=hurs
  TARGET_UNITS="%"
  OUTPUT_UNITS="%"
  VALID_MIN=--valid_min 0
  VALID_MAX=--valid_max 100
else ifeq (${VAR}, windspeed)
  SCALING=additive
  HIST_VAR=windspeed
  HIST_UNITS="m s-1"
  REF_VAR=windspeed
  REF_UNITS="m s-1"
  TARGET_VAR=windspeed
  TARGET_UNITS="m s-1"
  OUTPUT_UNITS="m s-1"
  VALID_MIN=--valid_min 0
endif

## Model options
$(call check_defined, GCM_NAME)
$(call check_defined, RCM_NAME)

ifeq (${GCM_NAME}, ECMWF-ERA5)
  HIST_EXP=evaluation
  TARGET_EXP=evaluation
else
  HIST_EXP=historical
  TARGET_EXP=ssp370
endif

ifeq (${GCM_NAME}, ACCESS-ESM1-5)
  GCM_RUN=r6i1p1f1
else ifeq (${GCM_NAME}, ACCESS-CM2)
  GCM_RUN=r4i1p1f1
else ifeq (${GCM_NAME}, CESM2)
  GCM_RUN=r11i1p1f1
else ifeq (${GCM_NAME}, CNRM-ESM2-1)
  GCM_RUN=r1i1p1f2
else
  GCM_RUN=r1i1p1f1
endif

## Input data
$(call check_defined, GCM_NAME)
$(call check_defined, GCM_RUN)
$(call check_defined, HIST_EXP)
$(call check_defined, TARGET_EXP)
$(call check_defined, RCM_NAME)
$(call check_defined, HIST_VAR)
$(call check_defined, REF_VAR)
$(call check_defined, TARGET_VAR)

ifeq (${RCM_NAME}, BARPA-R)
  CORDEX_PATH=/g/data/py18/BARPA/output/CMIP6/DD
  RCM_INSTITUTION=BOM
  RCM_GRID=AUS-15
else ifeq (${RCM_NAME}, CCAM-v2203-SN)
  #CORDEX_PATH=/g/data/xv83/CCAM/output/CMIP6/DD
  CORDEX_PATH=/g/data/hq89/CCAM/output/CMIP6/DD
  RCM_INSTITUTION=CSIRO
  RCM_GRID=AUS-10i
endif

ifeq (${VAR}, vph09)
  HIST_DATA := /g/data/xv83/ab7412/vph09_${GCM_NAME}/vph09_${GCM_NAME}_historical_1951_2014.nc
  TARGET_DATA := $(sort $(wildcard /g/data/xv83/ab7412/vph09_${GCM_NAME}/*.nc))
else ifeq (${VAR}, vph15)
  HIST_DATA := /g/data/xv83/ab7412/vph15_${GCM_NAME}/vph15_${GCM_NAME}_historical_1951_2014.nc
  TARGET_DATA := $(sort $(wildcard /g/data/xv83/ab7412/vph15_${GCM_NAME}/*.nc))
else ifeq (${VAR}, windspeed)
  HIST_DATA := /g/data/xv83/ab7412/windspeed_${GCM_NAME}/windspeed_${GCM_NAME}_historical_1951_2014.nc
  TARGET_DATA := $(sort $(wildcard /g/data/xv83/ab7412/windspeed_${GCM_NAME}/*.nc))
else
  HIST_PATH=${CORDEX_PATH}/${RCM_GRID}/${RCM_INSTITUTION}/${GCM_NAME}/${HIST_EXP}/${GCM_RUN}/${RCM_NAME}/v1-r1/day/${HIST_VAR}
  HIST_DATA := $(sort $(wildcard ${HIST_PATH}/v*/*day_198[5,6,7,8,9]*.nc) $(wildcard ${HIST_PATH}/v*/*day_199*.nc) $(wildcard ${HIST_PATH}/v*/*day_2*.nc))  
  TARGET_PATH=${CORDEX_PATH}/${RCM_GRID}/${RCM_INSTITUTION}/${GCM_NAME}/${TARGET_EXP}/${GCM_RUN}/${RCM_NAME}/v1-r1/day/${TARGET_VAR}
  TARGET_DATA := $(sort $(wildcard ${HIST_PATH}/v*/*.nc) $(wildcard ${TARGET_PATH}/v*/*.nc))
endif
RCM_VERSION=v1-r1

ifeq (${OBS_DATASET}, AGCD)
  REF_PATH=/g/data/xv83/agcd-csiro/${REF_VAR}/daily
  REF_DATA = $(sort $(wildcard ${REF_PATH}/*_198[5,6,7,8,9]*.nc) $(wildcard ${REF_PATH}/*_199*.nc) $(wildcard ${REF_PATH}/*_200*.nc) $(wildcard ${REF_PATH}/*_201[0,1,2,3,4]*.nc))
  ifeq (${OUTPUT_GRID}, af)
    OUTPUT_GRID_LABEL=AUS-05i
  else
    OUTPUT_GRID_LABEL=${RCM_GRID}
  endif
else ifeq (${OBS_DATASET}, BARRA-R2)
  REF_PATH=/g/data/ob53/BARRA2/output/reanalysis/AUS-11/BOM/ERA5/historical/hres/BARRA-R2/v1/day/${REF_VAR}/v20231001
  REF_DATA = $(sort $(wildcard ${REF_PATH}/*_198[5,6,7,8,9]*.nc) $(wildcard ${REF_PATH}/*_199*.nc) $(wildcard ${REF_PATH}/*_200*.nc) $(wildcard ${REF_PATH}/*_201[0,1,2,3,4]*.nc))
  ifeq (${OUTPUT_GRID}, af)
    OUTPUT_GRID_LABEL=AUS-11i
  else
    OUTPUT_GRID_LABEL=${RCM_GRID}
  endif
else ifeq (${OBS_DATASET}, AGCA-AGCD)
  REF_DATA=/g/data/xv83/ab7412/${REF_VAR}_AGCD_1985_2014.nc
  ifeq (${OUTPUT_GRID}, af)
    OUTPUT_GRID_LABEL=AUS-05i
  else
    OUTPUT_GRID_LABEL=${RCM_GRID}
  endif
endif

## Output data
$(call check_defined, OUTPUT_GRID_LABEL)
$(call check_defined, RCM_INSTITUTION)
$(call check_defined, GCM_NAME)
$(call check_defined, GCM_RUN)
$(call check_defined, HIST_EXP)
$(call check_defined, TARGET_EXP)
$(call check_defined, RCM_NAME)
$(call check_defined, TARGET_VAR)
$(call check_defined, HIST_START)
$(call check_defined, HIST_END)
$(call check_defined, REF_START)
$(call check_defined, REF_END)
$(call check_defined, TARGET_START)
$(call check_defined, TARGET_END)
$(call check_defined, METHOD)
$(call check_defined, SCALING)
$(call check_defined, NQUANTILES)
$(call check_defined, OBS_DATASET)

OUTFILE_ATTRIBUTES=--outfile_attrs /g/data/xv83/quantile-mapping/qq-workflows/acs/outfile_attributes_${SCALING}_${OBS_DATASET}.yml
BIAS_ADJUSTMENT=${RCM_VERSION}-${METHOD}-${OBS_DATASET}-${REF_START}-${REF_END}
TRAINING_DATES=${HIST_START}0101-${HIST_END}1231
ADJUSTMENT_DATES=${TARGET_START}0101-${TARGET_END}1231
OUTPUT_DATES=${OUTPUT_START}0101-${OUTPUT_END}1231
OUTDIR=/g/data/xv83/dbi599/bennett-postdoc/test-data/CORDEX-CMIP6/bias-adjusted-output/${OUTPUT_GRID_LABEL}/${RCM_INSTITUTION}/${GCM_NAME}/${TARGET_EXP}/${GCM_RUN}/${RCM_NAME}/${BIAS_ADJUSTMENT}/day/${TARGET_VAR}Adjust
# /g/data/xv83/dbi599/australian-climate-service

OUTPUT_AF_DIR=${OUTDIR}
AF_FILE=${TARGET_VAR}-${METHOD}-${SCALING}-monthly-q${NQUANTILES}-adjustment-factors_${OBS_DATASET}_${OUTPUT_GRID_LABEL}_${GCM_NAME}_${HIST_EXP}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${TRAINING_DATES}.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=${OUTDIR}
QQ_BASE=${TARGET_VAR}Adjust_${OUTPUT_GRID_LABEL}_${GCM_NAME}_${TARGET_EXP}_${GCM_RUN}_${RCM_NAME}_${BIAS_ADJUSTMENT}_day_${OUTPUT_DATES}
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc
#METADATA_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.yaml
METADATA_PATH=/g/data/xv83/quantile-mapping/qq-workflows/acs/outfile_attributes_additive_AGCA-AGCD.yml

OUTPUT_VALIDATION_DIR=${OUTDIR}
VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb
FINAL_QQ_PATH=${QQ_PATH}

