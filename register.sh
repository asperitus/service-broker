#!/usr/bin/env bash

set -x
#args
# SERVICE_NAME

usage() {
   cat << EOF

usage: $(basename $0) SERVICE_NAME

EOF

exit 1
}

[[ $# -lt 1 ]] && usage

SERVICE_NAME=$1
APP_NAME=${SERVICE_NAME}-broker

guid=$(cf curl /v2/apps?q=name:$APP_NAME | jq -r '.resources|.[].metadata.guid')
uri=https://$(cf curl /v2/apps/$guid/stats | jq -r '."0".stats.uris[0]')

#
cf create-service-broker $SERVICE_NAME admin admin $uri
cf enable-service-access $SERVICE_NAME