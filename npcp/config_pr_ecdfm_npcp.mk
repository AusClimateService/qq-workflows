# NPCP precipication bias correction configuration

## User configured variables

TASK=projection
#historical xvalidation projection
METHOD=ecdfm
INTERP=nearest
GROUPING=--time_grouping monthly
SCALING=multiplicative
OUTPUT_GRID=af
SSR=--ssr

OUTPUT_UNITS="mm day-1"
HIST_VAR=pr
HIST_UNITS="mm day-1"
REF_VAR=pr
REF_UNITS="mm day-1"
TARGET_VAR=pr
TARGET_UNITS="mm day-1"

OBS_DATASET=AGCD
GCM_NAME=CSIRO-ACCESS-ESM1-5
#ECMWF-ERA5 CSIRO-ACCESS-ESM1-5
GCM_RUN=r6i1p1f1
#r1i1p1f1 r6i1p1f1
RCM_NAME=BOM-BARPA-R
#BOM-BARPA-R 
RCM_VERSION=v1
EXPERIMENT=ssp370
#evaluation

HIST_START=1980
HIST_END=1999
REF_START=1980
REF_END=1999
TARGET_START=2080
#2000 2080
TARGET_END=2099
#2019 2099


## Automatic variables
HIST_PATH=/g/data/ia39/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/raw/task-reference
TARGET_PATH=/g/data/ia39/npcp/data/${TARGET_VAR}/${GCM_NAME}/${RCM_NAME}/raw/task-reference
REF_PATH=/g/data/ia39/npcp/data/${REF_VAR}/observations/${OBS_DATASET}/raw/task-reference

HIST_DATA := $(sort $(wildcard ${HIST_PATH}/*day_19*.nc))
TARGET_DATA := $(sort $(wildcard ${TARGET_PATH}/*day_20[8,9]*.nc))
#TARGET_DATA := $(sort $(wildcard ${TARGET_PATH}/*day_20*.nc))
REF_DATA := $(sort $(wildcard ${REF_PATH}/*.nc))

OUTPUT_HIST_DIR=/g/data/xv83/dbi599/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/${METHOD}/task-${TASK}
OUTPUT_REF_DIR=/g/data/xv83/dbi599/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/${METHOD}/task-${TASK}
OUTPUT_TARGET_DIR=/g/data/xv83/dbi599/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/${METHOD}/task-${TASK}

AF_FILE=${REF_VAR}-${METHOD}-${SCALING}-monthly-q100-ssr-adjustment-factors_${OBS_DATASET}_NPCP-20i_${GCM_NAME}_${EXPERIMENT}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${HIST_START}0101-${HIST_END}1231.nc
AF_PATH=${OUTPUT_REF_DIR}/${AF_FILE}

QQ_BASE=${REF_VAR}_NPCP-20i_${GCM_NAME}_${EXPERIMENT}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${TARGET_START}0101-${TARGET_END}1231_${METHOD}-${SCALING}-monthly-q100-${INTERP}-ssr-${OBS_DATASET}-${HIST_START}0101-${HIST_END}1231
QQ_PATH=${OUTPUT_REF_DIR}/${QQ_BASE}.nc

VALIDATION_NOTEBOOK=${OUTPUT_REF_DIR}/${QQ_BASE}.ipynb


