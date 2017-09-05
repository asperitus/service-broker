#!/usr/bin/env bash

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

#
which cf; if [ $? -ne 0 ]; then
    echo "cf not installed. see https://github.com/cloudfoundry/cli/releases"
    exit 1
fi

which uuid;if [ $? -ne 0 ]; then
    alias uuid=uuidgen
fi

#
export SERVICE_NAME
export APP_NAME=${SERVICE_NAME}-broker

cf push $APP_NAME --no-start -m 128M -k 256M -c bin/service-broker -b https://github.com/cloudfoundry/binary-buildpack.git

cf set-env $APP_NAME BASE_GUID $(uuid)
cf set-env $APP_NAME CREDENTIALS '{"port": "5432", "host": "localhost"}'
cf set-env $APP_NAME SERVICE_NAME $SERVICE_NAME
cf set-env $APP_NAME SERVICE_PLAN_NAME pg-diy
cf set-env $APP_NAME TAGS postgres-docker,do-it-yourself

cf env $APP_NAME
cf start $APP_NAME
#
