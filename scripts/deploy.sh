#!/usr/bin/env bash
set -e

usage(){
  echo "${BASH_SOURCE[0]} <ssh-connection-string>"
  echo "Example: ${BASH_SOURCE[0]} -i ~/certificate.pem user@host"
  exit 1
}

[[ $# -eq 0 ]] && usage


git push origin master

ssh $@ << EOF
  cd dockerized-jenkins
  git pull origin master
  make rebuild
EOF

