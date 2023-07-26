# NPCP bias correction configuration
#
# The four user defined variables are:
# - VAR (options: tasmin tasmax pr)
# - RCM_NAME (options: BOM-BARPA-R)
# - GCM_NAME (options:
#               CMCC-CMCC-ESM2
#               CSIRO-ACCESS-ESM1-5
#               CSIRO-ARCCSS-ACCESS-CM2
#               EC-Earth-Consortium-EC-Earth3
#               ECMWF-ERA5
#               NCAR-CESM2
#               NCC-NorESM2-MM
#             )
# - TARGET_START (start year for target period)
# - TARGET_END (end year for target period)
# - OUTPUT_START (start year for output data - i.e. don't have to output the whole target period)
# - OUTPUT_END (end year for output data - i.e. don't have to output the whole target period)
#
# To modify the four defaults, run something like this:
#   make [target] [-Bn] CONFIG=acs/config_acs.mk VAR=pr RCM_NAME=BOM-BARPA-R GCM_NAME=CSIRO-ACCESS-ESM1-5
#                       TARGET_START=2040 TARGET_END=2069 OUTPUT_START=2050 OUTPUT_END=2059
#

## User configured variables

VAR=tasmin
RCM_NAME=BOM-BARPA-R
GCM_NAME=ECMWF-ERA5
TARGET_START=2030
TARGET_END=2059
OUTPUT_START=${TARGET_START}
OUTPUT_END=${TARGET_END}

## Preset/automatic variables

METHOD=ecdfm
NQUANTILES=100
GROUPING=--time_grouping monthly
INTERP=nearest
OUTPUT_GRID=af

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

OBS_DATASET=AGCD
RCM_VERSION=v1

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
else
GCM_RUN=r1i1p1f1
endif

ifeq (${RCM_NAME}, BOM-BARPA-R)
RCM_INSTITUTION=BOM
else ifeq (${RCM_NAME}, CSIRO-CCAM-2203)
RCM_INSTITUTION=CSIRO
endif

CORDEX_PATH=/g/data/ia39/australian-climate-service/release/CORDEX-CMIP6/output
HIST_PATH=${CORDEX_PATH}/AUS-15/${RCM_INSTITUTION}/${GCM_NAME}/${HIST_EXP}/${GCM_RUN}/${RCM_NAME}/v1/day/${HIST_VAR}
TARGET_PATH=${CORDEX_PATH}/AUS-15/${RCM_INSTITUTION}/${GCM_NAME}/${TARGET_EXP}/${GCM_RUN}/${RCM_NAME}/v1/day/${TARGET_VAR}

HIST_START=1985
HIST_END=2014
HIST_DATA := $(sort $(wildcard ${HIST_PATH}/*day_198[5,6,7,8,9]*.nc) $(wildcard ${HIST_PATH}/*day_199*.nc) $(wildcard ${HIST_PATH}/*day_2*.nc))
REF_START=1985
REF_END=2014
REF_DATA := $(wildcard /g/data/xv83/agcd-csiro/${REF_VAR}/daily/*_AGCD-CSIRO_r005_*_daily_space-chunked.zarr)
TARGET_DATA := $(sort $(wildcard ${HIST_PATH}/*.nc) $(wildcard ${TARGET_PATH}/*.nc))
OUTPUT_TSLICE=--output_tslice ${OUTPUT_START}-01-01 ${OUTPUT_END}-12-31

TRAINING_DATES=${HIST_START}0101-${HIST_END}1231
ADJUSTMENT_DATES=${TARGET_START}0101-${TARGET_END}1231
OUTPUT_DATES=${OUTPUT_START}0101-${OUTPUT_END}1231

OUTDIR=/g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6-ECDFm/output/AUS-05i/${RCM_INSTITUTION}/${GCM_NAME}/${TARGET_EXP}/${GCM_RUN}/${RCM_NAME}/v1/day/${TARGET_VAR}
OUTPUT_AF_DIR=${OUTDIR}
OUTPUT_QQ_DIR=${OUTDIR}
OUTPUT_VALIDATION_DIR=${OUTDIR}

AF_FILE=${TARGET_VAR}-${METHOD}-${SCALING}-monthly-q${NQUANTILES}-adjustment-factors_${OBS_DATASET}_AUS-05i_${GCM_NAME}_${HIST_EXP}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${TRAINING_DATES}.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

QQ_BASE=${TARGET_VAR}_AUS-05i_${GCM_NAME}_${TARGET_EXP}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${OUTPUT_DATES}-from-${ADJUSTMENT_DATES}_${METHOD}-${SCALING}-monthly-q${NQUANTILES}-${INTERP}-${OBS_DATASET}-${TRAINING_DATES}

QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc

VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb

