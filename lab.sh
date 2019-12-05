#!/bin/bash

cd $(dirname $0)
git reset --hard HEAD 1>/dev/null 2>&1
git pull -f 1>/dev/null 2>&1

standName=${2}

function status() {
  cat trainings.yaml | grep 'name:' | awk '{print $3}'
}

function start() {
  docker-compose -f envs/${standName}.yaml up -d
}

function stop() {
  docker-compose -f envs/${standName}.yaml down --volumes
}

case $1 in
  status)
    status 
    ;;
  start)
    start
    ;;
  restart)
    stop
    start
    ;;
  stop)
    stop 
    ;;
  *) status
esac
