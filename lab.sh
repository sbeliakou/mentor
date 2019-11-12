#!/bin/bash

cd $(dirname $0)
LABHOME=$(pwd)

if [ -n "$(docker ps --filter label=lab.devops -q)" ]; then
  CLABNAME=$(docker inspect $(docker ps --filter label=lab.devops -q -n1) | jq -r '.[].Config.Labels."lab.name"')
  CLABNAME=${CLABNAME//:/\/}
else
  CLABNAME=""
fi

git pull 2>/dev/null 1>&2

function status() {
  echo "--------+--------------------------------+-------------------------------"
  echo " Status : Interactive Labs               :"
  echo "--------+--------------------------------+-------------------------------"
  for item in $(find ${LABHOME} -maxdepth 3 -name "docker-compose.y*ml" | sed 's#'${LABHOME}'/##;s#/docker-compose.*##' | sort)
  do 
    if [ "${item}" == "${CLABNAME}" ]; then
      printf "    \033[0;32m>>>\033[0m | \033[0;32m%-30s\033[0m | \033[0;32m%s\033[0m \n" "${item}" "running: http://localhost:8081"
    else
      printf "        | %-30s | \n" "${item}"
    fi
  done
  echo "--------+--------------------------------+-------------------------------"
}

function start() {
  LABNAME="${1}"
  if [ -n "${LABNAME}" ]; then
    if [ "${LABNAME}" != "${CLABNAME}" ]; then
      if [ -n "${LABNAME}" ]; then
        ok=""
        for item in $(find ${LABHOME} -maxdepth 3 -name "docker-compose.y*ml" | sed 's#'${LABHOME}'/##;s#/docker-compose.*##' | sort)
        do 
          if [ "${item}" == "${LABNAME}" ]; then
            ok=1 && break
          fi
        done
        if [ -n "${ok}" ]; then
          stop && cd ${LABHOME}/${LABNAME} && docker-compose pull && docker-compose up -d
        else
          echo "Can't find this lab from a list of availables. Please double check"
          status
        fi
      fi
    else
      echo "You're going to restart current lab (${CLABNAME}). Right?"
      stop && cd ${LABHOME}/${LABNAME} && docker-compose pull && docker-compose up -d
    fi
  fi
}

function stop() {
  if [ -n "${CLABNAME}" ]; then
    LABPWD=$(docker inspect $(docker ps --filter label=lab.devops -q -n1) | jq -r '.[].Config.Labels."lab.env"')
    echo -n "Are you sure to stop lab stand (${CLABNAME})? [Y/n] "
    while true; do
      read reply
      [[ "$reply" =~ ^([yY]es|[nN]o|[yYnN])$ ]] && break || echo -n 'Type "yes" or "no": '
    done
    if [[ "$reply" =~ [yY] ]]; then
      echo "will stop '${CLABNAME}'"
      cd ${LABPWD} && docker-compose down --volumes 2>/dev/null
      echo stopped: ${CLABNAME}
    else 
      echo "ok, no worries"
      return 1
    fi
  fi
  return 0
}

case $1 in
  status)
    status 
    ;;
  start)
    start ${2} 
    ;;
  restart)
    start "${CLABNAME}" 
    ;;
  stop)
    stop 
    ;;
  *) status
esac
