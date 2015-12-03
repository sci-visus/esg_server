#! /bin/bash
#
# Starts the on_demand_converter service.
#
# Please see conf/ondemand-env.sh to customize your installation.
#

DEBUG_MODE=$1

# configuration
ONDEMAND_BIN="`dirname "$0"`"
ONDEMAND_BIN="`cd "${ONDEMAND_BIN}"; pwd`"
ONDEMAND_CONF="`cd "${ONDEMAND_BIN}/../conf"; pwd`"
. ${ONDEMAND_CONF}/ondemand-env.sh
. ${ONDEMAND_BIN}/ondemand-defaults.sh

# start logging
echo "==================== starting ondemand converter service `date` ====================" >> ${ONDEMAND_LOGFILE}

# create db
if [ ! -e ${ONDEMAND_DB} ]; then
    echo "idx.db not found, creating..."
    sqlite3 ${ONDEMAND_DB} < ${ONDEMAND_BIN}/create_tables.sql
fi

# source uv-cdat runtime
source ${UVCDAT_DIR}/bin/setup_runtime.sh 

# stop any running instance
pid=${ONDEMAND_BIN}/current_instance.pid
${ONDEMAND_BIN}/stop_service.sh

# start service
if [ ${DEBUG_MODE} ]; then
  python ${ONDEMAND_BIN}/cdat_converter_service.py ${ARG_PORT} ${ARG_HOST} ${ARG_XMLPATH} ${ARG_IDXPATH} ${ARG_DB} ${ARG_VISUSSERVER} ${ARG_VISUSSERVER_USERNAME} ${ARG_VISUSSERVER_PASSWORD}
else
  python ${ONDEMAND_BIN}/cdat_converter_service.py ${ARG_PORT} ${ARG_HOST} ${ARG_XMLPATH} ${ARG_IDXPATH} ${ARG_DB} ${ARG_VISUSSERVER} ${ARG_VISUSSERVER_USERNAME} ${ARG_VISUSSERVER_PASSWORD} >> $ONDEMAND_LOGFILE 2>&1 &
fi
echo $! > $pid

echo "==================== started ondemand converter service (pid=$!) ====================" >> ${ONDEMAND_LOGFILE}
echo "ondemand converter service started."

