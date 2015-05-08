#!/usr/bin/env bash

usage(){
  echo "${BASH_SOURCE[0]} -s <server-host> -c <certificate-path> -u <user>"
  exit 1
}

[[ $# -eq 0 ]] && usage

while getopts s:c:u:h OPT; do
  case $OPT in
    s) 
      SERVER=$OPTARG
      ;;
    c)
      CERT=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    h|\?)
      usage
      ;;
  esac
done

git push origin master

ssh -i ${CERT} ${USER}@${SERVER} << EOF
  set -x
  cd dockerized-jenkins
  git pull origin master
  \$(cat ~/.bashrc | grep export)
  make rebuild
EOF

