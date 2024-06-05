#!/bin/bash

PWD=${PWD}
DOCKER_NETWORK_NAME='tde'
DOCKER_COMPOSE_FILE='docker-compose-all.yaml'

function sparkConf() {
    echo "applying spark.conf"
}

function sparkExists() {
    if [ -z "$SPARK_HOME" ];then
        echo "Missing SPARK_HOME environment variable"
        exit 1
    else
        echo "SPARK_HOME is set. location=$SPARK_HOME"
    fi
}

function createNetwork() {
    cmd="docker network ls | grep ${DOCKER_NETWORK_NAME}"
    eval $cmd
    retVAl=$?
    if [ $retVAl -ne 0 ]; then
        docker network create -d bridge ${DOCKER_NETWORK_NAME}
    else
        echo "docker network already exists ${DOCKER_NETWORK_NAME}"
    fi
}

function start() {
    if [ ! -d "${PWD}/data/mysqldir" -d ]; then
        echo "mysqldir doesn't exist. Adding docker/data/mysqldir for mysql database"
        mkdir "${PWD}/data/mysqldir"
    fi
    sparkExists
    createNetwork
    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --remove-orphans
}

function stop() {
    docker-compose -f ${DOCKER_COMPOSE_FILE} down --remove-orphans
}

function restart() {
    stop && start
}

function bootstrap() {
    docker cp "${PWD}/examples/bootstrap.sh" "mysqld:/"
    docker cp "${PWD}/examples/bootstrap.sql" "mysqld:/"
    hiveInit
    docker exec mysqld /bootstrap.sh

    echo "To bootstrap hive. you have to do as root from within docker"
    echo "1. docker exec -it mysql bash"
    echo "2. mysql -u root -p"
    echo "3. source bootstrap-hive.sql"

}

function buildAirflow() {
    docker build . --no-cache=true --build-arg AIRFLOW_BASE_IMAGE="apache/airflow:2.2.3-python3.8" --build-arg JAVA_LIBRARY="openjdk-11-jdk-headless" --tag `whoami`/apache-airflow-spark:2.2.3
}


function hiveInit() {
    docker cp "${PWD}/examples/bootstrap-hive.sql" "mysqld:/"
    docker cp "${PWD}/hive/install/hive-schema-2.3.0.mysql.sql" "mysqld:/"
    docker cp "${PWD}/hive/install/hive-txn-schema-2.3.0.mysql.sql" "mysqld:/"
}

function airFlowInit() {
    docker-compose -f ${DOCKER_COMPOSE_FILE} up airflow-init
}

case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart)
        restart
    ;;
    hiveInit)
        hiveInit
    ;;
    airflowInit)
        airFlowInit
    ;;
    buildAirflow)
        buildAirflow
    ;;
    bootstrap)
        bootstrap
    ;;
    *)
        echo $"Usage: $0 {airflowInit | buildAirflow | hiveInit | bootstrap | start | stop}"
    ;;
esac