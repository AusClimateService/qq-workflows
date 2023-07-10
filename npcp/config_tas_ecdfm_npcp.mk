# NPCP precipication bias correction configuration

## User configured variables

TASK=projection
#historical xvalidation projection
METHOD=ecdfm
INTERP=nearest
GROUPING=--time_grouping monthly
SCALING=additive

OUTPUT_UNITS=C
HIST_VAR=tasmin
HIST_UNITS=C
REF_VAR=tasmin
REF_UNITS=C
TARGET_VAR=tasmin
TARGET_UNITS=C

OBS_DATASET=AGCD
RCM_VERSION=v1

RCM_NAME=UQ-DES-CCAM-2105
#RCM_NAME=BOM-BARPA-R

#GCM_NAME=ECMWF-ERA5
#GCM_RUN=r1i1p1f1
#EXPERIMENT=evaluation
GCM_NAME=CSIRO-ACCESS-ESM1-5
GCM_RUN=r6i1p1f1
EXPERIMENT=ssp370

## Automatic variables

HIST_PATH=/g/data/ia39/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/raw/task-reference
REF_PATH=/g/data/ia39/npcp/data/${REF_VAR}/observations/${OBS_DATASET}/raw/task-reference
TARGET_PATH=/g/data/ia39/npcp/data/${TARGET_VAR}/${GCM_NAME}/${RCM_NAME}/raw/task-reference
ifeq (${TASK}, projection)
HIST_START=1980
HIST_END=1999
HIST_DATA := $(sort $(wildcard ${HIST_PATH}/*day_19*.nc))
REF_START=1980
REF_END=1999
REF_DATA := $(sort $(wildcard ${REF_PATH}/*day_19*.nc))
TARGET_START=2080
TARGET_END=2099
TARGET_DATA := $(sort $(wildcard ${TARGET_PATH}/*day_20[8,9]*.nc))
TRAINING_DATES=${HIST_START}0101-${HIST_END}1231
TARGET_DATES=${TARGET_START}0101-${TARGET_END}1231
else ifeq (${TASK}, historical)
HIST_START=1980
HIST_END=1999
HIST_DATA := $(sort $(wildcard ${HIST_PATH}/*day_19*.nc))
REF_START=1980
REF_END=1999
REF_DATA := $(sort $(wildcard ${REF_PATH}/*day_19*.nc))
TARGET_START=2000
TARGET_END=2019
TARGET_DATA := $(sort $(wildcard ${TARGET_PATH}/*day_20[0,1]*.nc))
TRAINING_DATES=${HIST_START}0101-${HIST_END}1231
TARGET_DATES=${TARGET_START}0101-${TARGET_END}1231
else ifeq (${TASK}, xvalidation)
HIST_START=1981
HIST_END=2019
HIST_DATA := $(sort $(wildcard ${HIST_PATH}/*day_19?[1,3,5,7,9]*.nc) $(wildcard ${HIST_PATH}/*day_200[1,3,5,7,9]*.nc) $(wildcard ${HIST_PATH}/*day_201[1,3,5,7,9]*.nc))
REF_START=1981
REF_END=2019
REF_DATA := $(sort $(wildcard ${REF_PATH}/*day_19?[1,3,5,7,9]*.nc) $(wildcard ${REF_PATH}/*day_200[1,3,5,7,9]*.nc) $(wildcard ${REF_PATH}/*day_201[1,3,5,7,9]*.nc))
TARGET_START=1980
TARGET_END=2018
TARGET_DATA := $(sort $(wildcard ${TARGET_PATH}/*day_19?[0,2,4,6,8]*.nc) $(wildcard ${TARGET_PATH}/*day_200[0,2,4,6,8]*.nc) $(wildcard ${TARGET_PATH}/*day_201[0,2,4,6,8]*.nc))
TRAINING_DATES=${HIST_START}0101-${HIST_END}1231-odd-years
TARGET_DATES=${TARGET_START}0101-${TARGET_END}1231-even-years
endif

OUTPUT_HIST_DIR=/g/data/xv83/dbi599/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/${METHOD}/task-${TASK}
OUTPUT_REF_DIR=/g/data/xv83/dbi599/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/${METHOD}/task-${TASK}
OUTPUT_TARGET_DIR=/g/data/xv83/dbi599/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/${METHOD}/task-${TASK}

AF_FILE=${REF_VAR}-${METHOD}-${SCALING}-monthly-q100-adjustment-factors_${OBS_DATASET}_NPCP-20i_${GCM_NAME}_${EXPERIMENT}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${TRAINING_DATES}.nc
AF_PATH=${OUTPUT_REF_DIR}/${AF_FILE}

QQ_BASE=${REF_VAR}_NPCP-20i_${GCM_NAME}_${EXPERIMENT}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${TARGET_DATES}_${METHOD}-${SCALING}-monthly-q100-${INTERP}-${OBS_DATASET}-${TRAINING_DATES}
QQ_PATH=${OUTPUT_REF_DIR}/${QQ_BASE}.nc

VALIDATION_NOTEBOOK=${OUTPUT_REF_DIR}/${QQ_BASE}.ipynb

