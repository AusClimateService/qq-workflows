# ACS bias correction configuration
#
# The user defined variables are:
# - VAR (required; options: tasmin tasmax pr)
# - RCM_NAME (required; options: BOM-BARPA-R CSIRO-CCAM-2203)
# - GCM_NAME (required; options:
#               CMCC-CMCC-ESM2
#               CNRM-CERFACS-CNRM-ESM2-1
#               CSIRO-ACCESS-ESM1-5
#               CSIRO-ARCCSS-ACCESS-CM2
#               EC-Earth-Consortium-EC-Earth3
#               ECMWF-ERA5
#               MPI-M-MPI-ESM1-2-HR
#               NCAR-CESM2
#               NCC-NorESM2-MM
#             )
# - TARGET_START (required; start year for target period)
# - TARGET_END (required; end year for target period)
# - OUTPUT_START (optional; start year for output data; default=TARGET_START)
# - OUTPUT_END (optional; end year for output data; default=TARGET_END)
#
# Example usage:
#   make [target] [-Bn] CONFIG=acs/config_acs.mk VAR=pr RCM_NAME=BOM-BARPA-R GCM_NAME=CSIRO-ACCESS-ESM1-5
#                       TARGET_START=2040 TARGET_END=2069 OUTPUT_START=2050 OUTPUT_END=2059
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
OUTPUT_GRID=af
OUTPUT_START=${TARGET_START}
OUTPUT_END=${TARGET_END}
OUTPUT_TSLICE=--output_tslice ${OUTPUT_START}-01-01 ${OUTPUT_END}-12-31

## Variable options
$(call check_defined, VAR)

ifeq (${VAR}, pr)
SCALING=multiplicative
SSR=--ssr
HIST_VAR=pr
REF_VAR=precip
TARGET_VAR=pr
OUTPUT_UNITS="mm day-1"
HIST_UNITS="kg m-2 s-1"
REF_UNITS="mm day-1"
TARGET_UNITS="kg m-2 s-1"
else ifeq (${VAR}, tasmin)
SCALING=additive
HIST_VAR=tasmin
REF_VAR=tmin
TARGET_VAR=tasmin
OUTPUT_UNITS=C
HIST_UNITS=K
REF_UNITS=C
TARGET_UNITS=K
else ifeq (${VAR}, tasmax)
SCALING=additive
HIST_VAR=tasmax
REF_VAR=tmax
TARGET_VAR=tasmax
OUTPUT_UNITS=C
HIST_UNITS=K
REF_UNITS=C
TARGET_UNITS=K
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

ifeq (${GCM_NAME}, CSIRO-ACCESS-ESM1-5)
GCM_RUN=r6i1p1f1
else ifeq (${GCM_NAME}, CSIRO-ARCCSS-ACCESS-CM2)
GCM_RUN=r4i1p1f1
else ifeq (${GCM_NAME}, NCAR-CESM2)
GCM_RUN=r11i1p1f1
else ifeq (${GCM_NAME}, CNRM-CERFACS-CNRM-ESM2-1)
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

ifeq (${RCM_NAME}, BOM-BARPA-R)
RCM_INSTITUTION=BOM
CORDEX_PATH=/g/data/ia39/australian-climate-service/release/CORDEX-CMIP6/output
HIST_PATH=${CORDEX_PATH}/AUS-15/${RCM_INSTITUTION}/${GCM_NAME}/${HIST_EXP}/${GCM_RUN}/${RCM_NAME}/v1/day/${HIST_VAR}
HIST_DATA := $(sort $(wildcard ${HIST_PATH}/*day_198[5,6,7,8,9]*.nc) $(wildcard ${HIST_PATH}/*day_199*.nc) $(wildcard ${HIST_PATH}/*day_2*.nc))
TARGET_PATH=${CORDEX_PATH}/AUS-15/${RCM_INSTITUTION}/${GCM_NAME}/${TARGET_EXP}/${GCM_RUN}/${RCM_NAME}/v1/day/${TARGET_VAR}
TARGET_DATA := $(sort $(wildcard ${HIST_PATH}/*.nc) $(wildcard ${TARGET_PATH}/*.nc))
else ifeq (${RCM_NAME}, CSIRO-CCAM-2203)
RCM_INSTITUTION=CSIRO
HIST_PATH=drs_cordex/CORDEX-CMIP6/output/AUS-10i/${RCM_INSTITUTION}/${GCM_NAME}/${HIST_EXP}/${GCM_RUN}/${RCM_NAME}/v1/day/${HIST_VAR}
HIST_DATA := $(sort $(wildcard /g/data/xv83/mxt599/ccam_*_aus-10i_12km/${HIST_PATH}/*day_198[5,6,7,8,9]*.nc) $(wildcard /g/data/xv83/mxt599/ccam_*_aus-10i_12km/${HIST_PATH}/*day_199*.nc) $(wildcard /g/data/xv83/mxt599/ccam_*_aus-10i_12km/${HIST_PATH}/*day_2*.nc))
TARGET_PATH=drs_cordex/CORDEX-CMIP6/output/AUS-10i/${RCM_INSTITUTION}/${GCM_NAME}/${TARGET_EXP}/${GCM_RUN}/${RCM_NAME}/v1/day/${TARGET_VAR}
TARGET_DATA := $(sort $(wildcard /g/data/xv83/mxt599/ccam_*_aus-10i_12km/${HIST_PATH}/*.nc) $(wildcard /g/data/xv83/mxt599/ccam_*_aus-10i_12km/${TARGET_PATH}/*.nc))
endif
OBS_DATASET=AGCD
RCM_VERSION=v1
REF_PATH=/g/data/xv83/agcd-csiro/${REF_VAR}/daily
REF_DATA = $(sort $(wildcard ${REF_PATH}/*_198[5,6,7,8,9]*.nc) $(wildcard ${REF_PATH}/*_199*.nc) $(wildcard ${REF_PATH}/*_200*.nc) $(wildcard ${REF_PATH}/*_201[0,1,2,3,4]*.nc))


## Output data
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

CORDEX=--cordex_attrs ${OBS_DATASET}
BIAS_ADJUSTMENT=${RCM_VERSION}-${METHOD}-${OBS_DATASET}-${REF_START}-${REF_END}
TRAINING_DATES=${HIST_START}0101-${HIST_END}1231
ADJUSTMENT_DATES=${TARGET_START}0101-${TARGET_END}1231
OUTPUT_DATES=${OUTPUT_START}0101-${OUTPUT_END}1231
OUTDIR=/g/data/xv83/dbi599/australian-climate-service/test-data/CORDEX-CMIP6/bias-adjusted-output/AUS-05i/${RCM_INSTITUTION}/${GCM_NAME}/${TARGET_EXP}/${GCM_RUN}/${RCM_NAME}/${BIAS_ADJUSTMENT}/day/${TARGET_VAR}Adjust

OUTPUT_AF_DIR=${OUTDIR}
AF_FILE=${TARGET_VAR}-${METHOD}-${SCALING}-monthly-q${NQUANTILES}-adjustment-factors_${OBS_DATASET}_AUS-05i_${GCM_NAME}_${HIST_EXP}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${TRAINING_DATES}.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

OUTPUT_QQ_DIR=${OUTDIR}
QQ_BASE=${TARGET_VAR}Adjust_AUS-05i_${GCM_NAME}_${TARGET_EXP}_${GCM_RUN}_${RCM_NAME}_${BIAS_ADJUSTMENT}_day_${OUTPUT_DATES}
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc

OUTPUT_VALIDATION_DIR=${OUTDIR}
VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb

