#!/bin/bash
################################################################################
# hive-thriftserver.sh
################################################################################
cd ~

if [[ "${HIVE_HOME}" == "" ]]; then
    echo -e "\e[33mThe HIVE_HOME environment variable is not set\e[0m"
    exit 1
fi

PORT="10000"
CONF_DIR="${HIVE_HOME}/conf/hive-thriftserver"
LOG_FILE="/var/log/hive/hive-thriftserver.log"

function PrintUsage() {
    local COMMAND=${0##*/}
    echo "Usage : shell> ${COMMAND} { start | stop | restart | status | pid | log }"
    echo "        ex> ${COMMAND} start"
    echo "        ex> ${COMMAND} stop"
    echo "        ex> ${COMMAND} restart"
    echo "        ex> ${COMMAND} status"
    echo "        ex> ${COMMAND} pid"
    echo "        ex> ${COMMAND} log"
    echo ""
    exit 1
}

function Pid() {
    local pid=$(ps -ef | grep -v grep | grep -v tail | grep "org.apache.hive.service.server.HiveServer2" | grep "hive.server2.thrift.port=${PORT}" | awk '{print $2}')
    echo ${pid} # <-- return PID
}

function Start() {
    local pid=$(Pid)
    if [[ "${pid}" == "" ]]; then
        ${HIVE_HOME}/bin/hive --config ${CONF_DIR} \
                              --service hiveserver2 \
                              --hiveconf hive.server2.thrift.port=${PORT} \
                              > /dev/null 2>&1 &
        echo "staring hive-thriftserver ..."
    else
        echo "hive-thriftserver is running! (PID=${pid})"
    fi
}

function Stop() {
    local pid=$(Pid)
    if [[ "${pid}" == "" ]]; then
        echo "hive-thriftserver is not running!"
    else
        echo "stopping hive-thriftserver ... (PID=${pid})"
        kill ${pid}
    fi
}

function Restart() {
    local pid=$(Pid)
    if [ "${pid}" == "" ]; then
        Start
    else
        Stop
        while true; do
            local pid=$(Pid)
            if [[ "${pid}" == "" ]]; then
                break
            fi
            sleep 1
        done
        sleep 1
        Start
    fi
}

function Status() {
    local pid=$(Pid)
    if [[ "${pid}" == "" ]]; then
        echo "hive-thriftserver is not running!"
    else
        echo "hive-thriftserver is running! (PID = ${pid})"
        ps -ef | grep ${pid}
    fi
}

function Log() {
    echo -e "tail -F \e[33m${LOG_FILE}\e[0m"
    tail -F ${LOG_FILE}
}

ACTION=${1}
case "${ACTION}" in
    pid)
        Pid
        ;;
    start)
        Start
        ;;
    stop)
        Stop
        ;;
    restart)
        Restart
        ;;
    status)
        Status
        ;;
    log)
        Log
        ;;
    *)
        PrintUsage
        ;;
esac