# NPCP bias correction configuration
#
# The four user defined variables are:
# - VAR (options: tasmin tasmax pr)
# - TASK (options: historical xvalidation projection)
# - RCM_NAME (options: BOM-BARPA-R UQ-DES-CCAM-2105 CSIRO-CCAM-2203)
# - GCM_NAME (options: ECMWF-ERA5 CSIRO-ACCESS-ESM1-5)
#
# To modify the four defaults, run something like this:
#   make [target] [-Bn] CONFIG=npcp/config_npcp.mk VAR=pr TASK=projection RCM_NAME=BOM-BARPA-R GCM_NAME=CSIRO-ACCESS-ESM1-5
#

## User provided variables

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

$(call check_defined, VAR)
$(call check_defined, TASK)
$(call check_defined, RCM_NAME)
$(call check_defined, GCM_NAME)

## Preset/automatic variables

METHOD=ecdfm
NQUANTILES=100
GROUPING=--time_grouping monthly
INTERP=nearest
OUTPUT_GRID=af

ifeq (${VAR}, pr)
SCALING=multiplicative
SSR=--ssr
UNITS="mm day-1"
else
SCALING=additive
UNITS=C
endif
HIST_VAR=${VAR}
REF_VAR=${VAR}
TARGET_VAR=${VAR}
OUTPUT_UNITS=${UNITS}
HIST_UNITS=${UNITS}
REF_UNITS=${UNITS}
TARGET_UNITS=${UNITS}

OBS_DATASET=AGCD
RCM_VERSION=v1

ifeq (${GCM_NAME}, ECMWF-ERA5)
GCM_RUN=r1i1p1f1
EXPERIMENT=evaluation
else ifeq (${GCM_NAME}, CSIRO-ACCESS-ESM1-5)
GCM_RUN=r6i1p1f1
EXPERIMENT=ssp370
endif

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
HIST_START=1980
HIST_END=2019
HIST_DATA := $(sort $(wildcard ${HIST_PATH}/*day_19?[1,3,5,7,9]*.nc) $(wildcard ${HIST_PATH}/*day_200[1,3,5,7,9]*.nc) $(wildcard ${HIST_PATH}/*day_201[1,3,5,7,9]*.nc))
REF_START=1980
REF_END=2019
REF_DATA := $(sort $(wildcard ${REF_PATH}/*day_19?[1,3,5,7,9]*.nc) $(wildcard ${REF_PATH}/*day_200[1,3,5,7,9]*.nc) $(wildcard ${REF_PATH}/*day_201[1,3,5,7,9]*.nc))
TARGET_START=1980
TARGET_END=2019
TARGET_DATA := $(sort $(wildcard ${TARGET_PATH}/*day_19?[0,2,4,6,8]*.nc) $(wildcard ${TARGET_PATH}/*day_200[0,2,4,6,8]*.nc) $(wildcard ${TARGET_PATH}/*day_201[0,2,4,6,8]*.nc))
TRAINING_DATES=${HIST_START}0101-${HIST_END}1231-odd-years
TARGET_DATES=${TARGET_START}0101-${TARGET_END}1231-even-years
endif

OUTDIR=/g/data/ia39/npcp/data/${HIST_VAR}/${GCM_NAME}/${RCM_NAME}/${METHOD}/task-${TASK}
OUTPUT_AF_DIR=${OUTDIR}
OUTPUT_QQ_DIR=${OUTDIR}
OUTPUT_VALIDATION_DIR=${OUTDIR}

AF_FILE=${REF_VAR}-${METHOD}-${SCALING}-monthly-q${NQUANTILES}-adjustment-factors_${OBS_DATASET}_NPCP-20i_${GCM_NAME}_${EXPERIMENT}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${TRAINING_DATES}.nc
AF_PATH=${OUTPUT_AF_DIR}/${AF_FILE}

QQ_BASE=${REF_VAR}_NPCP-20i_${GCM_NAME}_${EXPERIMENT}_${GCM_RUN}_${RCM_NAME}_${RCM_VERSION}_day_${TARGET_DATES}_${METHOD}-${SCALING}-monthly-q${NQUANTILES}-${INTERP}-${OBS_DATASET}-${TRAINING_DATES}
QQ_PATH=${OUTPUT_QQ_DIR}/${QQ_BASE}.nc

VALIDATION_NOTEBOOK=${OUTPUT_VALIDATION_DIR}/${QQ_BASE}.ipynb

